import SwiftUI

/// Toy Box resort/park picker. The selected resort renders as the screen's single
/// `ParkPanel` with a check-box row per park; every other resort is a neutral
/// surface pill that switches the selection.
///
/// Park toggle logic lives exclusively in `onTogglePark` — the view never mutates
/// `selectedParks` directly, so the at-least-one-park invariant stays in the ViewModel.
struct ParkSelectorView: View {
    @Binding var selectedResort: DisneyResort
    @Binding var selectedParks: Set<DisneyPark>
    let onResortChange: (DisneyResort) -> Void
    /// Called when the user taps a park row. The parent enforces deselection rules
    /// (e.g. keeping at least one park selected).
    let onTogglePark: (DisneyPark) -> Void

    var body: some View {
        VStack(spacing: DTDSpacing.tileGap) {
            resortPanel
            otherResorts
        }
    }

    // MARK: - Selected resort panel (the one ParkPanel on this screen)

    private var resortPanel: some View {
        let resort = selectedResort
        let parks = resort.parks
        // First selected park in resort order carries the "THEME" tag — it drives Trip.primaryPark.
        let themePark = parks.first(where: { selectedParks.contains($0) })

        return ParkPanel(park: resort.primaryPark) {
            VStack(alignment: .leading, spacing: DTDSpacing.x4) {
                HStack(alignment: .center) {
                    Text(resort.displayName)
                        .font(DTDFont.bodyStrong)
                        .foregroundStyle(.white)
                    Spacer(minLength: 0)
                    Text("SELECTED")
                        .font(DTDFont.labelSmall)
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, DTDSpacing.x4)
                        .background(DTDColor.onParkBadge)
                        .clipShape(Capsule())
                }

                Text("\(resort.location) · \(parks.count) park\(parks.count == 1 ? "" : "s")")
                    .font(DTDFont.prose)
                    .foregroundStyle(.white.opacity(0.8))

                if parks.count > 1 {
                    VStack(spacing: DTDSpacing.x3) {
                        ForEach(parks) { park in
                            parkRow(
                                park: park,
                                isSelected: selectedParks.contains(park),
                                isTheme: park == themePark
                            )
                        }
                    }
                    .padding(.top, DTDSpacing.x2)
                }
            }
        }
    }

    private func parkRow(park: DisneyPark, isSelected: Bool, isTheme: Bool) -> some View {
        Button {
            onTogglePark(park)
        } label: {
            HStack(spacing: DTDSpacing.x5) {
                checkBox(isSelected: isSelected, tint: park.colorPalette.primary)

                Text(park.displayName)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.85))

                Spacer(minLength: 0)

                if isTheme {
                    Text("THEME")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.vertical, DTDSpacing.x5)
            .padding(.horizontal, DTDSpacing.x6)
            .background(isSelected ? Color.white.opacity(0.16) : Color.clear)
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: DTDRadius.chip, style: .continuous)
                        .strokeBorder(DTDColor.onParkOutline, lineWidth: 1.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DTDRadius.chip, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(DTDPressStyle())
        .accessibilityLabel("\(park.displayName), \(isSelected ? "selected" : "not selected")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// White 20px box; the park-coloured check carries the park identity (replaces the
    /// removed `DisneyPark.emoji`). ponytail: mockup shows no separate colour swatch.
    private func checkBox(isSelected: Bool, tint: Color) -> some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(isSelected ? Color.white : Color.clear)
            .overlay {
                if isSelected {
                    Text("✓")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(tint)
                } else {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.55), lineWidth: 1.5)
                }
            }
            .frame(width: 20, height: 20)
    }

    // MARK: - Other resorts (neutral surface pills)

    private var otherResorts: some View {
        let others = DisneyResort.allCases.filter { $0 != selectedResort }
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DTDSpacing.x4) {
                ForEach(others) { resort in
                    DTDChip(resort.displayName) {
                        onResortChange(resort)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var resort: DisneyResort = .waltDisneyWorld
    @Previewable @State var parks: Set<DisneyPark> = [.magicKingdom]

    return ScrollView {
        ParkSelectorView(
            selectedResort: $resort,
            selectedParks: $parks,
            onResortChange: { resort = $0 },
            onTogglePark: { park in
                if parks.contains(park) && parks.count > 1 {
                    parks.remove(park)
                } else {
                    parks.insert(park)
                }
            }
        )
        .padding()
    }
    .background(DTDColor.bg)
}
