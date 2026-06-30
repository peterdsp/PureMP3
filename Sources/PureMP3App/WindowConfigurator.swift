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

    private static let contentSize = NSSize(width: 1120, height: 760)

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

        // Lock the content area to an exact size. Because the content view is
        // full-size (no title bar reservation), the SwiftUI content fills the
        // whole window edge-to-edge with nothing clipped at the top or bottom.
        if window.contentView?.frame.size != Self.contentSize {
            window.setContentSize(Self.contentSize)
        }
        window.contentMinSize = Self.contentSize
        window.contentMaxSize = Self.contentSize

        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.002).cgColor
    }
}
