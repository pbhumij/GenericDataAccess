import SQLite

enum DataAccessError: Error {
    case fetchFailed(Error)
    case insertionFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    case tableCreationFailed(Error)
    case noRecordsAffected
}

class GenericDbAccess<T: DatabaseEntity> where T.IDType.Datatype: Equatable {
    private let db: Connection
    
    init(database: Connection) throws {
        self.db = database
        do {
            try createTable()
        } catch {
            throw DataAccessError.tableCreationFailed(error)
        }
    }
    
    func createTable() {
        do {
            try db.run(T.table.create(ifNotExists: true) { t in
                for (expression, _) in T.schema {
                    switch expression {
                    case .int(let intExpression, let metadata):
                        if metadata.isPrimaryKey {
                            t.column(intExpression, primaryKey: .autoincrement) // Using SQLite.swift syntax for primary key
                        } else {
                            t.column(intExpression)
                        }
                        
                    case .string(let stringExpression, let metadata):
                        if metadata.isPrimaryKey {
                            t.column(stringExpression, primaryKey: true)
                        } else {
                            t.column(stringExpression)
                        }
                        
                    // Add other cases as needed
                    }
                }
                printTableInfo(tableName: T.tableName)
            })
        }catch{
            print("Failed to create table: \(error)")
        }
    }
    
    private func printTableInfo(tableName: String) {
        do {
            let statement = try db.prepare("PRAGMA table_info(\(tableName));")
            print("Table: \(tableName)")
            for row in statement {
                if let name = row[1] as? String, let type = row[2] as? String {
                    print("Column: \(name), Type: \(type)")
                }
            }
        } catch {
            print("Failed to retrieve table info: \(error)")
        }
    }
    
    func deleteTable(){
        do{
            try db.run(T.table.drop(ifExists: true))
        }catch{
            print("Failed to delete table: \(error)")
        }
    }

    
    func getAll() throws -> [T]{
        do{
            return try db.prepare(T.table).map{T(row: $0)}
        } catch {
            print ("fetch failed \(error)")
            throw DataAccessError.fetchFailed(error)
        }
    }
    
    func insert(_ item: T) throws {
        do {
            try db.run(T.table.insert(item.asSetters()))
        } catch {
            throw DataAccessError.insertionFailed(error)
        }
    }

    func update(_ item: T) throws {
       let query = T.table.filter(T.idExpression == item.id)
       do {
           let updated = try db.run(query.update(item.asSetters()))
           if updated == 0 {
               throw DataAccessError.noRecordsAffected
           }
       } catch {
           throw DataAccessError.updateFailed(error)
       }
    }
    
    func delete(_ item: T) throws {
        let query = T.table.filter(T.idExpression == item.id)
        do {
            let deleted = try db.run(query.delete())
            if deleted == 0 {
                throw DataAccessError.noRecordsAffected
            }
        } catch {
            throw DataAccessError.deleteFailed(error)
        }
    }
}
