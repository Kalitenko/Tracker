import Foundation

enum DataChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case insertSection(Int)
    case deleteSection(Int)
}

enum DataChangeType {
    case insert
    case delete
    case update
    case move(from: IndexPath?, to: IndexPath?)
}
