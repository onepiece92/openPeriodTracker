# Privacy Policy

**Luna: Open Period & Cycle Tracker**
*Last updated: March 27, 2026*

## Overview

Luna: Open Period & Cycle Tracker ("Luna", "the App", "we", "our") is a menstrual cycle tracking application developed by Brand Builder. We are committed to protecting your privacy. This Privacy Policy explains how the App handles your information.

**The most important thing to know: All your data stays on your device. We do not collect, transmit, store, or share any personal or health data.**

## Information We Do NOT Collect

- We do **not** collect personal information (name, email, phone number, address)
- We do **not** collect health or medical data from your device
- We do **not** use analytics, tracking pixels, or telemetry
- We do **not** use cookies or similar tracking technologies
- We do **not** require user accounts, registration, or login
- We do **not** transmit any data to remote servers
- We do **not** use advertising or ad networks
- We do **not** share data with third parties
- We do **not** sell user data

## Data Stored Locally on Your Device

The App stores the following data **exclusively on your device** using a local SQLite database:

### Health & Cycle Data
- Period start and end dates
- Flow intensity (light, medium, heavy)
- Mood selections
- Symptom selections
- Medical checklist responses (pain level, discharge, sleep quality, skin condition, energy level, digestion, weight changes, libido, breast changes, hair changes)
- Free-text notes

### Personal Information (Optional)
- Name and nickname (used only for in-app greeting)
- Birthday (used only to calculate age for age-appropriate health insights)

### App Preferences
- Cycle length and period length settings
- Default flow and mood preferences

**This data never leaves your device unless you explicitly choose to export it.**

## Data Export & Import

The App provides a CSV export feature that allows you to:
- Export all your cycle data to a CSV file
- Share that file via your device's share sheet (AirDrop, email, files, etc.)
- Import previously exported data

**You are in full control of when and how your data is exported.** The App does not automatically backup or sync data to any cloud service.

## Location Data

The App may request access to your device's location services. This is used **solely** to:
- Determine your geographic region (country/city)
- Provide region-appropriate diet and food recommendations

**Location data is:**
- Processed entirely on your device
- Never transmitted to any server
- Never stored permanently
- Used only at the moment of request to determine your region

You can deny location permission and the App will function fully — diet recommendations will default to global suggestions instead of region-specific ones.

## Notifications

The App may request permission to send local notifications. These are used **solely** to:
- Remind you when your predicted period date has passed (late period alert)

**Notifications are:**
- Generated entirely on your device
- Scheduled locally using your cycle prediction data
- Never sent from a remote server
- Fully optional — you can deny notification permission

## Optional AI Features

### On-Device Analysis
The App includes an on-device health analysis feature that generates cycle insights, health summaries, and diet recommendations. This analysis runs **entirely on your device** using rule-based algorithms and does not require any network connection.

### Ollama Integration (Optional)
The App optionally supports connecting to a local Ollama LLM server for enhanced AI health summaries. If you choose to enable this:
- The connection is made to a **user-configured local network address** (default: localhost)
- Cycle data is sent only to your own local Ollama server
- No data is sent to any external server or cloud service
- This feature is entirely opt-in and disabled by default

### AI Prompt Builder
The App generates text prompts containing your cycle data that you can manually copy and paste into external AI services (such as ChatGPT, Gemini, or Claude). **This action is entirely manual and user-initiated.** The App does not automatically send data to any external AI service.

## Third-Party Services

The App does **not** integrate with any third-party services for data collection, analytics, or advertising. The following third-party packages are used purely for on-device functionality:

| Package | Purpose | Network Usage |
|---------|---------|--------------|
| sqflite | Local database storage | None |
| geolocator | Device GPS location | None (on-device only) |
| geocoding | Convert coordinates to city/country | On-device processing |
| google_fonts | Typography | Initial font download only |
| flutter_local_notifications | Local notification scheduling | None |
| tflite_flutter | On-device machine learning | None |

## Children's Privacy

The App does not knowingly collect information from children under 13 years of age. The App does not require age verification, account creation, or any personal information to function. All data is stored locally on the device.

## Data Security

Your data is protected by:
- **Local-only storage** — Data exists only on your physical device
- **No network transmission** — Core app features make zero network calls
- **No cloud backup** — Data is not backed up to any cloud service by the App
- **Device encryption** — Your data benefits from your device's built-in encryption
- **User-controlled export** — Only you can export your data, and only when you choose to

## Data Retention & Deletion

- All data is stored locally on your device for as long as you use the App
- You can delete all data at any time using the "Reset All Data" feature in the App's Profile section
- Uninstalling the App removes all associated data from your device
- We retain no copies of your data on any server

## Medical Disclaimer

The App provides health insights, cycle predictions, diet recommendations, and wellness suggestions for **informational purposes only**. The App does **not** provide medical advice, diagnoses, or treatment recommendations. The health analysis features are based on general guidelines and your logged data patterns.

Always consult a qualified healthcare professional for medical advice. Do not rely solely on the App for health decisions.

## Your Rights

You have the right to:
- **Access** all your data (it's on your device and you can export it anytime)
- **Delete** all your data (via the Reset feature)
- **Port** your data (via CSV export)
- **Control** location and notification permissions (via device settings)
- **Use** the App without providing any personal information

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time. Any changes will be reflected in the "Last updated" date at the top of this document. Continued use of the App after changes constitutes acceptance of the updated policy.

## Open Source

The App is open source. You can review the complete source code to verify our privacy practices at:
https://github.com/YOUR_USERNAME/luna-period-tracker

## Contact Us

If you have questions or concerns about this Privacy Policy, please contact us at:

**Email:** [your-email@example.com]
**GitHub:** https://github.com/YOUR_USERNAME/luna-period-tracker/issues

## Compliance

This App is designed to comply with:
- **GDPR** (General Data Protection Regulation) — No personal data is collected or processed by us
- **CCPA** (California Consumer Privacy Act) — No personal information is sold or shared
- **HIPAA** — The App is not a covered entity; no health data is transmitted or stored externally
- **Apple App Store Guidelines** — Health data is stored locally and handled per Apple's requirements
- **Google Play Policies** — Health data handling complies with Google's sensitive data policies

---

*Luna: Open Period & Cycle Tracker is developed by Brand Builder.*
*Bundle ID: com.brandbuilder.periodtracker*
