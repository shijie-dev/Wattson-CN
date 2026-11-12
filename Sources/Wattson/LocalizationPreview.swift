import AppKit
import SwiftUI

/// Offline layout verification. No model.start(), device actions, login changes,
/// notification requests, or power-mode changes are performed.
@MainActor
enum LocalizationPreview {
    static func run(directory: String) -> Int32 {
        _ = NSApplication.shared
        let output = URL(fileURLWithPath: directory, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
            let model = DeviceModel()
            for tab in SettingsTab.allCases {
                try save(SettingsView(model: model, tab: tab, state: SettingsState()),
                         to: output.appendingPathComponent("settings-\(tab.rawValue).png"))
            }
            try save(MenuContentView(model: model, ui: PanelState()),
                     to: output.appendingPathComponent("panel.png"))
            print("Rendered panel and four settings panes: \(output.path)")
            return 0
        } catch {
            fputs("Layout verification failed: \(error)\n", stderr)
            return 1
        }
    }

    private static func save<V: View>(_ view: V, to url: URL) throws {
        let hosting = NSHostingView(rootView: view.environment(\.colorScheme, .light)
            .foregroundStyle(.primary).background(Color(nsColor: .windowBackgroundColor)))
        let size = hosting.fittingSize
        hosting.frame = NSRect(origin: .zero, size: size)
        let window = NSWindow(contentRect: hosting.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = hosting
        hosting.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        window.setContentSize(hosting.fittingSize)
        hosting.layoutSubtreeIfNeeded()
        guard let bitmap = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            throw NSError(domain: "Wattson-CN.Layout", code: 1)
        }
        hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "Wattson-CN.Layout", code: 2)
        }
        try data.write(to: url)
    }
}
