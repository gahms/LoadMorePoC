import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    private var _firstLoadMoreBefore: Bool = false
    
    @Published var rows: [ContentRowViewModel] = (100..<200).map {
        ContentRowViewModel(index: $0, text: "Line \($0)")
    }
    
    func loadMoreBefore() async throws -> ContentRowViewModel? {
        if _firstLoadMoreBefore {
            _firstLoadMoreBefore = false
            return nil
        }
        print("\(#function)...")
        try await Task.sleep(
            until: .now + .seconds(2),
            clock: .suspending
        )
        let firstRow = rows.first!
        let end = firstRow.index
        let start = end - 50
        let newRows = (start..<end).map {
            ContentRowViewModel(index: $0, text: "Line \($0)")
        }
        rows.insert(contentsOf: newRows, at: 0)
        print("\(#function)...done")
        
        return newRows.last!
    }

    func loadMoreAfter() async throws {
        print("\(#function)...")
        try await Task.sleep(
            until: .now + .seconds(2),
            clock: .suspending
        )
        let start = rows.last!.index + 1
        let end = start + 50
        rows.append(contentsOf: (start..<end).map {
            ContentRowViewModel(index: $0, text: "Line \($0)")
        })
        print("\(#function)...done")
    }
}

struct ContentRowViewModel: Identifiable, Equatable {
    var id: UUID = .init()
    var index: Int
    var text: String
    
    init(index: Int, text: String) {
        self.index = index
        self.text = text
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
