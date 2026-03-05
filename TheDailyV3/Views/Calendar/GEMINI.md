# Calendar View Instructions

## Overview
This folder contains the root user interface for **TheDailyV3**. The primary component is a custom monthly calendar that serves as the main navigation hub for the application.

## UI Requirements
* **Visual Style:** Emulate the native Apple Calendar month view (grid layout).
* **Grid Logic:** Use `LazyVGrid` to align days correctly based on the day of the week.
* **Date Selection:** Tapping a date must trigger a navigation action to the Report detail.

## Status Indicators (Color Coding)
Each date cell must react to the SwiftData state for that specific `Date`:
1.  **No Report:** Standard background (clear/default).
2.  **Draft Report:** Light Blue background (indicates report exists but `isSent == false`).
3.  **Sent Report:** Light Green background (indicates `isSent == true`).

## Navigation & Logic
* **State Detection:** For any selected date, the view must check the SwiftData `ModelContext` for an existing `DailyReport`.
* **Initialization:** * If a report exists: Open it in the detail view.
    * If no report exists: Initialize a new `DailyReport` instance for that date and then navigate to it.
* **iPad Optimization:** In the `NavigationSplitView` context, the Calendar should typically reside in the "Sidebar" or "Content" column depending on the device orientation.

## Implementation Notes for Gemini
* **Performance:** Use `@Query` with a `Predicate` to fetch only the reports for the currently visible month to ensure smooth scrolling.
* **Concurrency:** Use `.task(id: selectedMonth)` to perform any complex date calculations (like determining the number of padding days at the start of the month) off the Main Actor.
* **Modern SwiftUI:** Utilize `containerRelativeFrame` or `ViewThatFits` if necessary to ensure the grid looks professional on both iPhone and the larger iPad canvas.#  <#Title#>

