import SwiftUI

/// Eight segments — one per `Milestone.all` threshold (100, 50, 30, 14, 7, 3, 1, 0).
/// Passed milestones fill gold; remaining are dim. Never invents thresholds.
struct MilestoneStrip: View {
    let daysOut: Int
    var onPark: Bool = false

    /// Number of milestones already reached at `daysOut`: those whose threshold is at or
    /// above the current days-out (e.g. daysOut=30 → 100, 50, 30 → 3 of 8).
    static func passedCount(daysOut: Int) -> Int {
        Milestone.all.filter { $0.daysOut >= daysOut }.count
    }

    private var passed: Int { Self.passedCount(daysOut: daysOut) }

    var body: some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x3) {
            HStack(spacing: 4) {
                ForEach(Array(Milestone.all.enumerated()), id: \.element.id) { index, _ in
                    Capsule()
                        .fill(index < passed ? DTDColor.gold : remainingColor)
                        .frame(height: 8)
                }
            }
            Text("\(passed) of \(Milestone.all.count) milestones reached")
                .font(DTDFont.labelSmall)
                .textCase(.uppercase)
                .tracking(1.4)
                .foregroundStyle(onPark ? .white.opacity(0.78) : DTDColor.textMuted)
        }
    }

    private var remainingColor: Color {
        onPark ? .white.opacity(0.28) : DTDColor.hairline
    }
}

#Preview("Light") {
    VStack(spacing: 20) {
        MilestoneStrip(daysOut: 30)
        MilestoneStrip(daysOut: 100)
        ParkPanel(park: .shanghaiDisneylandPark, label: "SHANGHAI DISNEYLAND") {
            MilestoneStrip(daysOut: 7, onPark: true)
        }
    }
    .padding()
    .background(DTDColor.bg)
}

#Preview("Dark") {
    VStack(spacing: 20) {
        MilestoneStrip(daysOut: 30)
        MilestoneStrip(daysOut: 100)
        ParkPanel(park: .shanghaiDisneylandPark, label: "SHANGHAI DISNEYLAND") {
            MilestoneStrip(daysOut: 7, onPark: true)
        }
    }
    .padding()
    .background(DTDColor.bg)
    .preferredColorScheme(.dark)
}
