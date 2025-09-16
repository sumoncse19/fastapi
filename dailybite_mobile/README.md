# DailyBite Mobile App

A Flutter mobile application for tracking calories through AI-powered food photo analysis. This app works with the DailyBite FastAPI backend to provide a seamless food tracking experience.

## Features

### ✅ Completed Features

- **Authentication System**

  - User registration and login
  - JWT token-based authentication
  - Secure token storage with flutter_secure_storage
  - Auto-login on app restart

- **Camera Integration**

  - Take photos directly from camera
  - Select photos from gallery
  - Camera switching (front/back)
  - Photo preview before analysis

- **AI Food Analysis**

  - Upload photos to backend for AI analysis
  - Mock AI service integration for development
  - Automatic calorie estimation
  - Food name recognition

- **Meal Tracking**

  - View daily meal history
  - Edit meal details (name, calories, notes)
  - Delete meals
  - Real-time calorie tracking

- **Dashboard**

  - Daily calorie progress visualization
  - Calorie goal tracking with progress bar
  - Meal count and remaining calories
  - Goal achievement indicators

- **State Management**
  - Riverpod for robust state management
  - Reactive UI updates
  - Error handling and loading states

## Architecture

### Project Structure

```
lib/
├── core/
│   ├── constants/         # App constants and configuration
│   ├── services/          # API services and HTTP client
│   └── theme/            # Material 3 theme configuration
├── features/
│   ├── auth/             # Authentication feature
│   │   ├── providers/    # Auth state management
│   │   └── screens/      # Login/Register screens
│   ├── meals/            # Meal tracking feature
│   │   ├── providers/    # Meal state management
│   │   ├── screens/      # Dashboard, Camera screens
│   │   └── widgets/      # Reusable meal components
│   └── shared/
│       └── models/       # Shared data models
└── main.dart            # App entry point
```

### Key Technologies

- **Flutter 3.x** - Cross-platform mobile framework
- **Riverpod** - State management solution
- **Dio** - HTTP client for API communication
- **Camera Plugin** - Native camera integration
- **Image Picker** - Gallery photo selection
- **Flutter Secure Storage** - Secure token storage
- **Material 3** - Modern UI design system

## API Integration

The app communicates with the DailyBite FastAPI backend through:

- **Authentication Endpoints**

  - `POST /auth/register` - User registration
  - `POST /auth/token` - User login (OAuth2 form)
  - `GET /auth/me` - Get current user profile
  - `PUT /auth/profile` - Update user profile

- **Meal Endpoints**
  - `POST /meals/analyze-photo` - Upload and analyze meal photos
  - `GET /meals/` - Get user's meals (with date filtering)
  - `GET /meals/daily-summary/{date}` - Get daily calorie summary
  - `PUT /meals/{meal_id}` - Update meal details
  - `DELETE /meals/{meal_id}` - Delete meal

## Configuration

### Environment Variables

Update `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String appName = 'DailyBite';
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String baseUrl = 'https://your-api-domain.com'; // Production
}
```

### Backend URL Configuration

- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: Use your computer's IP address
- **Production**: Your deployed API URL

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK
- Android Studio / Xcode for device testing
- DailyBite FastAPI backend running

### Installation

1. **Install Dependencies**

   ```bash
   cd dailybite_mobile
   flutter pub get
   ```

2. **Configure Backend URL**

   - Update `lib/core/constants/app_constants.dart` with your backend URL

3. **Run the App**
   ```bash
   flutter run
   ```

### Testing on Devices

#### Android

```bash
flutter run -d android
```

#### iOS

```bash
flutter run -d ios
```

## Key Features Walkthrough

### 1. Authentication Flow

- Users register with email, password, and full name
- JWT tokens are stored securely and auto-refresh
- Seamless login persistence across app restarts

### 2. Photo Capture & Analysis

- High-quality camera integration with preview
- Gallery selection as alternative
- Real-time photo analysis with loading states
- Error handling for network issues

### 3. Daily Dashboard

- Visual progress tracking with Material 3 design
- Calorie goal management with progress indicators
- Meal history with edit/delete functionality
- Empty state guidance for new users

### 4. State Management

- Reactive state updates using Riverpod
- Centralized error handling and user feedback
- Optimistic UI updates for better UX

## Development Status

### ✅ Completed

- Full authentication system
- Camera and photo handling
- API integration with backend
- State management with Riverpod
- UI components and screens
- Error handling and loading states

### 🚧 Future Enhancements

- Meal history screen with date filtering
- Weekly/monthly calorie analytics
- Food database search and manual entry
- Nutrition information beyond calories
- Social features and meal sharing
- Offline mode and data caching
- Push notifications for meal reminders

## Testing

### Manual Testing Checklist

- [ ] User registration and login
- [ ] Camera photo capture
- [ ] Gallery photo selection
- [ ] Photo analysis and meal creation
- [ ] Meal editing and deletion
- [ ] Daily progress tracking
- [ ] App restart authentication persistence

### Backend Connectivity

Ensure the FastAPI backend is running and accessible from your device/emulator.

## Troubleshooting

### Common Issues

1. **Network Connection Issues**

   - Verify backend URL in app_constants.dart
   - Ensure backend is running and accessible
   - Check device/emulator network connectivity

2. **Camera Permission Issues**

   - Grant camera permissions when prompted
   - Check device camera functionality

3. **Build Issues**
   - Run `flutter clean && flutter pub get`
   - Ensure Flutter and Dart SDKs are up to date

## Contributing

1. Follow Flutter best practices and conventions
2. Use Riverpod for state management
3. Implement proper error handling
4. Add loading states for async operations
5. Follow Material 3 design guidelines

## License

This project is part of the DailyBite food tracking application suite.
