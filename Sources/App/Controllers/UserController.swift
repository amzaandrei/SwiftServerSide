//
//  UserController.swift
//  App
//
//  Created by Andrew on 1/19/19.
//

import Foundation
import Vapor
import Storage
import FluentSQL  
import Crypto

final class UserController {
    
    struct UserView: Encodable {
        var user: User?
        var messages: Future<[Message]>?
    }
    
    struct AllUserView: Encodable {
        var user: User
        var users: Future<[User]>
    }
     
    func allUsersPage(_ req: Request) throws -> Future<View> {
        let users = User.query(on: req).all()
        let user = try req.requireAuthenticated(User.self)
        let userViewList = AllUserView(user: user, users: users)
        return try req.view().render("usersPage", ["userViewList": userViewList])
    }
    
    func getUserPage(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap { user in
            let userViewList = UserView(user: user, messages: try user.message.query(on: req).sort(\Message.date, .ascending).all())
            return try req.view().render("userPage", ["userViewList": userViewList])
        }
    }
    
    func getSignUpPage(_ req: Request) throws -> Future<View> {
        return try req.view().render("signUpPage")
    }
    
    func getLogInPage(_ req: Request) throws -> Future<View> {
        return try req.view().render("logIn")
    }
    
    func getProfilePage(_ req: Request) throws -> Future<View> {
        var user = try req.requireAuthenticated(User.self)
//        let userViewList = UserView(user: user, messages: nil)
        return try req.view().render("profile", ["user": user])
    }
    
    func create(_ req: Request) throws -> Future<Response> {
        let username: String = try req.content.syncGet(at: "username")
        let firstName: String = try req.content.syncGet(at: "firstName")
        let lastName: String = try req.content.syncGet(at: "lastName")
        let state: String = try req.content.syncGet(at: "state")
        let email: String = try req.content.syncGet(at: "email")
        let age: String = try req.content.syncGet(at: "age")
        var password: String = try req.content.syncGet(at: "password")
//        let passwordLength: Int = password.count
        password = try BCryptDigest().hash(password)
//        guard
//            let name = req.data["filename"]?.string,
//            let blob = req.data["file"]?.bytes
//            else {
//                throw Abort(.badRequest, reason: "Fields 'filename' and/or 'file' is invalid")
//        }
//        do{
//            try Storage.upload(
//                bytes: blob,
//                fileName: name,
//                on: req
//            )
//        }catch let err{
//            print(err.localizedDescription)
//        }
        
        let userData = User(id: nil, username: username, age: age, state: state, firstName: firstName, lastName: lastName, email: email, password: password)
        return userData.save(on: req).map(to: Response.self, { _ in
            return req.redirect(to: "/")
        })
    }
    
    func login(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(User.self).flatMap { user in
            return User.authenticate(
                username: user.email,
                password: user.password,
                using: BCryptDigest(),
                on: req
                ).map { user in
                    guard let user = user else {
                        return req.redirect(to: "/" + EndpointsPath.logIn)
                    }
                    try req.authenticateSession(user)
                    return req.redirect(to: "/")
            }
        }
    }
    
    func update(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(User.self).flatMap({ (user) in
            var userCurrent = try req.requireAuthenticated(User.self)
            let newPass = try BCrypt.hash(user.password)
            if(try BCrypt.verify(userCurrent.password, created: newPass)){
                debugPrint("not the same")
            }else{
                debugPrint("the same")
                return Future.map(on: req) {
                    return req.redirect(to: "/alert")
                }
            }
            userCurrent.password = newPass
            return userCurrent.save(on: req).map(to: Response.self, { _ in
                return req.redirect(to: "/")
            })
        })
    }
    
    func getProfileAlertPage(_ req: Request) throws -> Future<View> {
        var user = try req.requireAuthenticated(User.self)
        user.alert = "The password is the same as before!"
        return try req.view().render("alert", ["user": user])
    }
    
    
    func renderMain(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)
        let userViewList = UserView(user: user, messages: try user.message.query(on: req).sort(\Message.date, .ascending).all())
        return try req.view().render("main", ["userViewList": userViewList])
    }
    
    
    func logout(_ req: Request) throws -> Future<Response> {
        try req.unauthenticateSession(User.self)
        return Future.map(on: req) { return req.redirect(to: "/" + EndpointsPath.logIn) }
    }
    
}


