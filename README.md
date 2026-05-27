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
