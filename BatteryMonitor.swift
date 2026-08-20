import Foundation
import IOKit.ps
import ServiceManagement
import SwiftUI

/// BatteryMonitor observes macOS battery status using IOKit notifications (zero polling / no timer)
/// and manages "Launch at Login" via modern SMAppService (macOS 13+).
@MainActor
final class BatteryMonitor: ObservableObject {
    @Published var batteryPercentage: Int = 100
    @Published var isLaunchAtLoginEnabled: Bool = false

    private var runLoopSource: CFRunLoopSource?

    init() {
        updateBatteryLevel()
        checkLaunchAtLoginStatus()
        setupBatteryObserver()
    }

    deinit {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    // MARK: - Dynamic Icon Name (1 to 10)
    /// Maps battery percentage to asset names "1" through "10"
    var iconName: String {
        switch batteryPercentage {
        case 91...100:
            return "1"
        case 81...90:
            return "2"
        case 71...80:
            return "3"
        case 61...70:
            return "4"
        case 51...60:
            return "5"
        case 41...50:
            return "6"
        case 31...40:
            return "7"
        case 21...30:
            return "8"
        case 11...20:
            return "9"
        default: // 0...10
            return "10"
        }
    }

    // MARK: - Dynamic Quote
    /// Returns the iconic SpongeBob quote based on the battery range
    var quoteText: String {
        if batteryPercentage > 20 {
            return "I don't need it"
        } else if batteryPercentage >= 11 {
            return "I actually need it."
        } else {
            return "I NEED IT!"
        }
    }

    // MARK: - Battery Level via IOKit
    /// Fetches the current battery level immediately
    func updateBatteryLevel() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return
        }

        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else {
                continue
            }

            // Verify the power source provides capacity info
            if let currentCapacity = description[kIOPSCurrentCapacityKey as String] as? Int,
               let maxCapacity = description[kIOPSMaxCapacityKey as String] as? Int,
               maxCapacity > 0 {
                let percentage = Int((Double(currentCapacity) / Double(maxCapacity)) * 100.0)
                let clampedPercentage = max(0, min(100, percentage))
                
                self.batteryPercentage = clampedPercentage
                return
            }
        }
    }

    // MARK: - IOKit Notification Registration
    /// Registers a CFRunLoopSource that gets triggered by the OS on battery updates (event-driven)
    private func setupBatteryObserver() {
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        let callback: IOPowerSourceCallbackType = { context in
            guard let context = context else { return }
            let monitor = Unmanaged<BatteryMonitor>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in
                monitor.updateBatteryLevel()
            }
        }

        if let source = IOPSNotificationCreateRunLoopSource(callback, context)?.takeRetainedValue() {
            self.runLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    // MARK: - Launch at Login (SMAppService)
    func checkLaunchAtLoginStatus() {
        isLaunchAtLoginEnabled = (SMAppService.mainApp.status == .enabled)
    }

    func toggleLaunchAtLogin(enable: Bool) {
        do {
            if enable {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            checkLaunchAtLoginStatus()
        } catch {
            print("Failed to toggle Launch at Login: \(error.localizedDescription)")
            checkLaunchAtLoginStatus()
        }
    }
}
