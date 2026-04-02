# Data Model & Schema Instructions (v2)

- **Overview:** Defines the **SwiftData** schema for **TheDailyV3**, optimized for rich media and iCloud sync for iOS 26+.
- **Status:** MVP (Full Schema Implementation)

## Model Definitions

### 1. DailyReport (Core Entity)
* **Identity & Metadata:**
    * `id`: UUID (Primary Identifier).
    * `timestamp`: Date (Start of day/midnight for calendar matching).
    * `reportTitle`: String (Formatted via `DailyReport.formatTitle(for:)`).
    * `isSent`: Bool (Default: `false`).
* **Content Persistence:**
    * `mealDescription`: String (Day's meals).
    * `dailyActivities`: String (Activities).
    * `eventSummaries`: [String] (Redundant storage for "frozen" report state).
    * `counterSummaries`: [String] (Redundant storage for "frozen" report state).
* **Media Tracking:**
    * `mediaIdentifier`: String? (UUID reference to external file).
    * `mediaCaption`: String? (User description).
    * `mediaType`: String? (Enum-backed: "image" or "video").
* **Relationships:**
    * `events`: [ReportEvent]? (Optional, Many-to-Many).
    * `counters`: [ReportCounter]? (Optional, Many-to-Many).

### 2. ReportEvent (Milestone Tracking)
* **Goal:** Track milestones and calculate dynamic temporal strings.
* **Properties:**
    * `id`: UUID.
    * `title`: String.
    * `targetDate`: Date.
    * `isAnniversary`: Bool.
    * `isActive`: Bool (Persistence flag for future reports).
* **Logic:** `reportLine(for:)` calculates intervals (Years/Months/Days) relative to a report date.

### 3. ReportCounter & CounterIncrement (Numerical Tracking)
* **ReportCounter:**
    * `id`: UUID.
    * `name`: String.
    * `history`: [CounterIncrement]? (Relationship, Cascade).
* **CounterIncrement:**
    * `id`: UUID.
    * `value`: Int (+1/-1).
    * `timestamp`: Date.
* **Logic:** `count(for:)` calculates cumulative totals up to a report date.

### 4. CustomImageMetadata (Custom Store Tracking)
* **Goal:** Prevent database bloat by tracking external assets.
* **Properties:**
    * `assetID`: String.
    * `source`: String ("PhotoLibrary" or "CustomStore").
    * `usageCount`: Int.
    * `lastUsed`: Date.

### 5. Contact (Settings & Messaging)
* **Goal:** Manage report recipients.
* **Properties:**
    * `name`: String.
    * `phoneNumber`: String.
    * `isDefault`: Bool.

## Architectural Constraints (iOS 26 / CloudKit)
1.  **Media Storage Rule:** **NEVER** store `Data` blobs in `@Model`. Store only the `String` identifier.
2.  **CloudKit Compatibility:** All relationships MUST be optional. No `@Attribute(.unique)`.
3.  **Redundant State:** `eventSummaries` and `counterSummaries` are populated when a report is finalized/sent to ensure historical accuracy even if source entities change.

## Implementation Notes for Gemini
* **Media Management:** Files are stored in the `Documents` directory via `MediaService.swift`.
* **Usage Tracking:** Increment `usageCount` in `CustomImageMetadata` when adding media to a `DailyReport`.
