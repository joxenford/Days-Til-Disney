import SwiftUI

struct SettingsView: View {
    @Environment(AppContainer.self) private var appContainer
    @State private var viewModel: SettingsViewModel?
    #if DEBUG
    @State private var showDebugSection = false
    @AppStorage("debug_forceOngoingTrip") private var forceOngoingTrip = false
    #endif

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
        // C-3: Match the dark gradient theme of the rest of the app.
        .preferredColorScheme(.dark)
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

            // iCloud Sync.
            Section {
                iCloudSyncRow(vm: vm)
            } header: {
                Text("iCloud")
            } footer: {
                if vm.iCloudSyncStatus == .notSignedIn {
                    Text("Sign in to iCloud in iOS Settings to sync your trips across iPhone and iPad.")
                        .font(DTDFont.caption)
                }
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

            // About.
            Section("About") {
                HStack {
                    Text("Days Til Disney")
                        .font(DTDFont.body)
                    Spacer()
                    Image(systemName: "castle.fill")
                        .foregroundStyle(Color.disneyGold)
                        .accessibilityHidden(true)
                }

                HStack {
                    Text("Version")
                        .font(DTDFont.body)
                    Spacer()
                    Text(vm.appVersion)
                        .font(DTDFont.body)
                        .foregroundStyle(.secondary)
                }
                #if DEBUG
                .onTapGesture(count: 3) {
                    withAnimation { showDebugSection = true }
                }
                #endif

                if let privacyURL = URL(string: "https://thinkupllc.com/privacy") {
                    Link("Privacy Policy", destination: privacyURL)
                        .font(DTDFont.body)
                }

                if let supportURL = URL(string: "https://thinkupllc.com/support") {
                    Link("Support", destination: supportURL)
                        .font(DTDFont.body)
                }
            }

            #if DEBUG
            if showDebugSection {
                Section {
                    Toggle(isOn: $forceOngoingTrip) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Force \"In Park\" Mode")
                                    .font(DTDFont.body)
                                Text("Treats all trips as ongoing to test live park data.")
                                    .font(DTDFont.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "ant.fill")
                                .foregroundStyle(.orange)
                                .font(.title3)
                                .frame(width: 28)
                        }
                    }
                    .tint(.orange)
                } header: {
                    Text("Debug")
                } footer: {
                    Text("Debug options are only available in development builds.")
                        .font(DTDFont.caption)
                }
            }
            #endif
        }
    }

    @ViewBuilder
    private func iCloudSyncRow(vm: SettingsViewModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: vm.iCloudSyncStatus.systemImage)
                .foregroundStyle(vm.iCloudSyncStatus.isActive ? Color.disneyGold : Color.secondary)
                .font(.title3)
                .frame(width: 28)
                .animation(.easeInOut(duration: 0.2), value: vm.iCloudSyncStatus.isActive)

            VStack(alignment: .leading, spacing: 2) {
                Text("Sync Trips")
                    .font(DTDFont.body)
                Text(vm.iCloudSyncStatus.displayTitle)
                    .font(DTDFont.caption)
                    .foregroundStyle(vm.iCloudSyncStatus.isActive ? .primary : .secondary)
            }

            Spacer()

            if !vm.iCloudSyncStatus.isActive && vm.iCloudSyncStatus != .unknown {
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
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("iCloud Sync, \(vm.iCloudSyncStatus.displayTitle)")
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

}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}
