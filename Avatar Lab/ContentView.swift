import SwiftUI

struct MainContentView: View {
    @State private var model = AvatarModel()
    @State private var showExporter = false
    @State private var exportURL: URL? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Live avatar preview
                AvatarView(model: model)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal)

                ScrollView {
                    AvatarControls(model: $model)
                }

                HStack(spacing: 12) {
                    Button("Randomize") {
                        model.randomize()
                    }
                    .buttonStyle(.bordered)

                    Button("Export SVG") {
                        exportURL = SVGRenderer.exportSVGToTemporaryFile(
                            svg: SVGRenderer.buildSVG(from: model)
                        )
                        showExporter = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Export PNG @4x") {
                        let renderer = ImageRenderer(
                            content: AvatarView(model: model).frame(width: 1024, height: 1024)
                        )
                        renderer.scale = 4.0
                        if let nsImage = renderer.nsImage {
                            exportURL = SVGRenderer.exportPNGToTemporaryFile(image: nsImage)
                        } else {
                            exportURL = nil
                        }
                        showExporter = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom)
            }
            .navigationTitle("Avatar Lab")
            .sheet(isPresented: $showExporter) {
                Group {
                    if let url = exportURL {
                        VStack(spacing: 20) {
                            Text("Ready to Share")
                                .font(.headline)
                            Text(url.lastPathComponent)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ShareLink(item: url) {
                                Label(
                                    "Share \(url.pathExtension.uppercased())",
                                    systemImage: "square.and.arrow.up"
                                )
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Dismiss") { showExporter = false }
                                .buttonStyle(.bordered)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Text("Export failed")
                                .font(.headline)
                            Text("Could not render the avatar. Please try again.")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Dismiss") { showExporter = false }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding(24)
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    MainContentView()
}
