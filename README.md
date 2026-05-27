Here's the enhanced README — styled after your Smart Grid Optimizer README:

---

<div align="center">

<h1>🎓 URBAN TUTOR</h1>
<h3>On-Demand Home Tutoring Platform — Flutter × Node.js × MongoDB × Firebase</h3>

<br/>

[![Live Demo](https://img.shields.io/badge/📱_FLUTTER_APP-Android_Build-3DDC84?style=for-the-badge&logo=android)](https://github.com/gitatharvaa/urban_tutor)
[![Backend API](https://img.shields.io/badge/⚙️_BACKEND-Node.js_+_Express-339933?style=for-the-badge&logo=nodedotjs)](https://github.com/gitatharvaa/urban_tutor)
[![GitHub](https://img.shields.io/badge/📁_SOURCE_CODE-GitHub-181717?style=for-the-badge&logo=github)](https://github.com/gitatharvaa/urban_tutor)

<br/>

![Flutter](https://img.shields.io/badge/Flutter_3.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=nodedotjs&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=flat-square&logo=mongodb&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=flat-square)
![Google Maps](https://img.shields.io/badge/Google_Maps_SDK-4285F4?style=flat-square&logo=googlemaps&logoColor=white)

<br/>

> **2 user roles · Real-time location tracking · Multi-criteria filter engine · Cloudinary media uploads · Firebase Auth + MongoDB**

</div>

---

## 🎓 What Is This?

A full-stack mobile platform that transforms how students find home tutors — built with Flutter, Node.js, and MongoDB.

**Problem 1** — Finding a qualified local tutor is fragmented and entirely offline. Parents depend on word-of-mouth referrals, scattered social media posts, or generic classified sites with no structured comparison.

**Problem 2** — Skilled tutors have no dedicated professional platform. They get lost on general listing sites, pay high commissions, and have no way to showcase credentials, manage availability, or reach the right students.

**Solution** — A dual-role mobile application where students discover nearby tutors on an interactive Google Maps view, filter by subject, price, experience, rating, and availability — while tutors manage profiles, upload credentials via Cloudinary, handle session bookings, and appear on the student map in real time.

> Empirical testing showed users could reduce hundreds of tutor listings to a curated shortlist of 5–10 highly relevant candidates in under a minute.

---

## 📱 App Screenshots

<div align="center">

| Home Screen | Tutor Listing |
|:---:|:---:|
| ![Home](https://raw.githubusercontent.com/gitatharvaa/urban_tutor/main/assets/screenshots/home_screen.png) | ![Listing](https://raw.githubusercontent.com/gitatharvaa/urban_tutor/main/assets/screenshots/tutor_listing.png) |

| Advanced Filter | Tutor Profile |
|:---:|:---:|
| ![Filter](https://raw.githubusercontent.com/gitatharvaa/urban_tutor/main/assets/screenshots/advanced_filter.png) | ![Profile](https://raw.githubusercontent.com/gitatharvaa/urban_tutor/main/assets/screenshots/tutor_profile.png) |

| Classroom Dashboard | Add Note |
|:---:|:---:|
| ![Classroom](https://raw.githubusercontent.com/gitatharvaa/urban_tutor/main/assets/screenshots/classroom.png) | ![Notes](https://raw.githubusercontent.com/gitatharvaa/urban_tutor/main/assets/screenshots/add_note.png) |

</div>

---

## 🎯 Project Objectives

This platform was designed around 8 core engineering and product objectives:

| # | Objective | Implementation |
|---|---|---|
| 1 | **Structured Tutor Discovery** | Centralized profiles with subjects, experience, qualifications, fees, locality |
| 2 | **Multi-Criteria Filter Engine** | Real-time client-side filtering across 7+ parameters simultaneously |
| 3 | **Scalable Full-Stack Architecture** | Flutter + Node.js/Express + MongoDB (modular, 3-tier) |
| 4 | **Efficient Student–Tutor Interaction** | Profile viewing, shortlisting, one-click enquiry submission |
| 5 | **High Usability & Performance** | Material Design, near-instant filter updates, smooth scroll with cloud images |
| 6 | **Tutor Visibility & Accessibility** | Dedicated profiles with credential uploads, Google Maps location pin |
| 7 | **Location-Based Tutor Matching** | GPS coordinates, locality-based filtering, Google Maps SDK for Android |
| 8 | **Data Security & Reliability** | Firebase Auth, JWT tokens, bcrypt password hashing, HTTPS API communication |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     USER LAYER                              │
│         Student App  ·  Tutor App  (same Flutter codebase) │
│              Role-based UI routing via Firebase Auth        │
└──────────────────────┬──────────────────────────────────────┘
                       │ Flutter (Dart) — Provider State Mgmt
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                PRESENTATION LAYER (Flutter)                 │
│                                                             │
│  State Management : Provider (ChangeNotifier)               │
│  Navigation       : Named Routes                            │
│  Maps             : google_maps_flutter (Maps SDK Android)  │
│  Location         : Geolocator + Geocoding                  │
│  Config           : flutter_dotenv (.env API keys)          │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS REST API (JWT Auth)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│            APPLICATION LAYER (Node.js + Express)            │
│                                                             │
│  Auth             : JWT (signed, env-stored secrets)        │
│  Business Logic   : Validation · Profile Mgmt · Enquiries   │
│  Media Uploads    : Cloudinary SDK                          │
│  ORM              : Mongoose (schema + data modelling)      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   DATA LAYER                                │
│                                                             │
│  MongoDB          → Users · Tutors · Enquiries · Sessions   │
│  Firebase Auth    → Email/password identity management      │
│  Firebase Storage → Profile photos (user-scoped)            │
│  Cloudinary       → Notes · Documents · CDN delivery        │
└─────────────────────────────────────────────────────────────┘
```

---

## ✨ Key Features

### 👨‍🎓 Student Side
- **Tutor Discovery Map** — Browse nearby tutors on Google Maps with real-time GPS location markers
- **Advanced Multi-Criteria Filtering** — Filter by subject, academic level, price range, experience, rating, teaching mode, availability, language, and locality — simultaneously
- **Quick Filter Chips** — One-tap "Nearby", "Affordable", "Experienced", "Top Rated" chips synced with the advanced filter panel
- **Tutor Profiles** — View full qualifications, credentials, subjects, ratings, and uploaded documents
- **Session Requests** — Send, track, and manage tutoring session bookings
- **Notes Access** — Download notes and study material shared by tutors via Cloudinary

### 👨‍🏫 Tutor Side
- **Profile Management** — Upload photo, qualifications, subjects, fee range, teaching mode, and availability
- **Notes Upload** — Share study materials with students via Cloudinary media pipeline
- **Session Management** — Accept, decline, and manage student session requests
- **Location Visibility** — Appear on the student discovery map based on GPS coordinates

### 🔐 Auth & Core
- Firebase Email/Password authentication with role selection at signup
- Role-based routing — Students and Tutors see completely different home screens
- `.env`-based API key management (Cloudinary, Google Maps) via `flutter_dotenv`
- JWT tokens on every authenticated API request; passwords bcrypt-hashed in MongoDB

---

## 🔍 Filter & Search Engine

The filter engine is the core product differentiator — designed for speed and accuracy.

```
Quick Chips (toggle)                Advanced Panel (combined)
─────────────────────               ──────────────────────────────
✓ All Tutors                        Subjects         (multi-select)
✓ Nearby                            Academic Level   (Std 1 – College)
✓ Affordable       ────────────►    Price Range      (slider)
✓ Experienced      (synced)         Experience       (0–10+ years)
✓ Top Rated                         Rating           (star threshold)
✓ Online                            Teaching Mode    (online/offline/hybrid)
                                    Availability     (days + time slots)
                                    Language         (multi-select)
                                    Locality         (city search + chips)
```

**How it works:**
- Filtering runs **client-side** via Provider-managed state — no repeated API calls
- Quick chips and advanced panel are **bidirectionally synced** (selecting "Affordable" auto-sets the price slider)
- Results update **instantaneously** even with multiple simultaneous filters
- Empty-result states handled gracefully with contextual messaging

---

## 🛠️ Tech Stack

```
┌─────────────────────┬──────────────────────────────────────────┐
│ Layer               │ Technologies                             │
├─────────────────────┼──────────────────────────────────────────┤
│ Mobile Framework    │ Flutter 3.x · Dart                       │
│ State Management    │ Provider (ChangeNotifier)                │
│ Authentication      │ Firebase Auth (Email/Password)           │
│ Backend API         │ Node.js · Express.js · Mongoose ODM      │
│ Database            │ MongoDB (Atlas / Community)              │
│ File Storage        │ Firebase Storage · Cloudinary            │
│ Maps & Location     │ google_maps_flutter · Geolocator         │
│ Geocoding           │ geocoding (reverse + forward)            │
│ Media Upload        │ Cloudinary Flutter SDK                   │
│ Security            │ JWT · bcrypt · HTTPS                     │
│ Environment Config  │ flutter_dotenv                           │
│ Build System        │ Gradle 8.11.1 · Kotlin 2.3.0            │
│ Java Compatibility  │ Java 17 (sourceCompatibility)            │
│ Android SDK         │ compileSdk 36 · targetSdk 36            │
│ Rendering           │ Impeller (Vulkan)                        │
└─────────────────────┴──────────────────────────────────────────┘
```

---

## 🔑 Key Technical Decisions

**Why Provider over Riverpod/Bloc?**
Urban Tutor has a straightforward unidirectional data flow — auth state → role routing → screen-level data. Provider's `ChangeNotifier` pattern is sufficient and avoids unnecessary boilerplate for this scope. Riverpod would add overhead without architectural benefit here.

**Why MongoDB over a relational DB?**
Tutor profiles have dynamic, varying attributes — subjects, availability slots, language preferences, fee structures. MongoDB's flexible schema handles this naturally without ALTER TABLE migrations or NULL-heavy rows.

**Why Cloudinary alongside Firebase Storage?**
Firebase Storage handles profile photos (small, user-scoped). Cloudinary handles notes and documents — its free tier provides CDN delivery, format conversion, and transformations that Firebase Storage doesn't offer natively. Better suited for educational content distribution.

**Why `local.properties` for the Maps API key?**
Hardcoding the Google Maps API key in `AndroidManifest.xml` exposes it in version control. The `local.properties` → `manifestPlaceholders["mapsApiKey"]` → `${mapsApiKey}` Gradle injection pattern keeps secrets entirely out of Git.

**Why `com.google.android.geo.API_KEY` and not `maps.v2.API_KEY`?**
The `v2.API_KEY` meta-data name is deprecated. The current `google_maps_flutter` plugin (Maps SDK for Android v6+) requires `geo.API_KEY` — using the old name causes a `java.lang.IllegalStateException: API key not found` crash at runtime.

**Why Kotlin 2.3.0?**
The `google_maps_flutter_android` plugin ships internal Kotlin stdlib compiled at metadata version `2.3.0`. Using Kotlin `2.1.0` causes an `Internal compiler error` during `compileDebugKotlin` due to metadata version mismatch. Aligning to `2.3.0` resolves this entirely.

**Why `compileSdk 36` / `targetSdk 36`?**
Android 16 (API 36) is the latest stable SDK. Targeting it ensures edge-to-edge display support, modern permission behavior, and Play Store compliance while maintaining backward compatibility to Android 7.0+.

---

## 🚀 Quick Start

### Option 1 — Clone & Run Locally

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
sdk.dir=C:\\Users\\YourUser\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\src\\flutter
MAPS_API_KEY=your_google_maps_api_key_here

# 5. Add Firebase config
# Download google-services.json from Firebase Console
# Place it at: android/app/google-services.json

# 6. Start backend (separate terminal)
cd backend
npm install
node server.js

# 7. Run the Flutter app
flutter run
```

### Verify AndroidManifest.xml

```xml
<!-- Inside <application> tag -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${mapsApiKey}" />
```

### Verify `android/app/build.gradle`

```gradle
defaultConfig {
    manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("MAPS_API_KEY", "")
}
```

---

## 📁 Project Structure

```
urban_tutor/
│
├── lib/
│   ├── main.dart                    # App entry, Firebase init, dotenv load
│   ├── firebase_options.dart        # FlutterFire generated config
│   │
│   ├── models/                      # User, Tutor, Session, Note data models
│   │
│   ├── providers/                   # Provider state management
│   │   ├── auth_provider.dart       # Firebase Auth state
│   │   ├── tutor_provider.dart      # Tutor data + GPS location
│   │   └── notes_provider.dart      # Notes CRUD + Cloudinary upload
│   │
│   ├── pages/
│   │   ├── auth/                    # Login, Signup, Role Selection
│   │   ├── student/                 # Home, Map, Tutor Profile, Sessions
│   │   ├── tutor/                   # Dashboard, Profile Edit, Notes, Sessions
│   │   └── shared/                  # Splash, Settings
│   │
│   ├── widgets/                     # Reusable UI components
│   └── services/                    # Firestore, Cloudinary, Location services
│
├── backend/
│   ├── server.js                    # Express app entry point
│   ├── routes/                      # Auth, tutors, enquiries, sessions
│   ├── models/                      # Mongoose schemas
│   ├── middleware/                  # JWT auth middleware
│   └── config/                      # DB connection, Cloudinary config
│
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml   # Permissions + Maps meta-data
│   │   ├── build.gradle                   # Kotlin 2.3.0 · compileSdk 36
│   │   └── google-services.json           # Firebase config (gitignored)
│   └── local.properties                   # SDK paths + MAPS_API_KEY (gitignored)
│
├── assets/screenshots/              # App screenshots
├── .env                             # Cloudinary keys (gitignored)
├── pubspec.yaml                     # Flutter dependencies
└── README.md
```

---

## 🌐 MongoDB Collections (Mongoose Schemas)

```
users/
  {uid}
    role         : "student" | "tutor"
    name         : String
    email        : String  (unique, indexed)
    passwordHash : String  (bcrypt)
    photoUrl     : String  (Firebase Storage)
    createdAt    : Date

tutors/
  {tutorId}
    userId       : ObjectId → users
    subjects     : [String]
    standards    : [String]          ← academic levels taught
    experience   : Number (years)
    feeRange     : { min, max }      ← monthly ₹
    teachingMode : "online" | "offline" | "hybrid"
    availability : [{ day, slots }]
    languages    : [String]
    locality     : String
    location     : { lat, lng }      ← GeoPoint for map pin
    qualifications: String
    rating       : Number (avg)
    isActive     : Boolean

sessions/
  {sessionId}
    studentId    : ObjectId → users
    tutorId      : ObjectId → tutors
    status       : "pending" | "accepted" | "completed" | "cancelled"
    subject      : String
    scheduledAt  : Date

enquiries/
  {enquiryId}
    studentId    : ObjectId → users
    tutorId      : ObjectId → tutors
    message      : String
    createdAt    : Date

notes/
  {noteId}
    tutorId      : ObjectId → tutors
    title        : String
    cloudinaryUrl: String
    uploadedAt   : Date
    sharedWith   : [ObjectId]        ← student UIDs
```

---

## 🔐 Permissions (AndroidManifest.xml)

| Permission | Purpose |
|---|---|
| `INTERNET` | Firebase, Cloudinary, Google Maps API, Node.js backend |
| `CAMERA` | Profile photo capture |
| `READ_EXTERNAL_STORAGE` | Notes/document upload from device |
| `ACCESS_FINE_LOCATION` | GPS coordinates for tutor map placement |
| `ACCESS_COARSE_LOCATION` | Fallback location for map view |
| `QUERY_ALL_PACKAGES` | Flutter engine process text plugin requirement |

---

## 📊 Performance Results

Testing was conducted with a synthetic dataset of diverse tutor profiles across multiple urban localities, simulating realistic student user journeys.

| Metric | Result |
|---|---|
| Tutor list initial load | Fast on typical 4G Android devices |
| Filter application speed | Near-instantaneous (client-side, no API call) |
| Multi-filter combinations tested | Subject + price + experience + rating simultaneously |
| Discovery efficiency | 100s of listings → 5–10 relevant candidates in < 1 minute |
| Image scroll performance | Smooth with Cloudinary CDN delivery |
| Memory stability | Stable across screen transitions (Filter → Profile → Home) |
| Filter engine edge cases | Empty results, overlapping criteria, single-match scenarios all handled |

---

## ⚠️ Known Limitations

| Limitation | Planned Fix |
|---|---|
| No real-time schedule sync | Phase 2 — Firebase Realtime Database availability calendar |
| No in-app payment | Phase 4 — Razorpay/Stripe integration |
| No in-app chat | Phase 2 — Firebase Realtime Database messaging |
| Rule-based filtering only | Phase 3 — ML-based personalized recommendations |
| No automated credential verification | Phase 5 — Document verification pipeline |
| Android only | Phase 5 — iOS support via AppDelegate.swift Maps key injection |

---

## 🔮 Future Development

- **Phase 2 — Real-Time Chat & Availability:** Firebase Realtime Database-powered messaging between students and tutors, with calendar-based availability scheduling and session reminders.

- **Phase 3 — AI-Powered Recommendations:** Replace rule-based filtering with a collaborative filtering model — personalized tutor suggestions based on student search history, subject preferences, and session outcomes.

- **Phase 4 — Payments & Reviews:** Razorpay/Stripe in-app payment with invoice generation; post-session rating system with aggregated scores displayed on tutor profile cards.

- **Phase 5 — iOS + Admin Panel:** iOS support with AppDelegate.swift-based Maps key injection; React + Firebase web admin dashboard for platform moderation, tutor verification, and analytics.

- **Phase 6 — Full Learning Platform:** Attendance tracking, assignment management, performance analytics, and progress dashboards — evolving from a discovery platform into a complete academic support ecosystem.

---

## 👤 Author

**Atharva Chavan**

[![GitHub](https://img.shields.io/badge/GitHub-gitatharvaa-181717?style=flat-square&logo=github)](https://github.com/gitatharvaa)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin)](https://linkedin.com/in/atharva-chavan1505)

*Academic Project — Major Project (Sem VIII), B.E. Computer Engineering*
*VCET, University of Mumbai | 2025–2026*
*Team: Gargi Betawadkar · Atharva Chavan · Arya Raul | Guide: Prof. Mrs. Smita Jawale*

---

<div align="center">

```
Built with curiosity, caffeine, and Ganpati Bappa's blessings 🙏
```

⭐ Star this repo if it helped you learn something

</div>
