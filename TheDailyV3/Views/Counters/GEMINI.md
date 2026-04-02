# Counters Editor & Selector Instructions

## Overview
This folder manages the lifecycle of **Counters**. These are persistent entities that track numerical changes over time. Unlike simple integers, these track a history of "Events" to ensure date-accuracy for reporting.

## Data Structure Requirements
* **Counter Entity:**
    * `name`: String (User-defined).
    * `history`: [CounterIncrement] (Relationship to individual change events).
    * **Computed Property:** `reportLine` -> Returns a String formatted as `"[name]: [count]"` (e.g., "Espresso: 3")
        - **Feature Change:** `[count]` should reflect the cumulative value of all increments up to the selected report's date.
* **CounterIncrement Entity:**
    * `value`: Int (The amount added/subtracted, e.g., +1 or -1).
    * `timestamp`: Date (The exact moment the user tapped the button or start-of-day for initial values).

## UI & User Interaction
* **Creation Flow:**
    * When creating a new counter, the user **must** be prompted for a "Starting Value."
    * Use a `TextField` with a numeric keyboard and a default value of `0`.
    * **Rule:** If the starting value is non-zero, it must be saved as a `CounterIncrement`. The `timestamp` for this initial increment MUST be set to the **start of the currently selected report's day**.
* **The Editor Interface:**
    * Provide a +/- interface for each counter.
    * **Feature Change (Daily Increment):** The center label between the +/- buttons must show the **daily increment** (e.g., +2 or -1) for the currently selected report's day. Tapping the buttons immediately updates this daily total.
    * **Feature Change (Cumulative Display):** The **cumulative value to date** must be displayed underneath the counter's name. "To date" refers strictly to all activity up to the end of the day of the selected report.
    * **Feature Change (Reset to Zero):** Users must be able to swipe right-to-left on a counter row to reveal a "Zero" (Reset) action. This automatically injects a neutralizing `CounterIncrement` (timestamped to the report's date) to force the cumulative total to `0`.
    * Support negative values (counters are not restricted to positive integers).
* **Selection for Report:**
    * Users must be able to toggle which counters are "active" for the current `DailyReport`.
    * **Logic (Persistence):** Counters show the **cumulative total** of all increments up to the end of the report's date. This ensures the value persists from day to day until manually adjusted.

## History & Visualization
* **Counter Detail View:**
    * Tapping a counter's name in the list navigates to a detailed view.
    * **Graph:** Displays a dual-axis chart (using SwiftUI Charts):
        * **Left Y-Axis (Bar Chart):** Shows the incremental change (daily totals) on any given day.
        * **Right Y-Axis (Line Chart):** Shows the cumulative total over time.
    * **Data Grain:** History is grouped by day to show progress trends.

## Logic & Concurrency
* **Date Matching:** Use a cumulative filter (e.g., `timestamp <= reportDate`) to calculate the current value for any given report.
* **Explanation (For Gemini):** 
    * Explain how to use `reduce` on the filtered history to calculate the running total.
    * Discuss the use of `Charts` for time-series visualization.

## Implementation Notes
* Use `HStack` with `Button` components for the +/- controls.
* Use a `ContentUnavailableView` if no counters have been created yet to guide the user to the "Add" button.
