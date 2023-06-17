//
//  Publication.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/17/23.
//  Copyright © 2023 AppyWeb. All rights reserved.
//

import Foundation
import SQLite

public struct Publication: Codable {
    var language: Int
    var symbol: String
    var issueTag: Int?
    var year: Int
    let fileName: String?
    let type: Int?
    let title: String?
    let shortTitle: String?
    let displayTitle: String?
    let referenceTitle: String?
    let undatedReferenceTitle: String?
    let titleRich: String?
    let displayTitleRich: String?
    let referenceTitleRich: String?
    let undatedReferenceTitleRich: String?
    let uniqueEnglishSymbol: String?
    let uniqueSymbol: String?
    let undatedSymbol: String?
    let englishSymbol: String?
    let hash: String?
    let timestamp: String?
    let minPlatformVersion: Int?
    let schemaVersion: Int?
    let issueId: Int
    let issueNumber: Int?
    let variation: String?
    let publicationType: String?
    let rootSymbol: String?
    let rootYear: Int?
    let rootLanguage: Int?
    let image: [ManifestImage]?
    
    static let publicationsTable = Table("Publication")
    static let language = Expression<Int>("MepsLanguageIndex")
    static let symbol = Expression<Int>("Symbol")
    static let year = Expression<Int?>("Year")
    static let issueTag = Expression<Int?>("IssueTagNumber")
    
}
