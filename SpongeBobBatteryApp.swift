import SwiftUI

@main
struct SpongeBobBatteryApp: App {
    @StateObject private var batteryMonitor = BatteryMonitor()

    var body: some Scene {
        MenuBarExtra {
            // 1. Dynamic SpongeBob Quote based on battery percentage
            Text(batteryMonitor.quoteText)
                .font(.headline)
            
            Divider()
            
            // 2. Exact Battery Percentage
            Text("Battery: \(batteryMonitor.batteryPercentage)%")
            
            // 3. Launch at Login Toggle (SMAppService)
            Toggle("Launch at Login", isOn: Binding(
                get: { batteryMonitor.isLaunchAtLoginEnabled },
                set: { newValue in
                    batteryMonitor.toggleLaunchAtLogin(enable: newValue)
                }
            ))
            
            Divider()
            
            // 4. Quit Button
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            // Colorful original image fitting the Menu Bar (22x22 points)
            Image(batteryMonitor.iconName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
    }
}
