# Data Model & Schema Instructions (v2)

## Overview
This folder defines the **SwiftData** schema for **TheDailyV3**. The model is optimized for rich media (images/video) and efficient iCloud synchronization for iOS 26+.

## Model Definitions

### 1. DailyReport (Core Entity)
* **Identity & Metadata:**
    * `id`: UUID (Primary Identifier).
    * `timestamp`: Date (Start of day/midnight for calendar matching).
    * `reportTitle`: String (Formatted: "Report for [Date]").
    * `isSent`: Bool (Default: `false`).
* **Content:**
    * `mealDescription`: String (Formatted string of the day's meals).
    * `dailyActivities`: String (Formatted string of activities).
    * `eventSummaries`: [String] (Extracted titles from associated events).
    * `counterSummaries`: [String] (Extracted titles/counts from associated counters).
* **Media (Placeholder Logic):**
    * `mediaIdentifier`: String? (A unique ID referencing a file in the custom store or System Photo Library).
    * `mediaCaption`: String? (User-provided description of the media).
    * `mediaType`: String? (Enum-backed: "image" or "video").
* **Relationships:**
    * `events`: [ReportEvent]? (Optional, Cascade).
    * `counters`: [ReportCounter]? (Optional, Cascade).

### 2. CustomImageMetadata (Custom Store Tracking)
* **Goal:** Track assets stored outside the main SwiftData binary to prevent database bloat.
* **Properties:**
    * `assetID`: String (Matches `mediaIdentifier` in the Report).
    * `source`: String (Enum-backed: "PhotoLibrary" or "CustomStore").
    * `usageCount`: Int (Incremented every time this asset is added to a report).
    * `lastUsed`: Date.

## Architectural Constraints (iOS 26 / CloudKit)
1.  **Media Storage Rule:** Do **NOT** store `Data` blobs in the `@Model`. Store only the `String` identifier. The actual binary must live in the `Application Support` directory or be fetched via `PHAsset` identifier.
2.  **CloudKit Compatibility:** All relationships are optional. No uniqueness constraints.
3.  **String Formatting:** Use a `computed property` or a `Service` to generate the `reportTitle` dynamically based on the `timestamp`.

## Implementation Notes for Gemini
* **Media Logic:** When I ask to "add an image," suggest a logic where the file is copied to a "CustomStore" folder and only its filename is saved to the `DailyReport`.
* **Usage Tracking:** When a `DailyReport` is created with a `mediaIdentifier`, Gemini should provide a snippet to find or create the `CustomImageMetadata` and increment the `usageCount`.
