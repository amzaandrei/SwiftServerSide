//
//  MessageController.swift
//  App
//
//  Created by Andrew on 1/23/19.
//

import Foundation
import Vapor 


final class MessageController {
    
    func create(_ req: Request) throws -> Future<Response> {
        let userCurrent = try req.requireAuthenticated(User.self)
        let userId = userCurrent.id
        let date: Double = Date().timeIntervalSince1970
        let messageText: String = try req.content.syncGet(at: "messageText")
        
        let message = Message(
            date: date,
            messageText: messageText,
            userId: userId!
        )
        
        return message.save(on: req).map({ _ in
            return req.redirect(to: "/")
        })
    }
    
    
}
