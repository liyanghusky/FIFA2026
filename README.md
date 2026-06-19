# FIFA2026

Windows-friendly local FIFA World Cup 2026 tracker.

## Run on Windows

Double-click:

```text
outputs/open-worldcup-tracker.bat
```

It starts a local Python server and opens:

```text
http://127.0.0.1:8766/
```

You can also run it manually:

```bash
py server_worldcup.py
```

## Features

- 48-team list
- Group standings
- Match schedule with local kick-off times
- Venue and broadcast labels when provided
- Search, group filter, status filter and refresh

Data is loaded through ESPN's public soccer endpoints, with official FIFA schedule and standings links included in the app metadata.
