import Foundation

/// A synchronized file writer to handle concurrent writes to the same file.
actor FileWriter {
    private let fileHandle: FileHandle
    
    init(url: URL) throws {
        self.fileHandle = try FileHandle(forWritingTo: url)
    }
    
    func write(data: Data, at offset: UInt64) throws {
        try fileHandle.seek(toOffset: offset)
        try fileHandle.write(contentsOf: data)
    }
    
    func truncate(toSize size: UInt64) throws {
        try fileHandle.truncate(atOffset: size)
    }
    
    func close() throws {
        try fileHandle.close()
    }
}
