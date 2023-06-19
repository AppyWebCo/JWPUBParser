//
//  JWPBible.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/18/23.
//  Copyright © 2023 AppyWeb. All rights reserved.
//

import Foundation
import SQLite
import SwiftSoup

struct JWPBible: Codable, JWPUBObject {
   
    static func export(db: Connection, publication: ManifestPublication, progress: Progress) async throws -> JWPBible {
        let jwpubParser = JWPUBParser.shared
       
        let htmlParser = HTMLParser.shared
        // Get verses from BibleVerse Table
        var verses: [JWPBibleVerse] = [JWPBibleVerse]()
      //  let total: Int = 50
        let allVerses = Array(try BibleVerse.getRows(db: db))
        //print(allVerses.count)
        let versesProgress: Progress = Progress(totalUnitCount: 0)
        let chaptersProgress: Progress = Progress(totalUnitCount: 0)
        let booksProgress: Progress = Progress(totalUnitCount: 0)
        
        if !allVerses.isEmpty {
            versesProgress.totalUnitCount = Int64(allVerses.count)
            progress.addChild(versesProgress, withPendingUnitCount: 30)
        }
       
        for row in allVerses {
            let bibleVerse = BibleVerse(row: row)
            let verseNumber = try htmlParser.parseInnerText(from: bibleVerse.label)
            let html =  try await jwpubParser.decrypt(bibleVerse.content, publication: publication)
            let content = try htmlParser.parseInnerText(from: html)
            let verse: JWPBibleVerse = JWPBibleVerse(bibleVerseId: bibleVerse.bibleVerseId, verseNumber: verseNumber, label: bibleVerse.label, content: content, html: html)
            verses.append(verse)
           // DispatchQueue.main.async {
                versesProgress.completedUnitCount += 1
          //  }
           
           // print(childProgress.fractionCompleted)
        }
       
        // Get chapter from BibleChapter Table
        var chapters: [JWPBibleChapter] = [JWPBibleChapter]()
        let allChapters = Array(try BibleChapter.getRows(db: db))
        if !allChapters.isEmpty {
            chaptersProgress.totalUnitCount = Int64(allChapters.count)
            progress.addChild(chaptersProgress, withPendingUnitCount: 30)
        }
        for row in allChapters {
            
            let bibleChapter = BibleChapter(row: row)
            let html = try await jwpubParser.decrypt(bibleChapter.content, publication: publication)
            let content = try htmlParser.parseInnerText(from: html)
            let chapterVerses = verses.filter { verse in
                return verse.bibleVerseId >= bibleChapter.firstVerseId && verse.bibleVerseId <= bibleChapter.lastVerseId
            }
            let chapter = JWPBibleChapter(bibleChapterId: bibleChapter.bibleChapterId, bookNumber: bibleChapter.bookNumber, chapterNumber: bibleChapter.chapterNumber, content: content, html: html, firstVerseId: bibleChapter.firstVerseId, lastVerseId: bibleChapter.lastVerseId, verses: chapterVerses)
            
            chapters.append(chapter)
            chaptersProgress.completedUnitCount += 1
        }
        
        // Get book from BibleBook Table
        var books: [JWPBibleBook] = [JWPBibleBook]()
        let allBooks = Array(try BibleBook.getRows(db: db))
        if !allBooks.isEmpty {
            booksProgress.totalUnitCount = Int64(allBooks.count)
            progress.addChild(booksProgress, withPendingUnitCount: 30)
        }
        for row in allBooks {
            
            let bibleBook = BibleBook(row: row)
            let html = try await jwpubParser.decrypt(bibleBook.profile, publication: publication)
            let content = try htmlParser.parseInnerText(from: html)
            let bookChapters = chapters.filter { $0.bookNumber == bibleBook.bibleBookId }
            let book = JWPBibleBook(bibleBookId: bibleBook.bibleBookId, profileContent: content, profileHtml: html, bookDisplayTitle: bibleBook.bookDisplayTitle, chapterDisplayTitle: bibleBook.chapterDisplayTitle, publicationId: bibleBook.publicationId, firstVerseId: bibleBook.firstVerseId, lastVerseId: bibleBook.lastVerseId, chapters: bookChapters)
            
            books.append(book)
            booksProgress.completedUnitCount += 1
           // DispatchQueue.main.async {
                //  progress.completedUnitCount += 1
           // }
        }
    
        let bible = JWPBible(title: publication.title ?? "", year: publication.year, symbol: publication.symbol, books: books)
    
        return bible
    }
    
    
    let title: String
    let year: Int
    let symbol: String
    var books: [JWPBibleBook]
}


struct JWPBibleBook: Codable {
    let bibleBookId: Int
    let profileContent: String
    let profileHtml: String
    let bookDisplayTitle: String
    let chapterDisplayTitle: String
    let publicationId: Int
    let firstVerseId: Int
    let lastVerseId: Int
    let chapters: [JWPBibleChapter]

}

struct JWPBibleChapter: Codable {
    let bibleChapterId: Int
    let bookNumber: Int
    let chapterNumber: Int
    let content: String
    let html: String
    let firstVerseId: Int
    let lastVerseId: Int
    let verses: [JWPBibleVerse]

}

struct JWPBibleVerse: Codable {
    let bibleVerseId: Int
    let verseNumber: String
    let label: String
    let content: String
    let html: String
}
