//
//  TheDailyV3App.swift
//  TheDailyV3
//
//  Created by Joe Jarriel on 3/5/26.
//

import SwiftUI
import SwiftData

@main
struct TheDailyV3App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DailyReport.self, CustomImageMetadata.self])
    }
}
