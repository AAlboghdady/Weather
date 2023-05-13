//
//  AppDatabase.swift
//  MVVM-C
//
//  Created by Abdurrahman Alboghdady on 10/04/2022.
//

import GRDB

/// AppDatabase lets the application access the database.
///
/// It applies the pratices recommended at
/// <https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md>
final class AppDatabase {
    /// Creates an `AppDatabase`, and make sure the database schema is ready.
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, and tests can use a fast
    /// in-memory `DatabaseQueue`.
    ///
    /// See <https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections>
    private let dbWriter: DatabaseWriter
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("Weather") { db in
            // Create a Weather table
            try db.create(table: "Weather") { t in
                t.column("id", .integer)
                t.column("main", .text)
                t.column("description", .text)
                t.column("icon", .text)
                t.column("city", .text).primaryKey()
                t.column("temp", .double)
            }
        }
        
        return migrator
    }
}

// MARK: - Database Access: Writes

extension AppDatabase {
    /// Saves (inserts or updates) a weather. When the method returns, the
    /// weather is present in the database, and its id is not nil.
    func saveWeather(_ weather: inout Weather) throws {
        _ = try dbWriter.write { db in
            try weather.save(db)
        }
    }
    
    func removeAllWeather() throws {
        _ = try dbWriter.write { db in
            try Weather.deleteAll(db)
        }
    }
}

// MARK: - Database Access: Reads
extension AppDatabase {
    /// Provides a read-only access to the database
    var databaseReader: DatabaseReader {
        dbWriter
    }
}
 

// MARK: - Database: get all weather
extension AppDatabase {
    /// get all weather
    func getAllWeatherFromDataBase(completion: @escaping (_ weatherArray: [Weather])->()) {
        // check if the weather are stored in the database first
        let request: QueryInterfaceRequest<Weather> = Weather.all()
        _ = ValueObservation
            .tracking(request.fetchAll(_:))
            .start(in: AppDatabase.shared.databaseReader,
                // Immediate scheduling feeds the data source right on subscription,
                // and avoids an undesired animation when the application starts.
                scheduling: .immediate,
                onError: { error in
                    // no data found
                completion([])
            }, onChange: { weatherArray in
                if weatherArray.isEmpty {
                    completion([])
                    return
                }
                completion(weatherArray)
            })
    }
}
