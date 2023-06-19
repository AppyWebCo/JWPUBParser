//
//  Crypto.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 4/19/23.
//

import Foundation
import CryptoKit
import Compression
import CommonCrypto

public func SHA256Hash(data: Data) -> String? {
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
}


func sha256(data : Data) -> Data {
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

func decrypt(with data: Data, key: [UInt8], iv: [UInt8]) -> Data? {
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

func aesDecrypt(crypt: [UInt8], key: [UInt8], iv: [UInt8]) -> [UInt8]? {
    guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES192 || key.count == kCCKeySizeAES256 else {
        print("Invalid key size")
        return nil
    }

    let cryptLength = crypt.count
    let keyLength = key.count

    var decrypted = [UInt8](repeating: 0, count: cryptLength + kCCBlockSizeAES128)
    var numBytesDecrypted: Int = 0

    let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)

    let status = CCCrypt(CCOperation(kCCDecrypt),
                          CCAlgorithm(kCCAlgorithmAES),
                          options,
                          key,
                          keyLength,
                          iv,
                          crypt,
                          cryptLength,
                          &decrypted,
                          cryptLength + kCCBlockSizeAES128,
                          &numBytesDecrypted)

    if status == kCCSuccess {
        decrypted.removeSubrange(numBytesDecrypted..<decrypted.count)
       // print(decrypted)
      //  return decrypted
       return pkcs5Trimming(encrypt: decrypted)
    } else {
        print("Decryption failed with error code: \(status)")
        return nil
    }
}

//func pkcs5Trimming(encrypt: [UInt8]) -> [UInt8] {
//    let padding = Int(encrypt[encrypt.count - 1])
//    return Array(encrypt.prefix(encrypt.count - padding))
//}



extension UnsignedInteger where Self: CVarArg {
    var hexa: String { .init(format: "%ll*0x", bitWidth / 4, self) }
}

extension DataProtocol {
    var sha256Digest: SHA256Digest { SHA256.hash(data: self) }
    var sha256Data: Data { .init(sha256Digest) }
    var sha256Hexa: String { sha256Digest.map(\.hexa).joined() }
}

func getId<D: DataProtocol>(data: D) -> String {
    data.sha256Hexa
}

extension Data {
   init?(hexEncodedString: String) {
       let len = hexEncodedString.count / 2
       var data = Data(capacity: len)

       for i in 0..<len {
           let j = hexEncodedString.index(hexEncodedString.startIndex, offsetBy: i*2)
           let k = hexEncodedString.index(j, offsetBy: 2)
           let bytes = hexEncodedString[j..<k]

           if var byte = UInt8(bytes, radix: 16) {
               data.append(&byte, count: 1)
           } else {
               return nil
           }
       }

       self = data
   }
}
