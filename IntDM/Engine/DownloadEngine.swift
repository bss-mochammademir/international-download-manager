import Foundation
import Observation

@Observable
class DownloadEngine {
    var downloads: [DownloadItem] = []
    private var activeDownloaders: [UUID: [SegmentDownloader]] = [:]
    private var urlSession: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.urlSession = URLSession(configuration: config)
    }
    
    func addDownload(url: URL, fileName: String, savePath: URL) {
        let newItem = DownloadItem(url: url, fileName: fileName, savePath: savePath)
        downloads.append(newItem)
        startDownload(item: newItem)
    }
    
    private func startDownload(item: DownloadItem) {
        Task {
            do {
                var request = URLRequest(url: item.url)
                request.httpMethod = "HEAD"
                
                let (_, response) = try await urlSession.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                let totalSize = httpResponse.expectedContentLength
                let canResume = httpResponse.allHeaderFields["Accept-Ranges"] as? String == "bytes"
                
                print("🚀 Starting download for: \(item.fileName)")
                print("📏 Total Size: \(totalSize), Can Resume: \(canResume)")
                
                if let index = downloads.firstIndex(where: { $0.id == item.id }) {
                    downloads[index].totalSize = totalSize
                    downloads[index].status = .downloading
                    
                    if canResume {
                        // Ensure directory exists
                        let directory = item.savePath.deletingLastPathComponent()
                        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                        
                        FileManager.default.createFile(atPath: item.savePath.path, contents: nil, attributes: nil)
                        let fileWriter = try FileWriter(url: item.savePath)
                        try await fileWriter.truncate(toSize: UInt64(totalSize))
                        
                        let segments = SegmentManager.createSegments(totalSize: totalSize, connectionCount: 8)
                        var downloaders: [SegmentDownloader] = []
                        
                        for segment in segments {
                            let downloader = SegmentDownloader(segment: segment, url: item.url, session: urlSession, fileWriter: fileWriter)
                            
                            downloader.onProgress = { [weak self] downloadedBytes in
                                DispatchQueue.main.async {
                                    if let idx = self?.downloads.firstIndex(where: { $0.id == item.id }) {
                                        self?.downloads[idx].downloadedSize += downloadedBytes
                                    }
                                }
                            }
                            
                            downloader.onCompletion = { [weak self] in
                                print("✅ Segment \(segment.id) completed.")
                                // Logic to check if all completed...
                                Task { [weak self] in
                                    await self?.checkCompletion(for: item.id)
                                }
                            }
                            
                            downloader.start()
                            downloaders.append(downloader)
                        }
                        
                        activeDownloaders[item.id] = downloaders
                    }
                }
            } catch {
                print("❌ Download Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkCompletion(for id: UUID) async {
        guard let downloaders = activeDownloaders[id] else { return }
        
        let allCompleted = downloaders.allSatisfy { $0.isCompleted }
        if allCompleted {
            print("🎉 Download \(id) completed!")
            DispatchQueue.main.async {
                if let idx = self.downloads.firstIndex(where: { $0.id == id }) {
                    self.downloads[idx].status = .completed
                }
            }
            activeDownloaders.removeValue(forKey: id)
        }
    }
}
