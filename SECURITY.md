# Security Policy

## Data Privacy

Luna is designed with a **zero-trust, privacy-first** architecture:

- All data is stored locally on your device using SQLite
- The app makes zero network calls for core functionality
- No analytics, telemetry, or crash reporting is collected
- No user accounts or cloud sync exists
- Location data (for regional diet recommendations) is processed on-device and never transmitted

## Optional Network Features

- **Ollama LLM**: Connects only to a user-configured local server (default: localhost:11434). No data leaves your local network.
- **Geolocator**: Uses device GPS for regional food recommendations. Coordinates are processed locally and never stored or transmitted.

## Reporting a Vulnerability

If you discover a security vulnerability, please:

1. **Do NOT** open a public issue
2. Email: [your-email@example.com]
3. Include steps to reproduce
4. Allow 48 hours for initial response

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x.x   | Yes      |

## Data Export

Users can export all their data as CSV at any time via Profile > Export. This ensures data portability and user control.
