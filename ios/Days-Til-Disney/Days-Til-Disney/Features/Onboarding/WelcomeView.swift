import SwiftUI

/// First-launch welcome screen shown after the splash animation.
/// Toy Box: a 3×2 tile grid, a plain headline, and stacked full-width buttons —
/// no hero mark, no sparkle constellation.
struct WelcomeView: View {
    /// Called when the user taps "Create your first trip" — the caller navigates to AddEditTripView.
    let onCreateTrip: () -> Void
    /// Called when the user taps the skip option — proceeds to HomeView without a trip.
    let onSkip: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private struct Tile: Identifiable {
        let id: Int
        let fill: Color
        var number: String?
        var ink: Color = .white
    }

    private var tiles: [Tile] {
        [
            Tile(id: 0, fill: DisneyPark.magicKingdom.colorPalette.panelColor(for: colorScheme), number: "45"),
            Tile(id: 1, fill: DTDColor.surface),
            Tile(id: 2, fill: DisneyPark.tokyoDisneyland.colorPalette.panelColor(for: colorScheme), number: "7"),
            Tile(id: 3, fill: DTDColor.surface),
            Tile(id: 4, fill: DTDColor.gold, number: "30", ink: DTDColor.goldInk),
            Tile(id: 5, fill: DTDColor.surface)
        ]
    }

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 3×2 decorative tile grid.
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: DTDSpacing.x4), count: 3),
                    spacing: DTDSpacing.x4
                ) {
                    ForEach(tiles) { tile in
                        ZStack {
                            RoundedRectangle(cornerRadius: DTDRadius.tileSm, style: .continuous)
                                .fill(tile.fill)
                            if let number = tile.number {
                                Text(number)
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundStyle(tile.ink)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(.top, DTDSpacing.x4)
                .accessibilityHidden(true)

                // Headline + body.
                VStack(alignment: .leading, spacing: DTDSpacing.x7) {
                    Text("The best part\nstarts early.")
                        .font(DTDFont.display)
                        .tracking(-1.4)
                        .foregroundStyle(DTDColor.textPrimary)

                    Text("Add your trip and the countdown begins. A fact a day, a packing list that knows your park, and live waits once you're through the gates.")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .lineSpacing(4)
                        .foregroundStyle(DTDColor.textMuted)
                }
                .padding(.top, DTDSpacing.x16)

                Spacer(minLength: DTDSpacing.x16)

                // Stacked full-width buttons.
                VStack(spacing: DTDSpacing.x5) {
                    DTDButton("Create your first trip", action: onCreateTrip)
                        .accessibilityLabel("Create your first trip")

                    DTDButton("I'll do this later", variant: .secondary, action: onSkip)
                        .accessibilityLabel("Skip onboarding and go to home screen")
                }
            }
            .padding(.horizontal, DTDSpacing.x11)
            .padding(.bottom, DTDSpacing.x11)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview

#Preview {
    WelcomeView(onCreateTrip: {}, onSkip: {})
}
