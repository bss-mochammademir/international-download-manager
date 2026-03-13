import SwiftUI

struct AddDownloadView: View {
    @Environment(DownloadEngine.self) private var engine
    @Binding var isPresented: Bool
    
    @State private var urlString = ""
    @State private var fileName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Download")
                .font(.headline)
            
            Form {
                TextField("URL", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Save As", text: $fileName)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Download Now") {
                    if let url = URL(string: urlString) {
                        let saveURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").appendingPathComponent(fileName.isEmpty ? url.lastPathComponent : fileName)
                        engine.addDownload(url: url, fileName: fileName.isEmpty ? url.lastPathComponent : fileName, savePath: saveURL)
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(urlString.isEmpty)
            }
            .padding()
        }
        .frame(width: 500)
        .padding()
    }
}
