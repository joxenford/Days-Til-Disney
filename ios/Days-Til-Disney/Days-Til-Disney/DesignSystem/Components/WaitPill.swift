import SwiftUI

/// Live standby wait. Thresholds mirror `ParkDashboardView`: under 20 min short (green),
/// under 45 mid (gold), otherwise long (red). Non-operating statuses show a neutral label.
struct WaitPill: View {
    let minutes: Int?
    var status: AttractionStatus = .operating

    var body: some View {
        // ponytail: 19/700 is the design's deliberate size — it clears the 3:1 large-text
        // contrast floor for the wait-* colours, so don't shrink it or reuse .inline (26).
        Text(text)
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.vertical, 6)
            .padding(.horizontal, DTDSpacing.x5)
            .background(DTDColor.textPrimary.opacity(0.06)) // 6% neutral wash
            .clipShape(Capsule())
    }

    private var text: String {
        switch status {
        case .operating:
            guard let minutes else { return "Walk-on" }
            return "\(minutes) min"
        case .closed, .refurbishment, .down:
            return status.displayLabel
        }
    }

    private var color: Color {
        switch status {
        case .operating:
            guard let minutes else { return DTDColor.waitShort }
            if minutes < 20 { return DTDColor.waitShort }
            if minutes < 45 { return DTDColor.waitMid }
            return DTDColor.waitLong
        case .closed, .refurbishment, .down:
            return DTDColor.textFaint
        }
    }
}

#Preview("Light") {
    HStack(spacing: 12) {
        WaitPill(minutes: 10)
        WaitPill(minutes: 30)
        WaitPill(minutes: 90)
        WaitPill(minutes: nil)
        WaitPill(minutes: nil, status: .refurbishment)
    }
    .padding()
    .background(DTDColor.surface)
}

#Preview("Dark") {
    HStack(spacing: 12) {
        WaitPill(minutes: 10)
        WaitPill(minutes: 30)
        WaitPill(minutes: 90)
        WaitPill(minutes: nil)
        WaitPill(minutes: nil, status: .refurbishment)
    }
    .padding()
    .background(DTDColor.surface)
    .preferredColorScheme(.dark)
}
