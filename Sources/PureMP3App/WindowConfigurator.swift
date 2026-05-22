import AppKit
import SwiftUI

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            configure(window: view.window)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: nsView.window)
        }
    }

    private func configure(window: NSWindow?) {
        guard let window else { return }

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.styleMask.insert(.fullSizeContentView)

        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.002).cgColor
    }
}
