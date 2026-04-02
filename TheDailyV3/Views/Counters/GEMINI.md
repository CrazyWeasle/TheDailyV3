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
## Selection for Report:
    * Users must be able to toggle which counters are "active" for the current `DailyReport`.
    * **Logic (Persistence):** Counters show the **cumulative total** of all increments up to the end of the report's date. This ensures the value persists from day to day until manually adjusted.

## History & Visualization
* **Counter Detail View:**
    * Tapping a counter's name in the list navigates to a detailed view.
    * **Graph:** Displays a `LineChart` (using SwiftUI Charts) showing the cumulative total over time.
    * **Data Grain:** History is grouped by day to show progress trends.

## Logic & Concurrency
* **Date Matching:** Use a cumulative filter (e.g., `timestamp <= reportDate`) to calculate the current value for any given report.
* **Explanation (For Gemini):** 
    * Explain how to use `reduce` on the filtered history to calculate the running total.
    * Discuss the use of `Charts` for time-series visualization.

## Implementation Notes
* Use `HStack` with `Button` components for the +/- controls.
* Use a `ContentUnavailableView` if no counters have been created yet to guide the user to the "Add" button.
