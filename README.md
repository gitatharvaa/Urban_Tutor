<div align="center">

<h1>🎓 URBAN TUTOR</h1>
<h3>On-Demand Home Tutoring Platform — Flutter × Firebase × Google Maps</h3>

<br/>

[

<br/>









<br/>

> **2 user roles · Real-time location tracking · Cloudinary media uploads · Firebase Auth + Firestore**

</div>

***

## 🎓 What Is This?

A full-stack mobile application that connects students with local home tutors — built entirely with Flutter and Firebase.

**Problem 1** — Finding a qualified local tutor is fragmented and offline. Parents have no reliable way to discover, verify, and book tutors near them.

**Problem 2** — Tutors have no professional platform to showcase their qualifications, manage sessions, and reach students in their area.

**Solution** — A dual-role mobile app where students can discover nearby tutors on an interactive map, view profiles with uploaded credentials, and request sessions — while tutors can manage their availability, upload notes/media via Cloudinary, and handle bookings in real time.

***

## 📱 App Screenshots

<div align="center">

| Home Screen | Tutor Map View |
|:---:|:---:|
|  |  |

| Tutor Profile | Student Dashboard |
|:---:|:---:|
|  |  |

</div>

***

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     USER LAYER                              │
│         Student App  ·  Tutor App  (same Flutter codebase) │
│              Role-based UI via Firebase Auth                │
└──────────────────────┬──────────────────────────────────────┘
                       │ Flutter (Dart)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   FLUTTER APP LAYER                         │
│                                                             │
│  State Management: Provider                                 │
│  Navigation: Named Routes                                   │
│  Local Storage: flutter_dotenv (.env)                       │
│  Location: Geolocator + Geocoding                           │
│  Maps: google_maps_flutter (Maps SDK for Android)           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND SERVICES                          │
│                                                             │
│  Firebase Auth       → Email/password authentication        │
│  Cloud Firestore     → User profiles, sessions, notes       │
│  Firebase Storage    → Profile photos                       │
│  Cloudinary          → Notes, documents, media uploads      │
│  Google Maps SDK     → Interactive tutor location map       │
│  Geolocator          → Real-time GPS coordinates            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  PLATFORM                                   │
│  Android (compileSdk 36 · targetSdk 36 · Kotlin 2.3.0)     │
│  Gradle 8.11.1 · Java 17 · Impeller Rendering (Vulkan)     │
└─────────────────────────────────────────────────────────────┘
```

***

## ✨ Key Features

### 👨‍🎓 Student Side
- **Tutor Discovery Map** — Browse nearby tutors on a Google Maps view with real-time location markers
- **Tutor Profiles** — View qualifications, subjects, ratings, and uploaded credentials
- **Session Requests** — Send, track, and manage tutoring session bookings
- **Notes Access** — Download/view notes and study material shared by tutors via Cloudinary

### 👨‍🏫 Tutor Side
- **Profile Management** — Upload profile photo, qualifications, subjects taught, and availability
- **Notes Upload** — Share notes and documents with students using Cloudinary media pipeline
- **Session Management** — Accept or decline student session requests
- **Location Visibility** — Appear on the student map based on GPS coordinates

### 🔐 Auth & Core
- Firebase Email/Password authentication with role selection at signup
- Role-based routing — Students and Tutors see entirely different home screens
- `.env`-based API key management (Cloudinary, Google Maps) via `flutter_dotenv`
- Foreground geolocator service with persistent location binding

***

## 🛠️ Tech Stack

```
┌─────────────────────┬──────────────────────────────────────────┐
│ Layer               │ Technologies                             │
├─────────────────────┼──────────────────────────────────────────┤
│ Mobile Framework    │ Flutter 3.x · Dart                       │
│ State Management    │ Provider                                  │
│ Authentication      │ Firebase Auth (Email/Password)           │
│ Database            │ Cloud Firestore                          │
│ File Storage        │ Firebase Storage · Cloudinary            │
│ Maps & Location     │ google_maps_flutter · Geolocator         │
│ Geocoding           │ geocoding (reverse + forward)            │
│ Media Upload        │ Cloudinary Flutter SDK                   │
│ Environment Config  │ flutter_dotenv                           │
│ Build System        │ Gradle 8.11.1 · Kotlin 2.3.0            │
│ Java Compatibility  │ Java 17 (sourceCompatibility)           │
│ Android SDK         │ compileSdk 36 · targetSdk 36            │
│ Rendering           │ Impeller (Vulkan)                        │
└─────────────────────┴──────────────────────────────────────────┘
```

***

## 🔑 Key Technical Decisions

**Why Provider over Riverpod/Bloc?**
Urban Tutor has a straightforward unidirectional data flow — user auth state → role routing → screen-level data. Provider's `ChangeNotifier` pattern is sufficient and avoids unnecessary boilerplate for a project of this scope.

**Why Cloudinary alongside Firebase Storage?**
Firebase Storage handles profile photos (small, user-scoped files). Cloudinary handles notes and documents — its free tier provides transformations, CDN delivery, and format conversion that Firebase Storage doesn't offer natively, making it better suited for educational content distribution.

**Why `local.properties` for the Maps API key?**
Hardcoding the Google Maps API key in `AndroidManifest.xml` would expose it in version control. The `local.properties` → `manifestPlaceholders["mapsApiKey"]` → `${mapsApiKey}` pattern keeps secrets out of Git entirely, with Gradle injecting the value at build time.

**Why `com.google.android.geo.API_KEY` and not `maps.v2.API_KEY`?**
The `v2.API_KEY` meta-data name is deprecated. The current `google_maps_flutter` plugin (backed by Maps SDK for Android v6+) requires `geo.API_KEY` as the meta-data name — using the old name causes a `java.lang.IllegalStateException: API key not found` crash at runtime.

**Why Kotlin 2.3.0?**
The `google_maps_flutter_android` plugin now ships its internal Kotlin stdlib compiled at metadata version `2.3.0`. Using an older Kotlin Gradle plugin (e.g., `2.1.0`) causes an `Internal compiler error` during `compileDebugKotlin` because of metadata version mismatch. Aligning the project to `2.3.0` resolves this.

**Why `compileSdk 36` and `targetSdk 36`?**
Android 16 (API 36) is the latest stable SDK. Targeting it ensures the app receives modern permission behavior, edge-to-edge display support, and access to the latest Play Store requirements while staying compatible with devices running Android 7.0+ (minSdk from Flutter defaults).

***

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.x)
- Android Studio / VS Code with Flutter extension
- Firebase project with Auth + Firestore + Storage enabled
- Google Cloud project with **Maps SDK for Android** and **Geocoding API** enabled
- Cloudinary account

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/gitatharvaa/urban_tutor.git
cd urban_tutor

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure environment variables
# Create a .env file in the project root:
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset

# 4. Add Google Maps API key to android/local.properties
# (already gitignored — create manually)
sdk.dir=C:\\Users\\YourUser\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\src\\flutter
MAPS_API_KEY=your_google_maps_api_key_here

# 5. Add Firebase config
# Download google-services.json from Firebase Console
# Place it at: android/app/google-services.json

# 6. Run the app
flutter run
```

### Verify AndroidManifest.xml has these entries
```xml
<!-- Inside <application> tag -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${mapsApiKey}" />
```

And `android/app/build.gradle` has:
```gradle
defaultConfig {
    manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("MAPS_API_KEY", "")
}
```

***

## 📁 Project Structure

```
urban_tutor/
│
├── lib/
│   ├── main.dart                   # App entry point, Firebase init, dotenv load
│   ├── firebase_options.dart       # FlutterFire generated config
│   │
│   ├── models/                     # Data models (User, Tutor, Session, Note)
│   │
│   ├── providers/                  # Provider state management
│   │   ├── auth_provider.dart      # Firebase Auth state
│   │   ├── tutor_provider.dart     # Tutor data + location
│   │   └── notes_provider.dart     # Notes CRUD + Cloudinary upload
│   │
│   ├── pages/
│   │   ├── auth/                   # Login, Signup, Role selection
│   │   ├── student/                # Student home, map, tutor profile, sessions
│   │   ├── tutor/                  # Tutor home, profile edit, notes, sessions
│   │   └── shared/                 # Common screens (splash, settings)
│   │
│   ├── widgets/                    # Reusable UI components
│   └── services/                   # Firestore, Cloudinary, Location services
│
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   └── AndroidManifest.xml # Permissions + Maps API key meta-data
│   │   ├── build.gradle            # Kotlin 2.3.0 · compileSdk 36 · Java 17
│   │   └── google-services.json    # Firebase config (gitignored)
│   ├── build.gradle                # Project-level Gradle config
│   ├── settings.gradle             # Kotlin plugin version declaration
│   └── local.properties            # SDK paths + MAPS_API_KEY (gitignored)
│
├── assets/
│   └── screenshots/                # App screenshots for README
│
├── .env                            # Cloudinary keys (gitignored)
├── .gitignore
├── pubspec.yaml                    # Flutter dependencies
└── README.md
```

***

## 🔐 Permissions (AndroidManifest.xml)

| Permission | Purpose |
|---|---|
| `INTERNET` | Firebase, Cloudinary, Google Maps API calls |
| `CAMERA` | Profile photo capture for tutors/students |
| `READ_EXTERNAL_STORAGE` | Document/notes upload from device |
| `ACCESS_FINE_LOCATION` | GPS coordinates for tutor map placement |
| `ACCESS_COARSE_LOCATION` | Fallback location for map view |
| `QUERY_ALL_PACKAGES` | Flutter engine process text plugin requirement |

***

## 🌐 Firebase Structure (Firestore)

```
users/
  {uid}/
    role: "student" | "tutor"
    name: string
    email: string
    photoUrl: string
    location: GeoPoint          ← tutors only
    subjects: string[]          ← tutors only
    availability: string        ← tutors only

sessions/
  {sessionId}/
    studentId: string
    tutorId: string
    status: "pending" | "accepted" | "completed"
    subject: string
    scheduledAt: Timestamp

notes/
  {noteId}/
    tutorId: string
    title: string
    cloudinaryUrl: string
    uploadedAt: Timestamp
    sharedWith: string[]        ← student UIDs
```

***

## 🔮 Future Development

- **Phase 2 — In-App Chat:** Real-time messaging between students and tutors using Firebase Realtime Database, with file sharing support.

- **Phase 3 — Ratings & Reviews:** Post-session rating system where students rate tutors, with aggregated scores displayed on tutor profile cards.

- **Phase 4 — Payment Integration:** Razorpay/Stripe integration for direct in-app session payments with invoice generation.

- **Phase 5 — iOS Support:** Extend to iOS with `AppDelegate.swift`-based Maps key injection and iOS-specific permission handling.

- **Phase 6 — Admin Panel:** Web-based admin dashboard (React + Firebase) for platform moderation, tutor verification, and analytics.

***

## 👤 Author

**Atharva**

[
[

***

<div align="center">

```
Built with curiosity, caffeine, and Ganpati Bappa's blessings 🙏
```

⭐ Star this repo if it helped you learn something

</div>
