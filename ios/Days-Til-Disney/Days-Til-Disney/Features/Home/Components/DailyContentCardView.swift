import SwiftUI

/// Card displaying the day's curated Disney content (tip, fact, trivia, or ride spotlight).
struct DailyContentCardView: View {
    let content: DailyContent
    @State private var isExpanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row: gold dot + eyebrow label, then title.
            HStack(spacing: DTDSpacing.x4) {
                Circle()
                    .fill(DTDColor.gold)
                    .frame(width: 26, height: 26)

                // H-3: Use .textCase(.uppercase) instead of .uppercased() so VoiceOver
                // reads the natural word rather than spelling individual letters.
                Text(content.type.displayName)
                    .font(DTDFont.labelUpper)
                    .foregroundStyle(DTDColor.goldLabel)
                    .textCase(.uppercase)
                    .tracking(1.4)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(DTDColor.textFaint)
            }
            .padding(.horizontal, DTDSpacing.x11)
            .padding(.top, DTDSpacing.x10)

            Text(content.title)
                .font(DTDFont.heading)
                .foregroundStyle(DTDColor.textPrimary)
                .lineLimit(isExpanded ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DTDSpacing.x11)
                .padding(.top, DTDSpacing.x5)

            // Body — expandable.
            if isExpanded {
                Text(content.body)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, DTDSpacing.x11)
                    .padding(.top, DTDSpacing.x3)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                if let source = content.source {
                    Text("Source: \(source)")
                        .font(DTDFont.prose)
                        .foregroundStyle(DTDColor.textFaint)
                        .padding(.horizontal, DTDSpacing.x11)
                        .padding(.top, DTDSpacing.x2)
                }
            } else {
                // Collapsed preview.
                Text(content.body)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                    .lineLimit(2)
                    .padding(.horizontal, DTDSpacing.x11)
                    .padding(.top, DTDSpacing.x3)
            }

            Spacer().frame(height: DTDSpacing.x10)
        }
        .background {
            RoundedRectangle(cornerRadius: DTDRadius.card, style: .continuous)
                .fill(DTDColor.surfaceRaised)
        }
        .onTapGesture {
            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isExpanded
            ? "\(content.type.accessibilityLabel): \(content.title). \(content.body)"
            : "\(content.type.accessibilityLabel): \(content.title)"
        )
        .accessibilityHint(isExpanded ? "Tap to collapse" : "Tap to expand")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview("Fun Fact") {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        DailyContentCardView(content: .preview)
            .padding(.horizontal, 20)
    }
}

#Preview("Planning Tip") {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        DailyContentCardView(content: DailyContent(
            type: .planningTip,
            title: "Book Dining 60 Days Out",
            body: "Walt Disney World resort guests can make dining reservations 60 days before their check-in date for the entire length of their stay. Log into My Disney Experience at 6:00 AM Eastern Time for the best availability at popular restaurants like Be Our Guest and Cinderella's Royal Table.",
            resort: .waltDisneyWorld,
            daysOutRange: .planningTips,
            source: nil
        ))
        .padding(.horizontal, 20)
    }
    .background(DTDColor.bg)
}
