<div align="center">

<h1>🎓 URBAN TUTOR</h1>
<h3>Connecting Parents & Students with Nearby Home Tutors</h3>
<p><em>A location-aware tutor discovery and booking platform for urban and semi-urban India</em></p>

<br/>

[
[
[

<br/>










<br/>

> **2 user roles · 8 functional modules · Advanced multi-criteria filter engine · Real-time location-based discovery · Cloudinary media pipeline · JWT-secured REST API**

</div>

***

## 📖 What Is Urban Tutor?

Urban Tutor is a **full-stack mobile application** that solves one of the most overlooked problems in Indian education — the chaotic, word-of-mouth-driven process of finding a home tutor.

In densely populated cities like Mumbai, Vasai, and Virar, hundreds of tutors may be available within a 2 km radius of a student. Yet parents still rely on WhatsApp groups and neighbourhood gossip to find one. Tutors, on the other hand, lack any professional digital presence to reach the right students.

**Urban Tutor bridges this gap** — a dedicated, education-focused marketplace that brings structure, transparency, and efficiency to the ₹6.4 lakh crore private tutoring ecosystem in India.

***

## ❗ Problem Statement

> *How can students and parents efficiently discover, evaluate, and connect with suitable tutors in densely populated urban environments using a structured, scalable, and user-friendly digital platform that enables multi-criteria filtering, ensures reliable information, and reduces the time and effort involved in the tutor selection process?*

### Why This Problem Matters

| Pain Point | Impact |
|---|---|
| Tutors found via word-of-mouth only | No standardization, no way to compare |
| No subject/fee/experience filters on generic platforms | Wastes hours of parent time |
| Skilled tutors lack professional digital presence | Low reach, relies on personal networks |
| Existing platforms (OLX, Sulekha) are not education-specific | No domain filters like academic level or teaching style |
| Over 60% of Indian students rely on private tutoring (UNESCO, 2021) | Massive unmet need for structured discovery |

***

## 🎯 Project Objectives

1. **Structured Tutor Discovery** — Centralized platform with rich, comparable tutor profiles (subjects, fees, experience, qualifications, locality)
2. **Advanced Multi-Criteria Filtering** — Dynamic filter engine combining quick chips + granular advanced filters across 8+ parameters
3. **Scalable Full-Stack Architecture** — Flutter frontend + Node.js/Express backend + MongoDB data layer with clean separation of concerns
4. **Efficient Student–Tutor Interaction** — Profile viewing, shortlisting, bookmarking, and one-click enquiry submission
5. **Location-Based Matching** — Proximity-aware tutor discovery using GPS and locality-based filtering
6. **Tutor Visibility & Accessibility** — Professional space for tutors to showcase qualifications, availability, and teaching style
7. **High Usability & Performance** — Mobile-first Material Design UI with real-time filter updates, sub-second response
8. **Data Security & Reliability** — JWT authentication, bcrypt password hashing, HTTPS-only API communication

***

## 🖥️ App Screenshots

<div align="center">

| Home Screen | Classroom / Tutor Listing |
|:---:|:---:|
|  |  |

| Advanced Filter Screen | Classroom Dashboard |
|:---:|:---:|
|  |  |

| Tutor Profile Detail | Add Note Feature |
|:---:|:---:|
|  |  |

</div>

> 📌 Replace the above paths with your actual screenshot URLs from the repo.

***

## 🏗️ System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        USER LAYER                                │
│    Student / Parent App          Tutor App                       │
│         (same Flutter codebase — role-based UI)                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │ Flutter (Dart) — Material Design
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER (Flutter)                   │
│                                                                  │
│  State Management: Provider (ChangeNotifier)                     │
│  Navigation: Named Routes                                        │
│  UI: Material Design · Responsive across mobile + web           │
│  Location: Geolocator + Geocoding (GPS coordinates)             │
│  Maps: google_maps_flutter (Maps SDK for Android)               │
│  Media: Cloudinary Flutter SDK                                   │
│  Config: flutter_dotenv (.env for API keys)                      │
└────────────────────────┬─────────────────────────────────────────┘
                         │ HTTPS · JWT Bearer Token
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│                 APPLICATION LAYER (Node.js + Express)            │
│                                                                  │
│  Auth Module         → JWT token issuance + validation           │
│  Tutor Module        → Profile CRUD, availability management     │
│  Search & Filter     → Multi-criteria query processing           │
│  Enquiry Module      → Student-to-tutor enquiry handling         │
│  Media Module        → Cloudinary upload integration             │
│  Admin Module        → Platform management (future)             │
└────────────────────────┬─────────────────────────────────────────┘
                         │ Mongoose ODM
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│                    DATA LAYER (MongoDB + Cloudinary)             │
│                                                                  │
│  Collections:                                                    │
│    users      → name, email, role, auth credentials             │
│    tutors     → subjects, experience, fees, location, mode       │
│    enquiries  → studentId, tutorId, message, timestamp           │
│    notes      → tutorId, title, cloudinaryUrl, sharedWith        │
│                                                                  │
│  Media Storage: Cloudinary (profile photos, notes, documents)   │
│  Auth: Firebase Auth (Email/Password)                            │
└──────────────────────────────────────────────────────────────────┘
```

***

## ⚙️ How the Filter Engine Works

The **Filter and Search Engine** is the core differentiator of Urban Tutor. It operates entirely client-side using Provider-managed state, enabling **real-time zero-latency updates** without repeated API calls.

```
User Input
    │
    ├── Quick Filter Chips (toggleable)
    │     "All Tutors"  "📍 Nearby"  "₹ Affordable"
    │     "⭐ Experienced"  "🏆 Top Rated"  "💻 Online"
    │
    └── Advanced Filter Panel (granular)
          ├── Subjects (Mathematics, Science, English, Hindi, Physics...)
          ├── Academic Level (Class 1–12, Competitive Exams)
          ├── Fee Range (slider: ₹0 – ₹5000/month)
          ├── Experience (0–2 yrs / 2–5 yrs / 5+ yrs)
          ├── Rating (3★ / 4★ / 4.5★ and above)
          ├── Teaching Mode (Online / Offline / Both)
          ├── Availability (Days + Time Slots)
          └── Preferred Location (City chips: Mumbai, Vasai, Virar...)
                         │
                         ▼
              Provider notifies listeners
                         │
                         ▼
          Tutor list updates INSTANTLY
    (hundreds of profiles → curated 5–10 in < 1 minute)
```

**Synchronization:** Quick chips are linked to the advanced panel — selecting "Affordable" automatically adjusts the fee range slider, ensuring filter consistency.

***

## ✨ Features

### 👨‍🎓 Student / Parent Side
- **Home Screen** — Search bar + quick filter chips + live tutor card list
- **Advanced Filter Panel** — 8+ filter dimensions with `Clear All` / `Apply Filters`
- **Tutor Profile Detail** — Full info: subjects, standards, experience, fee, contact, location, about
- **Shortlist & Bookmark** — Save tutors for later reference
- **Send Enquiry** — One-click enquiry with message directly from tutor profile
- **Notes Access** — View and download study materials shared by tutors via Cloudinary
- **Classroom Dashboard** — Upcoming classwork, assignments, quizzes, recent activity, XP/level system

### 👨‍🏫 Tutor Side
- **Profile Management** — Create/update subjects, academic standards, fee, experience, teaching mode, locality
- **Media Upload** — Upload profile photo and credential documents via Cloudinary pipeline
- **Add Notes** — Share notes with title, description, grade, subject, difficulty, visibility (Public/Private), and optional file upload (PDF/DOC/JPG, max 50MB)
- **Enquiry Management** — View and respond to student enquiries
- **Active/Inactive Toggle** — Mark profile visible or hidden without deleting account

### 🔐 Auth & Security
- **Firebase Email/Password Authentication** — Role selection (Student / Tutor) at signup
- **JWT-secured REST API** — All protected endpoints require Bearer token
- **bcrypt password hashing** — Passwords never stored in plain text
- **Environment-based secret management** — All API keys in `.env` / `local.properties` (never in version control)

***

## 🛠️ Tech Stack

```
┌──────────────────────┬────────────────────────────────────────────┐
│ Layer                │ Technologies                               │
├──────────────────────┼────────────────────────────────────────────┤
│ Mobile Framework     │ Flutter 3.x · Dart                         │
│ State Management     │ Provider (ChangeNotifier)                  │
│ Authentication       │ Firebase Auth · JWT (backend sessions)     │
│ Backend API          │ Node.js (LTS) · Express.js                 │
│ Database             │ MongoDB Atlas · Mongoose ODM               │
│ Media Storage        │ Cloudinary SDK (images, PDFs, documents)   │
│ Maps & Location      │ google_maps_flutter · Geolocator           │
│ Geocoding            │ geocoding package (reverse + forward)      │
│ HTTP Client          │ http / dio                                 │
│ UI Components        │ flutter_rating_bar · google_fonts          │
│ Environment Config   │ flutter_dotenv                             │
│ Local Storage        │ shared_preferences (saved filters)         │
│ Build System         │ Gradle 8.11.1 · Kotlin 2.3.0              │
│ Java Compatibility   │ Java 17 (sourceCompatibility)             │
│ Android SDK          │ compileSdk 36 · targetSdk 36              │
│ Rendering Engine     │ Impeller (Vulkan)                          │
│ Dev Tools            │ Android Studio · VS Code · Postman         │
│ Version Control      │ Git · GitHub                               │
└──────────────────────┴────────────────────────────────────────────┘
```

***

## 🗂️ Major Modules

| Module | Responsibility |
|---|---|
| **Authentication** | Registration, login, JWT session handling, role-based routing |
| **Tutor Management** | Profile CRUD, active/inactive toggle, Cloudinary media upload |
| **Search & Filter Engine** | Real-time multi-criteria filtering, quick chips + advanced panel |
| **Student Interaction** | Tutor browsing, shortlisting, enquiry submission |
| **Notes & Classroom** | Tutor note creation, Cloudinary upload, student-facing classroom dashboard |
| **Location Module** | Geolocator GPS, Google Maps view, locality-based proximity filtering |
| **Media Pipeline** | Cloudinary integration for profile photos, documents (PDF/DOC/JPG, max 50MB) |
| **Administration** *(future)* | Platform moderation, tutor verification, analytics |

***

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.x (stable channel)
- Node.js LTS + npm
- Android Studio / VS Code with Flutter & Dart plugins
- Firebase project (Auth + Firestore + Storage enabled)
- Google Cloud project (**Maps SDK for Android** + **Geocoding API** enabled)
- MongoDB Atlas cluster
- Cloudinary account (free tier works)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/gitatharvaa/urban_tutor.git
cd urban_tutor

# 2. Install Flutter dependencies
flutter pub get

# 3. Create .env in project root (gitignored)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset

# 4. Create android/local.properties (gitignored)
sdk.dir=C:\Users\YourUser\AppData\Local\Android\Sdk
flutter.sdk=C:\src\flutter
flutter.versionName=1.0.0
flutter.versionCode=1
MAPS_API_KEY=your_google_maps_api_key_here

# 5. Add Firebase config
# Download google-services.json from Firebase Console
# Place at: android/app/google-services.json

# 6. Set up backend
cd backend
npm install
cp .env.example .env   # fill in MONGO_URI, JWT_SECRET, CLOUDINARY keys
npm start              # runs on http://localhost:5000

# 7. Run the Flutter app (new terminal)
cd ..
flutter run
```

### ⚠️ AndroidManifest.xml — Required Entry

```xml
<!-- Inside <application> tag in android/app/src/main/AndroidManifest.xml -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${mapsApiKey}" />
```

### ⚠️ android/app/build.gradle — Required Entry

```gradle
defaultConfig {
    manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("MAPS_API_KEY", "")
    // ... rest of config
}
```

***

## 📁 Project Structure

```
urban_tutor/
│
├── lib/
│   ├── main.dart                     # Entry point: Firebase init, dotenv load, app boot
│   ├── firebase_options.dart         # FlutterFire generated config
│   │
│   ├── models/                       # Data models
│   │   ├── tutor_model.dart          # Tutor profile: subjects, fees, location, mode
│   │   ├── user_model.dart           # User: name, email, role
│   │   ├── enquiry_model.dart        # Student enquiry
│   │   └── note_model.dart           # Tutor note + Cloudinary URL
│   │
│   ├── providers/                    # Provider state management
│   │   ├── auth_provider.dart        # Firebase Auth state + role
│   │   ├── tutor_provider.dart       # Tutor list + location + filter state
│   │   └── notes_provider.dart       # Notes CRUD + Cloudinary upload pipeline
│   │
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── role_selection_page.dart
│   │   ├── student/
│   │   │   ├── home_page.dart        # Search bar + quick filters + tutor cards
│   │   │   ├── filter_page.dart      # Advanced filter panel (8+ dimensions)
│   │   │   ├── tutor_detail_page.dart # Full tutor profile + enquiry action
│   │   │   ├── map_page.dart         # Google Maps with tutor location markers
│   │   │   └── classroom_page.dart   # Assignments, quizzes, notes, XP system
│   │   └── tutor/
│   │       ├── tutor_home_page.dart
│   │       ├── profile_edit_page.dart
│   │       ├── add_note_page.dart    # Note creation + Cloudinary upload
│   │       └── enquiry_list_page.dart
│   │
│   ├── widgets/                      # Reusable UI components
│   │   ├── tutor_card.dart
│   │   ├── filter_chip_bar.dart
│   │   └── rating_widget.dart
│   │
│   └── services/                     # Business logic + API calls
│       ├── auth_service.dart
│       ├── tutor_service.dart
│       ├── cloudinary_service.dart
│       └── location_service.dart
│
├── backend/
│   ├── server.js                     # Express app entry point
│   ├── routes/
│   │   ├── auth.js                   # POST /register, POST /login
│   │   ├── tutors.js                 # GET /tutors, POST/PUT/DELETE /tutor
│   │   ├── enquiries.js              # POST /enquiry, GET /enquiries/:tutorId
│   │   └── notes.js                  # POST /note, GET /notes/:tutorId
│   ├── models/                       # Mongoose schemas
│   │   ├── User.js
│   │   ├── Tutor.js
│   │   ├── Enquiry.js
│   │   └── Note.js
│   ├── middleware/
│   │   └── auth.js                   # JWT verification middleware
│   └── .env.example                  # Template for env vars
│
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml  # Permissions + Maps API key meta-data
│   │   ├── build.gradle                  # Kotlin 2.3.0 · compileSdk 36 · Java 17
│   │   └── google-services.json          # Firebase config (gitignored)
│   ├── build.gradle                      # Project-level Gradle config
│   ├── settings.gradle                   # Kotlin plugin + Flutter loader
│   └── local.properties                  # SDK paths + MAPS_API_KEY (gitignored)
│
├── assets/
│   └── screenshots/
│
├── .env                              # Cloudinary keys (gitignored)
├── .gitignore
├── pubspec.yaml
└── README.md
```

***

## 🔐 Android Permissions

| Permission | Purpose |
|---|---|
| `INTERNET` | Firebase, Cloudinary, Node.js API, Google Maps |
| `ACCESS_FINE_LOCATION` | GPS for real-time tutor proximity on map |
| `ACCESS_COARSE_LOCATION` | Fallback location for map initialisation |
| `CAMERA` | Profile photo capture |
| `READ_EXTERNAL_STORAGE` | Document/notes upload from device |
| `QUERY_ALL_PACKAGES` | Flutter engine ProcessText plugin requirement |

***

## 📊 Performance Evaluation

Testing was conducted with a synthetic dataset of diverse tutor profiles across subjects, experience bands, fee ranges, and urban/semi-urban locations.

| Parameter | Observation |
|---|---|
| **Filter response time** | Near-instantaneous — client-side Provider state, no API call on filter change |
| **Tutor list load time** | Fast initial fetch on 4G connections |
| **Discovery efficiency** | Users reduced full tutor list to 5–10 relevant candidates in under 1 minute |
| **Memory stability** | Stable memory during navigation between Home → Filter → Profile → Back |
| **Media loading** | Smooth Cloudinary CDN delivery even on scrolling lists |
| **Filter accuracy** | Intersection of all selected criteria correctly applied across all test combinations |
| **Edge case handling** | Empty result states handled gracefully without crashes |
| **Usability feedback** | Interface rated intuitive by peer test group; filter panel clarity highlighted positively |

***

## ⚠️ Current Limitations

1. **No real-time availability sync** — Tutor schedule data is static; no live calendar sync
2. **No in-app payment gateway** — Fee transactions handled externally (planned for v2)
3. **No real-time chat** — Communication via enquiry only; no instant messaging
4. **Rule-based filtering only** — No ML/AI recommendation engine (planned for v3)
5. **No automated tutor verification** — Profile authenticity relies on self-reported data
6. **Platform: Android only** — iOS and web require additional configuration

***

## 🔮 Future Roadmap

- **Phase 2 — In-App Chat:** Real-time messaging using Firebase Realtime Database with file attachment support
- **Phase 3 — Ratings & Reviews:** Post-session rating system with aggregated scores on tutor cards
- **Phase 4 — Payment Integration:** Razorpay/Stripe for in-app session booking and fee payment
- **Phase 5 — AI Recommendations:** ML-based tutor matching using student history, subject performance, and behavioral signals
- **Phase 6 — Tutor Analytics Dashboard:** Enquiry rate tracking, student engagement metrics, profile views
- **Phase 7 — Calendar & Scheduling:** Session booking with calendar sync, automated reminders via FCM
- **Phase 8 — iOS Support:** AppDelegate-based Maps key injection, iOS permission flows

***

## 👥 Team

**Major Project — Sem VIII, B.E. Computer Engineering**
**Vidyavardhini's College of Engineering & Technology, Vasai (W)**
*(NAAC and NBA Accredited · Affiliated with University of Mumbai · 2025–2026)*

| Name | Roll No. |
|---|---|
| Gargi Betawadkar | 12 |
| Atharva Chavan | 27 |
| Arya Raul | 16 |

**Guide:** Prof. Mrs. Smita Jawale
**HOD:** Dr. Megha Trivedi
**Principal:** Dr. Rakesh Himte

***

## 👤 Author

**Atharva Chavan**

[
[

***

<div align="center">

```
Built with curiosity, caffeine, and Ganpati Bappa's blessings 🙏
```

⭐ Star this repo if it helped you learn something

</div>
