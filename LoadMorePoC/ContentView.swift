import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var pendingScroll: ContentRowViewModel?

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ProgressView()
                        .tint(viewModel.loading ? .blue : .gray)
                        .padding(.all, 4)
                        .onAppear {
                            pendingScroll = viewModel.loadSectionMoreBefore()
                        }
                    Divider()
                    ForEach(viewModel.sections) { section in
                        Section {
                            ForEach(section.rows) { row in
                                Text(row.text)
                                    .padding()
                                    .id(row.id)
                                Divider()
                            }
                        } header: {
                            HStack {
                                Spacer()
                                Text("\(section.text)")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding()
                            .background(.secondary)
                        }
                    }
                    if viewModel.isNotEmpty {
                        ProgressView()
                            .padding()
                            .onAppear {
                                viewModel.loadSectionMoreAfter()
                            }
                    }
                }
            }
            .onChange(of: self.pendingScroll) { _, vm in
                guard let vm = vm else { return }

                print("scroll to \(vm.index)")
                scrollProxy.scrollTo(vm.id, anchor: .top)
                self.pendingScroll = nil
            }
            .task {
                pendingScroll = await viewModel.loadSections()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
