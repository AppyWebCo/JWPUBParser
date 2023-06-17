//
//  Extension.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 4/18/23.
//

import Foundation
import Compression

public extension Data {

    /// Compresses the data using the specified compression algorithm.
    func compressed(using algo: compression_algorithm = COMPRESSION_LZMA, pageSize: Int = 128) throws -> Data {
        guard #available(iOS 13.0, *) else {
            return try _legacyCompressed(using: algo, pageSize: pageSize)
        }

        var outputData = Data()
        let filter = try OutputFilter(.compress, using: Algorithm(rawValue: algo)!, bufferCapacity: pageSize, writingTo: { $0.flatMap({ outputData.append($0) }) })

        var index = 0
        let bufferSize = count

        while true {
            let rangeLength = Swift.min(pageSize, bufferSize - index)

            let subdata = self.subdata(in: index ..< index + rangeLength)
            index += rangeLength

            try filter.write(subdata)

            if (rangeLength == 0) { break }
        }

        return outputData
    }
    
    /// Decompresses the data using the specified compression algorithm.
    func decompressed(from algo: compression_algorithm = COMPRESSION_LZMA, pageSize: Int = 128) throws -> Data {
        guard #available(iOS 13.0, *) else {
            return try _legacyDecompressed(from: algo, pageSize: pageSize)
        }

        do {
            var outputData = Data()
            let bufferSize = count
            var decompressionIndex = 0

            let filter = try InputFilter(.decompress, using: Algorithm(rawValue: algo)!) { (length: Int) -> Data? in
                let rangeLength = Swift.min(length, bufferSize - decompressionIndex)
                let subdata = self.subdata(in: decompressionIndex ..< decompressionIndex + rangeLength)
                decompressionIndex += rangeLength

                return subdata
            }

            while let page = try filter.readData(ofLength: pageSize) {
                outputData.append(page)
            }

            return outputData
        } catch {
            // Try legacy decompression if modern decompression fails
            return try _legacyDecompressed()
        }
    }

    private func _legacyCompressed(using algo: compression_algorithm = COMPRESSION_LZMA, pageSize: Int = 128) throws -> Data {
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)

        let compressedSize = compression_encode_buffer(
            destinationBuffer,
            count,
            [UInt8](self),
            count,
            nil,
            algo
        )

        return NSData(bytesNoCopy: destinationBuffer, length: compressedSize) as Data
    }

    private func _legacyDecompressed(from algo: compression_algorithm = COMPRESSION_LZMA, pageSize: Int = 128) throws -> Data {
        let decodedCapacity = 8_000_000
        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: decodedCapacity)

        let result = try withUnsafeBytes {
            (encodedSourceBuffer: UnsafePointer<UInt8>) -> Data in

            let decodedCharCount = compression_decode_buffer(decodedDestinationBuffer,
                                                             decodedCapacity,
                                                             encodedSourceBuffer,
                                                             count,
                                                             nil,
                                                             algo)

            return NSData(bytesNoCopy: decodedDestinationBuffer, length: decodedCharCount) as Data
        }

        return result
    }

}
