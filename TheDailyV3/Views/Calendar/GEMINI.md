# Custom Reporting Calendar

- **Overview:** A custom monthly calendar serving as the primary navigation hub. It allows users to view report history and navigate to daily reports.
- **Status:** MVP (Full CRUD via DailyReport integration)

## Functional Requirements

### Grid Generation & Navigation
- The view must display a monthly grid where each cell represents a day.
- **[Constraint]:** Tapping a date must trigger navigation to the `DailyReport` for that specific day.
- **[State Rule]:** Selection state updates must occur immediately on user interaction (e.g., via a `.simultaneousGesture` on the `NavigationLink`). Do not rely on the destination view's `.onAppear` modifier to update the parent grid's selection state, as this causes race conditions in split-view environments.
- **[Edge Case]:** If no report exists for a selected date, the system must initialize a new `DailyReport` instance before navigating.

### State Detection & Visual Cues
- Each cell must reflect the persistence state of its corresponding date.
- **[Rule]:** No Report -> Standard/Clear background.
- **[Rule]:** Draft Report (`isSent == false`) -> Light Blue background.
- **[Rule]:** Sent Report (`isSent == true`) -> Light Green background.

### Data Retrieval
- **[Constraint]:** Use SwiftData `@Query` with a `Predicate` to fetch only reports for the currently visible month to maintain performance.
- **[Architecture Rule]:** The `@Query` must be isolated in a wrapper view (e.g., `MonthQueryView`) that does not observe the `selectedDate` binding. This prevents the query from being constantly re-initialized and breaking SwiftUI's dependency graph when the user taps different days.

## UI/UX & Formatting

### Layout Structure
- **Container:** `LazyVGrid` with 7 columns.
- **Headers:** Monthly title (Month + Year) and fixed weekdays header (Sun-Sat).
- **Alignment:** Centered grid cells with consistent sizing across iPhone and iPad.

### Data Formatting
- **Status Colors:**
  - Draft: Blue (opacity 0.3)
  - Sent: Green (opacity 0.3)
- **Typography:** Primary color for current month dates; secondary color for padding dates (from previous/next months).

## Technical Architecture

- **Layout Tool:** SwiftUI `LazyVGrid`.
- **Data Model:** `DailyReport` (SwiftData).
- **Integration:** Integrated as the primary view in the `NavigationSplitView` sidebar (iPad) or as the root view of the navigation stack (iPhone).

## Future Considerations
- **Heatmap Overlay:** Visualize activity levels (counters/events) directly on the calendar grid.
- **Search Integration:** Allow the global search bar to filter dates directly on the calendar view.
