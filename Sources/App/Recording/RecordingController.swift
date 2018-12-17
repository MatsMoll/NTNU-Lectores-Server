//
//  RecordingController.swift
//  App
//
//  Created by Mats Mollestad on 15/12/2018.
//

import Vapor
import FluentPostgreSQL

class RecordingController {
    
    func getAll(_ req: Request) -> Future<[Recording]> {
        
        if let filters = try? req.query.decode(RecordingFilter.self) {
            
            var query = Recording.query(on: req)
            if let lector = filters.lector {
                query = query.filter(\.lector, .like ,"%\(lector)%")
            }
            
            if let subject = filters.subject {
                query = query.filter(\.subject, .like ,"%\(subject)%")
            }
            
            if let cursor = filters.cursor {
                let amount = filters.amount ?? 100
                query = query.range(cursor..<(cursor + amount))
            } else if let amount = filters.amount {
                let cursor = 0
                query = query.range(cursor..<(cursor + amount))
            }
            
            return query.all()
        } else {
            return Recording.query(on: req).all()
        }
    }
    
    func evaluateData(_ req: Request) throws -> Future<[Recording]> {
        return try req.content.decode(HTMLData.self).map { (html) in
            let data = html.data.data(using: .utf8)
            return try NTNUSource.allRecordings(from: data!).recoridngs
        }
    }
    
    func startGjovikFetch(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(NTNUGjovikFetchRequest.self).map { [unowned req] (fetch) in
            NTNUSource.shared.fetchUpdates(with: req, startPage: fetch.startPage)
            return .ok
        }
    }
}


struct RecordingFilter: Content {
    let cursor: Int?
    let amount: Int?
    let lector: String?
    let subject: String?
}

struct HTMLData: Content {
    let data: String
}

struct NTNUGjovikFetchRequest: Content {
    let startPage: Int
}
