# CLAUDE.md

This file provides guidance for Claude Code when working in this repository.

## Project Overview

This is an iOS Swift/SwiftUI app called **HomeworkHelper** — an AI-powered homework assistant supporting multiple AI providers. It lives in the `HomeworkHelper/` directory and is a standard Xcode project with no build scripts or CI.

## Architecture

- **MVVM** — `ChatViewModel` owns all state; views are dumb
- **No third-party dependencies** — URLSession for networking, Security.framework for Keychain
- **Actor-based services** — `AnthropicService` and `OpenAICompatibleService` are Swift `actor` types using `async/await`
- **Multi-provider** — `AIProvider` enum drives which service and endpoint are used per request

## AI Providers

| Provider | Model | Key Required |
|---|---|---|
| Free (Pollinations.ai) | `openai` (GPT-4o mini) | No — works out of the box |
| Anthropic | `claude-haiku-4-5-20251001` | Yes — `console.anthropic.com` |
| OpenAI | `gpt-4o-mini` | Yes — `platform.openai.com` |
| OpenRouter | `meta-llama/llama-3.1-8b-instruct:free` | Yes — `openrouter.ai` |

## Key Files

| File | Role |
|---|---|
| `HomeworkHelper/Models/AIProvider.swift` | Provider enum — edit to add/change providers, models, endpoints |
| `HomeworkHelper/Services/AnthropicService.swift` | Anthropic API client (Anthropic wire format) |
| `HomeworkHelper/Services/OpenAICompatibleService.swift` | Client for OpenAI-compatible providers (Free/OpenAI/OpenRouter) |
| `HomeworkHelper/Services/KeychainService.swift` | Per-provider API key storage — never store keys anywhere else |
| `HomeworkHelper/ViewModels/ChatViewModel.swift` | All business logic and state — system prompt lives here |
| `HomeworkHelper/Models/AnthropicRequest.swift` | Anthropic wire format — custom `Encodable` for content blocks |
| `HomeworkHelper/Models/OpenAIRequest.swift` | OpenAI wire format — text + image_url content blocks |

## Development Notes

- **iOS 16+ target** — do not use APIs newer than iOS 16 without a version check
- **No hardcoded API keys** — always use `KeychainService`. Keyless providers (`.free`) pass `nil`
- **Image resizing** — both services cap images at 1568px before base64 encoding; keep this in place
- **Conversation history** — only the last 10 messages are sent per request (`maxHistoryMessages`)
- **System prompt** — base prompt is a private `let` in `ChatViewModel.swift`; subject hints are prepended per request
- **Free provider** — `AIProvider.requiresAPIKey == false` skips Keychain checks and omits the `Authorization` header entirely

## Adding a New AI Provider

1. Add a case to `AIProvider` in `Models/AIProvider.swift`
2. Fill in `icon`, `defaultModel`, `apiEndpoint`, `requiresAPIKey`, `pricingNote`, etc.
3. If it uses OpenAI-compatible format, set `usesOpenAIFormat = true` — no other changes needed
4. If it uses a new wire format, create a new `actor` service and add a branch in `ChatViewModel.sendMessage()`

## Adding a New Subject

1. Add a case to the `Subject` enum in `Models/Subject.swift`
2. Add the `icon` (SF Symbol name), `systemPromptHint`, and `rawValue`
3. No other changes needed — `Subject.allCases` drives the UI automatically

## No Build Commands

This is an Xcode project — there are no `make`, `npm`, or `swift build` commands to run. Open `HomeworkHelper/HomeworkHelper.xcodeproj` in Xcode 15+ and press Cmd+R to build.
