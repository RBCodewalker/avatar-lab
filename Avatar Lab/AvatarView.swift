import SwiftUI

// MARK: - Clip mask shape

private struct AvatarMaskShape: Shape {
    let style: AvatarModel.ShapeStyleOption

    func path(in rect: CGRect) -> Path {
        let s  = min(rect.width, rect.height) / 512.0
        let ox = (rect.width  - 512 * s) / 2
        let oy = (rect.height - 512 * s) / 2
        let t  = CGAffineTransform(translationX: ox, y: oy).scaledBy(x: s, y: s)
        switch style {
        case .circle:
            return Path(ellipseIn: CGRect(x: 16, y: 16, width: 480, height: 480)).applying(t)
        case .roundedSquare:
            return Path(roundedRect: CGRect(x: 32, y: 32, width: 448, height: 448),
                        cornerRadius: 64).applying(t)
        case .hexagon:
            var p = Path()
            p.move(to:    CGPoint(x: 256, y: 24))
            p.addLine(to: CGPoint(x: 468, y: 152))
            p.addLine(to: CGPoint(x: 468, y: 360))
            p.addLine(to: CGPoint(x: 256, y: 488))
            p.addLine(to: CGPoint(x: 44,  y: 360))
            p.addLine(to: CGPoint(x: 44,  y: 152))
            p.closeSubpath()
            return p.applying(t)
        }
    }
}

// MARK: - Hair shapes
// Each shape receives a frame of 512*s × 512*s, so path(in:) computes s = rect.width/512.

private struct ShortHairShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 512
        var p = Path()
        p.move(to: CGPoint(x: 148*s, y: 200*s))
        p.addCurve(to:     CGPoint(x: 256*s, y: 118*s),
                   control1: CGPoint(x: 155*s, y: 148*s),
                   control2: CGPoint(x: 205*s, y: 118*s))
        p.addCurve(to:     CGPoint(x: 364*s, y: 200*s),
                   control1: CGPoint(x: 307*s, y: 118*s),
                   control2: CGPoint(x: 357*s, y: 148*s))
        p.closeSubpath()
        return p
    }
}

private struct LongHairShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 512
        var p = Path()
        p.move(to: CGPoint(x: 130*s, y: 200*s))
        p.addCurve(to:     CGPoint(x: 256*s, y: 112*s),
                   control1: CGPoint(x: 140*s, y: 148*s),
                   control2: CGPoint(x: 196*s, y: 112*s))
        p.addCurve(to:     CGPoint(x: 382*s, y: 200*s),
                   control1: CGPoint(x: 316*s, y: 112*s),
                   control2: CGPoint(x: 372*s, y: 148*s))
        p.addLine(to: CGPoint(x: 392*s, y: 380*s))
        p.addCurve(to:     CGPoint(x: 256*s, y: 430*s),
                   control1: CGPoint(x: 370*s, y: 418*s),
                   control2: CGPoint(x: 320*s, y: 430*s))
        p.addCurve(to:     CGPoint(x: 120*s, y: 380*s),
                   control1: CGPoint(x: 192*s, y: 430*s),
                   control2: CGPoint(x: 142*s, y: 418*s))
        p.closeSubpath()
        return p
    }
}

// MARK: - Eye shapes (stroked, full 512-space frame)

private struct SmileEyesShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 512
        var p = Path()
        p.move(to: CGPoint(x: 206*s, y: 225*s))
        p.addCurve(to:     CGPoint(x: 234*s, y: 225*s),
                   control1: CGPoint(x: 214*s, y: 235*s),
                   control2: CGPoint(x: 226*s, y: 235*s))
        p.move(to: CGPoint(x: 286*s, y: 225*s))
        p.addCurve(to:     CGPoint(x: 314*s, y: 225*s),
                   control1: CGPoint(x: 294*s, y: 235*s),
                   control2: CGPoint(x: 306*s, y: 235*s))
        return p
    }
}

// MARK: - Mouth shapes (stroked, full 512-space frame)

private struct SmileMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 512
        var p = Path()
        p.move(to: CGPoint(x: 206*s, y: 290*s))
        p.addCurve(to:     CGPoint(x: 306*s, y: 290*s),
                   control1: CGPoint(x: 230*s, y: 320*s),
                   control2: CGPoint(x: 282*s, y: 320*s))
        return p
    }
}

private struct FrownMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 512
        var p = Path()
        p.move(to: CGPoint(x: 206*s, y: 310*s))
        p.addCurve(to:     CGPoint(x: 306*s, y: 310*s),
                   control1: CGPoint(x: 230*s, y: 280*s),
                   control2: CGPoint(x: 282*s, y: 280*s))
        return p
    }
}

// MARK: - AvatarView

struct AvatarView: View {
    let model: AvatarModel

