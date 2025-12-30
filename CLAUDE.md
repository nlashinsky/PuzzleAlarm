# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project. Open `PuzzleAlarm.xcodeproj` and use:
- **Build & Run**: ⌘R
- **Build only**: ⌘B
- **Run tests**: ⌘U

No command-line build tools (SPM, xcodebuild) are configured.

## Required Xcode Capabilities

Under **Signing & Capabilities**, enable:
- Background Modes: "Audio, AirPlay, and Picture in Picture"
- Push Notifications

## Architecture

**SwiftUI + MVVM with iOS 17+ @Observable macro**

### App Lifecycle
`PuzzleAlarmApp` is the entry point. It:
- Injects three environment objects: `AlarmStore`, `NotificationManager`, `AudioManager`
- Listens for `.alarmTriggered` notifications to display `ActiveAlarmView` as a full-screen overlay
- Schedules all enabled alarms on launch

### Data Flow
1. `Alarm` model defines alarm properties including `PuzzleType` and `Difficulty`
2. `AlarmStore` persists alarms to UserDefaults and provides CRUD operations
3. `NotificationManager` schedules local notifications with backup notifications every 30 seconds
4. When notification fires → `AppDelegate` posts `.alarmTriggered` → `ContentView` shows `ActiveAlarmView`
5. User solves puzzle → `onComplete` callback dismisses the alarm

### Puzzle System
- `AnyPuzzleView` routes `PuzzleType` to concrete puzzle views (Math, Memory, Pattern)
- Each puzzle has a ViewModel (`@Observable`) and View pair
- `Difficulty` enum controls puzzle complexity via computed properties (`mathProblemsRequired`, `memoryPairs`, `patternLength`)
- `PuzzleType.random` randomly selects one of the three puzzle types

### Background Audio Workaround
iOS kills background apps. `AudioManager.startBackgroundAudio()` plays a silent audio loop to keep the app alive (requires a `silence.caf` file in bundle).

## Key Types

| Type | Purpose |
|------|---------|
| `Alarm` | Core model with time, repeat days, puzzle config |
| `Weekday` | Maps to Calendar weekday integers (Sunday=1) |
| `PuzzleType` | Enum: math, memory, pattern, random |
| `Difficulty` | Enum: easy, medium, hard with puzzle-specific values |
