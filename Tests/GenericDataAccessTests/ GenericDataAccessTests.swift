import XCTest
import SQLite

@testable import GenericDataAccess

struct User: DatabaseEntity, Equatable{
    typealias IDType = Int
    let id: IDType
    let name: String
    let status: String
    
    static let table = Table("users")
    static let tableName = "users" 
    static let idExpression = Expression<Int>("id")
    
    static let schema: [(ColumnExpression, String)] = [
            (.int(Expression<Int>("id"), ColumnMetadata(isPrimaryKey: true)), "INTEGER"),
            (.string(Expression<String>("name"), ColumnMetadata(isPrimaryKey: false)), "TEXT"),
            (.string(Expression<String>("status"), ColumnMetadata(isPrimaryKey: false)), "TEXT")
        ]
    
    init(row: SQLite.Row) {
        id = row[User.idExpression]
        name = row[Expression<String>("name")]
        status = row[Expression<String>("status")]
    }
    
    init(id: IDType, name: String, status: String){
        self.id = id
        self.name = name
        self.status = status
    }
    
    func asSetters() -> [SQLite.Setter] {
        return[
            User.idExpression <- id,
            Expression<String>("name") <- name,
            Expression<String>("status") <- status
        ]
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.status == rhs.status
    }
    
}

final class ZirohDataAccessTests: XCTestCase {
    var dbPath: String?
    var db: Connection!
    var userDb: GenericDbAccess<User>!
    
    override func setUp() {
       super.setUp()
       let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
       dbPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("myDatabase.db").path
       let fileManager = FileManager.default
       if !fileManager.fileExists(atPath: dbPath!) {
           fileManager.createFile(atPath: dbPath!, contents: nil, attributes: nil)
       }
    }

    override func tearDown() {
       db = nil
       userDb = nil
       super.tearDown()
    }

    func testGetAllUsers() throws {
       guard let dbPath = dbPath else {
           XCTFail("Database path is nil")
           return
       }
       db = try Connection(dbPath)
       userDb = try GenericDbAccess(database: db)
       userDb.deleteTable()
       userDb.createTable()
        try userDb.insert(User(id: 1, name: "Alice", status: "good"))
        try userDb.insert(User(id: 2, name: "Bob", status: "bad"))
       
       do {
           let users = try userDb.getAll()
           let expectedUsers = [
               User(id: 1, name: "Alice", status: "good"),
               User(id: 2, name: "Bob", status: "bad")
           ]
           
           XCTAssertEqual(users, expectedUsers)
       } catch {
           XCTFail("Failed to get all users: \(error)")
       }
    }
    
    func testInsertUser() throws {
        db = try Connection(dbPath!)
        userDb = try GenericDbAccess(database: db)
        let newUser = User(id: 1, name: "John Doe", status: "good")
        do {
            userDb.deleteTable()
            userDb.createTable()
            try userDb.insert(newUser)
            let users = try userDb.getAll()
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users.first?.id, 1)
            XCTAssertEqual(users.first?.name, "John Doe")
            XCTAssertEqual(users.first?.status, "good")
        } catch {
            XCTFail("\(error)")
        }
        
    }
}
