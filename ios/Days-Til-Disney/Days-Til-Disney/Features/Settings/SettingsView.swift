import SwiftUI

struct SettingsView: View {
    @Environment(AppContainer.self) private var appContainer
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                settingsForm(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let vm = SettingsViewModel.make(from: appContainer)
            viewModel = vm
            await vm.onAppear()
        }
    }

    @ViewBuilder
    private func settingsForm(vm: SettingsViewModel) -> some View {
        Form {
            // Appearance.
            Section("Appearance") {
                Picker("Theme", selection: Binding(
                    get: { vm.themeMode },
                    set: { vm.themeMode = $0 }
                )) {
                    ForEach(UserPreferences.ThemeMode.allCases) { mode in
                        Label(mode.displayName, systemImage: mode.systemImageName)
                            .tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            // Notifications.
            Section {
                notificationsRow(vm: vm)
            } header: {
                Text("Notifications")
            } footer: {
                if vm.notificationPermissionDenied {
                    Text("Notification permission was denied. Enable it in iOS Settings to receive milestone alerts.")
                        .font(DTDFont.caption)
                }
            }

            // Future features (v1.1).
            Section("Coming Soon") {
                featureComingSoon(
                    icon: "square.and.arrow.up",
                    title: "Share Countdown",
                    detail: "Share your countdown as a beautiful image."
                )
                featureComingSoon(
                    icon: "rectangle.on.rectangle",
                    title: "Home Screen Widget",
                    detail: "See your countdown without opening the app."
                )
            }

            // About.
            Section("About") {
                HStack {
                    Text("Days Til Disney")
                        .font(DTDFont.body)
                    Spacer()
                    Image(systemName: "castle.fill")
                        .foregroundStyle(Color.disneyGold)
                }

                HStack {
                    Text("Version")
                        .font(DTDFont.body)
                    Spacer()
                    Text(vm.appVersion)
                        .font(DTDFont.body)
                        .foregroundStyle(.secondary)
                }

                if let privacyURL = URL(string: "https://thinkupllc.com/privacy") {
                    Link("Privacy Policy", destination: privacyURL)
                        .font(DTDFont.body)
                }

                if let supportURL = URL(string: "https://thinkupllc.com/support") {
                    Link("Support", destination: supportURL)
                        .font(DTDFont.body)
                }
            }
        }
    }

    @ViewBuilder
    private func notificationsRow(vm: SettingsViewModel) -> some View {
        if vm.notificationPermissionDenied {
            // System permission denied — show a link to iOS Settings.
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .foregroundStyle(Color.secondary)
                    .font(.title3)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Milestone Notifications")
                        .font(DTDFont.body)
                    Text("Get notified at 100 days, 1 week, and more.")
                        .font(DTDFont.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(DTDFont.captionBold)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
            }
        } else {
            // Normal toggle row.
            Toggle(isOn: Binding(
                get: { vm.milestoneNotificationsEnabled },
                set: { newValue in
                    Task { await vm.setMilestoneNotifications(enabled: newValue) }
                }
            )) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Milestone Notifications")
                            .font(DTDFont.body)
                        Text("Get notified at 100 days, 1 week, and more.")
                            .font(DTDFont.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(
                            vm.milestoneNotificationsEnabled ? Color.disneyGold : Color.secondary
                        )
                        .font(.title3)
                        .frame(width: 28)
                }
            }
            .tint(Color.disneyGold)
        }
    }

    private func featureComingSoon(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.secondary)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(DTDFont.body)
                    Text("v1.1")
                        .font(DTDFont.captionBold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.5))
                        .clipShape(Capsule())
                }
                Text(detail)
                    .font(DTDFont.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(0.6)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}
