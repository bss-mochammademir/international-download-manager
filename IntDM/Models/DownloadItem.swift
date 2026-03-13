import Foundation

enum DownloadStatus: String, Codable {
    case queued
    case downloading
    case paused
    case merging
    case completed
    case failed
}

struct DownloadItem: Identifiable, Codable {
    let id: UUID
    let url: URL
    var fileName: String
    var status: DownloadStatus
    var totalSize: Int64
    var downloadedSize: Int64
    var progress: Double {
        guard totalSize > 0 else { return 0 }
        return Double(downloadedSize) / Double(totalSize)
    }
    var createdAt: Date
    var savePath: URL
    
    init(url: URL, fileName: String, savePath: URL) {
        self.id = UUID()
        self.url = url
        self.fileName = fileName
        self.status = .queued
        self.totalSize = 0
        self.downloadedSize = 0
        self.createdAt = Date()
        self.savePath = savePath
    }
}
