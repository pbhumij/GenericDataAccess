

  <h1>GenericDataAccess</h1>

  <p>GenericDataAccess provides an abstract way to access databases and RESTful APIs. It is designed to be extendable and easy to use.</p>

  <hr />

  <h2>Table of Contents</h2>
  <ul>
    <li><a href="#genericdbaccess">GenericDbAccess</a></li>
    <li><a href="#genericrestclient">GenericRestClient</a></li>
    <li><a href="#license">License</a></li>
  </ul>

  <hr />

  <h2 id="genericdbaccess">GenericDbAccess</h2>

  <h3>Usage</h3>

  <h4>1. Implement DatabaseEntity protocol in your struct or class</h4>

  <pre>
  <code>
  struct User: DatabaseEntity {
    typealias IDType = Int
    let id: IDType
    let name: String

    static let table = Table("users")
    static let tableName = "users"
    static let idExpression = Expression&lt;Int&gt;("id")

    static let schema: [(ColumnExpression, String)] = [
      (.int(Expression&lt;Int&gt;("id"), ColumnMetadata(isPrimaryKey: true)), "INTEGER"),
      (.string(Expression&lt;String&gt;("name"), ColumnMetadata(isPrimaryKey: false)), "TEXT")
    ]

    init(row: SQLite.Row) {
      id = row[User.idExpression]
      name = row[Expression&lt;String&gt;("name")]
    }

    init(id: IDType, name: String, status: String) {
      self.id = id
      self.name = name
    }

    func asSetters() -> [SQLite.Setter] {
      return [
        User.idExpression &lt;- id,
        Expression&lt;String&gt;("name") &lt;- name
      ]
    }
  }
  </code>
  </pre>

  <h4>2. Create GenericDbAccess instance and start using it</h4>

  <pre>
  <code>
  var dbPath: String?
  var db: Connection!
  var userDb: GenericDbAccess&lt;User&gt;!

  dbPath = "Path/To/db"
  db = try Connection(dbPath)
  var userDb = try GenericDbAccess(database: db)

  // INSERT
  userDb.insert(User(id: 1, name: "Alice"))

  // GET
  let users = try userDb.getAll()
  </code>
  </pre>

  <hr />

  <h2 id="genericrestclient">GenericRestClient</h2>

  <h3>Usage</h3>

  <h4>1. Implement Codable protocol for request body or response</h4>

  <pre>
  <code>
  struct User: Codable {
    let id: Int?
    let name: String?
  }
  </code>
  </pre>

  <h4>2. Create instance of GenericRestClient</h4>

  <pre>
  <code>
  var restClient = GenericRestClient&lt;User&gt;(baseUrl: "com.example.abc")
  var user = restClient.get(endpoint: "user123")
  </code>
  </pre>

<hr />

<hr />

<h2 id="license">License</h2>

<p>This project is licensed under the terms of the MIT license. For more details, see the <a href="LINK_TO_LICENSE_FILE">LICENSE</a> file.</p>




</body>

</html>
