import Foundation
import SwiftData

@Model final class TestModel {
    var id: UUID = UUID()
    @Relationship(inverse: \TestModel2.models) var items: [TestModel2]? = []
    init() {}
}

@Model final class TestModel2 {
    var id: UUID = UUID()
    var models: [TestModel]? = []
    init() {}
}

let schema = Schema([TestModel.self, TestModel2.self])
let config = ModelConfiguration(cloudKitDatabase: .automatic)
do {
    let container = try ModelContainer(for: schema, configurations: [config])
    print("Success")
} catch {
    print("Error: \(error)")
}
