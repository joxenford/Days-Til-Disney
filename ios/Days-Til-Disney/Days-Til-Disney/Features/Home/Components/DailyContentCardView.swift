import SwiftUI

/// Card displaying the day's curated Disney content (tip, fact, trivia, or ride spotlight).
struct DailyContentCardView: View {
    let content: DailyContent
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row.
            HStack(spacing: 12) {
                Image(systemName: content.type.systemImageName)
                    .font(.title3)
                    .foregroundStyle(Color.disneyGold)
                    .frame(width: 36, height: 36)
                    .background(Color.disneyGold.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(content.type.displayName.uppercased())
                        .font(DTDFont.captionBold)
                        .foregroundStyle(Color.disneyGold)
                        .tracking(1.5)

                    Text(content.title)
                        .font(DTDFont.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)

            // Body — expandable.
            if isExpanded {
                Text(content.body)
                    .font(DTDFont.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                if let source = content.source {
                    Text("Source: \(source)")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                }
            } else {
                // Collapsed preview.
                Text(content.body)
                    .font(DTDFont.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(2)
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
            }

            Spacer().frame(height: 18)
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.disneyGold.opacity(0.05))
                }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(content.type.accessibilityLabel): \(content.title). \(content.body)")
        .accessibilityHint(isExpanded ? "Tap to collapse" : "Tap to expand")
    }
}

// MARK: - Preview

#Preview("Fun Fact") {
    ZStack {
        Color(hex: "#0D2545").ignoresSafeArea()
        DailyContentCardView(content: .preview)
            .padding(.horizontal, 20)
    }
}

#Preview("Planning Tip") {
    ZStack {
        Color(hex: "#0D2545").ignoresSafeArea()
        DailyContentCardView(content: DailyContent(
            type: .planningTip,
            title: "Book Dining 60 Days Out",
            body: "Walt Disney World resort guests can make dining reservations 60 days before their check-in date for the entire length of their stay. Log into My Disney Experience at 6:00 AM Eastern Time for the best availability at popular restaurants like Be Our Guest and Cinderella's Royal Table.",
            resort: .waltDisneyWorld,
            daysOutRange: .planningTips,
            source: "Disney Official"
        ))
        .padding(.horizontal, 20)
    }
}
