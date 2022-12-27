import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var pendingScroll: ContentRowViewModel?
    @State private var atTop: Bool = true

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ProgressView()
                        .tint(viewModel.loading ? .blue : .gray)
                        .padding(.all, 4)
                    /*
                        .onAppear {
                            Task {
                                _ = try await viewModel.loadMoreBefore()
                            }
                        }
                     */
                    Divider()
                    ForEach(viewModel.rows) { vm in
                        Text(vm.text).id(vm.id)
                        Divider()
                    }
                    if !viewModel.rows.isEmpty {
                        ProgressView()
                            .padding()
                            .onAppear {
                                Task {
                                    try await viewModel.loadMoreAfter()
                                }
                            }
                    }
                }
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) {
                    if $0 <= 0 && atTop != true {
                        atTop = true
                    }
                    else if $0 > 0 && atTop != false {
                        atTop = false
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            /*
            .onAppear {
                print("ScrollView.onAppear")
                let initialFirstRow = viewModel.rows[50]
                scrollProxy.scrollTo(initialFirstRow.id)
            }
             */
            .onChange(of: self.atTop) { o in
                if atTop {
                    Task {
                        pendingScroll = try await viewModel.loadMoreBefore()
                    }
                }
            }
            .onChange(of: self.pendingScroll) { vm in
                guard let vm = vm else { return }

                print("scroll to \(vm.index)")
                scrollProxy.scrollTo(vm.id, anchor: .top)
                self.pendingScroll = nil
            }
            .task {
                pendingScroll = await viewModel.load()
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
