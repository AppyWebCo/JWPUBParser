//
//  JWTest.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/15/23.
//

import CryptoKit
import CommonCrypto
import Foundation
import zlib

struct TPublication {
    let id: Int
    let version: Int
    let title: String
    let symbol: String
    let issueTag: Int
    let year: Int
    let languageIndex: Int
    let language: String
    let firstDatedTextDateOffset: Date
    let lastDatedTextDateOffset: Date
}

let contentsFileName = "contents"

typealias DocumentIndex = [Int: Document]

let secret: [UInt8] = {
    let hexString = "11CBB5587E32846D4C26790C633DA289F66FE5842A3A585CE1BC3A294AF5ADA7"
    guard let data = Data(hexEncodedString: hexString) else { return [] }
    return [UInt8](data)
}()

extension ManifestPublication {
    func decryptContent(encryptedContent: [UInt8]) -> String {
        var contentKey: String
        if issueTag == 0 {
            contentKey = "\(language)_\(symbol)_\(year)"
        } else {
            contentKey = "\(language)_\(symbol)_\(year)_\(issueTag)"
        }
        let contentKeyData = Data(contentKey.utf8)
        let keyHash = SHA256.hash(data: contentKeyData)
        let halfHashLen = keyHash.description.count / 2

        var key = [UInt8](repeating: 0, count: secret.count / 2)
        var iv = [UInt8](repeating: 0, count: secret.count / 2)
//        for i in 0..<halfHashLen {
//            key[i] = secret[i] ^ keyHash[i]
//            iv[i] = secret[halfHashLen + i] ^ keyHash[halfHashLen + i]
//        }
        for i in 0..<halfHashLen {
           // print(halfHashLen + i)
            key[i] = secret[i] ^ UInt8(keyHash.hashValue.description.utf8CString[i])
            iv[i] = secret[halfHashLen + i] ^ UInt8(keyHash.hashValue.description.utf8CString[halfHashLen + i])
        }

      //  let decrypted = aesDecrypt(crypt: encryptedContent, key: key, iv: iv)
//        guard let decompressed = try? zlib.decompress(data: decrypted) else {
//            fatalError("Error decompressing plaintext")
//        }

        //return String(data: decompressed, encoding: .utf8)!
        return ""
    }
}

func aesDecrypt(crypt: [UInt8], key: [UInt8], iv: [UInt8]) -> [UInt8] {
    let cryptData = Data(crypt)
    let keyData = Data(key)
    let ivData = Data(iv)

    let cryptPointer = cryptData.withUnsafeBytes { buffer in
        buffer.bindMemory(to: UInt8.self)
    }
    
    let keyPointer = keyData.withUnsafeBytes { buffer in
        buffer.bindMemory(to: UInt8.self)
    }
    
    let ivPointer = ivData.withUnsafeBytes { buffer in
        buffer.bindMemory(to: UInt8.self)
    }
        
    let bufferSize = crypt.count
    var decrypted = [UInt8](repeating: 0, count: bufferSize)

    var numBytesDecrypted: Int = 0
    let cryptStatus = CCCrypt(CCOperation(kCCDecrypt),
                              CCAlgorithm(kCCAlgorithmAES),
                              CCOptions(kCCOptionPKCS7Padding),
                              keyPointer.baseAddress, key.count,
                              ivPointer.baseAddress,
                              cryptPointer.baseAddress, crypt.count,
                              &decrypted,
                              bufferSize,
                              &numBytesDecrypted)

    guard cryptStatus == Int32(kCCSuccess) else {
        fatalError("Error decrypting content")
    }

    return pkcs5Trimming(encrypt: decrypted)
}

func pkcs5Trimming(encrypt: [UInt8]) -> [UInt8] {
    let padding = encrypt[Int(encrypt.count) - 1]
    return Array(encrypt[0..<(encrypt.count - Int(padding))])
}
