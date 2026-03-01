import SwiftUI

struct AvatarControls: View {
    @Binding var model: AvatarModel

    var body: some View {
        VStack(spacing: 12) {
            GroupBox("Shape") {
                Picker("Shape", selection: $model.shape) {
                    ForEach(AvatarModel.ShapeStyleOption.allCases, id: \.self) { shape in
                        Text(shape.rawValue.capitalized).tag(shape)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            GroupBox("Colors") {
                HStack {
                    ColorPickerLabel(title: "Background", color: $model.background)
                    ColorPickerLabel(title: "Skin", color: $model.skin)
                }
                HStack {
                    ColorPickerLabel(title: "Hair", color: $model.hair)
                    ColorPickerLabel(title: "Accent", color: $model.accent)
                }
            }
            .padding(.horizontal)

            GroupBox("Features") {
                VStack {
                    HStack {
                        Picker("Hair", selection: $model.hairStyle) {
                            ForEach(AvatarModel.HairStyle.allCases, id: \.self) { style in
                                Text(style.rawValue.capitalized).tag(style)
                            }
                        }
                        Picker("Eyes", selection: $model.eyeStyle) {
                            ForEach(AvatarModel.EyeStyle.allCases, id: \.self) { style in
                                Text(style.rawValue.capitalized).tag(style)
                            }
                        }
                    }
                    Picker("Mouth", selection: $model.mouthStyle) {
                        ForEach(AvatarModel.MouthStyle.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct ColorPickerLabel: View {
    let title: String
    @Binding var color: AvatarModel.ColorOption

    @State private var swiftUIColor: Color = .white
    @State private var isPresented = false

    var body: some View {
        Button {
            swiftUIColor = color.swiftUIColor
            isPresented = true
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.swiftUIColor)
                    .frame(width: 28, height: 28)
                Text(title)
                Spacer()
                Text(color.hex)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.bordered)
        .sheet(isPresented: $isPresented) {
            VStack(spacing: 16) {
                ColorPicker(title, selection: $swiftUIColor, supportsOpacity: false)
                    .padding()
                Button("Done") {
                    if let components = swiftUIColor.cgColor?.components, components.count >= 3 {
                        color = .custom(r: Double(components[0]), g: Double(components[1]), b: Double(components[2]))
                    }
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    AvatarControls(model: .constant(AvatarModel()))
        .padding()
}
