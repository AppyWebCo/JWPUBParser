//
//  JWPUBParser.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/18/23.
//  Copyright © 2023 AppyWeb. All rights reserved.
//

import Foundation
import SQLite
import SwiftUI
import DataCompression
import Zlib
import Compression


enum ParsingError: Error {
    // Throw when an invalid password is entered
    case couldNotDecryptData

    // Throw when an expected resource is not found
    case notFound
    case couldNotParseHtml

    // Throw in all other cases
    case unexpected(code: Int)
}

extension ParsingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .couldNotDecryptData:
            return "The data could not be decrypted"
        case .notFound:
            return "Could not parse the HTML Content."
        case .couldNotParseHtml:
            return "Could not parse the HTML Content."
        case .unexpected(_):
            return "An unexpected error occurred."
        }
    }
}

public actor JWPUBParser {
    
    let fileManager = FileManager()
    let htmlParser = HTMLParser.shared
    let decoder = JSONDecoder()
    let folderName = UUID().uuidString
    
    static let shared = JWPUBParser()


    public func read(at url: URL, progress: Progress) async throws -> JWPUBObject? {
    
        let (dbPath, publication) = try unzip(at: url, progress: progress)
        
        if let dbPath, let publication {
            let db = try Connection(dbPath.path())
            let type = try publication.getPublicationType()
            switch type {
            case .bible: return try await JWPBible.export(db: db, publication: publication, progress: progress)
            case .mwb: return try await JWPMeetingWorkBook.export(db: db, publication: publication, progress: progress)
            case .none:
                throw ParsingError.notFound
            }
        }
        return nil
    }
    
    // This returns the path of the Database
    public func unzip(at path: URL, progress: Progress) throws -> (URL?, ManifestPublication?) {
        // Get current working directory path
        let currentWorkingPath = fileManager.currentDirectoryPath
        let childProgress1 = Progress(totalUnitCount: 0)
        let childProgress2 = Progress(totalUnitCount: 0)
        progress.addChild(childProgress1, withPendingUnitCount: 5)
        progress.addChild(childProgress2, withPendingUnitCount: 5)
        // Creates a temporary folder name
        let folderName = UUID().uuidString
        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
        destinationURL.append(path: folderName, directoryHint: .isDirectory)
    
        guard let manifest = try unzipJWPUB(from: path, at: destinationURL, progress: childProgress1) else {
            throw ParsingError.notFound
        }

        guard let dbPath = try unzipContents(at: destinationURL, manifest: manifest, progress: childProgress2) else {
            throw ParsingError.notFound
        }
        return (dbPath, manifest.publication)
    }
    
    func unzipContents(at destinationPath: URL, manifest: Manifest, progress: Progress) throws -> URL? {
        
        let urls = try fileManager.contentsOfDirectory(atPath: destinationPath.relativePath)
        
        guard let contentString = urls.first(where: { $0.contains("contents") }) else { return nil }
        
        guard let contentsURL = URL(string: contentString) else { return nil }
        
        let contentFullPath = destinationPath.appending(path: contentsURL.lastPathComponent)
        
        let assetsPath = destinationPath.appending(path: "assets")
        try fileManager.unzipItem(at: contentFullPath, to: assetsPath, progress: progress)
        if let publication = manifest.publication, let fileName = publication.fileName {
            let dbPath = assetsPath.appending(component: fileName)
            return dbPath
        }
       return nil
    }
    
    func unzipJWPUB(from path: URL, at destinationPath: URL, progress: Progress) throws -> Manifest? {

      //  let dbService = DBService.shared
     
        try fileManager.createDirectory(at: destinationPath, withIntermediateDirectories: true, attributes: nil)
            
        try fileManager.unzipItem(at: path, to: destinationPath, progress: progress)
            
        if let manifest = try readManifest(from: destinationPath) {
            return manifest
        }
        return nil
    }
    
    
    func readManifest(from destinationPath: URL) throws -> Manifest? {
            let urls = try fileManager.contentsOfDirectory(atPath: destinationPath.relativePath)
            
            guard let manifestPath = urls.first(where: { $0.contains("manifest") }) else { return nil }
            
            guard let manifestURL = URL(string: manifestPath) else { return nil }
            
            let fullManifestPath = destinationPath.appending(path: manifestURL.lastPathComponent)
                
            let jsonData = try Data(contentsOf: fullManifestPath)
            
            let myData = try decoder.decode(Manifest.self, from: jsonData)
            
            return myData
    }
    
    public func decrypt(_ encryptedData: Data?, publication: ManifestPublication) throws -> String {
        var contentKey: String
        if publication.issueId == 0 {
            contentKey = "\(publication.language)_\(publication.symbol)_\(publication.year)"
        } else {
            contentKey = "\(publication.language)_\(publication.symbol)_\(publication.year)_\(publication.issueId)"
        }
        
        let deob = JWPDeobfuscatorSwift(contentKey: contentKey)
    
        if let encryptedData, let data = deob.apply(protectedData: encryptedData) {
            
            let string = String(decoding: data, as: UTF8.self)
            print(string)
           
            return string
        } else {
            print("Could not decrypt data")
            throw ParsingError.couldNotDecryptData
        }
    }
    
}



import Foundation
import CommonCrypto
import zlib
import CryptoKit



class JWPDeobfuscatorSwift {
    private var key = [UInt8](repeating: 0, count: kCCKeySizeAES128)
    private var iv = [UInt8](repeating: 0, count: kCCKeySizeAES128)
    
    init(contentKey: String) {
   
        let dummy: [UInt8] = {
            let hexString = "11CBB5587E32846D4C26790C633DA289F66FE5842A3A585CE1BC3A294AF5ADA7"
            let data = Data(hexEncodedString: hexString)
            return [UInt8](data ?? Data())
        }()
            
        let contentKeyData = Data(contentKey.utf8)
        
        // Generate the base SHA256 hash
        var temp = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let tempLength = Int(CC_SHA256_DIGEST_LENGTH)
        let keyUTF8 = contentKey.utf8CString
        CC_SHA256(keyUTF8.map { $0 }, CC_LONG(strlen(keyUTF8.map { $0 })), &temp)
        
        // Prepare key and iv
        for i in 0..<tempLength / 2 {
            self.key[i] = UInt8(dummy[i]) ^ temp[i]
            self.iv[i] = UInt8(dummy[i + tempLength / 2]) ^ temp[i + tempLength / 2]
        }
    }
    
    func apply(protectedData: Data) -> Data? {

        if let decryptedData = decrypt(with: protectedData) {
            return decryptedData.decompressed
        }
        return nil
    }

    func decrypt(with data: Data) -> Data? {
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        
        var numOfBytesDecrypted: size_t = 0
        let status = data.withUnsafeBytes { dataBytes in
            return CCCrypt(CCOperation(kCCDecrypt),
                           CCAlgorithm(kCCAlgorithmAES128),
                           CCOptions(kCCOptionPKCS7Padding),
                           key, kCCKeySizeAES128,
                           iv,
                           dataBytes.baseAddress,
                           data.count,
                           &buffer,
                           bufferSize,
                           &numOfBytesDecrypted)
        }
    
        if status == kCCSuccess {
            return Data(bytes: buffer, count: numOfBytesDecrypted)
        }
        
        return nil
    }

}
