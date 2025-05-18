# Flutter Web App - Office Space Booker (Concept)

This is a Flutter-based web application designed to demonstrate routing with `go_router`, a persistent bottom navigation bar, and basic UI for managing locations and viewing available desks.

## Features

*   **Bottom Navigation Bar:** Persistent navigation for Home, Locations, and Settings sections.
*   **Routing with `go_router`:**
    *   URL-based navigation.
    *   `ShellRoute` for the main application layout with the bottom navigation bar.
    *   Path parameters for dynamic content (e.g., displaying a single location's details).
*   **Home Screen:** A dashboard view with static summary widgets (e.g., total locations, active users, system health, recent activities).
*   **Locations Screen:**
    *   Displays a scrollable list of office locations.
    *   Each list item is tappable to view location details.
*   **Single Location Screen:**
    *   Displays details for a specific location.
    *   Includes an interactive calendar (`table_calendar`) to select a date.
    *   Shows a list of (dummy) available desks for the selected date at that location.
*   **Settings Screen:** A placeholder screen for future application settings.
*   **Generic API Service:** A basic `ApiService` class for making GET and POST requests, designed for future integration with a backend.

## Project Structure (Key `lib` Directory)


## Key Design Choices & Architecture

### 1. Navigation (`go_router`)

*   **Centralized Routing:** All routes are defined in `router.dart` using `GoRouter`.
*   **`ShellRoute` for Persistent UI:** The `MainShell` widget (containing the `Scaffold` with `BottomNavigationBar`) is used as the builder for a `ShellRoute`. Child routes of this `ShellRoute` are rendered within the `MainShell`'s body. This ensures the bottom navigation bar remains visible across the main sections of the app.
*   **Route Synchronization:** The `MainShell` widget uses `GoRouterState.of(context).uri` to determine the currently active route and update the `currentIndex` of the `BottomNavigationBar`, ensuring it stays in sync even with browser back/forward navigation.
*   **Path Parameters:** Used for detail screens, e.g., `/locations/:locationId`, allowing specific data to be fetched or displayed based on the ID in the URL.
*   **Navigator Keys:**
    *   `_rootNavigatorKey`: For routes that should appear *above* the shell (e.g., a full-screen dialog, not currently used extensively).
    *   `_shellNavigatorKey`: For routes that should appear *within* the `MainShell`.

### 2. UI Structure

*   **`MainShell` (`widgets/main_shell.dart`):**
    *   Acts as the main scaffold for the application's core sections.
    *   Contains the `BottomNavigationBar`.
    *   Renders the `child` widget passed by the `ShellRoute`, which corresponds to the currently active screen.
*   **Screens (`screens/`):**
    *   Each top-level navigable item in the bottom bar has a corresponding screen widget (e.g., `HomeScreen`, `LocationsScreen`).
    *   Screens are generally `StatelessWidget` or `StatefulWidget` depending on their need to manage local UI state.
*   **Reusable Widgets (`widgets/`):**
    *   Components like `DashboardCard` are created to promote code reuse and maintainability, especially on the `HomeScreen`.

### 3. Data Flow & State Management

*   **Dummy Data:** Currently, sample data (locations, desks, availability) is generated statically within `router.dart` (`_generateSampleLocations`). This data is passed to the relevant screens via their constructors when routes are built.
    *   `LocationsScreen` receives the list of all locations.
    *   `SingleLocationScreen` receives a specific `LocationItem` object.
*   **Local Screen State:** `StatefulWidget` is used for managing UI state within individual screens (e.g., `_selectedDay` and `_availableDesksForSelectedDay` in `SingleLocationScreen`).
*   **No Global State Management (Yet):** For this demonstration, a dedicated global state management solution (like Provider, Riverpod, BLoC) has not been implemented. For a production app, this would be a crucial addition for managing shared application state, user authentication, and data fetched from an API.

### 4. API Interaction

*   **`ApiService` (`services/api_service.dart`):**
    *   A generic service built using the `http` package.
    *   Provides methods for `get()` and `post()` requests.
    *   Includes basic error handling, JSON decoding, and a custom `ApiException`.
    *   It is designed to be instantiated with a `baseUrl` and used for communicating with a backend.
    *   **Current Status:** This service is defined but **not yet fully integrated** to fetch dynamic data for the UI. The UI currently relies on the dummy data from `router.dart`.

### 5. Key Packages Used

*   **`go_router`:** For declarative routing.
*   **`table_calendar`:** For displaying an interactive calendar on the `SingleLocationScreen`.
*   **`http`:** For making HTTP requests in the `ApiService`.

## Running the Application

1.  Ensure you have Flutter SDK installed and web support enabled (`flutter config --enable-web`).
2.  Clone the repository (if applicable) or ensure all files are in place.
3.  Open your terminal in the project's root directory.
4.  Run `flutter pub get` to fetch dependencies.
5.  Run the application on a web browser: `flutter run -d chrome` (or your preferred browser).

## Potential Future Enhancements

*   **Backend Integration:** Connect the `ApiService` to a real backend to fetch and persist data (locations, desks, bookings, user settings).
*   **State Management:** Implement a robust state management solution (e.g., Riverpod, Provider, BLoC) for managing application-wide state, user authentication, and API data.
*   **User Authentication:** Add login/registration functionality.
*   **Desk Booking:** Implement the actual logic for booking a desk.
*   **User Settings Persistence:** Use `shared_preferences` or `flutter_secure_storage` to save user settings.
*   **Improved UI/UX:** Refine styling, add animations, and improve responsiveness.
*   **Testing:** Add unit, widget, and integration tests.
*   **Error Handling:** More comprehensive error display to the user.