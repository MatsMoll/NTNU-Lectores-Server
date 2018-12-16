//
//  Recording.swift
//  App
//
//  Created by Mats Mollestad on 15/12/2018.
//

import Vapor
import FluentMySQL

final class Recording: MySQLModel {
    
    var id: Int?
    
    enum Errors: Error {
        case noChildNodes
        case unableToFindDate
    }
    
    
    let startDate: Date
    let duration: Int
    let lector: String
    let title: String
    let subject: String
    let info: String?
    
    let audioUrl: String
    let cameraUrl: String
    let screenUrl: String
    let combinedMediaUrl: String
    
    
    
    init(startDate: Date, duration: Int, lector: String, title: String, subject: String, info: String?, audioUrl: String, cameraUrl: String, screenUrl: String, combinedMediaUrl: String) {
        self.startDate = startDate
        self.duration = duration
        self.lector = lector
        self.title = title
        self.subject = subject
        self.info = info
        self.audioUrl = audioUrl
        self.cameraUrl = cameraUrl
        self.screenUrl = screenUrl
        self.combinedMediaUrl = combinedMediaUrl
    }
}


extension Recording: MySQLMigration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(Recording.self, on: connection) { (builder) in
            
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.startDate)
            builder.field(for: \.duration)
            builder.field(for: \.lector)
            builder.field(for: \.title)
            builder.field(for: \.subject)
            builder.field(for: \.info)
            builder.field(for: \.audioUrl)
            builder.field(for: \.cameraUrl)
            builder.field(for: \.screenUrl)
            builder.field(for: \.combinedMediaUrl)
            
            builder.unique(on: \.audioUrl)
            builder.unique(on: \.cameraUrl)
            builder.unique(on: \.screenUrl)
            builder.unique(on: \.combinedMediaUrl)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(Recording.self, on: connection)
    }
}

extension Recording: Content { }


extension Recording {
    
    static func create(from node: XMLNode, baseUrl: String) throws -> Recording {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let dateNode = node.child(at: 0),
            var dateString = dateNode.stringValue else {
                throw Errors.unableToFindDate
        }
        dateString.removeLast()
        
        guard let date = formatter.date(from: dateString) else {
            throw Errors.unableToFindDate
        }
        
        guard let durationNode = node.child(at: 1),
            var durationString = durationNode.stringValue else {
                throw Errors.unableToFindDate
        }
        
        while let lastChar = durationString.unicodeScalars.last,
            !CharacterSet.decimalDigits.contains(lastChar) {
                durationString.removeLast()
        }
        
        guard let duration = Int(durationString) else {
            throw Errors.unableToFindDate
        }
        
        guard let lectorNode = node.child(at: 2),
            var lector = lectorNode.stringValue else {
                throw Errors.unableToFindDate
        }
        lector.removeLast()
        
        guard let titleNode = node.child(at: 3),
            var title = titleNode.stringValue else {
                throw Errors.unableToFindDate
        }
        if !title.isEmpty {
            title.removeLast()
        }
        
        guard let subjectNode = node.child(at: 4),
            var subject = subjectNode.stringValue else {
                throw Errors.unableToFindDate
        }
        subject.removeLast()
        
        guard let paths = try node.child(at: 5)?.nodes(forXPath: "./a/@href"),
            paths.count >= 4,
            let audio = paths[0].stringValue,
            let camera = paths[1].stringValue,
            let screen = paths[2].stringValue,
            let combined = paths[3].stringValue else {
                throw Errors.unableToFindDate
        }
        
        var info: String? = nil
        
        if let infoNode = try node.child(at: 6)?.nodes(forXPath: "./img/@title").first {
            info = infoNode.stringValue
        }
        
        return Recording(startDate: date,
                         duration: duration,
                         lector: lector,
                         title: title,
                         subject: subject,
                         info: info,
                         audioUrl: baseUrl + audio,
                         cameraUrl: baseUrl + camera,
                         screenUrl: baseUrl + screen,
                         combinedMediaUrl: baseUrl + combined)
    }
}
