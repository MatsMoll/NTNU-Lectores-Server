//
//  NTNUSource.swift
//  App
//
//  Created by Mats Mollestad on 15/12/2018.
//

import Vapor
import Foundation


class NTNUSource {
    
    static var shared: NTNUSource?
    
    /// The base url of the site
    /// NB: Because of the setup on the site, the last "/" needs to be omited
    private let baseUrl = "https://forelesning.gjovik.ntnu.no"
    
    /// The site to find the content
    private let startPath = "/publish/index.php?page=13"
    
    private var timer: Timer?
    
    private let app: Application
    private let connection: DatabaseConnectable
    
    
    init(app: Application) throws {
        self.app = app
        self.connection = try app.connectionPool(to: .psql).requestConnection().wait()
    }
    
    
    func fetchUpdates() {
        do {
            try loadRecords(baseUrl: baseUrl, path: startPath)
        } catch {
            print("Error: ", error.localizedDescription)
        }
        
        
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        
        let weekday = calendar.component(.weekday, from: now)
        let hour = calendar.component(.hour, from: now)
        let min = calendar.component(.minute, from: now)
        
        var timeInterval: TimeInterval = 0
        
        timeInterval += (15 - Double(min))
        
        if hour < 18 && hour > 8 {
            timeInterval += 60 * 60
        } else {
            timeInterval += (9 + 24 - Double(hour)) * 60 * 60
        }
        
        if weekday == 7 {
            timeInterval += 2 * 24 * 60 * 60
        } else if weekday == 1 {
            timeInterval += 24 * 60 * 60
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.fetchUpdates()
        }
    }
    
    
    private func loadRecords(baseUrl: String, path: String) throws {
        
        let recordsUrl = baseUrl + path
        let httpResponse = try app.client().get(recordsUrl).wait()
        
        if let data = httpResponse.http.body.data,
            let document = try? XMLDocument(data: data, options: .documentTidyHTML),
            let recordingNodes = try? document.nodes(forXPath: "//tr[@class='lecture']") {
            
            for node in recordingNodes {
                if let recording = try? Recording.create(from: node, baseUrl: baseUrl + "/") {
                    
                    // Will throw if adding a recording if it allreay exists (because of unique constraint)
                    // May also do for some other instinces
                    _ = try recording.save(on: connection).wait()
                }
            }
            
            if let nextPageNode = try? document.nodes(forXPath: "//div[@class='paginator']//a[. = 'Neste']/@href"),
                let nextPagePath = nextPageNode.first?.stringValue {
                try loadRecords(baseUrl: baseUrl, path: nextPagePath)
            }
        }
    }
    
    static func allRecordings(from data: Data) throws -> (nextPath: String?, recoridngs: [Recording]) {
        
        let document = try XMLDocument(data: data, options: .documentTidyHTML)
        let recordingNodes = try document.nodes(forXPath: "//tr[@class='lecture']")
        
        var recordings = [Recording]()
        
        for node in recordingNodes {
            if let recording = try? Recording.create(from: node, baseUrl: "/") {
                recordings.append(recording)
            }
        }
        
        if let nextPageNode = try? document.nodes(forXPath: "//div[@class='paginator']//a[. = 'Neste']/@href"),
            let nextPagePath = nextPageNode.first?.stringValue {
            return (nextPagePath, recordings)
        } else {
            return (nil, recordings)
        }
    }
}
