//
//  Extension+Publication.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/17/23.
//

import Foundation
import SQLite

extension Publication {
    
    func extract(content: Data) -> Data? {
        
        var contentKey: String
        if issueId == 0 {
            contentKey = "\(language)_\(symbol)_\(year)"
        } else {
            contentKey = "\(language)_\(symbol)_\(year)_\(issueId)"
        }
        
        guard let deob = MCLDeobfuscator(key: contentKey) else {
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
    
//    public func getDBInfo(from connection: Connection) {
//        do {
//            if let _publication = try connection.pluck(self.publicationsTable) {
//                
//            }
//        } catch {
//            
//        }
//    }

}
