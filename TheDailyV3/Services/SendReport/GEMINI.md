# Messaging Service Instructions

## Overview
This folder handles the extraction and transmission of reports. It is responsible for fetching a `DailyReport` from SwiftData based on a provided `Date` and formatting it for `MFMessageComposeViewController`.

## Data Retrieval Logic
* **Input:** The service must be initialized or called with a `Date` object.
* **Fetching:** Use a `FetchDescriptor` with a `Predicate` to find the `DailyReport` where the `timestamp` matches the start of the provided `Date`.
* **Context:** Perform the fetch on a background `ModelContext` or the `@MainActor` context depending on the caller, but ensure the UI remains responsive.

## Media Attachment Logic (Actual Binary)
* **Custom Store Integration:** Use the `mediaIdentifier` from the fetched report to locate the actual file in the app's `Documents/CustomStore` directory.
* **Attachment:** Use `addAttachmentData(_:typeIdentifier:filename:)`.
    * For Images: Use `public.image` (UTType).
    * For Videos: Use `public.movie` (UTType).
* **Error Handling:** If the file is missing from the store, the service should still send the text portion of the report but log a warning.

## Report Composition (Strict Ordering)
1. **Attachment:** The actual Image/Video file.
2. **Caption:** `report.mediaCaption`
3. *[Empty Line]*
4. **Meals:** `report.mealDescription`
5. *[Empty Line]*
6. **Counters:** `report.counterSummaries` (joined by `\n`)
7. **Events:** `report.eventSummaries` (joined by `\n`)
8. *[Empty Line]*
9. **Activities:** `report.dailyActivities`

## UI & Delegate Logic
* **Component:** `UIViewControllerRepresentable` wrapping `MFMessageComposeViewController`.
* **Coordinator:** Must update the `isSent` status of the **fetched** report in the database only upon a `.sent` result.

## Learning & Concurrency (For Gemini)
* **Explanation:** Explain the use of `Predicate<DailyReport>` for date matching (e.g., `timestamp >= startOfDay && timestamp < endOfDay`).
* **Explanation:** Explain why we fetch the model again in this service rather than passing the object (Data Isolation/Thread Safety).
