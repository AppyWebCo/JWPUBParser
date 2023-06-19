//
//  Manifest.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 4/18/23.
//

import Foundation

public struct ManifestImage: Codable {
    let signature: String?
    let fileName: String?
    let type: String?
    let attribute: String?
    let width: Int?
    let height: Int?
}

public struct Manifest: Codable {
    let name: String?
    let hash: String?
    let timestamp: String?
    let version: Int?
    let expandedSize: Int?
    let contentFormat: String?
    let htmlValidated: Bool?
    let mepsPlatformVersion: Double?
    let mepsBuildNumber: Int?
    let publication: ManifestPublication?
}
