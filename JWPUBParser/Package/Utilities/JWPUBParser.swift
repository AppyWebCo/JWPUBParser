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
        
        guard let deob = JWPDeobfuscator(key: contentKey) else {
            throw ParsingError.couldNotDecryptData
        }
        
        if let data = deob.apply(encryptedData) {
            let string = String(decoding: data, as: UTF8.self)
            return string
        } else {
            throw ParsingError.couldNotDecryptData
        }
    }
    
}

