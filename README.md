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

If that port is already in use, the server automatically chooses the next available local port.

You can also run it manually:

```bash
py server_worldcup.py
```

## Deploy publicly

### GitHub Pages static version

This repo now includes a root `index.html` for GitHub Pages.

1. Go to GitHub repo Settings -> Pages.
2. Source: `Deploy from a branch`.
3. Branch: `main`, folder: `/ (root)`.
4. Save.
5. The public URL will be:

```text
https://liyanghusky.github.io/FIFA2026/
```

This static version fetches ESPN public endpoints directly in the browser.

### Render web-service version

This repo also includes `render.yaml` for Render deployment.

1. Go to Render and create a new Blueprint or Web Service from this GitHub repo.
2. Use the default branch, `main`.
3. Start command: `python server_worldcup.py`
4. Render provides a public URL after deploy.

The server uses Render's `PORT` environment variable and binds to `0.0.0.0` automatically when deployed.

## Features

- 48-team list
- Group standings
- Next-match spotlight with countdown
- Match schedule with local kick-off times
- Venue and broadcast labels when provided
- Favorite teams saved in the browser
- Search, group filter, status filter, quick views and refresh

Data is loaded through ESPN's public soccer endpoints, with official FIFA schedule and standings links included in the app metadata.
