# Instructions for Gemini CLI: Media Selection (Local File Storage)

## Objective
Implement media selection for **TheDailyV3** by saving files to the local file system and storing only the reference filename in SwiftData.

## Requirements

### 1. Data Model Update (`Report.swift`)
- Add `var mediaFilename: String?` (stores the UUID-based filename).
- Add `var mediaType: String?` (e.g., "image" or "video").
- **Remove** any previous `mediaData` blobs to keep the database lightweight.

### 2. File Manager Helper (`MediaStorageService.swift`)
- Create a service to handle I/O operations:
    - **Save Function:** Takes `Data`, generates a `UUID().uuidString`, saves it to the `Documents` directory, and returns the filename.
    - **Load Function:** Takes a filename and returns the `URL` for the file in the `Documents` directory.
    - **Delete Function:** Removes the file from the disk when a report is deleted.

### 3. Media Picker Logic (`ReportDetailView.swift`)
- Use `PhotosPicker` to select media.
- **Processing Flow:**
    1. Extract `Data` from `PhotosPickerItem`.
    2. Pass `Data` to `MediaStorageService.save()`.
    3. Save the resulting filename string to the `Report` model.

### 4. UI Integration
- Use `AsyncImage` or `Image(uiImage:)` to display images via the local file URL.
- Use `VideoPlayer(url:)` for videos, fetching the URL from the storage service using the saved filename.
- Ensure that deleting a `Report` or removing media triggers the `Delete Function` to prevent "ghost" files from taking up phone storage.

## Execution Strategy
- Ensure the `Documents` directory path is constructed dynamically (never hardcode the full path, as the App Container ID changes on updates).
- Implement `onDelete` logic in the View or Model to clean up orphaned files.#  <#Title#>

