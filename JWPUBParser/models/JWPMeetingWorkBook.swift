//
//  JWPMeetingWorkBook.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/18/23.
//  Copyright © 2023 AppyWeb. All rights reserved.
//

import Foundation
import SQLite
import SwiftSoup

struct JWPMeetingWorkBook: Codable, JWPUBObject {
    static func export(db: SQLite.Connection, publication: ManifestPublication, progress: Progress) async throws -> JWPMeetingWorkBook {
        let jwpubParser = JWPUBParser.shared
        let htmlParser = HTMLParser.shared
        
        // GET workbook weeks
        var weeks: [JWPMeetingWorkBookWeek] = [JWPMeetingWorkBookWeek]()
        let mwbProgramClassType: Int = 106
        for row in try Document.getRows(db: db, filter: Document.classType == mwbProgramClassType) {
            let document = try Document(row: row)
            let html = try await jwpubParser.decrypt(document.content, publication: publication)
            let content = try htmlParser.parseInnerText(from: html)
            let week: JWPMeetingWorkBookWeek = JWPMeetingWorkBookWeek(docId: document.documentId, title: document.title ?? "", subtitle: document.subtitle ?? "", html: html, content: content)
            weeks.append(week)
            DispatchQueue.main.async {
                progress.completedUnitCount += 1
            }
        }
        
        let workbook = JWPMeetingWorkBook(title: publication.displayTitle ?? "", year: publication.year, issueId: publication.issueId, symbol: publication.symbol, weeks: weeks)
        
        return workbook
    }
    
    

    
    let title: String
    let year: Int
    let issueId: Int
    let symbol: String
    let weeks: [JWPMeetingWorkBookWeek]
}

struct JWPMeetingWorkBookWeek: Codable {
    
    let docId: Int
    let title: String
    let subtitle: String
    let html: String
    let content: String
    
}

