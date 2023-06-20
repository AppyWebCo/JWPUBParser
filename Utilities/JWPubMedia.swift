//
//  JWPubMedia.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/19/23.
//  Copyright © 2023 AppyWeb. All rights reserved.
//

import Foundation

actor JWPubMedia {
    
    static var shared = JWPubMedia()
    
    func fetch() async throws {
        let uri: String = "https://b.jw-cdn.org/apis/pub-media/GETPUBMEDIALINKS?booknum=0&output=json&pub=bi12&fileformat=JWPUB&alllangs=0&langwritten=E"
        
        guard let url = URL(string: uri) else {
               return
        }
    
        let (data, _) = try await URLSession.shared.data(from: url)
        
         let decodedResponse = try JSONDecoder().decode(PubMediaItem.self, from: data)
        print(decodedResponse)
        
    }
    
    

    
}



// MARK: - PubMediaItem
struct PubMediaItem: Codable {
    let pubName, parentPubName: String?
    let booknum: Int?
    let pub, issue, formattedDate: String?
    let fileformat: [String]?
    let specialty: String?
    let pubImage: PubImage?
    let languages: [String : Language]
   let files: [String : [String: [JWPubFile]]]
}

// MARK: - Epub
struct JWPubFile: Codable {
    let title: String?
    let file: PubImage?
    let filesize: Int?
    let trackImage: PubImage?
    let label: String?
    let track: Int?
    let hasTrack: Bool?
    let pub: String?
    let docid, booknum: Int?
    let mimetype, edition, editionDescr, format: String?
    let formatDescr, specialty, specialtyDescr: String?
    let subtitled: Bool?
    let frameWidth, frameHeight, frameRate, duration: Int?
    let bitRate: Int?
}

// MARK: - PubImage
struct PubImage: Codable {
    let url: String?
    let stream: String?
    let modifiedDatetime: String?
    let checksum: String?
}


// MARK: - LanguagesE
struct Language: Codable {
    let name, direction, locale: String?
}
