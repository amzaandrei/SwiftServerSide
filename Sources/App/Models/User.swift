//
//  userModel.swift
//  App
//
//  Created by Andrew on 1/19/19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

struct User: PostgreSQLModel {
    
    var id: Int?
    var firstName: String!
    var lastName: String!
    var state: String!
    var username: String!
    var age: String!
    var email: String!
    var password: String!
//    var passwordLength: Int
    var alert: String!
//    var imageName: String?
//    var imageData: File?
    
    
    init(id: Int? = nil, username: String, age: String, state: String, firstName: String, lastName: String, email: String, password: String) {
        self.id = id
        self.username = username
        self.age = age
        self.lastName = lastName
        self.firstName = firstName
        self.state = state
        self.email = email
        self.password = password
//        self.passwordLength = passwordLength
//        self.imageName = imageName
//        self.imageData = imageData
    }
}

extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.email
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}
extension User: SessionAuthenticatable {}

extension User {
    
    var message: Children<User, Message> {
        return children(\.userId)
    }
    
}

