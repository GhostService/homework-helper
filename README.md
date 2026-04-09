# HomeworkHelper

An iOS app that uses **Claude Haiku** (`claude-haiku-4-5-20251001`) as an AI-powered homework and study assistant — a replacement for Gauth AI built on Anthropic's API.

Students can photograph or type homework problems across 9 subjects and receive step-by-step explanations via a conversational chat interface.

## Features

- **Photo input** — take a photo or upload from library; image is auto-resized and sent to Claude as base64
- **Conversational chat** — full multi-turn history with follow-up question support
- **9 subjects** — Math, Physics, Chemistry, Biology, English, History, Computer Science, Economics, General
- **Step-by-step explanations** — structured responses with numbered steps, bold key terms, and a final answer line
- **Secure API key storage** — Anthropic key stored in iOS Keychain, never hardcoded
- **iOS 16+** — SwiftUI + MVVM, no third-party dependencies

## Project Structure

```
HomeworkHelper/
├── HomeworkHelper.xcodeproj
└── HomeworkHelper/
    ├── HomeworkHelperApp.swift
    ├── Info.plist
    ├── Assets.xcassets
    ├── Models/
    │   ├── Subject.swift
    │   ├── ChatMessage.swift
    │   ├── AnthropicRequest.swift
    │   └── AnthropicResponse.swift
    ├── Services/
    │   ├── AnthropicService.swift      # Anthropic Messages API client
    │   └── KeychainService.swift       # Secure key storage
    ├── ViewModels/
    │   └── ChatViewModel.swift         # All state + business logic
    └── Views/
        ├── ContentView.swift
        ├── HomeView.swift
        ├── ChatView.swift
        ├── MessageBubble.swift
        ├── ImagePickerView.swift
        ├── CameraView.swift
        ├── SubjectSelectorView.swift
        ├── SettingsView.swift
        └── LoadingIndicator.swift
```

## Installing on Your iPhone

You need a Mac with Xcode installed. No paid Apple Developer account required (free sideloading works, but apps expire after 7 days).

### Step 1 — Open the project

```bash
open HomeworkHelper/HomeworkHelper.xcodeproj
```

Or double-click `HomeworkHelper.xcodeproj` in Finder.

### Step 2 — Sign in with your Apple ID

- In Xcode: **Xcode menu → Settings → Accounts**
- Click **+** → **Apple ID** → sign in with your regular Apple account

### Step 3 — Set up code signing

- In the left sidebar, click the **HomeworkHelper** project (top item)
- Select the **HomeworkHelper** target → **Signing & Capabilities** tab
- Check **Automatically manage signing**
- Set **Team** to your Apple ID name
- Change **Bundle Identifier** to something unique, e.g. `com.yourname.homeworkhelper`

### Step 4 — Connect your iPhone

- Plug it into your Mac with a USB cable
- On your iPhone: tap **Trust** when prompted, then enter your passcode

### Step 5 — Select your iPhone as the build target

- At the top of Xcode, click the device/simulator selector (e.g. "iPhone 16 Pro")
- Your connected iPhone should appear — select it

### Step 6 — Build and install

Press **Cmd+R** (or click the play button). Xcode will build and push the app to your phone.

### Step 7 — Trust the app on your iPhone

iOS blocks unsigned apps by default the first time:

- **Settings → General → VPN & Device Management**
- Tap your Apple ID email under "Developer App"
- Tap **Trust**

### Step 8 — Add your Anthropic API key

- Get a free API key at `console.anthropic.com`
- Open the app — it prompts for your key on first launch
- The key is stored securely in the iOS Keychain

> **Note:** Free Apple accounts require reinstalling every 7 days. Just reconnect your phone and press Cmd+R again. A paid Apple Developer account ($99/year) removes this limit.

## API

The app calls `POST https://api.anthropic.com/v1/messages` directly via `URLSession`. No backend required — your API key stays on-device in the Keychain.

- Model: `claude-haiku-4-5-20251001`
- Max tokens: 2048
- Images: JPEG, max 1568px, base64-encoded inline
- Conversation window: last 10 messages sent per request

## Requirements

- iOS 16.0+
- Xcode 15+
- Anthropic API key (free tier available at `console.anthropic.com`)
