//
//  Models.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 4/18/23.
//

import Foundation
import SQLite

public protocol JWPUBObject {
    
    static func export(db: Connection, publication: ManifestPublication, progress: Progress) async throws -> Self
    
}

struct Asset {
    let assetId: Int
    let filePath: String
    let type: String
    let versionNumber: Int

    // Initialize model from SQLite row
    init(row: Row) {
        assetId = row[Expression<Int>("AssetId")]
        filePath = row[Expression<String>("FilePath")]
        type = row[Expression<String>("Type")]
        versionNumber = row[Expression<Int>("VersionNumber")]
    }
}


struct BibleBook {
    let bibleBookId: Int
    let bookDocumentId: Int
    let introDocumentId: Int?
    let overviewDocumentId: Int?
    let outlineDocumentId: Int?
    let profile: Data?
    let bookDisplayTitle: String
    let bookDisplayTitleRich: String?
    let chapterDisplayTitle: String
    let chapterDisplayTitleRich: String?
    let publicationId: Int
    let firstVerseId: Int
    let lastVerseId: Int
    let hasCommentary: Bool

    // Initialize model from SQLite row
    init(row: Row) {
        bibleBookId = row[Expression<Int>("BibleBookId")]
        bookDocumentId = row[Expression<Int>("BookDocumentId")]
        introDocumentId = row[Expression<Int?>("IntroDocumentId")]
        overviewDocumentId = row[Expression<Int?>("OverviewDocumentId")]
        outlineDocumentId = row[Expression<Int?>("OutlineDocumentId")]
        profile = row[Expression<Data?>("Profile")]
        bookDisplayTitle = row[Expression<String>("BookDisplayTitle")]
        bookDisplayTitleRich = row[Expression<String?>("BookDisplayTitleRich")]
        chapterDisplayTitle = row[Expression<String>("ChapterDisplayTitle")]
        chapterDisplayTitleRich = row[Expression<String?>("ChapterDisplayTitleRich")]
        publicationId = row[Expression<Int>("PublicationId")]
        firstVerseId = row[Expression<Int>("FirstVerseId")]
        lastVerseId = row[Expression<Int>("LastVerseId")]
        hasCommentary = row[Expression<Bool>("HasCommentary")]
    }
    
    static public let table = Table("BibleBook")
    
    static public func getRows(db: Connection) throws -> [Row] {
        let all = Array(try db.prepare(Self.table))
        return all
    }
}


struct BibleChapter {
    let bibleChapterId: Int
    let bookNumber: Int
    let chapterNumber: Int
    let content: Data?
    let preContent: Data?
    let postContent: Data?
    let firstVerseId: Int
    let lastVerseId: Int
    let firstFootnoteId: Int?
    let lastFootnoteId: Int?
    let firstBibleCitationId: Int?
    let lastBibleCitationId: Int?
    let firstParagraphOrdinal: Int?
    let lastParagraphOrdinal: Int?

    // Initialize model from SQLite row
    init(row: Row) {
        bibleChapterId = row[Expression<Int>("BibleChapterId")]
        bookNumber = row[Expression<Int>("BookNumber")]
        chapterNumber = row[Expression<Int>("ChapterNumber")]
        content = Data(bytes: row[Expression<Blob>("Content")].bytes, count: row[Expression<Blob>("Content")].bytes.count)
        preContent = row[Expression<Data?>("PreContent")]
        postContent = row[Expression<Data?>("PostContent")]
        firstVerseId = row[Expression<Int>("FirstVerseId")]
        lastVerseId = row[Expression<Int>("LastVerseId")]
        firstFootnoteId = row[Expression<Int?>("FirstFootnoteId")]
        lastFootnoteId = row[Expression<Int?>("LastFootnoteId")]
        firstBibleCitationId = row[Expression<Int?>("FirstBibleCitationId")]
        lastBibleCitationId = row[Expression<Int?>("LastBibleCitationId")]
        firstParagraphOrdinal = row[Expression<Int?>("FirstParagraphOrdinal")]
        lastParagraphOrdinal = row[Expression<Int?>("LastParagraphOrdinal")]
    }
    
    static public let table = Table("BibleChapter")
    
    static public func getRows(db: Connection) throws -> [Row] {
        let all = Array(try db.prepare(Self.table))
        return all
    }
}


struct BibleChapterParagraph {
    let bibleChapterParagraphId: Int
    let bibleChapterId: Int
    let paragraphIndex: Int
    let beginPosition: Int
    let endPosition: Int

    // Initialize model from SQLite row
    init(row: Row) {
        bibleChapterParagraphId = row[Expression<Int>("BibleChapterParagraphId")]
        bibleChapterId = row[Expression<Int>("BibleChapterId")]
        paragraphIndex = row[Expression<Int>("ParagraphIndex")]
        beginPosition = row[Expression<Int>("BeginPosition")]
        endPosition = row[Expression<Int>("EndPosition")]
    }
}

