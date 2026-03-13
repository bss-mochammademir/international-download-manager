import Foundation

class SegmentManager {
    static func createSegments(totalSize: Int64, connectionCount: Int) -> [DownloadSegment] {
        guard totalSize > 0 else { return [] }
        
        var segments: [DownloadSegment] = []
        let segmentSize = totalSize / Int64(connectionCount)
        
        for i in 0..<connectionCount {
            let start = Int64(i) * segmentSize
            let end = (i == connectionCount - 1) ? (totalSize - 1) : (start + segmentSize - 1)
            
            segments.append(DownloadSegment(
                id: i,
                startByte: start,
                endByte: end,
                currentByte: start,
                isCompleted: false
            ))
        }
        
        return segments
    }
}
