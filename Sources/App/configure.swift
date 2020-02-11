
import Vapor
import FluentPostgreSQL
import Leaf
import Storage
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    
    try services.register(AuthenticationProvider())
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    try services.register(FluentPostgreSQLProvider())
    
    let postgresqlConfig = PostgreSQLDatabaseConfig(
        hostname: "localhost",
        port: 5432,
        username: "Amza",
        database: "my2",
        password: nil
    )
    let postgres = PostgreSQLDatabase(config: postgresqlConfig)
    var db = DatabasesConfig()
    db.add(database: postgres, as: .psql)
    services.register(db)
    
    let driver = try S3Driver(
        bucket: "savephotosamazon",
        accessKey: "AKIAISI56X3NGTDN4BKA",
        secretKey: "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"
    )
    
    services.register(driver)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Message.self, database: .psql)
    services.register(migrations)

    
}
