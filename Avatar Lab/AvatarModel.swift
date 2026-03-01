import Foundation
import SwiftUI

struct AvatarModel: Equatable, Hashable, Codable {
    var seed: Int = Int(Date().timeIntervalSince1970) & 0xFFFF
    var background: ColorOption = .preset(0xF2F3F5)
    var skin: ColorOption = .preset(0xF6C89F)
    var hair: ColorOption = .preset(0x2E2E2E)
    var accent: ColorOption = .preset(0x5B8DEF)
    var shape: ShapeStyleOption = .circle
    var hairStyle: HairStyle = .short
    var eyeStyle: EyeStyle = .round
    var mouthStyle: MouthStyle = .smile

    enum ShapeStyleOption: String, CaseIterable, Codable { case circle, roundedSquare, hexagon }
    enum HairStyle: String, CaseIterable, Codable { case bald, short, long, bun, curls }
    enum EyeStyle: String, CaseIterable, Codable { case round, oval, smile, wink }
    enum MouthStyle: String, CaseIterable, Codable { case smile, neutral, frown }

    enum ColorOption: Equatable, Hashable, Codable {
        case preset(UInt32)
        case custom(r: Double, g: Double, b: Double)

        var hex: String {
            switch self {
            case .preset(let rgb):
                return String(format: "#%06X", rgb & 0xFFFFFF)
            case .custom(let r, let g, let b):
                let R = UInt32(max(0, min(255, Int(r * 255))))
                let G = UInt32(max(0, min(255, Int(g * 255))))
                let B = UInt32(max(0, min(255, Int(b * 255))))
                return String(format: "#%02X%02X%02X", R, G, B)
            }
        }

        var swiftUIColor: Color {
            switch self {
            case .preset(let rgb):
                let r = Double((rgb >> 16) & 0xFF) / 255.0
                let g = Double((rgb >> 8) & 0xFF) / 255.0
                let b = Double(rgb & 0xFF) / 255.0
                return Color(red: r, green: g, blue: b)
            case .custom(let r, let g, let b):
                return Color(red: r, green: g, blue: b)
            }
        }
    }
}
extension AvatarModel {
    var svgString: String { SVGRenderer.buildSVG(from: self) }

    mutating func randomize() {
        seed = Int.random(in: 0...0xFFFF)
        hairStyle  = AvatarModel.HairStyle.allCases.randomElement()!
        eyeStyle   = AvatarModel.EyeStyle.allCases.randomElement()!
        mouthStyle = AvatarModel.MouthStyle.allCases.randomElement()!
        shape      = AvatarModel.ShapeStyleOption.allCases.randomElement()!

        let skinPresets: [UInt32]  = [0xFDDBBC, 0xF6C89F, 0xEAA97F, 0xC8784F, 0x8D5524, 0x4A2912]
        let hairPresets: [UInt32]  = [0x2E2E2E, 0x5C3D1E, 0xB5651D, 0xFAD02C, 0xCC3333, 0xE8E8E8]
        let accentPresets: [UInt32] = [0x5B8DEF, 0xE05252, 0x6DC26D, 0xF0A500, 0x9B59B6, 0x1ABC9C]
        let bgPresets: [UInt32]    = [0xF2F3F5, 0xEAF4EA, 0xEAF0FA, 0xFFF4EA, 0xF9EAF5, 0xFAFAEA]

        skin       = .preset(skinPresets.randomElement()!)
        hair       = .preset(hairPresets.randomElement()!)
        accent     = .preset(accentPresets.randomElement()!)
        background = .preset(bgPresets.randomElement()!)
    }
}

