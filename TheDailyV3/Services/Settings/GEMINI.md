# Instructions for Gemini CLI: Settings View Implementation

## Objective
Implement a SwiftData-backed Settings View for **TheDailyV3** to manage a list of report contacts. The system must support a single "default" recipient that persists across devices via CloudKit.

## Requirements

### 1. Data Model (`Contact.swift`)
- Create a SwiftData model named `Contact`.
- **Properties:**
    - `name: String`
    - `phoneNumber: String`
    - `isDefault: Bool`
- **Logic:** The model must be compatible with CloudKit (ensure all properties are optional or have default values).

### 2. View Logic (`SettingsView.swift`)
- **Query:** Use `@Query` to fetch all contacts sorted by name.
- **List Display:** Show each contact's name and phone number.
- **Selection State:** - Display a `checkmark.circle.fill` next to the contact where `isDefault` is true.
    - When a user taps a contact, set its `isDefault` to `true` and set all other contacts to `false`.
- **Initialization Logic:** - When adding the first contact to an empty list, automatically set its `isDefault` property to `true`.
- **Persistence:** Ensure all changes are saved to the `modelContext`.

### 3. User Interface
- Use a `NavigationStack` with a `List`.
- Provide an "Add Contact" button that opens a sheet.
- Include a `Form` in the sheet for `name` and `phoneNumber` input.
- Enable swipe-to-delete functionality for the contact list.

### 4. App Integration
- Update the main `App` struct to include `Contact.self` in the `.modelContainer`.

## Implementation Strategy
- Scan the existing codebase for the `TheDailyV3App.swift` or equivalent entry point.
- Create necessary files in the `Models` and `Views` directories respectively.
- Ensure SwiftUI previews are included for the new `SettingsView`.
