//
//  DBService.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 4/18/23.
//

import Foundation
import SQLite
import Compression
import CryptoKit

class DBService {
    
    public static let shared = DBService()
    
    func read(url: URL, manifest: Publication, fileName: String) {
        
        do {
    
            let db = try Connection(url.path())
            
            //let verses = Table("BibleVerse")
            let documents = Table("Document")
            //let publications = Table(Publication.tableName)
            
          //  let bibleVerseId = Expression<Int>("BibleVerseId")
          //  let label = Expression<String>("Label")
            let content = Expression<Data>("Content")
            let title = Expression<String>("Title")

                       
            for row in try db.prepare(documents) {
                guard let data = manifest.extract(content: row[content]) else {
                    fatalError("not extracted")
                }
                let string = String(decoding: data, as: UTF8.self)
                print("string: \(string)")
                
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}



//
//  PublicationKey.swift
//  MEPSCommon
//
//  Created on 11/10/21.
//  Copyright © 2021 Watch Tower Bible and Tract Society of Pennsylvania, Inc. All rights reserved.
//

/// Uniquely identifies a publication item.
/// - Tag: PublicationKey
@objc(MCLPublicationKey)
public class PublicationKey: NSObject, NSCoding {
    
    /// The constant value representing the lack of an issue id.
    @objc public static let NonExistentIssueID: Int = 0
    
    /// The language of the publication.
    @objc public let mepsLanguage: Int
    
    /// The key symbol of the publication.
    @objc public let keySymbol: String
    
    /// The issue tag number if this is a periodical.
    @objc public let issueTagNumber: Int
    
    /// Creates a new publication key.
    /// - Parameters:
    ///    - mepsLanguage: The language of the publication.
    ///    - keySymbol: The symbol of the publication.
    @objc public init(mepsLanguage: Int, keySymbol: String) {
        self.mepsLanguage = mepsLanguage
        self.keySymbol = keySymbol
        self.issueTagNumber = PublicationKey.NonExistentIssueID
    }
    
    /// Creates a new publication key.
    /// - Parameters:
    ///    - mepsLanguage: The language of the publication.
    ///    - keySymbol: The symbol of the publication.
    ///    - issueTagNumber: The issue tag number if this is a periodical.
    @objc public init(mepsLanguage: Int, keySymbol: String, issueTagNumber: Int) {
        self.mepsLanguage = mepsLanguage
        self.keySymbol = keySymbol
        self.issueTagNumber = issueTagNumber
    }
    
    @objc public required init?(coder: NSCoder) {
        guard let symbol = coder.decodeObject(forKey: "pubSymbol") as? String else {
            return nil
        }
        
        self.mepsLanguage = coder.decodeInteger(forKey: "pubLanguage")
        self.keySymbol = symbol
        self.issueTagNumber = coder.decodeInteger(forKey: "pubIssueTagNumber")
    }
        
    @objc public override var hash: Int {
        return self.keySymbol.hash ^ (self.mepsLanguage << 16) ^ self.issueTagNumber
    }
    
    @objc public override var description: String {
        if self.issueTagNumber != PublicationKey.NonExistentIssueID {
            return "\(self.mepsLanguage)_\(self.keySymbol)_\(self.issueTagNumber)"
        } else {
            return "\(self.mepsLanguage)_\(self.keySymbol)"
        }
    }
    
    @objc override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PublicationKey else { return false }
        return other.mepsLanguage == self.mepsLanguage
            && other.keySymbol == self.keySymbol
            && other.issueTagNumber == self.issueTagNumber
    }
    
    @objc public func encode(with coder: NSCoder) {
        coder.encode(self.mepsLanguage, forKey: "pubLanguage")
        coder.encode(self.keySymbol, forKey: "pubSymbol")
        coder.encode(self.issueTagNumber, forKey: "pubIssueTagNumber")
    }
    
    /// Parses a publication key from the string value.
    /// - Parameter text: The string value.
    /// - Returns The created publication key, or nil if the parsing fails.
    @objc public static func publicationKey(from text: String) -> PublicationKey? {
        
        let elems = text.components(separatedBy: "_")
        if elems.count < 2 {
            return nil
        }
        
        let symbol = elems[1]
        if elems.count == 2,
           let language = Int(elems[0]) {
            return PublicationKey(mepsLanguage: language, keySymbol: symbol)
        }
        
        if elems.count == 3,
           let language = Int(elems[0]),
           let issueTag = Int(elems[2]) {
            return PublicationKey(mepsLanguage: language, keySymbol: symbol, issueTagNumber: issueTag)
        }
        
        return nil
    }
}

