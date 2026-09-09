# redhawkwallet-flutter

Flutter-based cross-platform version of Red Hawk Wallet, a campus commerce and
student wallet platform with student, vendor, and admin features.

## Stack

- **Flutter** (Dart) — Android and iOS
- **Firebase** — Auth, Cloud Firestore, Cloud Functions, Cloud Messaging, Storage
- **Stripe** — add-funds (sandbox)
- **go_router** — routing and role-based redirects

## Prerequisites

- Flutter SDK (stable channel)
- Xcode + CocoaPods (iOS), Android SDK (Android)
- A Firebase project with `google-services.json` (Android) and
  `GoogleService-Info.plist` (iOS) in place
- Firebase CLI, for deploying `functions/`, `firestore.rules`, and
  `firestore.indexes.json`

## Run

```sh
flutter pub get
flutter run                 # pick a connected device or emulator
```

For a physical iOS device, sign the Runner target with your team in Xcode first
(`open ios/Runner.xcworkspace`).

## Cloud Functions

```sh
cd functions
npm install
npm run deploy              # or: firebase deploy --only functions
```

`sendSupportMessage` needs the `ANTHROPIC_API_KEY` secret
(`firebase functions:secrets:set ANTHROPIC_API_KEY`).

## Branches

- `main` — released/stable
- `dev` — integration branch; feature branches merge here first
