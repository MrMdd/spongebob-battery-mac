import Cocoa

// Standalone Helper to click the Menu Bar item in macOS GUI session
guard let screen = NSScreen.main else {
    print("No screen found")
    exit(1)
}

let screenWidth = screen.frame.width
// Status bar item is near the right edge
// Try clicking at standard menu bar coordinates
let testPoints = [
    CGPoint(x: screenWidth - 75, y: 12),
    CGPoint(x: screenWidth - 95, y: 12),
    CGPoint(x: screenWidth - 55, y: 12)
]

for point in testPoints {
    if let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left),
       let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) {
        down.post(tap: .cghidEventTap)
        usleep(100_000)
        up.post(tap: .cghidEventTap)
        print("Clicked at: \(point)")
        break
    }
}
