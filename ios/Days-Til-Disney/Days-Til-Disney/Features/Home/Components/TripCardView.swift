import SwiftUI

/// A compact card for secondary (non-primary) trips shown below the hero countdown.
struct TripCardView: View {
    let trip: Trip
    let onTap: () -> Void
    let onSetPrimary: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteAlert = false

    private var isPast: Bool { trip.isPast }

    /// Single meta line beneath the trip name — park + countdown status.
    private var metaText: String {
        if isPast {
            let d = trip.daysSinceEnd
            return d == 0 ? "Complete" : "\(d) \(d == 1 ? "day" : "days") ago"
        }
        if trip.isOngoing {
            return "\(trip.primaryPark.displayName) · you're there now!"
        }
        let d = trip.daysUntilStart
        return "\(trip.primaryPark.displayName) · \(d) \(d == 1 ? "day" : "days") away"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DTDSpacing.x6) {
                // Park-identity swatch (not a park panel — a colour dot).
                RoundedRectangle(cornerRadius: DTDRadius.chip, style: .continuous)
                    .fill(trip.colorPalette.primary)
                    .frame(width: 44, height: 44)

                // Trip info.
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.name)
                        .font(DTDFont.bodyStrong)
                        .foregroundStyle(DTDColor.textPrimary)
                        .lineLimit(1)

                    Text(metaText)
                        .font(DTDFont.prose)
                        .foregroundStyle(DTDColor.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text("›")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(DTDColor.textFaint)
            }
            .padding(.vertical, DTDSpacing.x7)
            .padding(.horizontal, DTDSpacing.x8)
            .background {
                RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous)
                    .fill(DTDColor.surface)
            }
            // Past trips read as fond memories — dimmed to 60% per the Toy Box spec.
            .opacity(isPast ? 0.6 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            // "Set as Primary" is only meaningful for upcoming/ongoing trips.
            if !isPast {
                Button {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    onSetPrimary()
                } label: {
                    Label("Set as Primary", systemImage: "star.fill")
                }
            }

            Button {
                onEdit()
            } label: {
                Label("Edit Trip", systemImage: "pencil")
            }

            Divider()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Trip", systemImage: "trash")
            }
        }
        .alert("Delete Trip?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                let haptic = UIImpactFeedbackGenerator(style: .heavy)
                haptic.impactOccurred()
                onDelete()
            }
        } message: {
            Text("This will permanently remove \"\(trip.name)\" and cannot be undone.")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel({
            if isPast {
                let d = trip.daysSinceEnd
                return d == 0
                    ? "\(trip.name), trip complete"
                    : "\(trip.name), \(d) \(d == 1 ? "day" : "days") ago"
            } else {
                let d = trip.daysUntilStart
                return "\(trip.name), \(d) \(d == 1 ? "day" : "days") away"
            }
        }())
        .accessibilityHint("Tap to view details. Long press for options.")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DTDColor.bg.ignoresSafeArea()
        VStack(spacing: 12) {
            TripCardView(
                trip: Trip.preview,
                onTap: {},
                onSetPrimary: {},
                onEdit: {},
                onDelete: {}
            )
            TripCardView(
                trip: Trip.previewToday,
                onTap: {},
                onSetPrimary: {},
                onEdit: {},
                onDelete: {}
            )
            TripCardView(
                trip: Trip.previewPast,
                onTap: {},
                onSetPrimary: {},
                onEdit: {},
                onDelete: {}
            )
        }
        .padding(.horizontal, 20)
    }
}
