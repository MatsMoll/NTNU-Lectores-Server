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
}


struct RecordingFilter: Content {
    let cursor: Int?
    let amount: Int?
    let lector: String?
    let subject: String?
}
