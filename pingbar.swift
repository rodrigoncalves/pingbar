import Cocoa

// Menu bar ping graph for 8.8.8.8. Build: swiftc -O pingbar.swift -o pingbar
let host = "8.8.8.8"
// ponytail: en/pt-BR picked from system language; add a language = add a case, or move to .lproj if it grows.
var lang = UserDefaults.standard.integer(forKey: "lang")  // 0 = system, 1 = English, 2 = Português
var pt: Bool { lang == 2 || (lang == 0 && (Locale.preferredLanguages.first?.hasPrefix("pt") ?? false)) }
func t(_ en: String, _ ptBR: String) -> String { pt ? ptBR : en }
var N = UserDefaults.standard.integer(forKey: "N") == 0 ? 60 : UserDefaults.standard.integer(forKey: "N")  // samples shown (1 per second) = graph width

final class App: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var samples: [Double?] = []  // nil = timeout

    func applicationDidFinishLaunching(_: Notification) {
        buildMenu()
        item.button?.imagePosition = .imageLeft
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.tick() }
        tick()
    }

    func buildMenu() {
        let m = NSMenu()
        let size = NSMenuItem(title: t("Size", "Tamanho"), action: nil, keyEquivalent: "")
        let sub = NSMenu()
        for (name, n) in [(t("Small (30s)", "Pequeno (30s)"), 30), (t("Medium (60s)", "Médio (60s)"), 60), (t("Large (120s)", "Grande (120s)"), 120), (t("Extra large (240s)", "Extra (240s)"), 240)] {
            let it = NSMenuItem(title: name, action: #selector(setSize(_:)), keyEquivalent: "")
            it.target = self
            it.tag = n
            it.state = n == N ? .on : .off
            sub.addItem(it)
        }
        size.submenu = sub
        m.addItem(size)
        let login = NSMenuItem(title: t("Launch at login", "Iniciar no login"), action: #selector(toggleLogin(_:)), keyEquivalent: "")
        login.target = self
        login.state = FileManager.default.fileExists(atPath: plist.path) ? .on : .off
        m.addItem(login)
        let langItem = NSMenuItem(title: t("Language", "Idioma"), action: nil, keyEquivalent: "")
        let langMenu = NSMenu()
        for (name, n) in [(t("System", "Sistema"), 0), ("English", 1), ("Português", 2)] {
            let it = NSMenuItem(title: name, action: #selector(setLang(_:)), keyEquivalent: "")
            it.target = self
            it.tag = n
            it.state = n == lang ? .on : .off
            langMenu.addItem(it)
        }
        langItem.submenu = langMenu
        m.addItem(langItem)
        m.addItem(.separator())
        m.addItem(withTitle: t("Quit", "Sair"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = m
    }

    @objc func setLang(_ s: NSMenuItem) {
        lang = s.tag
        UserDefaults.standard.set(lang, forKey: "lang")
        buildMenu()
    }

    // ponytail: LaunchAgent plist (bare binary, no .app bundle for SMAppService). Path must stay put.
    let plist = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents/local.pingbar.plist")

    @objc func toggleLogin(_ s: NSMenuItem) {
        if s.state == .on {
            try? FileManager.default.removeItem(at: plist)
            s.state = .off
        } else {
            let d: [String: Any] = ["Label": "local.pingbar", "ProgramArguments": [Bundle.main.executablePath!], "RunAtLoad": true]
            if (d as NSDictionary).write(to: plist, atomically: true) { s.state = .on }
        }
    }

    @objc func setSize(_ s: NSMenuItem) {
        N = s.tag
        UserDefaults.standard.set(N, forKey: "N")
        s.menu?.items.forEach { $0.state = $0.tag == N ? .on : .off }
        while samples.count > N { samples.removeFirst() }
        redraw()
    }

    func tick() {
        DispatchQueue.global().async {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/sbin/ping")
            p.arguments = ["-c", "1", "-W", "1000", host]
            let pipe = Pipe()
            p.standardOutput = pipe
            p.standardError = FileHandle.nullDevice
            try? p.run()
            // close both ends explicitly: leaked pipes hit the fd limit after ~2h and every ping then "timed out"
            try? pipe.fileHandleForWriting.close()
            let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            try? pipe.fileHandleForReading.close()
            var ms: Double? = nil
            if let r = out.range(of: #"time=[0-9.]+"#, options: .regularExpression) {
                ms = Double(out[r].dropFirst(5))
            }
            DispatchQueue.main.async { self.push(ms) }
        }
    }

    func push(_ ms: Double?) {
        samples.append(ms)
        if samples.count > N { samples.removeFirst() }
        redraw()
    }

    func redraw() {
        let s = samples
        let ms = s.last ?? nil
        let top = max(100, s.compactMap { $0 }.max() ?? 0)
        item.button?.image = NSImage(size: NSSize(width: N * 3, height: 18), flipped: false) { _ in
            for (i, v) in s.enumerated() {
                let x = CGFloat(i * 3)
                guard let v = v else {
                    NSColor.systemRed.setFill()
                    NSRect(x: x, y: 0, width: 2, height: 18).fill()
                    continue
                }
                (v < 60 ? NSColor.systemGreen : v < 100 ? NSColor.systemOrange : NSColor.systemRed).setFill()
                NSRect(x: x, y: 0, width: 2, height: max(1, CGFloat(v / top) * 18)).fill()
            }
            return true
        }
        let last = ms.map { String(format: " %.0fms", $0) } ?? " ✕"
        item.button?.attributedTitle = NSAttributedString(
            string: last, attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)])
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = App()
app.delegate = delegate
app.run()
