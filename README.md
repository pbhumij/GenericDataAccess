# GenericDataAccess

GenericDbAccess
1. Implement DatabaseEntity protocol in your struct or class. 
   Example:
   
   struct User: DatabaseEntity{
    typealias IDType = Int
    let id: IDType
    let name: String
    
    static let table = Table("users")
    static let tableName = "users" 
    static let idExpression = Expression<Int>("id")
    
    static let schema: [(ColumnExpression, String)] = [
            (.int(Expression<Int>("id"), ColumnMetadata(isPrimaryKey: true)), "INTEGER"),
            (.string(Expression<String>("name"), ColumnMetadata(isPrimaryKey: false)), "TEXT"),
        ]
    
    init(row: SQLite.Row) {
        id = row[User.idExpression]
        name = row[Expression<String>("name")]
    }
    
    init(id: IDType, name: String, status: String){
        self.id = id
        self.name = name
    }
    
    func asSetters() -> [SQLite.Setter] {
        return[
            User.idExpression <- id,
            Expression<String>("name") <- name,
        ]
    }
}

2. Create GenericDbAccess instance and start using it.
   Example:
  
    var dbPath: String?
    var db: Connection!
    var userDb: GenericDbAccess<User>!

    dbPath = "Path/To/db"
    db = try Connection(dbPath)
    var userDb = try GenericDbAccess(database: db)
  
    --INSERT--
    userDb.insert(User(id: 1, name: "Alice"))

    --GET--
    let users = try userDb.getAll()


GenericRestClient

1. Implement Codable protocol for request body or response.

   Example: I want to make a GET request which would return me a User object

       struct User: Codable{
           let id: Int?
           let name: String?
       }

2. Create instance of GenericRestClient

   Example:

      var restClient = GenericRestClient<User>(baseUrl: "com.example.abc")
      var user = restClient.get(endpoint: "user123")


