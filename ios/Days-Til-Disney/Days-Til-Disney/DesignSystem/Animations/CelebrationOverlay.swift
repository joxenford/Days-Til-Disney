import SwiftUI

/// Full-screen celebration overlay triggered at milestone moments.
/// Displays animated particles (confetti / fireworks / sparkle) with haptic feedback.
struct CelebrationOverlay: View {
    let event: MilestoneEvent
    @Binding var isPresented: Bool

    @State private var particles: [ParticleState] = []
    @State private var showContent: Bool = false

    var body: some View {
        ZStack {
            // Dimmed backdrop.
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Particle field.
            GeometryReader { geo in
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                }
            }
            .allowsHitTesting(false)

            // Milestone card.
            if showContent {
                MilestoneCelebrationCard(event: event, onDismiss: dismiss)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                    .padding(.horizontal, 32)
            }
        }
        .onAppear {
            triggerHaptic()
            spawnParticles()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.2)) {
                showContent = true
            }
        }
    }

    // MARK: - Private

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showContent = false
            isPresented = false
        }
    }

    private func triggerHaptic() {
        if event.celebrationType.isHeavyHaptic {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        } else {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }

    private func spawnParticles() {
        let colors: [Color] = [.yellow, .red, .blue, .green, .orange, .pink, .purple, .white]
        particles = (0..<60).map { i in
            ParticleState(
                id: i,
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: Double.random(in: 0...UIScreen.main.bounds.height * 0.5),
                size: Double.random(in: 6...14),
                color: colors.randomElement() ?? .yellow,
                opacity: Double.random(in: 0.7...1.0),
                scale: Double.random(in: 0.5...1.5)
            )
        }

        withAnimation(.easeOut(duration: 2.5)) {
            for i in particles.indices {
                particles[i].y += Double.random(in: 200...500)
                particles[i].opacity = 0
            }
        }
    }
}

// MARK: - Supporting types

private struct ParticleState: Identifiable {
    let id: Int
    var x: Double
    var y: Double
    var size: Double
    var color: Color
    var opacity: Double
    var scale: Double
}

// MARK: - Milestone card

private struct MilestoneCelebrationCard: View {
    let event: MilestoneEvent
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(event.title)
                .font(DTDFont.displayMedium)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(event.subtitle)
                .font(DTDFont.body)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            Button(action: onDismiss) {
                Text("Let's Go!")
                    .font(DTDFont.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title). \(event.subtitle)")
    }
}

// MARK: - Preview

#Preview("100 Days Milestone") {
    @Previewable @State var isPresented = true

    ZStack {
        Color(hex: "#1A3A6B").ignoresSafeArea()

        if isPresented {
            CelebrationOverlay(
                event: MilestoneEvent(
                    milestone: Milestone.all.first!,
                    trip: Trip.preview
                ),
                isPresented: $isPresented
            )
        }
    }
}
