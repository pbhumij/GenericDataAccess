
import SQLite

enum ColumnExpression {
    case int(Expression<Int>, ColumnMetadata)
    case string(Expression<String>, ColumnMetadata)
    // Add other cases as needed
}

struct ColumnMetadata {
    let isPrimaryKey: Bool
    // Add other metadata as needed
}

protocol DatabaseEntity {
    associatedtype IDType: Value where IDType.Datatype: Equatable
    var id: IDType { get }
    static var table: Table { get }
    static var idExpression: Expression<IDType> { get }
    static var schema: [(ColumnExpression, String)] { get }
    static var tableName: String { get }
    init(row: Row)
    func asSetters() -> [Setter]
}

