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

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Park color indicator strip — dimmed for past trips.
                RoundedRectangle(cornerRadius: 4)
                    .fill(trip.colorPalette.primary.opacity(isPast ? 0.45 : 1.0))
                    .frame(width: 5)

                // Trip info.
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(DTDFont.bodyMedium)
                        .foregroundStyle(.white.opacity(isPast ? 0.55 : 1.0))
                        .lineLimit(1)

                    Text(trip.primaryPark.displayName)
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(isPast ? 0.4 : 0.65))

                    Text(trip.startDate.dayMonthDateString)
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(isPast ? 0.3 : 0.5))
                }

                Spacer()

                // Countdown badge — shows "Trip Complete" for past trips.
                if isPast {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.4))

                        Text("Complete")
                            .font(DTDFont.caption)
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .frame(width: 64)
                } else {
                    VStack(spacing: 2) {
                        Text("\(trip.daysUntilStart)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text(trip.daysUntilStart == 1 ? "day" : "days")
                            .font(DTDFont.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(width: 52)
                }

                // Context menu chevron.
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(isPast ? 0.2 : 0.4))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(trip.colorPalette.primary.opacity(isPast ? 0.03 : 0.08))
                    }
            }
            // Dim the whole card when the trip is in the past.
            .opacity(isPast ? 0.75 : 1.0)
            .saturation(isPast ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
        .contextMenu {
            // "Set as Primary" is only meaningful for upcoming/ongoing trips.
            if !isPast {
                Button {
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
        .accessibilityLabel(isPast ? "\(trip.name), trip complete" : "\(trip.name), \(trip.daysUntilStart) days away")
        .accessibilityHint("Tap to view details. Long press for options.")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "#0D2545").ignoresSafeArea()
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
        }
        .padding(.horizontal, 20)
    }
}
