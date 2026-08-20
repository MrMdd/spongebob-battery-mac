import SwiftUI
import AppKit

// MARK: - Standalone Showcase Image Generator using SwiftUI ImageRenderer (macOS 13+)
@main
struct ShowcaseGenerator {
    @MainActor
    static func main() {
        print("=== Generating High-Resolution 2x Retina Showcase Preview ===")
        
        let view = ShowcaseGalleryView()
            .frame(width: 900, height: 600)
            .background(Color(nsColor: .windowBackgroundColor))

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // High-DPI 2x Retina scale

        if let nsImage = renderer.nsImage,
           let tiffData = nsImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            let outputPath = "output/showcase_preview.png"
            do {
                try pngData.write(to: URL(fileURLWithPath: outputPath))
                print("SUCCESS: Showcase image saved to \(outputPath)")
            } catch {
                print("ERROR: Failed to save PNG: \(error)")
            }
        } else {
            print("ERROR: ImageRenderer failed to produce NSImage")
        }
    }
}

// MARK: - Showcase Gallery View
struct ShowcaseGalleryView: View {
    let levels: [(num: String, range: String)] = [
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
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 6) {
                Text("🧽 SpongeBob Battery - macOS Menu Bar App")
                    .font(.system(size: 24, weight: .bold))
                Text("Tüm Pil Kademeleri ve Açılır Menü (Dropdown) Görsel Önizlemesi")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            // Section 1: All 10 Icon Stages
            VStack(alignment: .leading, spacing: 12) {
                Text("10 Aşamalı Kuruma Seviyesi (Pil Yüzdesine Göre):")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach(levels, id: \.num) { item in
                        VStack(spacing: 6) {
                            if let img = loadLocalImage(named: item.num) {
                                Image(nsImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            } else {
                                Image(systemName: "battery.100")
                                    .font(.system(size: 24))
                            }
                            
                            Text(item.range)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(width: 72, height: 72)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.05)))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.primary.opacity(0.03)))

            // Section 2: Three Dropdown Menu States
            VStack(alignment: .leading, spacing: 12) {
                Text("Menü Çubuğuna Tıklandığında Açılan Menü Durumları:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack(spacing: 24) {
                    // State 1: > 20%
                    DropdownCard(
                        iconName: "1",
                        quote: "I don't need it",
                        battery: 85,
                        headerNote: "Pil > %20 Durumu",
                        statusColor: .primary
                    )

                    // State 2: 11% - 20%
                    DropdownCard(
                        iconName: "9",
                        quote: "I actually need it.",
                        battery: 15,
                        headerNote: "Pil %11 - %20 Durumu",
                        statusColor: .orange
                    )

                    // State 3: <= 10%
                    DropdownCard(
                        iconName: "10",
                        quote: "I NEED IT!",
                        battery: 5,
                        headerNote: "Pil ≤ %10 Durumu",
                        statusColor: .red
                    )
                }
            }

            Spacer()
        }
        .padding(20)
    }

    private func loadLocalImage(named: String) -> NSImage? {
        let possiblePaths = [
            "icons-2/\(named).png",
            "Assets.xcassets/\(named).imageset/\(named).png",
            "\(named).png"
        ]
        for path in possiblePaths {
            if let img = NSImage(contentsOfFile: path) {
                return img
            }
        }
        return nil
    }
}

// Simulated macOS Dropdown Menu Card
struct DropdownCard: View {
    let iconName: String
    let quote: String
    let battery: Int
    let headerNote: String
    let statusColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Title Note
            Text(headerNote)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(statusColor)
                .padding(.bottom, 8)

            // Dropdown Mockup
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let img = loadLocalImage(named: iconName) {
                        Image(nsImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    Text(quote)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(statusColor)
                }

                Divider()

                Text("Battery: \(battery)%")
                    .font(.system(size: 13, weight: .medium))

                HStack {
                    Text("Launch at Login")
                        .font(.system(size: 13))
                    Spacer()
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                        .disabled(true)
                }

                Divider()

                HStack {
                    Text("Quit")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("⌘Q")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor)).shadow(color: .black.opacity(0.15), radius: 6, y: 3))
        }
        .frame(width: 250)
    }

    private func loadLocalImage(named: String) -> NSImage? {
        let possiblePaths = [
            "icons-2/\(named).png",
            "Assets.xcassets/\(named).imageset/\(named).png",
            "\(named).png"
        ]
        for path in possiblePaths {
            if let img = NSImage(contentsOfFile: path) {
                return img
            }
        }
        return nil
    }
}
