import Foundation
import SwiftUI

enum SVGRenderer {
    static func buildSVG(from model: AvatarModel, size: CGSize = CGSize(width: 512, height: 512)) -> String {
        let w = Int(size.width)
        let h = Int(size.height)
        let bg = model.background.hex
        let skin = model.skin.hex
        let hair = model.hair.hex
        let accent = model.accent.hex

        let maskShape: String
        switch model.shape {
        case .circle:
            maskShape = "<circle cx='256' cy='256' r='240' />"
        case .roundedSquare:
            maskShape = "<rect x='32' y='32' width='448' height='448' rx='64' ry='64'/>"
        case .hexagon:
            maskShape = "<polygon points='256,24 468,152 468,360 256,488 44,360 44,152'/>"
        }

        let hairPath: String = HairPaths.path(for: model.hairStyle, color: hair)
        let eyes: String = EyePaths.path(for: model.eyeStyle)
        let mouth: String = MouthPaths.path(for: model.mouthStyle)

        return """
        <svg xmlns='http://www.w3.org/2000/svg' width='\(w)' height='\(h)' viewBox='0 0 512 512' shape-rendering='geometricPrecision' text-rendering='geometricPrecision'>
          <defs>
            <clipPath id='avatarMask'>
              \(maskShape)
            </clipPath>
          </defs>
          <rect width='100%' height='100%' fill='\(bg)'/>
          <g clip-path='url(#avatarMask)'>
            <!-- Background accent blob -->
            <g opacity='0.25'>
              <circle cx='110' cy='120' r='90' fill='\(accent)'/>
              <circle cx='420' cy='380' r='120' fill='\(accent)'/>
            </g>

            <!-- Neck and face -->
            <g>
              <ellipse cx='256' cy='330' rx='60' ry='40' fill='\(skin)'/>
              <circle cx='256' cy='230' r='110' fill='\(skin)'/>
            </g>

            <!-- Hair -->
            \(hairPath)

            <!-- Eyes -->
            \(eyes)

            <!-- Mouth -->
            \(mouth)
          </g>
        </svg>
        """
    }

    static func exportSVGToTemporaryFile(svg: String) -> URL? {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("avatar_\(UUID().uuidString).svg")
        do {
            try svg.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    static func exportPNGToTemporaryFile(image: NSImage) -> URL? {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("avatar_\(UUID().uuidString).png")
        guard let data = pngData(from: image) else { return nil }
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func pngData(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }
}

struct HairPaths {
    static func path(for style: AvatarModel.HairStyle, color: String) -> String {
        switch style {
        case .bald:
            return ""
        case .short:
            return "<path d='M156 210c20-60 120-90 200-30 6 4 12 10 18 16-6 34-20 54-40 64-60 30-160 20-178-50z' fill='\(color)'/>"
        case .long:
            return "<path d='M120 220c20-50 80-90 150-90s120 40 150 90v120c-40 40-90 60-150 60s-110-20-150-60V220z' fill='\(color)'/>"
        case .bun:
            return "<g fill='\(color)'><circle cx='256' cy='140' r='36'/><path d='M156 210c20-60 120-90 200-30 6 4 12 10 18 16-6 34-20 54-40 64-60 30-160 20-178-50z'/></g>"
        case .curls:
            return "<g fill='\(color)'>\n              <circle cx='180' cy='170' r='26'/>\n              <circle cx='220' cy='150' r='30'/>\n              <circle cx='260' cy='145' r='28'/>\n              <circle cx='300' cy='150' r='30'/>\n              <circle cx='340' cy='170' r='26'/>\n            </g>"
        }
    }
}

struct EyePaths {
    static func path(for style: AvatarModel.EyeStyle) -> String {
        switch style {
        case .round:
            return "<g fill='black'><circle cx='216' cy='230' r='10'/><circle cx='296' cy='230' r='10'/></g>"
        case .oval:
            return "<g fill='black'><ellipse cx='216' cy='230' rx='12' ry='8'/><ellipse cx='296' cy='230' rx='12' ry='8'/></g>"
        case .smile:
            return "<g stroke='black' stroke-width='6' stroke-linecap='round' fill='none'><path d='M206 225c8 10 20 10 28 0'/><path d='M286 225c8 10 20 10 28 0'/></g>"
        case .wink:
            return "<g><line x1='206' y1='230' x2='234' y2='230' stroke='black' stroke-width='6' stroke-linecap='round'/><circle cx='296' cy='230' r='10' fill='black'/></g>"
        }
    }
}

struct MouthPaths {
    static func path(for style: AvatarModel.MouthStyle) -> String {
        switch style {
        case .smile:
            return "<path d='M206 290c24 30 76 30 100 0' stroke='black' stroke-width='8' fill='none' stroke-linecap='round'/>"
        case .neutral:
            return "<line x1='210' y1='290' x2='302' y2='290' stroke='black' stroke-width='8' stroke-linecap='round'/>"
        case .frown:
            return "<path d='M206 310c24-30 76-30 100 0' stroke='black' stroke-width='8' fill='none' stroke-linecap='round'/>"
        }
    }
}

