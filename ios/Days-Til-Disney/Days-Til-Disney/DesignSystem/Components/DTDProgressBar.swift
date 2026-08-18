import SwiftUI

/// Packing progress. Always accompanied by a "12/38" numeral — the bar never carries
/// the number alone. Animates its width with a spring on value change.
struct DTDProgressBar: View {
    enum Tone {
        case accent   // navy/gold accent on a light surface
        case gold     // gold inside a park panel
        case ink
    }

    let value: Int
    let total: Int
    var tone: Tone = .accent
    var height: CGFloat = 8

    private var fraction: CGFloat {
        guard total > 0 else { return 0 }
        return min(1, max(0, CGFloat(value) / CGFloat(total)))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                Capsule()
                    .fill(fillColor)
                    .frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: fraction)
    }

    private var fillColor: Color {
        switch tone {
        case .accent: return DTDColor.accentInteractive
        case .gold:   return DTDColor.gold
        case .ink:    return DTDColor.textPrimary
        }
    }

    private var trackColor: Color {
        tone == .gold ? .white.opacity(0.22) : DTDColor.hairline
    }
}

#Preview("Light") {
    VStack(spacing: 16) {
        DTDProgressBar(value: 12, total: 38)
        DTDProgressBar(value: 30, total: 38, tone: .ink, height: 10)
        ParkPanel(park: .animalKingdom, label: "ANIMAL KINGDOM") {
            DTDProgressBar(value: 12, total: 38, tone: .gold, height: 10)
        }
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(spacing: 16) {
        DTDProgressBar(value: 12, total: 38)
        DTDProgressBar(value: 30, total: 38, tone: .ink, height: 10)
        ParkPanel(park: .animalKingdom, label: "ANIMAL KINGDOM") {
            DTDProgressBar(value: 12, total: 38, tone: .gold, height: 10)
        }
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
