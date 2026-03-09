import SwiftUI

/// Visual resort/park picker. Displays resort cards grouped by destination.
/// Each resort card expands to show individual park selection checkmarks.
///
/// Park toggle logic lives exclusively in `onTogglePark` — the view never mutates
/// `selectedParks` directly, avoiding duplicated guard logic.
struct ParkSelectorView: View {
    @Binding var selectedResort: DisneyResort
    @Binding var selectedParks: Set<DisneyPark>
    let onResortChange: (DisneyResort) -> Void
    /// Called when the user taps a park row. The parent is responsible for enforcing
    /// deselection rules (e.g. keeping at least one park selected).
    let onTogglePark: (DisneyPark) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(DisneyResort.allCases) { resort in
                ResortCard(
                    resort: resort,
                    isSelected: selectedResort == resort,
                    selectedParks: selectedResort == resort ? selectedParks : [],
                    onSelect: {
                        onResortChange(resort)
                    },
                    onTogglePark: { park in
                        // Only forward the toggle when the user is acting on the
                        // currently selected resort's parks.
                        if selectedResort == resort {
                            onTogglePark(park)
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Resort card

private struct ResortCard: View {
    let resort: DisneyResort
    let isSelected: Bool
    let selectedParks: Set<DisneyPark>
    let onSelect: () -> Void
    let onTogglePark: (DisneyPark) -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Resort header row.
            // Expansion rules:
            //   - Newly selected resort: .onChange(of: isSelected) opens it.
            //   - Already selected resort: tapping toggles open/closed.
            //   - Switching away from a resort: .onChange closes it implicitly
            //     because isSelected becomes false, hiding the expanded section.
            Button(action: {
                if isSelected {
                    // Already selected — toggle the expanded panel.
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } else {
                    // Selecting a new resort — onSelect triggers .onChange which
                    // sets isExpanded = true for this card.
                    onSelect()
                }
            }) {
                HStack(spacing: 14) {
                    // Selection indicator.
                    ZStack {
                        Circle()
                            .strokeBorder(isSelected ? resort.primaryPark.colorPalette.primary : Color.secondary.opacity(0.4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        if isSelected {
                            Circle()
                                .fill(resort.primaryPark.colorPalette.primary)
                                .frame(width: 14, height: 14)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(resort.displayName)
                            .font(DTDFont.bodyMedium)
                            .foregroundStyle(.primary)

                        Text(resort.location)
                            .font(DTDFont.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Park count badge.
                    Text("\(resort.parks.count) \(resort.parks.count == 1 ? "park" : "parks")")
                        .font(DTDFont.caption)
                        .foregroundStyle(.secondary)

                    Image(systemName: isExpanded && isSelected ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Park selection (expanded state).
            if isExpanded && isSelected && resort.parks.count > 1 {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(resort.parks) { park in
                        ParkRow(
                            park: park,
                            isSelected: selectedParks.contains(park),
                            onToggle: { onTogglePark(park) }
                        )
                    }
                }
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(resort.primaryPark.colorPalette.primary, lineWidth: 2)
                    }
                }
        }
        .onChange(of: isSelected) { _, nowSelected in
            if nowSelected { isExpanded = true }
        }
    }
}

// MARK: - Park row (within expanded resort card)

private struct ParkRow: View {
    let park: DisneyPark
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? park.colorPalette.primary : Color.secondary.opacity(0.5))
                    .font(.title3)

                Text(park.emoji)
                    .font(.body)

                Text(park.displayName)
                    .font(DTDFont.body)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(park.displayName), \(isSelected ? "selected" : "not selected")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var resort: DisneyResort = .waltDisneyWorld
    @Previewable @State var parks: Set<DisneyPark> = [.magicKingdom]

    ScrollView {
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
    .background(Color(.systemGroupedBackground))
}
