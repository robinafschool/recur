# Core specification
**Name**: Recur
**Genre**: Journal, habit tracker and productivity app

## Problem and solution
**Problem**: Journaling is unstructured and even though it's a goldmine of data, it's hard to use it for anything other than a diary.
**Solution**: Recur is a journal app with structured data that allows you to track your habits and goals using checklists and inputs, while also allowing you to write freeform entries, that are stored in a structured way.

## Target audience
People who want to not only track their habits and goals, but also use the data for historical analysis of how they've changed over time.
- Want to be ahead of others
- Want to be more productive, less distracted

# Features specification
## Main features
- User registration and login (email, Google SSO)
- Journal entries (structured and freeform inputs in one place)
- Defining habits (structured checklist)
- Parsing into structured data
- Displaying historical data

## Additional features
- Blocking distractions
- Non-interactive AI agent - schedule actions based on the journal entries

# Technical specification
## Backend
- **Database**: Supabase
- **Backend functionality**: Supabase Edge Functions
- **LLM provider**: Mistral AI

## Frontend

- **Framework**: Flutter (cross-platform for iOS, Android, Web, desktop)
- **State management**: Riverpod (or alternatively Bloc for complex business logic separation)
- **UI Library**: Flutter Material / Cupertino widgets
- **Authentication UI**: flutter_supabase for sign in/out (including Google SSO)
- **Networking/API**: Supabase client for Flutter (for database, auth, and storage)
- **Notifications**: Integration with Firebase Cloud Messaging (FCM) or local_notifications for habit reminders and daily prompts

## Additional integrations

- **Offline support**: Hive or local SQLite (for journaling offline or caching historical data)
- **Parsing/Visualization**: Packages for data visualization (e.g., charts_flutter) to present historical trends


## Frontend responsibilities

- Secure authentication (email, Google)
- Entry forms for journaling (structured & freeform)
- Habit/goal checklists and input tracking
- Structured parsing of inputs (display and possibly editing)
- Historical data visualizations (charts, streaks, progress)
- Distraction blocking UI (timers, blockers, focus sessions)
- AI agent suggestions & scheduling (displayed non-interactively or as notifications)
- Settings, account management, and onboarding screens

## Wireframes
- Login screen
- Journal entry screen (structured inputs for habits/goals)
- Habit/goal checklist screen
- Historical data visualization screen
- Distraction blocking screen
- AI-scheduled actions screen
- Settings screen