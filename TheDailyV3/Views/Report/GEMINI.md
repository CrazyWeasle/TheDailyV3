# Report Form View Instructions

## Overview
This folder contains the UI for creating and editing a `DailyReport`. The form must be dynamic, allowing users to input text while displaying summaries of linked data.

## UI Structure & Layout
* **Header:** * Display the `reportTitle` (e.g., "Report for March 5, 2026").
    * Show a "Sent" badge if `isSent` is true.
* **Media Section (Placeholder):**
    * A visual container for the media associated with `mediaIdentifier`.
    * A text field for the `mediaCaption`.
    * *Note:* For now, provide a button that "Simulates" picking a photo by generating a random string for the identifier.
* **Text Input Sections:**
    * **Meal:** A multi-line `TextEditor` for `mealDescription`.
    * **Activities:** A multi-line `TextEditor` for `dailyActivities`.
* **Data Summaries:**
    * **Events List:** A non-editable list showing the `eventSummaries` strings.
    * **Counters List:** A non-editable list showing the `counterSummaries` strings.

## Logic & State Management
* **Editability:** If `isSent == true`, all text fields must be disabled (`.disabled(true)`). The user should only be able to view the content.
* **Auto-Save:** Use the SwiftData `autosaveEnabled` feature or explicitly call `try? modelContext.save()` when the view disappears.
* **Messages Integration:**
    * Provide a "Send Report" button in the toolbar.
    * This button should only appear if `isSent == false`.
    * Upon successful completion of the message sheet, set `isSent = true` and timestamp the completion.

## Concurrency & Explanation (For Gemini)
* **Debouncing:** If I add a search or validation feature to this form, use **Combine** to debounce the input as per the Root instructions.
* **SwiftData Context:** Explain how to pass the `DailyReport` object safely into the form using `@Bindable` (iOS 26 standard) so that changes reflect in the database immediately.
* **MainActor:** Ensure the "Send" logic and sheet presentation are explicitly marked `@MainActor`.

## Implementation Notes
* Use `Section` headers in a `Form` or `List` to group the Meal, Activities, and Media sections clearly.
* On iPad, this view should occupy the "Detail" column of the `NavigationSplitView`.#  <#Title#>

