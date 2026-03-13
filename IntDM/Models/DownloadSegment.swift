import Foundation

struct DownloadSegment: Identifiable, Codable {
    let id: Int
    let startByte: Int64
    let endByte: Int64
    var currentByte: Int64
    var isCompleted: Bool
    
    var size: Int64 {
        return endByte - startByte + 1
    }
    
    var downloadedSize: Int64 {
        return currentByte - startByte
    }
}
