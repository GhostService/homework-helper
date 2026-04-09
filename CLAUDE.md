# CLAUDE.md

This file provides guidance for Claude Code when working in this repository.

## Project Overview

This is an iOS Swift/SwiftUI app called **HomeworkHelper** — a Claude Haiku-powered homework assistant. It lives in the `HomeworkHelper/` directory and is a standard Xcode project with no build scripts or CI.

## Architecture

- **MVVM** — `ChatViewModel` owns all state; views are dumb
- **No third-party dependencies** — URLSession for networking, Security.framework for Keychain
- **Actor-based service** — `AnthropicService` is a Swift `actor` using `async/await`
- **Model**: `claude-haiku-4-5-20251001` via `POST https://api.anthropic.com/v1/messages`

## Key Files

| File | Role |
|---|---|
| `HomeworkHelper/Services/AnthropicService.swift` | Anthropic API client — edit this to change model, token limits, image handling |
| `HomeworkHelper/ViewModels/ChatViewModel.swift` | All business logic and state — system prompt lives here |
| `HomeworkHelper/Models/AnthropicRequest.swift` | Wire format for the API — custom `Encodable` for content blocks |
| `HomeworkHelper/Services/KeychainService.swift` | API key storage — do not store keys anywhere else |

## Development Notes

- **iOS 16+ target** — do not use APIs newer than iOS 16 without a version check
- **No hardcoded API keys** — always use `KeychainService`
- **Image resizing** — `AnthropicService.resizeImage()` caps at 1568px before encoding; keep this in place to avoid API payload limits
- **Conversation history** — only the last 10 messages are sent per request (`maxHistoryMessages`); adjust in `AnthropicService` if needed
- **System prompt** — the base prompt is a private `let` at the top of `ChatViewModel.swift`; subject-specific prefixes are appended per request

## Adding a New Subject

1. Add a case to the `Subject` enum in `Models/Subject.swift`
2. Add the `icon` (SF Symbol name), `systemPromptHint`, and `rawValue`
3. No other changes needed — `Subject.allCases` drives the UI automatically

## No Build Commands

This is an Xcode project — there are no `make`, `npm`, or `swift build` commands to run. Open `HomeworkHelper/HomeworkHelper.xcodeproj` in Xcode 15+ and press Cmd+R to build.
