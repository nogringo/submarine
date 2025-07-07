# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Submarine is a Nostr-based password manager that stores encrypted secrets on the Nostr network using event kind 4111. It implements a custom NIP (Nostr Improvement Proposal) for decentralized password management.

## Key Technologies

- **Flutter**: Cross-platform framework (supports Web, Desktop, Mobile)
- **GetX**: State management, routing, and dependency injection
- **NDK (Nostr Development Kit)**: Nostr protocol integration
- **NIP-44**: Encryption standard for content
- **Sembast**: Local database for caching

## Architecture

### State Management Pattern
The project uses GetX with a consistent pattern:
- Controllers extend `GetxController`
- Reactive state using `.obs` observables
- UI updates via `Obx` widgets
- Example pattern:
```dart
// In controller
final secrets = <Secret>[].obs;

// In view
Obx(() => ListView.builder(
  itemCount: controller.secrets.length,
  ...
))
```

### Repository Pattern
Central `Repository` class (`lib/repository.dart`) manages:
- Nostr event publishing/listening
- User authentication via private key
- Encryption/decryption of secrets
- Real-time updates via streams

### Routing
Named routes defined in `lib/app_routes.dart`:
- `/sign-in`: Login page
- `/`: Password manager (main page)
- `/create-password`: Create new secret
- `/secret-detail`: View secret details
- `/create-note`: Create note (future feature)

## Development Commands

```bash
# Run the app
flutter run

# Build for production
flutter build web --release --base-href /submarine/  # For GitHub Pages
flutter build apk
flutter build ios
flutter build windows/macos/linux

# Code quality
flutter analyze
flutter format .
flutter test

# Add packages
flutter pub add <package_name>  # Always use this command to add dependencies
```

## Data Models

### Secret Structure (from NIP.md)
```json
{
  "id": "<random id>",
  "title": "<title>",
  "fields": [
    {"name": "Username", "kind": "text", "value": "user@example.com"},
    {"name": "Password", "kind": "secret", "value": "encrypted_password"},
    {"name": "OTP", "kind": "otp", "value": {...}}
  ],
  "urls": ["https://example.com"],
  "note": "Optional note"
}
```

### Field Types
- **text**: Visible text fields
- **secret**: Hidden fields (passwords) with visibility toggle
- **otp**: TOTP/HOTP fields with progress indicator

## Important Implementation Details

### Encryption
- All secrets encrypted using NIP-44 before storing on Nostr
- Private key stored locally using `flutter_secure_storage`
- Shared secrets use recipient's public key for encryption

### Event Handling
- Secrets stored as kind 4111 events
- Deletions use kind 5 events (NIP-09)
- Real-time updates via NDK event listeners

### UI Components
- `AreaView`: Reusable container widget in `lib/widgets/area_view.dart`
- Consistent theming with system accent color support
- Desktop apps use custom window management (hidden title bar)

## Current Features

- ✅ Create, read, update, delete secrets
- ✅ Multiple field types (text, password, OTP placeholders)
- ✅ Local caching with Sembast
- ✅ Real-time sync across devices
- ⏳ OTP generation (UI ready, needs OTP package)
- ⏳ Secret sharing (protocol defined, not implemented)

## Testing Approach

When testing Nostr functionality:
1. Use test relays or local relay for development
2. Create test accounts with temporary private keys
3. Clean up test events after testing

## Common Tasks

### Adding a New Page
1. Create folder in `lib/screens/<feature_name>/`
2. Create page and controller files
3. Add route to `lib/app_routes.dart`
4. Register route in `main.dart` getPages list
5. Add middleware if authentication required

### Working with Secrets
- Always use `Repository.to` for Nostr operations
- Subscribe to `secretsStream` for real-time updates
- Handle encryption/decryption through Repository methods

### UI Consistency
- Use `AreaView` widget for consistent containers
- Follow existing field display patterns from create_password_page
- Implement tap-to-copy for sensitive fields
- Use toastification for user feedback (when added)