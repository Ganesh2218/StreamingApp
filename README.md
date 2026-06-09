# LiveHub 🔴

> **Production-ready Flutter live streaming application** powered by Agora RTC and RTMP/CDN restreaming.  
> Stream to YouTube Live, Facebook Live, or any custom RTMP endpoint — simultaneously.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🔴 **Live Streaming** | Agora RTC broadcaster role with HD video |
| 📡 **RTMP Restreaming** | YouTube, Facebook, or custom RTMP destination |
| 👥 **Audience View** | Remote video rendering + live chat UI |
| 🎙 **Mic & Camera Controls** | Toggle, mute, flip camera on-the-fly |
| 📊 **Network Quality** | Real-time signal quality indicator |
| ⏱ **Live Timer** | Streaming duration stopwatch |
| 👁 **Viewer Count** | Live audience size from Agora events |
| 💬 **Chat UI** | Audience-side chat (seeded demo data) |
| 🌑 **Dark Theme** | TikTok/YouTube-style dark streaming UI |
| 🏗 **Clean Architecture** | Domain → Data → Presentation layers |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # Routes, keys, RTMP presets
│   │   └── agora_config.dart      # Agora engine configuration
│   ├── services/
│   │   ├── agora_service.dart     # Agora RTC engine wrapper (GetxService)
│   │   └── storage_service.dart   # Local persistence (GetStorage)
│   ├── theme/
│   │   └── app_theme.dart         # Dark + light Material 3 themes
│   ├── utils/
│   │   ├── app_utils.dart         # Duration/viewer count formatting
│   │   └── permission_utils.dart  # Camera/mic permission helpers
│   └── widgets/
│       ├── live_badge.dart        # Animated pulsing LIVE badge
│       ├── viewer_count_widget.dart
│       ├── network_quality_widget.dart
│       └── streaming_timer.dart
│
├── data/
│   ├── datasource/
│   │   └── local_stream_datasource.dart  # GetStorage datasource + seed data
│   ├── models/
│   │   ├── user_model.dart        # User with role (host/audience)
│   │   └── stream_model.dart      # Stream config + live status
│   └── repositories/
│       └── stream_repository_impl.dart
│
├── domain/
│   ├── repositories/
│   │   └── stream_repository.dart # Abstract contracts
│   └── usecases/
│       └── stream_usecases.dart   # Single-responsibility use cases
│
├── presentation/
│   ├── auth/                      # Login + role selection
│   ├── home/                      # Live stream discovery grid
│   ├── create_live/               # Stream config form
│   ├── host_live/                 # Broadcaster screen (Agora + RTMP)
│   ├── audience_live/             # Viewer screen
│   ├── bindings/                  # GetX dependency bindings
│   └── routes/                    # Centralised route table
│
└── main.dart                      # Entry point, service boot
```

---

## 🚀 Quick Start

### 1. Prerequisites

- Flutter `>=3.6.0`
- Dart `>=3.6.0`
- An [Agora](https://console.agora.io) account (free tier includes 10,000 minutes/month)

### 2. Clone & Install

```bash
git clone <your-repo-url>
cd livehub
flutter pub get
```

### 3. Configure Agora App ID

Open `lib/core/constants/app_constants.dart` and replace:

```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID_HERE';
```

with your actual App ID from [console.agora.io](https://console.agora.io).

> ⚠️ **Never commit your App ID to a public repo.** Use environment variables or a secrets manager in production.

### 4. Run the App

```bash
# Android
flutter run

# iOS (requires macOS + Xcode)
cd ios && pod install && cd ..
flutter run
```

---

## 🎙 Agora Setup Guide

### Step 1 — Create a Project

1. Sign in at [console.agora.io](https://console.agora.io)
2. Click **Create New Project**
3. Select **Secured mode** (token) for production, or **Testing mode** for development
4. Copy the **App ID**

### Step 2 — Enable Media Push (RTMP)

1. In your project → **Extensions**
2. Enable **Media Push**
3. This allows `startRtmpStreamWithoutTranscoding()` to function

### Step 3 — Token Server (Production)

For production apps, deploy a token server. Agora provides reference implementations:

```
https://github.com/AgoraIO-Community/agora-token-service
```

Update `AgoraConfig.tokenServerUrl` with your server URL.

---

## 📡 RTMP Restreaming Workflow

```
Host presses "Go Live"
       │
       ▼
Agora channel joined (WebRTC)
       │
       ▼
onJoinChannelSuccess fires
       │
       ▼
