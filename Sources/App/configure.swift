import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

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

//    // Configure a PostgreSQL database
//    let postgreSQLConfig: PostgreSQLDatabaseConfig!
//    if let url = Environment.get("DATABASE_URL") {
//        guard let urlConfig = PostgreSQLDatabaseConfig(url: url) else {
//            fatalError("Failed to create PostgreSQL Config")
//        }
//        postgreSQLConfig = urlConfig
//    } else {
//        let databasePort = 5432
//        let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
//        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
//        let username = Environment.get("DATABASE_USER") ?? "vapor"
//        let password = Environment.get("DATABASE_PASSWORD") ?? nil
//        postgreSQLConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, database: databaseName, password: password)
//    }
//    let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)
//
//    // Register the configured SQLite database to the database config.
//    var databases = DatabasesConfig()
//    databases.enableLogging(on: .psql)
//    databases.add(database: postgreSQL, as: .psql)
//    services.register(databases)
//
//    /// Configure migrations
//    var migrations = MigrationConfig()
//    migrations.add(model: Recording.self, database: .psql)
//    services.register(migrations)
}
