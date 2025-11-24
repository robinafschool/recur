# Recur - Flutter Frontend

A minimalist journal, habit tracker, and productivity app built with Flutter.

## Project Structure

```
lib/
├── config/
│   └── app_theme.dart          # Centralized theme configuration
├── screens/
│   ├── login_screen.dart       # Login and authentication
│   ├── habits_screen.dart      # Habit checklist (main screen after login)
│   ├── journal_list_screen.dart # List of journal entries
│   ├── journal_entry_screen.dart # Create/edit journal entries
│   ├── ai_schedule_screen.dart # AI-powered habit scheduling
│   ├── analytics_screen.dart   # Analytics and trends visualization
│   ├── focus_screen.dart       # Focus mode with timer and app blocking
│   └── settings_screen.dart    # User settings and preferences
├── widgets/
│   └── bottom_nav_bar.dart     # Reusable bottom navigation bar
└── main.dart                   # App entry point with routing
```

## Theme Customization

All colors, spacing, text styles, and other design elements are centralized in `lib/config/app_theme.dart`. This makes it easy to modify the entire app's appearance by changing values in one place.

### Key Theme Elements

**Colors:**
- `backgroundColor` - Main background color (#1A1A1A)
- `surfaceColor` - Surface/card color (#2A2A2A)
- `primaryColor` - Primary accent color (#4A9EFF)
- `textPrimary` - Primary text color (white)
- `textSecondary` - Secondary text color (#888888)
- `borderColor` - Border color (white)
- `activeGreen` - Active state color (#2D5A2D)
- `errorColor` - Error/danger color (#FF4444)

**Spacing:**
- Consistent spacing values from 4px to 60px
- Access via `AppTheme.spacing20`, `AppTheme.spacing30`, etc.

**Border Radius:**
- `radiusSmall` - 4px
- `radiusMedium` - 8px
- `radiusLarge` - 13px
- `radiusCircular` - 50%

**Text Styles:**
- `AppTheme.logo` - Large logo text
- `AppTheme.heading1` - Main headings
- `AppTheme.heading2` - Subheadings
- `AppTheme.body` - Body text
- `AppTheme.bodySecondary` - Secondary body text
- `AppTheme.caption` - Small text
- `AppTheme.buttonText` - Button labels

### Example: Changing the Theme

To change the color scheme, edit values in `lib/config/app_theme.dart`:

```dart
// Change primary color from blue to purple
static const Color primaryColor = Color(0xFF9D4EDD);

// Change background to lighter shade
static const Color backgroundColor = Color(0xFF2A2A2A);

// Adjust spacing throughout the app
static const double spacing20 = 24.0; // Increase default spacing
```

## Navigation

The app uses named routes defined in `main.dart`:

- `/login` - Login screen (initial route)
- `/habits` - Habits screen (home after login)
- `/journal-list` - Journal entries list
- `/journal-entry` - New/edit journal entry
- `/ai-schedule` - AI schedule & suggestions
- `/analytics` - Analytics dashboard
- `/focus` - Focus mode
- `/settings` - Settings

## Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Features Implemented

### Login Screen
- Email/password authentication
- Google SSO button
- Sign up link

### Habits Screen
- Interactive habit checklist
- Checkboxes with completion tracking
- Create new habit button
- Settings navigation

### Journal List Screen
- List of journal entries with previews
- Entry metadata (date, time, tags)
- Navigation to analytics
- Tap to view/edit entries

### Journal Entry Screen
- Large text area for freeform writing
- Auto-save functionality
- Placeholder text with AI habit detection hint

### AI Schedule Screen
- Today's scheduled tasks
- Habit reminders
- AI suggestions with reasoning
- Complete/skip actions

### Analytics Screen
- Time filter (All Time, This Month, This Week, Custom)
- Statistics cards (streaks, completion rates)
- Chart placeholders for visualizations
- Current streaks list

### Focus Screen
- Pomodoro-style timer (25:00)
- Play/pause/stop controls
- Blocked apps management
- Today's focus sessions log

### Settings Screen
- User account info
- Notification preferences
- Privacy settings (data export, delete account)
- Appearance options
- About section (version, terms, privacy policy)
- Sign out button

## Design Principles

1. **Minimalist** - Clean, uncluttered interface with focus on content
2. **Dark Theme** - Easy on the eyes, modern aesthetic
3. **Consistent Spacing** - Regular padding and margins throughout
4. **Border-Based Design** - Clear visual separation without heavy shadows
5. **Accessible Navigation** - Bottom nav bar for primary screens
6. **Responsive** - Works on mobile, tablet, and desktop

## Next Steps

1. **Backend Integration** - Connect to Supabase for data persistence
2. **Authentication** - Implement actual login/signup with Supabase Auth
3. **Charts** - Add data visualization library for analytics
4. **State Management** - Implement Riverpod or Bloc for complex state
5. **Offline Support** - Add local storage with Hive/SQLite
6. **AI Integration** - Connect to Mistral AI for habit parsing
7. **Notifications** - Set up FCM for reminders
8. **Testing** - Add unit and widget tests

