import Foundation
import SwiftUI

@Observable
class ContentViewModel {
    var sections: [ContentSectionViewModel] = []
    var loading: Bool = false
    
    var isNotEmpty: Bool {
        !sections.isEmpty
    }
    
    func loadSections() async -> ContentRowViewModel? {
        print("\(#function)...")
        loading = true
        defer { loading = false }
        
        do {
            try await Task.sleep(
                until: .now + .seconds(1),
                clock: .suspending
            )
            
            sections = [200, 300, 400].map {
                ContentSectionViewModel(
                    index: $0,
                    text: "Section: \($0)",
                    rows: ($0..<($0+100)).map { rowIndex in
                        ContentRowViewModel(index: rowIndex,
                                            text: "Line \(rowIndex)")
                    }
                )
            }
            
            return sections[1].rows[50]
        }
        catch {
            // CancellationError
            return nil
        }
    }
    
    func loadSectionMoreBefore() -> ContentRowViewModel? {
        guard let firstSection = sections.first else {
            print("\(#function) empty -> ignoring")
            return nil
        }
        
        loading = true
        defer { loading = false }
        
        print("\(#function)...")
        
        let newSectionIndex = firstSection.index - 100
        let newSection = ContentSectionViewModel(
            index: newSectionIndex,
            text: "Section: \(newSectionIndex)",
            rows: (newSectionIndex..<(newSectionIndex+100)).map { rowIndex in
                ContentRowViewModel(index: rowIndex,
                                    text: "Line \(rowIndex)")
            }
        )
        
        sections.insert(newSection, at: 0)
        print("\(#function)...done")
        
        return newSection.rows.last!
    }

    func loadSectionMoreAfter() {
        guard let lastSection = sections.last else {
            print("\(#function) empty -> ignoring")
            return
        }
        
        loading = true
        defer { loading = false }
        
        print("\(#function)...")
        
        let newSectionIndex = lastSection.index + 100
        let newSection = ContentSectionViewModel(
            index: newSectionIndex,
            text: "Section: \(newSectionIndex)",
            rows: (newSectionIndex..<(newSectionIndex+100)).map { rowIndex in
                ContentRowViewModel(index: rowIndex,
                                    text: "Line \(rowIndex)")
            }
        )
        
        sections.append(newSection)
        print("\(#function)...done")
    }
}

struct ContentSectionViewModel: Identifiable, Equatable {
    var id: UUID = .init()
    var index: Int
    var text: String
    var rows: [ContentRowViewModel]
    
    init(index: Int, text: String, rows: [ContentRowViewModel]) {
        self.index = index
        self.text = text
        self.rows = rows
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
