import SwiftUI

/// A compact card for secondary (non-primary) trips shown below the hero countdown.
struct TripCardView: View {
    let trip: Trip
    let onTap: () -> Void
    let onSetPrimary: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Park color indicator strip.
                RoundedRectangle(cornerRadius: 4)
                    .fill(trip.colorPalette.primary)
                    .frame(width: 5)

                // Trip info.
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(DTDFont.bodyMedium)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(trip.primaryPark.displayName)
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.65))

                    Text(trip.startDate.dayMonthDateString)
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                // Days countdown badge.
                VStack(spacing: 2) {
                    Text("\(trip.daysUntilStart)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(trip.daysUntilStart == 1 ? "day" : "days")
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(width: 52)

                // Context menu chevron.
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(trip.colorPalette.primary.opacity(0.08))
                    }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onSetPrimary()
            } label: {
                Label("Set as Primary", systemImage: "star.fill")
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
            Button("Delete", role: .destructive) { onDelete() }
        } message: {
            Text("This will permanently remove \"\(trip.name)\" and cannot be undone.")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(trip.name), \(trip.daysUntilStart) days away")
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
