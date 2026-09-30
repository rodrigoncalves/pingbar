# pingbar

macOS menu bar app that graphs ping latency to 8.8.8.8. Single Swift file, no dependencies.

- Bar graph of the last N seconds (1 ping/second) plus the current latency, e.g. `31ms`.
- Bar color: green < 60ms, orange < 100ms, red ≥ 100ms. Timeouts show as a full red bar and `✕`.
- Graph scale is 100ms, or the highest spike in the window if larger.

## Build and run

```bash
swiftc -O pingbar.swift -o pingbar
./pingbar
```

Requires the Xcode command line tools (`xcode-select --install`).

## Menu

- **Size**: graph width, 30s / 60s (default) / 120s / 240s. Saved in `UserDefaults`.
- **Launch at login**: writes/removes `~/Library/LaunchAgents/local.pingbar.plist` (`RunAtLoad`). Takes effect at next login. The plist stores the binary's path, so put the binary somewhere permanent first (e.g. `~/apps/pingbar/`).
- **Quit**

## Configuration

Change `host` at the top of `pingbar.swift` to ping something else, then rebuild.
