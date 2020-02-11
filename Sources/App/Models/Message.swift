//
//  Message.swift
//  App
//
//  Created by Andrew on 1/23/19.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Message: PostgreSQLModel {
    
    var id: Int?
    var date: Double!
    var messageText: String!
    var userId: User.ID!
    
    init(id: Int? = nil,date: Double, messageText: String, userId: User.ID){
        self.id = id
        self.date = date
        self.messageText = messageText
        self.userId = userId
    }
    
    struct MessageForm: Content {
        var date: Double
        var messageText: String
        var userId: Int
    }
    
}


extension Message: Content {}
extension Message: Migration {}

extension Message {
    
    var user: Parent<Message, User> {
        return parent(\.userId)
    }
    
}