    var body: some View {
        GeometryReader { geo in
            let s  = min(geo.size.width, geo.size.height) / 512.0
            let ox = (geo.size.width  - 512 * s) / 2
            let oy = (geo.size.height - 512 * s) / 2

            ZStack {
                // Background always fills the full strip (outside clip too)
                model.background.swiftUIColor

                // Avatar elements clipped to the selected frame shape
                ZStack {
                    // Accent blobs
                    Circle()
                        .fill(model.accent.swiftUIColor.opacity(0.25))
                        .frame(width: 180*s, height: 180*s)
                        .position(x: 110*s + ox, y: 120*s + oy)
                    Circle()
                        .fill(model.accent.swiftUIColor.opacity(0.25))
                        .frame(width: 240*s, height: 240*s)
                        .position(x: 420*s + ox, y: 380*s + oy)

                    // Long hair behind head
                    if model.hairStyle == .long {
                        LongHairShape()
                            .fill(model.hair.swiftUIColor)
                            .frame(width: 512*s, height: 512*s)
                            .position(x: 256*s + ox, y: 256*s + oy)
                    }

                    // Neck
                    Ellipse()
                        .fill(model.skin.swiftUIColor)
                        .frame(width: 120*s, height: 80*s)
                        .position(x: 256*s + ox, y: 330*s + oy)

                    // Head
                    Circle()
                        .fill(model.skin.swiftUIColor)
                        .frame(width: 220*s, height: 220*s)
                        .position(x: 256*s + ox, y: 230*s + oy)

                    hairLayer(s: s, ox: ox, oy: oy)
                    eyeLayer(s: s, ox: ox, oy: oy)
                    mouthLayer(s: s, ox: ox, oy: oy)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipShape(AvatarMaskShape(style: model.shape))
            }
        }
    }

    // MARK: - Hair

    @ViewBuilder
    private func hairLayer(s: CGFloat, ox: CGFloat, oy: CGFloat) -> some View {
        let hair = model.hair.swiftUIColor
        switch model.hairStyle {
        case .bald, .long:
            EmptyView()
        case .short:
            ShortHairShape()
                .fill(hair)
                .frame(width: 512*s, height: 512*s)
                .position(x: 256*s + ox, y: 256*s + oy)
        case .bun:
            ShortHairShape()
                .fill(hair)
                .frame(width: 512*s, height: 512*s)
                .position(x: 256*s + ox, y: 256*s + oy)
            // Bun knot: center (256, 108) r=40
            Circle()
                .fill(hair)
                .frame(width: 80*s, height: 80*s)
                .position(x: 256*s + ox, y: 108*s + oy)
        case .curls:
            Circle().fill(hair).frame(width: 52*s, height: 52*s).position(x: 180*s+ox, y: 170*s+oy)
            Circle().fill(hair).frame(width: 60*s, height: 60*s).position(x: 220*s+ox, y: 150*s+oy)
            Circle().fill(hair).frame(width: 56*s, height: 56*s).position(x: 260*s+ox, y: 145*s+oy)
            Circle().fill(hair).frame(width: 60*s, height: 60*s).position(x: 300*s+ox, y: 150*s+oy)
            Circle().fill(hair).frame(width: 52*s, height: 52*s).position(x: 340*s+ox, y: 170*s+oy)
        }
    }

    // MARK: - Eyes

    @ViewBuilder
    private func eyeLayer(s: CGFloat, ox: CGFloat, oy: CGFloat) -> some View {
        switch model.eyeStyle {
        case .round:
            Circle().fill(Color.black).frame(width: 20*s, height: 20*s).position(x: 216*s+ox, y: 230*s+oy)
            Circle().fill(Color.black).frame(width: 20*s, height: 20*s).position(x: 296*s+ox, y: 230*s+oy)
        case .oval:
            Ellipse().fill(Color.black).frame(width: 24*s, height: 16*s).position(x: 216*s+ox, y: 230*s+oy)
            Ellipse().fill(Color.black).frame(width: 24*s, height: 16*s).position(x: 296*s+ox, y: 230*s+oy)
        case .smile:
            SmileEyesShape()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 6*s, lineCap: .round))
                .frame(width: 512*s, height: 512*s)
                .position(x: 256*s+ox, y: 256*s+oy)
        case .wink:
            // Left eye: closed line
            Capsule()
                .fill(Color.black)
                .frame(width: 28*s, height: 6*s)
                .position(x: 220*s+ox, y: 230*s+oy)
            // Right eye: open circle
            Circle().fill(Color.black).frame(width: 20*s, height: 20*s).position(x: 296*s+ox, y: 230*s+oy)
        }
    }

    // MARK: - Mouth

    @ViewBuilder
    private func mouthLayer(s: CGFloat, ox: CGFloat, oy: CGFloat) -> some View {
        switch model.mouthStyle {
        case .smile:
            SmileMouthShape()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 8*s, lineCap: .round))
                .frame(width: 512*s, height: 512*s)
                .position(x: 256*s+ox, y: 256*s+oy)
        case .neutral:
            // Simple horizontal line: from x=210 to x=302, y=290 → center x=256, width=92
            Capsule()
                .fill(Color.black)
                .frame(width: 92*s, height: 8*s)
                .position(x: 256*s+ox, y: 290*s+oy)
        case .frown:
            FrownMouthShape()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 8*s, lineCap: .round))
                .frame(width: 512*s, height: 512*s)
                .position(x: 256*s+ox, y: 256*s+oy)
        }
    }
}

#Preview {
    AvatarView(model: AvatarModel())
        .frame(width: 300, height: 300)
        .padding()
}
