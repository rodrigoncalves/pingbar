# pingbar

macOS menu bar app that graphs ping latency to 8.8.8.8, so latency spikes are always visible at the top of the screen. Single Swift file, no dependencies.

<img width="145" height="24" alt="pingbar in the menu bar" src="https://github.com/user-attachments/assets/8ed16832-09ec-495c-9a9e-e7a7f51ac36e" />

- Bar graph of the last N seconds (1 ping/second) plus the current latency, e.g. `31ms`.
- Bar color: green < 60ms, orange < 100ms, red ≥ 100ms. Timeouts show as a full red bar and `✕`.
- Graph scale is 100ms, or the highest spike in the window if larger.

## Build and install

Requires the Xcode command line tools (`xcode-select --install`).

```bash
./build.sh
```

This builds `~/Applications/PingBar.app` (ad-hoc signed, no Dock icon), so it shows up in Spotlight: press ⌘Space and type "PingBar". After rebuilding, quit the running app and open it again.

Without the bundle: `swiftc -O pingbar.swift -o pingbar && ./pingbar`.

## Menu

Click the graph in the menu bar:

- **Size**: graph width, 30s / 60s (default) / 120s / 240s.
- **Launch at login**: adds/removes `~/Library/LaunchAgents/local.pingbar.plist` (`RunAtLoad`). Takes effect at next login. The plist stores the path of the running binary, so enable it from the installed `PingBar.app`, not from a throwaway build.
- **Language**: System (default), English or Português (pt-BR).
- **Quit**

Size and language are remembered between runs (`UserDefaults`).

## Configuration

Change `host` at the top of `pingbar.swift` to ping something else, then rebuild.

## Uninstall

Quit the app, then delete `~/Applications/PingBar.app` and `~/Library/LaunchAgents/local.pingbar.plist`.

## License

[MIT](LICENSE)
