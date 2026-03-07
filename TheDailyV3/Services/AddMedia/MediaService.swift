import Foundation

public final class MediaService {
    public static let shared = MediaService()
    
    private init() {}
    
    public var customStoreURL: URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeURL = documentsURL.appendingPathComponent("CustomStore")
        
        if !fileManager.fileExists(atPath: storeURL.path) {
            try? fileManager.createDirectory(at: storeURL, withIntermediateDirectories: true)
        }
        
        return storeURL
    }
    
    public func saveMedia(data: Data, identifier: String) throws {
        let fileURL = customStoreURL.appendingPathComponent(identifier)
        try data.write(to: fileURL)
    }
    
    public func loadMedia(identifier: String) -> Data? {
        let fileURL = customStoreURL.appendingPathComponent(identifier)
        return try? Data(contentsOf: fileURL)
    }
}
