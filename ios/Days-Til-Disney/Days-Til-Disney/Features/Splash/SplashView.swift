import SwiftUI

/// Launch splash. A single 132×132 park panel with a sample numeral, the plain
/// "Countdown to Magic" wordmark, and a loading bar — then calls `onComplete`.
struct SplashView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 132×132 park panel, "45" bottom-aligned inside 16px padding.
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: DTDRadius.device, style: .continuous)
                        .fill(DisneyPark.magicKingdom.colorPalette.panelColor(for: colorScheme))
                    // ponytail: 64pt is a splash one-off, not in the numeral scale.
                    Text("45")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .tracking(-4)
                        .foregroundStyle(.white)
                        .padding(DTDSpacing.x7)
                }
                .frame(width: 132, height: 132)

                Text("Countdown\nto Magic")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .tracking(-1.6)
                    .foregroundStyle(DTDColor.textPrimary)
                    .padding(.top, DTDSpacing.x16)

                Text("Getting your trips…")
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                    .padding(.top, DTDSpacing.x6)

                DTDProgressBar(value: 62, total: 100, tone: .accent, height: 8)
                    .padding(.top, DTDSpacing.x12)
            }
            .padding(.horizontal, 40)
            .opacity(contentOpacity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Countdown to Magic, loading")
        .task {
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.5)) {
                contentOpacity = 1
            }
            // Use Task.sleep instead of DispatchQueue.main.asyncAfter so the wait is
            // cancellable when the view disappears (e.g. if the user force-quits).
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            onComplete()
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView(onComplete: {})
}
