# PuzzleAlarm

An iOS alarm clock app that forces you to wake up by solving puzzles before the alarm stops. No snooze button, no escape—your brain has to engage before you can silence the alarm.

## Features

- **Math Puzzles** - Solve arithmetic problems (addition, subtraction, multiplication)
- **Memory Puzzles** - Match pairs of cards in a classic memory game
- **Pattern Puzzles** - Watch and repeat a sequence of highlighted cells
- **Three Difficulty Levels** - Easy, Medium, and Hard affect puzzle complexity
- **Repeating Alarms** - Set alarms for specific days of the week
- **Persistent Notifications** - Backup notifications ensure you wake up

## How It Works

1. Create an alarm and choose your puzzle type and difficulty
2. When the alarm triggers, a full-screen puzzle appears
3. Solve the puzzle correctly to dismiss the alarm
4. No dismiss button, no way out—your brain must wake up!

### Puzzle Details

| Puzzle | Easy | Medium | Hard |
|--------|------|--------|------|
| Math | 1 problem | 2 problems | 3 problems |
| Memory | 3 pairs (6 cards) | 5 pairs (10 cards) | 8 pairs (16 cards) |
| Pattern | 4-step sequence | 6-step sequence | 8-step sequence |

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nlashinsky/PuzzleAlarm.git
   ```

2. Open `PuzzleAlarm.xcodeproj` in Xcode

3. Select your target device or simulator

4. Build and run (⌘R)

### Required Capabilities

In Xcode, ensure these are enabled under **Signing & Capabilities**:
- **Background Modes**: Audio, AirPlay, and Picture in Picture
- **Push Notifications** (for Time Sensitive alerts)

## Project Structure

```
PuzzleAlarm/
├── App/
│   ├── PuzzleAlarmApp.swift      # App entry point
│   └── AppDelegate.swift          # Notification handling
├── Core/
│   ├── Audio/
│   │   └── AudioManager.swift     # Alarm sound playback
│   ├── Notifications/
│   │   └── NotificationManager.swift
│   └── Persistence/
│       └── AlarmStore.swift       # UserDefaults storage
├── Features/
│   ├── AlarmList/                 # Main alarm list screen
│   ├── AlarmEditor/               # Create/edit alarms
│   ├── ActiveAlarm/               # Full-screen alarm + puzzle
│   └── Puzzles/
│       ├── MathPuzzle/
│       ├── MemoryPuzzle/
│       └── PatternPuzzle/
└── Models/
    ├── Alarm.swift
    └── Difficulty.swift
```

## iOS Limitations

Third-party apps cannot fully replicate Apple's Clock app due to iOS restrictions:

- Notification sounds are limited to 30 seconds
- Users can always dismiss notifications or force-quit apps
- No true background alarm capability without system privileges

**Workaround**: The app uses a silent audio loop to stay alive in the background, similar to apps like Alarmy. For best results:
- Don't force-quit the app
- Keep notifications enabled
- Grant all requested permissions

## Tech Stack

- **SwiftUI** with iOS 17+ features
- **@Observable** macro for state management
- **MVVM** architecture
- **UserDefaults** for persistence
- **AVAudioSession** for background audio
- **UNUserNotificationCenter** for local notifications

## License

MIT License - feel free to use this code for your own projects.
