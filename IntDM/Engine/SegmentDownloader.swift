import Foundation

class SegmentDownloader: NSObject, URLSessionDataDelegate {
    var segment: DownloadSegment
    let url: URL
    let session: URLSession
    var task: URLSessionDataTask?
    let fileWriter: FileWriter
    
    var isCompleted = false
    
    var onProgress: ((Int64) -> Void)?
    var onCompletion: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(segment: DownloadSegment, url: URL, session: URLSession, fileWriter: FileWriter) {
        self.segment = segment
        self.url = url
        self.session = session
        self.fileWriter = fileWriter
        super.init()
    }
    
    func start() {
        let range = "bytes=\(segment.currentByte)-\(segment.endByte)"
        var request = URLRequest(url: url)
        request.addValue(range, forHTTPHeaderField: "Range")
        
        print("🌐 Starting Segment \(segment.id): \(range)")
        
        let task = session.dataTask(with: request)
        task.delegate = self
        self.task = task
        task.resume()
    }
    
    func pause() {
        task?.cancel()
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let currentOffset = segment.currentByte
        let dataCount = Int64(data.count)
        
        // Update local offset immediately to prevent overlapping writes if multiple data chunks arrive
        segment.currentByte += dataCount
        
        Task {
            do {
                try await fileWriter.write(data: data, at: UInt64(currentOffset))
                onProgress?(dataCount)
            } catch {
                onError?(error)
                task?.cancel()
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            onError?(error)
        } else {
            isCompleted = true
            onCompletion?()
        }
    }
}
