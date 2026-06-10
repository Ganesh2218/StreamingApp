# LiveHub

A Flutter live streaming app built with **Agora**. A host can go live, an audience can watch, and the same stream can be pushed to YouTube, Facebook, or any RTMP platform at the same time.

## Features

- Host go live (camera + mic) using Agora
- Audience join and watch a live stream
- Host end live, with a clear "Stream has ended" message for viewers
- Restream to YouTube / Facebook / custom RTMP (Agora Media Push)
- Mic, camera, and flip-camera controls
- Live viewer count, network quality, and stream timer
- Dark streaming UI with audience chat

## Requirements

- Flutter 3.6 or newer
- A free Agora account: https://console.agora.io

## Setup

### 1. Install packages

```bash
flutter pub get
```

### 2. Add your Agora App ID and token

Open `lib/core/constants/app_constants.dart` and set:

```dart
static const String agoraAppId = 'YOUR_APP_ID';
static const String agoraToken = 'YOUR_TEMP_TOKEN';
```

- **App ID**: Agora Console → your project → Basic Settings → App ID.
- **Temp Token**: Agora Console → Security → **Generate Temp Token**. When it asks for a channel name, enter `testchannel` (it must match `testChannelName` in the same file). The token lasts about 24 hours.

> The test channel is fixed in this build. Host and audience both use `testchannel`, and it must match the channel the token was generated for.

### 3. Run

```bash
flutter run
```

Use two devices: one as host, one as audience. A real phone is best for the host (emulators have no real camera).

## How to test

1. **Host device**: tap Go Live → Setup Stream → leave RTMP fields empty → Start Streaming. You should see your own camera.
2. **Audience device**: tap the **TEST – Join My Live Channel** tile, or type `testchannel` in the search box and tap the join icon.
3. The audience now sees the host's video.
4. When the host ends the stream, the audience screen shows **"Stream has ended"**.

## RTMP restreaming (YouTube / Facebook)

This part needs a **billing-enabled** Agora account with **Media Push** turned on (it is not free).

1. Agora Console → your project → enable **Media Push**.
2. In Setup Stream, choose a platform and enter the RTMP URL + stream key:
   - YouTube: `rtmp://a.rtmp.youtube.com/live2/` + your stream key
   - Facebook: `rtmps://live-api-s.facebook.com:443/rtmp/` + your stream key
3. Go live. The stream auto-pushes to the platform and stops when you end the live.

Instagram has no public RTMP endpoint, so it only works through a relay service (for example Restream.io).

## Project structure

```
lib/
├── core/          App constants, Agora service, theme, utils, shared widgets
├── data/          Models, local datasource, repository
├── domain/        Repository contracts and use cases
└── presentation/  Auth, home, create live, host live, audience live screens
```

## Main packages

| Package | Use |
|---|---|
| agora_rtc_engine | Video, audio, and RTMP push |
| get | State management, routing, dependency injection |
| get_storage | Local storage |
| permission_handler | Camera and mic permissions |
| wakelock_plus | Keep the screen on while live |

## Notes

- App ID and tokens are secrets. Use a token server in production instead of a static temp token.
- For production, set `useTestChannel = false` in `app_constants.dart` so each stream gets its own channel.
