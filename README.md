# Universal Clipboard Sync

A cross-platform clipboard synchronization system built with **Flutter** that enables near real-time sharing of clipboard text across multiple devices, independent of proprietary ecosystems.

This project was built as a hackathon MVP to demonstrate the feasibility of **secure, peer-to-peer clipboard sync** across heterogeneous devices.

---

## Overview

In multi-device workflows, copying content on one device and pasting it on another is often restricted to platform-locked solutions. **Universal Clipboard Sync* aims to solve this by providing:

- Cross-platform clipboard monitoring

- Secure device pairing

- Peer-to-peer clipboard synchronization

- Local clipboard history

- User-controlled sync behavior

The system is designed to be **offline-first**, **low-latency**, and **platform-agnostic**.

## High-Level Architecture

```
    ┌────────────┐
    │OS Clipboard│
    └─────┬──────┘
          │ (polling)
          ▼
┌─────────────────────┐
│ Flutter Application │
│                     │
│  Clipboard Service  │
│  Deduplication      │
│  SQLite Database    │
│                     │
│  Sync Service       │
│  WebRTC DataChannel │
└──────────┬──────────┘
           │ (signaling only)
           ▼
 ┌────────────────────┐
 │ WebSocket Server   │
 │ (Signaling Layer)  │
 └────────────────────┘
```

### Key Design Choice

- **Clipboard data never passes through the server**
- **Clipboard content is sent peer-to-peer via WebRTC**
- **The server is used only for signaling**

---

## Core Components

### 1. Clipboard Monitoring

**Location:** `services/clipboard_service.dart`

- Flutter does not expose native clipboard change events

- Clipboard is polled every **~800ms**

- On change:

    - Content is hashed (**SHA-256**)

    - Deduplicated

    - Stored locally in SQLite

**Why polling?**
This is the only reliable cross-platform approach available in Flutter today.

---

### 2. Local Storage (SQLite)

**Location:** `data/database/`

**Tables:**
- `clipboard_events` – clipboard history
- `devices` – paired devices
- `sync_state` – per-device sync tracking
- `settings` – user preferences

**Why SQLite?**
- Fast local reads
- Offline support
- Enables clipboard history, deduplication, and retry logic

---

### 3. Device Pairing

**Location:** `services/pairing_service.dart`, `ui/add_device/`

- Devices generate:
  - Device ID
  - Public key *(placeholder)*
  - One-time pairing code

- Pairing info is displayed as a **QR code**
- Designed for future secure pairing flow

**Current state:** pairing UI + identity generation

---

### 4. Networking Model
#### Signaling Server (WebSocket)

**Location:** `signaling-server/server.js`

- Minimal **Node.js WebSocket server**

**Responsibilities:**
- Room-based peer discovery
- Relaying WebRTC offers, answers, and ICE candidates

**Why WebSocket signaling?**  
WebRTC requires an external channel to exchange connection metadata.

---


#### Peer-to-Peer Sync (WebRTC)

**Location:** `network/webrtc_connection.dart`

- WebRTC `RTCPeerConnection`
- Reliable ordered `RTCDataChannel`
- Clipboard data sent directly between devices

**Why WebRTC?**
- Low latency
- No server bandwidth usage
- Supports LAN and internet peers
- Aligns with privacy & scalability goals

---

### 5. Sync Protocol

**Location:** `network/protocol.dart`, `services/sync_service.dart`

A lightweight custom protocol:


| Message Type  | Purpose                              |
|---------------|--------------------------------------|
| `hello`       | Device presence                      |
| `eventList`   | Exchange clipboard event IDs         |
| `requestEvent`| Request missing clipboard content    |
| `sendEvent`   | Send clipboard data                  |
| `ack`         | Confirm successful sync              |

**Why ID-based sync?**
- Avoids duplicate transfers
- Enables conflict handling
- Scales to many devices

---


## User Interface

**Location:** `ui/`

**Screens:**
- **History** – local clipboard history
- **Devices** – paired devices + online status
- **Add Device** – QR-based pairing
- **Settings**
  - Enable / disable sync
  - Max clipboard size
  - Clear history

---

## Technology Stack

### Client

- Flutter / Dart
- SQLite (`sqlite3`, `path_provider`)
- WebRTC (`flutter_webrtc`)
- WebSockets (`web_socket_channel`)
- QR generation (`qr_flutter`)
- Cryptography (`crypto`, `uuid`)

### Server

- Node.js
- `ws` WebSocket library

---


## Security & Privacy (Design Goals)

- Clipboard data is never stored on a server
- Peer-to-peer data transfer
- Cryptographic hashes for deduplication
- Public-key infrastructure planned *(future work)*

---

## How to Run

### Signaling Server

```bash
cd signaling-server
npm install ws
node server.js
```

Server runs on:

```bash
ws://localhost:8080
```

### Flutter App

```bash
flutter pub get
flutter run
```

Run on two devices or emulators for testing.



Universal Clipboard Sync demonstrates a privacy-first, peer-to-peer approach to cross-platform clipboard synchronization. While this hackathon version focuses on core architecture and feasibility, the design is intentionally extensible and scalable.


