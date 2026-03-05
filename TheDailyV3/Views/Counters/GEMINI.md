# Counters Editor & Selector Instructions

## Overview
This folder manages the lifecycle of **Counters**. These are persistent entities that track numerical changes over time. Unlike simple integers, these track a history of "Events" to ensure date-accuracy for reporting.

## Data Structure Requirements
* **Counter Entity:**
    * `name`: String (User-defined).
    * `history`: [CounterIncrement] (Relationship to individual change events).
    * **Computed Property:** `reportLine` -> Returns a String formatted as `"[name]: [count]"` (e.g., "Espresso: 3").
* **CounterIncrement Entity:**
    * `value`: Int (The amount added/subtracted, e.g., +1 or -1).
    * `timestamp`: Date (The exact moment the user tapped the button).

## UI & User Interaction
* **Creation Flow:**
    * When creating a new counter, the user **must** be prompted for a "Starting Value."
    * Use a `TextField` with a numeric keyboard and a default value of `0`.
* **The Editor Interface:**
    * Provide a +/- interface for each counter.
    * Support negative values (counters are not restricted to positive integers).
* **Selection for Report:**
    * Users must be able to toggle which counters are "active" for the current `DailyReport`.
    * **Logic:** When generating the `counterSummaries` for a report, only include increments where the `CounterIncrement.timestamp` matches the `DailyReport.timestamp` (Day/Month/Year).

## Logic & Concurrency
* **Date Matching:** Use `Calendar.current.isDate(_:inSameDayAs:)` to filter counter history for the relevant report day.
* **Explanation (For Gemini):** * Explain how to use SwiftData's `#Predicate` to fetch only the increments relevant to a specific 24-hour window.
    * Discuss the use of `@MainActor` for the increment functions to ensure the UI updates the "Count" label immediately.

## Implementation Notes
* Use `HStack` with `Button` components for the +/- controls.
* Use a `ContentUnavailableView` if no counters have been created yet to guide the user to the "Add" button.
