import Foundation
import SwiftData

@Model
final class CustomImageMetadata {
    var assetID: String = ""
    var source: String = "" // "PhotoLibrary" or "CustomStore"
    var usageCount: Int = 0
    var lastUsed: Date = Date()
    
    init(assetID: String, source: String) {
        self.assetID = assetID
        self.source = source
        self.usageCount = 1
        self.lastUsed = Date()
    }
}