struct BibleCitation {
    let bibleCitationId: Int
    let documentId: Int
    let blockNumber: Int
    let elementNumber: Int
    let firstBibleVerseId: Int
    let lastBibleVerseId: Int
    let bibleVerseId: Int
    let paragraphOrdinal: Int
    let marginalClassification: Int
    let sortPosition: Int

    // Initialize model from SQLite row
    init(row: Row) {
        bibleCitationId = row[Expression<Int>("BibleCitationId")]
        documentId = row[Expression<Int>("DocumentId")]
        blockNumber = row[Expression<Int>("BlockNumber")]
        elementNumber = row[Expression<Int>("ElementNumber")]
        firstBibleVerseId = row[Expression<Int>("FirstBibleVerseId")]
        lastBibleVerseId = row[Expression<Int>("LastBibleVerseId")]
        bibleVerseId = row[Expression<Int>("BibleVerseId")]
        paragraphOrdinal = row[Expression<Int>("ParagraphOrdinal")]
        marginalClassification = row[Expression<Int>("MarginalClassification")]
        sortPosition = row[Expression<Int>("SortPosition")]
    }
}

struct BibleMarginalSymbol {
    let bibleMarginalSymbolId: Int
    let symbol: String

    // Initialize model from SQLite row
    init(row: Row) {
        bibleMarginalSymbolId = row[Expression<Int>("BibleMarginalSymbolId")]
        symbol = row[Expression<String>("Symbol")]
    }
}


struct BibleOutlineEntry {
    let bibleOutlineEntryId: Int
    let parentBibleOutlineEntryId: Int?
    let level: Int
    let beginChapterNumber: Int?
    let beginVerseNumber: Int?
    let endChapterNumber: Int?
    let endVerseNumber: Int?
    let content: Data?
    let book: Int
    let classNumber: Int

    // Initialize model from SQLite row
    init(row: Row) {
        bibleOutlineEntryId = row[Expression<Int>("BibleOutlineEntryId")]
        parentBibleOutlineEntryId = row[Expression<Int?>("ParentBibleOutlineEntryId")]
        level = row[Expression<Int>("Level")]
        beginChapterNumber = row[Expression<Int?>("BeginChapterNumber")]
        beginVerseNumber = row[Expression<Int?>("BeginVerseNumber")]
        endChapterNumber = row[Expression<Int?>("EndChapterNumber")]
        endVerseNumber = row[Expression<Int?>("EndVerseNumber")]
        content = row[Expression<Data?>("Content")]
        book = row[Expression<Int>("Book")]
        classNumber = row[Expression<Int>("Class")]
    }
}


struct BiblePublication {
    let biblePublicationId: Int
    let bibleVersion: String

    // Initialize model from SQLite row
    init(row: Row) {
        biblePublicationId = row[Expression<Int>("BiblePublicationId")]
        bibleVersion = row[Expression<String>("BibleVersion")]
    }
}


public struct BibleVerse {
    let bibleVerseId: Int
    let label: String
    let content: Data
    let adjustmentInfo: Data?
    let beginParagraphOrdinal: Int
    let endParagraphOrdinal: Int

    // Initialize model from SQLite row
    init(row: Row) {
        bibleVerseId = row[Expression<Int>("BibleVerseId")]
        label = row[Expression<String>("Label")]
        content = row[Expression<Data>("Content")]
        adjustmentInfo = row[Expression<Data?>("AdjustmentInfo")]
        beginParagraphOrdinal = row[Expression<Int>("BeginParagraphOrdinal")]
        endParagraphOrdinal = row[Expression<Int>("EndParagraphOrdinal")]
    }
    
    static public let table = Table("BibleVerse")
    
    static public func getRows(db: Connection) throws -> [Row] {
        let all = Array(try db.prepare(Self.table))
        return all
    }
}


struct BibleVerseRanking {
    let bibleVerseRankingId: Int
    let keyword: String
    let rankingData: Data

    // Initialize model from SQLite row
    init(row: Row) {
        bibleVerseRankingId = row[Expression<Int>("BibleVerseRankingId")]
        keyword = row[Expression<String>("Keyword")]
        rankingData = row[Expression<Data>("RankingData")]
    }
}

struct DatedText {
    let datedTextId: Int
    let documentId: Int
    let link: String
    let firstDateOffset: Date
    let lastDateOffset: Date
    let firstFootnoteId: Int
    let lastFootnoteId: Int
    let firstBibleCitationId: Int
    let lastBibleCitationId: Int
    let beginParagraphOrdinal: Int
    let endParagraphOrdinal: Int
    let caption: String
    let captionRich: String
    let content: Data

