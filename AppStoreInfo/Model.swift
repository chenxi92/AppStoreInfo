//
//  Model.swift
//  AppStoreInfo
//
//  Created by peak on 2021/12/22.
//

import Foundation

struct AppMetadataResults: Decodable {
    let results: [AppMetadata]
}

struct AppMetadata: Decodable {
    let screenshotUrls: [URL]
    let ipadScreenshotUrls: [URL]
    let trackName: String
    let contentAdvisoryRating: String
    let trackViewUrl: URL
    let version: String
    let description: String
    let averageUserRating: Double
    let sellerName: String
    let releaseNotes: String
    let artworkUrl100: URL
    let fileSizeBytes: String
}

extension AppMetadata {
    var averageRate: String {
        let formater = NumberFormatter()
        formater.numberStyle = .decimal
        formater.minimumFractionDigits = 1
        formater.maximumFractionDigits = 2
        return formater.string(from: NSNumber(value: averageUserRating)) ?? ""
    }
    
    var size: String {
        guard let number =  Double(fileSizeBytes) else {
            return ""
        }
        let mb = number / 1000.0 / 1000.0
        return String(format: "%.1f", mb)
    }
}
