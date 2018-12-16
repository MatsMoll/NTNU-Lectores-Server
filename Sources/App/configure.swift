import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(MySQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    let mysqlConfig: MySQLDatabaseConfig!
    if let url = Environment.get("DATABASE_URL") {
        guard let urlConfig = try MySQLDatabaseConfig(url: url) else {
            fatalError("Failed to create MySQL Config")
        }
        mysqlConfig = urlConfig
    } else {
        let databasePort = 3306
        let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        let username = Environment.get("DATABASE_USER") ?? "vapor"
        let password = Environment.get("DATABASE_PASSWORD") ?? "password"
        print("name: \(databaseName)\nhost: \(hostname)")
        print("name: \(username)\nhost: \(password)")
        mysqlConfig = MySQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, password: password, database: databaseName)
    }
    let mysql = MySQLDatabase(config: mysqlConfig)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .mysql)
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Recording.self, database: .mysql)
    services.register(migrations)

}