    // Initialize model from SQLite row
    init(row: Row) {
        datedTextId = row[Expression<Int>("DatedTextId")]
        documentId = row[Expression<Int>("DocumentId")]
        link = row[Expression<String>("Link")]
        firstDateOffset = row[Expression<Date>("FirstDateOffset")]
        lastDateOffset = row[Expression<Date>("LastDateOffset")]
        firstFootnoteId = row[Expression<Int>("FirstFootnoteId")]
        lastFootnoteId = row[Expression<Int>("LastFootnoteId")]
        firstBibleCitationId = row[Expression<Int>("FirstBibleCitationId")]
        lastBibleCitationId = row[Expression<Int>("LastBibleCitationId")]
        beginParagraphOrdinal = row[Expression<Int>("BeginParagraphOrdinal")]
        endParagraphOrdinal = row[Expression<Int>("EndParagraphOrdinal")]
        caption = row[Expression<String>("Caption")]
        captionRich = row[Expression<String>("CaptionRich")]
        content = row[Expression<Data>("Content")]
    }
}



struct Document: Codable {
    var documentId: Int
    var publicationId: Int
    var mepsDocumentId: Int?
    var mepsLanguageIndex: Int?
    var classType: Int?
    var type: Int?
    var sectionNumber: Int?
    var chapterNumber: Int?
    var title: String?
    var titleRich: String?
    var tocTitle: String?
    var tocTitleRich: String?
    var contextTitle: String?
    var contextTitleRich: String?
    var featureTitle: String?
    var featureTitleRich: String?
    var subtitle: String?
    var subtitleRich: String?
    var featureSubtitle: String?
    var featureSubtitleRich: String?
    var content: Data?
    var firstFootnoteId: Int?
    var lastFootnoteId: Int?
    var firstBibleCitationId: Int?
    var lastBibleCitationId: Int?
    var paragraphCount: Int?
    var hasMediaLinks: Bool?
    var hasLinks: Bool?
    var firstPageNumber: Int?
    var lastPageNumber: Int?
    var contentLength: Int?
    var preferredPresentation: String?
    var contentReworkedDate: String?
    var hasPronunciationGuide: Bool?

    
    init(row: Row) throws {
         documentId = row[Expression<Int>("DocumentId")]
         publicationId = row[Expression<Int>("PublicationId")]
         mepsDocumentId = row[Expression<Int?>("MepsDocumentId")]
         mepsLanguageIndex = row[Expression<Int?>("MepsLanguageIndex")]
         classType = row[Expression<Int?>("Class")]
         type = row[Expression<Int?>("Type")]
         sectionNumber = row[Expression<Int?>("SectionNumber")]
         chapterNumber = row[Expression<Int?>("ChapterNumber")]
         title = row[Expression<String?>("Title")]
         titleRich = row[Expression<String?>("TitleRich")]
         tocTitle = row[Expression<String?>("TocTitle")]
         tocTitleRich = row[Expression<String?>("TocTitleRich")]
         contextTitle = row[Expression<String?>("ContextTitle")]
         contextTitleRich = row[Expression<String?>("ContextTitleRich")]
         featureTitle = row[Expression<String?>("FeatureTitle")]
         featureTitleRich = row[Expression<String?>("FeatureTitleRich")]
         subtitle = row[Expression<String?>("Subtitle")]
         subtitleRich = row[Expression<String?>("SubtitleRich")]
         featureSubtitle = row[Expression<String?>("FeatureSubtitle")]
         featureSubtitleRich = row[Expression<String?>("FeatureSubtitleRich")]
         content = row[Expression<Data?>("Content")]
         firstFootnoteId = row[Expression<Int?>("FirstFootnoteId")]
         lastFootnoteId = row[Expression<Int?>("LastFootnoteId")]
         firstBibleCitationId = row[Expression<Int?>("FirstBibleCitationId")]
         lastBibleCitationId = row[Expression<Int?>("LastBibleCitationId")]
         paragraphCount = row[Expression<Int?>("ParagraphCount")]
         hasMediaLinks = row[Expression<Bool?>("HasMediaLinks")]
         hasLinks = row[Expression<Bool?>("HasLinks")]
         firstPageNumber = row[Expression<Int?>("FirstPageNumber")]
         lastPageNumber = row[Expression<Int?>("LastPageNumber")]
         contentLength = row[Expression<Int?>("ContentLength")]
         preferredPresentation = row[Expression<String?>("PreferredPresentation")]
         contentReworkedDate = row[Expression<String?>("ContentReworkedDate")]
    }
    
    static public let table = Table("Document")
    static public let classType = Expression<Int>("Class")
    static public func getRows(db: Connection, filter: Expression<Bool>) throws -> [Row] {
        let all = Array(try db.prepare(Self.table.where(filter)))
        return all
    }
}
