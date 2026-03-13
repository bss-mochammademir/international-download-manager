import SwiftUI

struct MainView: View {
    @Environment(DownloadEngine.self) private var engine
    @State private var isShowingAddSheet = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DownloadListView(isShowingAddSheet: $isShowingAddSheet)
        }
        .frame(minWidth: 800, minHeight: 500)
        .sheet(isPresented: $isShowingAddSheet) {
            AddDownloadView(isPresented: $isShowingAddSheet)
        }
    }
}

struct SidebarView: View {
    var body: some View {
        List {
            Label("All Downloads", systemImage: "arrow.down.circle")
            Label("Finished", systemImage: "checkmark.circle")
            Label("Unfinished", systemImage: "clock")
        }
        .listStyle(.sidebar)
    }
}

struct DownloadListView: View {
    @Environment(DownloadEngine.self) private var engine
    @Binding var isShowingAddSheet: Bool
    
    var body: some View {
        Table(engine.downloads) {
            TableColumn("File Name", value: \.fileName)
            TableColumn("Size") { item in
                Text(ByteCountFormatter.string(fromByteCount: item.totalSize, countStyle: .file))
            }
            TableColumn("Status") { item in
                Text(item.status.rawValue.capitalized)
            }
            TableColumn("Progress") { item in
                ProgressView(value: item.progress)
                    .progressViewStyle(.linear)
                    .tint(item.status == .completed ? .green : .blue)
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: { isShowingAddSheet = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
            ToolbarItem {
                Button(action: {}) {
                    Label("Pause", systemImage: "pause.fill")
                }
            }
        }
    }
}

