import Foundation
import SwiftUI

@main
struct IntDMApp: App {
    @State private var engine = DownloadEngine()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(engine)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
