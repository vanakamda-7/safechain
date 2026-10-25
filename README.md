# SafeChain

SafeChain is a privacy-first women's safety and guardian response application.

A user can raise an SOS alert by tapping the SOS button or shaking the phone.
Nearby verified guardians receive an anonymous zone-based alert.

After a guardian accepts the incident, the user can choose to share their exact
location with that guardian using the "Share My Exact Location" button.

## Important Setup

This project uses Firebase. Before running the app:

```bash
cd safetchain_app
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
flutter run
```

The `flutterfire configure` command generates:

```text
lib/firebase_options.dart
android/app/google-services.json
```

## Features

- User and guardian registration
- Email/password login
- SOS button
- Shake-to-SOS detection
- Location permission handling
- Anonymous nearby guardian alerts
- Guardian accept and response tracking
- Real-time incident status updates
- Consent-based exact location sharing
- I Am Safe button
- Emergency escalation option

## Location Privacy Flow

1. User grants Android location permission.
2. User triggers SOS.
3. App reads the user's GPS location.
4. App saves the incident and location in Firestore.
5. Nearby verified guardians receive only an anonymous zone alert.
6. Guardian accepts the incident.
7. User sees the "Share My Exact Location" button.
8. User taps the button to explicitly share exact GPS coordinates.
9. The responding guardian sees the shared exact location.

The guardian never receives the user's exact location unless the user taps
"Share My Exact Location".

## Firestore Collections

```text
users
guardians
incidents
incident_responses
guardians/{guardianId}/alerts
```

## Demo Firestore Rules

For local hackathon testing only:

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Do not use these rules in production.
