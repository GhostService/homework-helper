# HomeworkHelper

An iOS homework and study assistant powered by your choice of AI provider — including a **fully free, no-account-required** option. Students can photograph or type problems across 9 subjects and get step-by-step explanations via a conversational chat interface.

## AI Providers

| Provider | Model | API Key |
|---|---|---|
| **Free** (Pollinations.ai) | GPT-4o mini | None — works out of the box |
| **Anthropic** | Claude Haiku (`claude-haiku-4-5-20251001`) | Free tier at `console.anthropic.com` |
| **OpenAI** | GPT-4o mini | `platform.openai.com` |
| **OpenRouter** | Llama 3.1 8B (free tier) | `openrouter.ai` |

Switch providers any time from the home screen. All API keys are stored securely in the iOS Keychain — never hardcoded.

## Features

- **Free by default** — the Free provider (Pollinations.ai) requires no sign-up, no API key, and works immediately on install
- **Photo input** — take a photo or upload from library; images are auto-resized to 1568px max and sent as base64
- **Conversational chat** — full multi-turn history with follow-up question support
- **9 subjects** — Math, Physics, Chemistry, Biology, English, History, Computer Science, Economics, General
- **Step-by-step explanations** — numbered steps, bold key terms, `Answer:` line, and a `Key Concept:` summary
- **iOS 16+** — SwiftUI + MVVM, zero third-party dependencies

## Project Structure

```
HomeworkHelper/
├── HomeworkHelper.xcodeproj
└── HomeworkHelper/
    ├── HomeworkHelperApp.swift
    ├── Info.plist
    ├── Assets.xcassets
    ├── Models/
    │   ├── AIProvider.swift            # Provider enum (endpoints, keys, models)
    │   ├── Subject.swift               # Subject enum (drives subject picker UI)
    │   ├── ChatMessage.swift
    │   ├── AnthropicRequest.swift      # Anthropic wire format
    │   ├── AnthropicResponse.swift
    │   └── OpenAIRequest.swift         # OpenAI-compatible wire format
    ├── Services/
    │   ├── AnthropicService.swift      # Anthropic Messages API client
    │   ├── OpenAICompatibleService.swift  # OpenAI/OpenRouter/Free client
    │   └── KeychainService.swift       # Per-provider key storage
    ├── ViewModels/
    │   └── ChatViewModel.swift         # All state + business logic
    └── Views/
        ├── ContentView.swift
        ├── HomeView.swift              # Provider + subject pickers, CTAs
        ├── ChatView.swift
        ├── MessageBubble.swift
        ├── ImagePickerView.swift
        ├── CameraView.swift
        ├── SubjectSelectorView.swift
        ├── SettingsView.swift          # Per-provider key management
        └── LoadingIndicator.swift
```

## Installing on Your iPhone

You need a Mac with Xcode installed. No paid Apple Developer account required (free sideloading works, but apps expire after 7 days and need to be reinstalled).

### Step 1 — Open the project

```bash
open HomeworkHelper/HomeworkHelper.xcodeproj
```

Or double-click `HomeworkHelper.xcodeproj` in Finder.

### Step 2 — Sign in with your Apple ID

- Xcode menu → **Settings → Accounts**
- Click **+** → **Apple ID** → sign in with your regular Apple account

### Step 3 — Set up code signing

- In the left sidebar click the **HomeworkHelper** project (top item)
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

Press **Cmd+R** (or the play button). Xcode will build and push the app to your phone.

### Step 7 — Trust the app on your iPhone

iOS blocks unsigned apps by default the first time:

- **Settings → General → VPN & Device Management**
- Tap your Apple ID email under "Developer App"
- Tap **Trust**

### Step 8 — Start using the app

The app opens to the **Free** provider by default — no API key needed, just start asking questions. To use Anthropic, OpenAI, or OpenRouter, tap the gear icon and add your key in Settings.

> **Note:** Free Apple accounts require reinstalling every 7 days. Reconnect your phone and press Cmd+R again. A paid Apple Developer account ($99/year) removes this limit and lets you submit to the App Store.

## Technical Details

- **No backend** — all API calls are made directly from the app via `URLSession`
- **Free provider** — `POST https://text.pollinations.ai/openai` — OpenAI-compatible, no `Authorization` header
- **Anthropic provider** — `POST https://api.anthropic.com/v1/messages` with `x-api-key` header
- **OpenAI / OpenRouter** — `POST` to respective `/v1/chat/completions` endpoints with `Bearer` token
- **Images** — JPEG, max 1568px, base64-encoded inline in each request
- **Conversation window** — last 10 messages sent per request to manage token usage
- **Max tokens** — 2048 per response

## Requirements

- iOS 16.0+
- Xcode 15+
- No API key required for the Free tier
