# TheDailyV3: Root Project Instructions

## Project Identity & Goals
**TheDailyV3** is a reporting and tracking application built for iOS 26+. It focuses on high-performance data entry, cross-device synchronization via SwiftData/iCloud, and seamless communication through the Messages app.

## Technical Stack & Constraints
* **Target:** iOS 26.0+ / iPadOS 26.0+
* **Language:** Swift 6+ (Strict Concurrency: Complete)
* **UI Framework:** SwiftUI (100%)
* **Persistence:** **SwiftData** with **iCloud/CloudKit** sync.
    * *Constraint:* No `@Attribute(.unique)` (CloudKit incompatibility).
    * *Constraint:* Relationships must be Optional; properties must have default values.
* **Layout:** Use `NavigationSplitView` for all platforms.
    * **iPad:** Multi-column (Sidebar/Detail or Sidebar/Content/Detail).
    * **iPhone:** Graceful collapse to a navigation stack.
    * **top level view** the sidebar in the navigationsplitview (iPad) and the top level view (iPhone) should present four items: a link to the calendar, a link to the events editor, a link to the counter editor and a link to the editable gallery of images that can be added to reports directly from the application

## Core Features
### 1. Custom Reporting Calendar
* Provide a color-coded interface indicating "Report Created" vs. "Report Sent."
* Tapping a date opens the report for that day.
* Sent reports are Read-Only; Draft reports are Editable.

### 2. Search & Filter
* Global search across all reports (Sent and Drafts).
* **Requirement:** Use **Combine** to debounce user input (0.3s) before performing the search to maintain UI fluidity.

### 3. Contact & Messages Integration
* **Contacts:** Use the `CNContact.identifier` (String) to store the default recipient. Do not store names/numbers to avoid sync drift.
* **Messages:** Detect "Sent" status automatically upon successful completion of the message compose sheet.

### 4. Report Composition
* A dynamic form to create daily reports.
* Support for adding multiple **Events** (array) and **Counters** (array) to a single report.

## Learning & Explanation Rules (For Gemini)
I am currently learning the latest Swift concurrency features. When providing code or architectural advice:
1.  **Explain the "Why":** Don't just give the code. Explain the choice between `Task`, `TaskGroup`, and `AsyncSequence`.
2.  **Concurrency Boundaries:** Clearly explain how data moves between Background Actors and the `@MainActor`.
3.  **Modern Syntax:** Prioritize Swift 6 features (e.g., `@Sendable`, `package` visibility, trailing closure improvements).

## Project Structure
This project uses folder-level `GEMINI.md` files. Always check for a local `GEMINI.md` in subfolders for specific implementation details regarding Data Models, Services, or View-specific logic.#  <#Title#>

