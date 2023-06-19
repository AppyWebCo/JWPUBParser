//
//  Extension+Publication.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/17/23.
//

import Foundation
import SQLite

extension ManifestPublication {
    
    public enum ManifestPublicationType: String, CaseIterable {
        
        case bible = "bi"
        case mwb = "mwb"
        
        static public var allCases: [ManifestPublication.ManifestPublicationType] {
            return [.bible, .mwb]
        }
        
        
        
    }
    
    func extract(content: Data) -> Data? {
        
        var contentKey: String
        if issueId == 0 {
            contentKey = "\(language)_\(symbol)_\(year)"
        } else {
            contentKey = "\(language)_\(symbol)_\(year)_\(issueId)"
        }
        
        guard let deob = JWPDeobfuscator(key: contentKey) else {
            fatalError("could not run deobfuscator :(")
        }
        
        if let data = deob.apply(content) {
            return data
        }
        return nil
    }
    
    public func getContentKey() -> String {
        let NonExistentIssueID: Int = 0
        if issueTag != NonExistentIssueID {
            return "\(self.language)_\(self.symbol)_\(self.year)_\(self.issueId)"
        } else {
            return "\(self.language)_\(self.symbol)_\(self.year)"
        }
    }
    
    public func getPublicationType() throws -> ManifestPublicationType? {
        
        if let categories {
            guard let category = ManifestPublicationType.allCases.first(where: { categories.contains($0.rawValue) }) else {
                throw ParsingError.notFound
            }
            return category
        }
        return nil
    }
    

}
