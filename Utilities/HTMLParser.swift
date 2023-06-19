//
//  HTMLParser.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 6/18/23.
//  Copyright © 2023 AppyWeb. All rights reserved.
//

import Foundation
import SwiftSoup

public class HTMLParser {
    
    static public var shared = HTMLParser()
    
    func parseInnerText(from html: String) throws -> String {
        let doc: SwiftSoup.Document = try SwiftSoup.parse(html)
        return try doc.text(trimAndNormaliseWhitespace: true)
    }
    
}
