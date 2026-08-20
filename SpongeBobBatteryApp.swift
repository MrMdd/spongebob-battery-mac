import SwiftUI

@main
struct SpongeBobBatteryApp: App {
    @StateObject private var batteryMonitor = BatteryMonitor()
    
    // Check if launched with --preview flag (used for automated screenshot preview)
    private let isPreviewMode = CommandLine.arguments.contains("--preview")

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
            Image(batteryMonitor.iconName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }

        // Preview Window: only opens when launched with '--preview'
        if isPreviewMode {
            Window("SpongeBob Battery - All States Preview", id: "preview_window") {
                BatteryPreviewGalleryView()
            }
            .defaultSize(width: 820, height: 540)
        }
    }
}

// MARK: - Visual Preview Showcase for All Battery States & Dropdown Menus
struct BatteryPreviewGalleryView: View {
    let levels: [(name: String, range: String)] = [
        ("1", "100-91%"),
        ("2", "90-81%"),
        ("3", "80-71%"),
        ("4", "70-61%"),
        ("5", "60-51%"),
        ("6", "50-41%"),
        ("7", "40-31%"),
        ("8", "30-21%"),
        ("9", "20-11%"),
        ("10", "10-0%")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("🧽 SpongeBob Battery - Tüm Pil Durumları Önizlemesi")
                .font(.title2.bold())
                .padding(.top, 15)

            // 1. All 10 Icons Showcase
            VStack(alignment: .leading, spacing: 8) {
                Text("10 Kademeli İkon Seviyeleri (100% ➡️ 0%):")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)

                HStack(spacing: 14) {
                    ForEach(levels, id: \.name) { item in
                        VStack(spacing: 6) {
                            Image(item.name)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(6)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(8)
                            
                            Text(item.range)
                                .font(.system(size: 10, weight: .medium))
                        }
                    }
                }
            }
            .padding()
            .background(Color.primary.opacity(0.04))
            .cornerRadius(12)

            Divider()

            // 2. Three Dropdown Menu States
            Text("Açılır Menü Durumları (Dropdown Menu Previews):")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)

            HStack(spacing: 24) {
                // State 1: > 20%
                DropdownMockupView(
                    iconName: "1",
                    quote: "I don't need it",
                    percentage: 85,
                    titleColor: .primary
                )

                // State 2: 11% - 20%
                DropdownMockupView(
                    iconName: "9",
                    quote: "I actually need it.",
                    percentage: 15,
                    titleColor: .orange
                )

                // State 3: <= 10%
                DropdownMockupView(
                    iconName: "10",
                    quote: "I NEED IT!",
                    percentage: 5,
                    titleColor: .red
                )
            }

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 800, minHeight: 520)
    }
}

// Simulated macOS Dropdown Menu View
struct DropdownMockupView: View {
    let iconName: String
    let quote: String
    let percentage: Int
    let titleColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(iconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Text(quote)
                    .font(.headline)
                    .foregroundColor(titleColor)
            }

            Divider()

            Text("Battery: \(percentage)%")
                .font(.subheadline)

            HStack {
                Text("Launch at Login")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(true)
            }

            Divider()

            Text("Quit (⌘Q)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(width: 230)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .windowBackgroundColor)).shadow(radius: 4))
    }
}
