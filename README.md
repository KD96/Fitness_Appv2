# Fitness App MVP

A minimal viable product (MVP) for an iOS fitness app that allows users to track workouts, earn crypto tokens, and engage with a social activity feed.

## Features

### 1. Fitness Tracking
- Log and track various types of workouts (running, walking, cycling, swimming, etc.)
- Record workout duration, calories burned, and notes
- View workout history and details

### 2. Token Rewards
- Earn crypto tokens (FTNS) for completing workouts
- Basic token calculation (1 token per 10 minutes of activity)
- Track token balance and recent earnings

### 3. Social Features
- View friend profiles
- Activity feed showing friends' workouts
- Share your workout accomplishments

## Technical Details

This MVP is built with:
- SwiftUI for the user interface
- UserDefaults for basic data persistence (would be replaced with a more robust solution in production)
- MVVM architecture with ObservableObject for state management

## Future Enhancements

Potential future enhancements beyond this MVP:
- HealthKit integration for more accurate workout tracking
- Blockchain integration for token transactions
- Achievements and challenges
- Robust user authentication
- Cloud sync with Firebase or other backend
- Activity sharing to external social networks

## Installation

1. Clone the repository
2. Open the Xcode project
3. Build and run on a simulator or device running iOS 14.0+ 