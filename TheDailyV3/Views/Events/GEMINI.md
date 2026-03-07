# Events Editor & Selector Instructions

## Overview
This folder manages the lifecycle of **Events** for **TheDailyV3**. Events are date-specific milestones that calculate a dynamic temporal string (time since or until) based on the specific date of a `DailyReport`. Unlike standard counters, these track the relationship between the current report and a fixed point in time.

---

## Data Structure Requirements
* **Event Entity:**
    * `title`: String (User-defined).
    * `targetDate`: Date (The fixed moment in time being tracked).
    * `isAnniversary`: Bool (Determines if the event should automatically resurface annually).
    * `isActive`: Bool (Persistence flag to include the event in current and subsequent reports).
* **Computed Property: `reportLine`**
    * **Format**: Returns a string as `"[interval] [since/until] [title]"`.
    * **Interval Logic**: Must show precise years, months, and days.
    * **Omission Rule**: If years or months are zero, they must be omitted from the string (e.g., "5 days since" instead of "0 years, 0 months, and 5 days since").

---

## UI & User Interaction
* **Creation Flow:**
    * Prompt the user for a `title`.
    * Use a `DatePicker` to set the `targetDate`.
    * Provide a toggle for "Track as Anniversary".
* **The Editor Interface:**
    * Display a list of all events with a toggle to manage the `isActive` status.
    * **Persistence**: Once an event is toggled `isActive`, it must remain active for the next report automatically.
* **Selection for Report:**
    * **Manual**: Include events in the `DailyReport` if they are manually toggled `isActive`.
    * **Automatic**: Include events automatically if `isAnniversary` is true and the month/day matches the `reportDate`.

---

## Logic & Calculation
* **Reference Point**: All time calculations must be performed between the `targetDate` and the **date of the report**, not the current system time.
* **Directional Context**:
    * If `targetDate` < `reportDate`: Use the suffix **"since"**.
    * If `targetDate` > `reportDate`: Use the suffix **"until"**.
* **Anniversary Logic**: Use `Calendar.current` to check if the `targetDate` month and day components match the `reportDate` components, regardless of the year.

---

## Implementation Notes
* **Formatting**: Utilize `DateComponentsFormatter` with `allowedUnits = [.year, .month, .day]` and `zeroFormattingBehavior = .dropAll` to handle the conditional omission of units.
* **SwiftData Fetching**: Use a `#Predicate` that filters for `isActive == true` OR events where the anniversary components match the report context.
* **User Guidance**: Use a `ContentUnavailableView` to prompt the user to create their first event if the list is empty.
