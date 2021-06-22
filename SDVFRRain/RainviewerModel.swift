//
//  RainviewerModel.swift
//  SDVFRRain
//
//  Created by Julien Roze on 22/06/2021.
//

import UIKit

// Model for rainviewer json : https://api.rainviewer.com/public/weather-maps.json

struct RainviewerData: Codable {
    var version: String
    var generated: Int
    var host: String
    var radar: RainviewerRadar

}

struct RainviewerRadar: Codable {
    var past: [RainviewerTime]
}

struct RainviewerTime: Codable {
    var time: Int
    var path: String
}
