# EventLift - Service Marketplace App

EventLift is a comprehensive Flutter app that connects customers with service providers for event-related services. Built with Firebase backend and modern Flutter architecture.

## Features

### 🔐 Authentication
- Email/password authentication using Firebase Auth
- User role selection (Customer/Service Provider) during signup
- Secure user management with Firestore

### 🏪 Service Marketplace
- Browse available services with search and category filtering
- Service categories: Photography, Catering, Decoration, Entertainment, Transportation
- Beautiful service cards with images and pricing
- Service detail pages with booking functionality

### 📅 Booking System
- Request bookings for services with custom dates
- Special requirements and notes
- Booking status management (Pending, Accepted, Declined, Completed, Cancelled)
- Real-time updates using Firestore

### 💬 Chat System
- Real-time messaging between customers and providers
- Conversation management
- Chat history and notifications

### 👤 User Management
- Role-based navigation and features
- Profile management
- Service management for providers

## Tech Stack

- **Frontend**: Flutter 3.8+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Riverpod
- **Navigation**: Go Router
- **UI**: Material 3 Design
- **Image Handling**: Image Picker + Firebase Storage

## Project Structure

```
lib/
├── common/
│   ├── models/          # Data models
│   ├── providers/       # Riverpod providers
│   ├── utils/           # Utility classes
│   └── widgets/         # Shared widgets
├── features/
│   ├── auth/            # Authentication screens
│   ├── services/        # Service management
│   ├── bookings/        # Booking system
│   ├── chat/            # Messaging system
│   └── main/            # Main app navigation
└── main.dart            # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.8.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Firebase project

### 1. Clone the Repository
```bash
git clone <repository-url>
cd eventlift
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication, Firestore, and Storage

#### Configure Authentication
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Email/Password authentication

#### Configure Firestore
1. Go to Firestore Database
2. Create database in test mode
3. Set up security rules (see below)

#### Configure Storage
1. Go to Storage
2. Create storage bucket
3. Set up security rules (see below)

### 4. Add Firebase Configuration Files

#### Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory
3. Add it to your Xcode project

### 5. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Services can be read by anyone, written by providers
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.providerId;
    }
    
    // Bookings can be read/written by involved parties
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.customerId || 
         request.auth.uid == resource.data.providerId);
    }
    
    // Conversations and messages
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.customerId || 
         request.auth.uid == resource.data.providerId);
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          (request.auth.uid == resource.data.senderId || 
           request.auth.uid == resource.data.receiverId);
      }
    }
  }
}
```

### 6. Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profiles/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
    
    // Service images
    match /services/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 7. Run the App
```bash
flutter run
```

## Usage

### For Customers
1. Sign up as a Customer
2. Browse available services
3. Filter by category or search
4. Book services with custom requirements
5. Chat with providers
6. Manage bookings

### For Service Providers
1. Sign up as a Service Provider
2. Add your services with images and pricing
3. Manage service availability
4. Respond to booking requests
5. Chat with customers
6. Mark bookings as completed

## Customization

### Adding New Service Categories
1. Update `ServiceCategory` enum in `lib/common/models/service_model.dart`
2. Add corresponding icons and display names
3. Update UI components as needed

### Modifying UI Theme
1. Edit theme configuration in `lib/main.dart`
2. Update color schemes and typography
3. Modify component styles in respective widget files

## Troubleshooting

### Common Issues

#### Firebase Initialization Error
- Ensure Firebase configuration files are properly placed
- Check Firebase project settings
- Verify package dependencies

#### Image Upload Issues
- Check Firebase Storage rules
- Ensure proper permissions
- Verify image picker configuration

#### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart SDK versions
- Verify all dependencies are compatible

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review Firebase documentation

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the robust backend services
- Riverpod for state management
- Material Design team for the design system
