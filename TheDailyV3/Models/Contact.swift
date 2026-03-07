import SwiftData
import Foundation

@Model
class Contact {
    var name: String = ""
    var phoneNumber: String = ""
    var isDefault: Bool = false
    
    init(name: String = "", phoneNumber: String = "", isDefault: Bool = false) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.isDefault = isDefault
    }
}
