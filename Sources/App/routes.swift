import Vapor
import Authentication
/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req -> Future<View> in
        return try req.view().render("main")
    }
    
    let userController = UserController()
    router.post("signUP", use: userController.create)
    router.get("user", User.parameter, use: userController.getUserPage)
    router.get(EndpointsPath.signUp, use: userController.getSignUpPage)
    router.get(EndpointsPath.logIn, use: userController.getLogInPage)
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    authSessionRouter.post("login", use: userController.login)
    
    let messageController = MessageController()
    let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/" + EndpointsPath.logIn))
    protectedRouter.get("/", use: userController.renderMain)
    protectedRouter.get(EndpointsPath.profile, use: userController.getProfilePage)
    protectedRouter.get(EndpointsPath.alert, use: userController.getProfileAlertPage)
    protectedRouter.post("update", use: userController.update)
    protectedRouter.post("sendMessage", use: messageController.create)
    protectedRouter.get("users", use: userController.allUsersPage)
    
    router.get("logout", use: userController.logout)
    
    
}