startRtmpStreamWithoutTranscoding(url) called
       │
       ▼
onRtmpStreamingStateChanged → Running
       │
       ├── Host UI: "RTMP Connected ✓"
       └── Viewers on YouTube/Facebook see the stream
```

### RTMP URL Format

| Platform | Base URL |
|---|---|
| YouTube Live | `rtmp://a.rtmp.youtube.com/live2/` |
| Facebook Live | `rtmps://live-api-s.facebook.com:443/rtmp/` |
| Custom | Any valid `rtmp://` or `rtmps://` endpoint |

The full push URL = **Base URL** + **Stream Key**  
e.g. `rtmp://a.rtmp.youtube.com/live2/xxxx-xxxx-xxxx-xxxx`

---

## 📱 Platform Configuration

### Android

- **Min SDK:** 21 (required by Agora)
- **Permissions:** Camera, Microphone, Internet, Wake Lock (all in `AndroidManifest.xml`)
- **ProGuard:** Rules in `android/app/proguard-rules.pro`

### iOS

- **Min iOS:** 12.0
- **Permissions:** NSCameraUsageDescription, NSMicrophoneUsageDescription, NSLocalNetworkUsageDescription (all in `Info.plist`)
- **Background Modes:** `audio`, `voip` (required for streams to continue when backgrounded)
- **ATS:** `NSAllowsArbitraryLoads = true` (required for plain RTMP; remove for RTMPS-only)

```bash
# After pub get on iOS
cd ios
pod install
cd ..
```

---

## 🎨 Design System

| Token | Value | Usage |
|---|---|---|
| `primaryColor` | `#FF2D55` | Live badge, CTAs, gradients |
| `secondaryColor` | `#6C63FF` | Purple accents, avatars |
| `accentColor` | `#00D2FF` | Cyan highlights, info badges |
| `darkBg` | `#0A0A0F` | Main background |
| `darkCard` | `#1A1A2E` | Card / input surfaces |
| `successColor` | `#34C759` | RTMP Connected state |
| `warningColor` | `#FF9500` | RTMP Connecting state |
| `errorColor` | `#FF3B30` | Errors, End Live button |

Typography is served by `google_fonts` (Inter family) — no font files to bundle.

---

## ⚡ Key Dependencies

| Package | Purpose |
|---|---|
| `agora_rtc_engine ^6.3` | Agora RTC (video, audio, RTMP push) |
| `get ^4.6` | State management, routing, DI |
| `get_storage ^2.1` | Local storage (streams, user) |
| `permission_handler ^11` | Runtime camera/mic permissions |
| `wakelock_plus ^1.2` | Keep screen on during broadcast |
| `stop_watch_timer ^3.2` | Streaming duration timer |
| `flutter_animate ^4.5` | Smooth UI micro-animations |
| `google_fonts ^6.2` | Inter font via network |
| `equatable ^2.0` | Value equality for models |
| `uuid ^4.5` | Channel ID generation |

---

## 🔐 Security Notes

1. **App ID** — Treat like a password. Use token auth in production.
2. **Stream Key** — Shown masked in the UI. Never log it.
3. **Token** — Tokens expire. Implement refresh logic for production via your token server.
4. **RTMP** — Plain RTMP is unencrypted. Prefer `rtmps://` (Facebook, custom) where available.

---

## 🛠 Error Handling

| Scenario | UI Response |
|---|---|
| Camera/mic denied | Snackbar with "Open Settings" button |
| Invalid RTMP URL | Inline form validation + snackbar |
| Agora join failed | Status → `Failed`, snackbar with retry hint |
| RTMP push failed | `RTMP Failed ✗` chip + snackbar with error code |
| Network drop | Status → `Reconnecting`, auto-reconnect by Agora |
| Token expired | `errInvalidToken` → status `Failed`, prompt re-auth |

---

## 🏗 Architecture Decisions

- **Clean Architecture** — Domain layer has zero Flutter/platform dependencies. Business logic is fully testable.
- **Repository Pattern** — `StreamRepository` abstract interface separates domain from data. Swap local storage for a Firebase/Supabase implementation by providing a new `StreamRepository` implementation.
- **GetX** — Chosen for unified state management + routing + DI with minimal boilerplate, ideal for real-time reactive streaming data.
- **Permanent Services** — `AgoraService` and `StorageService` are registered as `permanent: true` so they survive screen navigation.

---

## 📄 License

MIT — free for personal and commercial use.

---

*Built with Flutter and ❤️ by the LiveHub team*
#   S t r e a m i n g A p p  
 