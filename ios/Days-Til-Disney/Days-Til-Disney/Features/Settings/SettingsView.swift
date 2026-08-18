import SwiftUI

struct SettingsView: View {
    @Environment(AppContainer.self) private var appContainer
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    settingsContent(vm: vm)
                } else {
                    ProgressView().tint(DTDColor.accentInteractive)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            let vm = SettingsViewModel.make(from: appContainer)
            viewModel = vm
            await vm.onAppear()
        }
    }

    @ViewBuilder
    private func settingsContent(vm: SettingsViewModel) -> some View {
        ScrollView {
            VStack(spacing: DTDSpacing.tileGap) {
                appearanceCard(vm: vm)
                iCloudRow(vm: vm)
                notificationsRow(vm: vm)
                aboutCard(vm: vm)
                disclaimer

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, DTDSpacing.gutter)
            .padding(.top, DTDSpacing.x7)
            // Family (a) — clamp to ~680 and centre on regular-width iPad; no-op on compact.
            .dtdContentColumn()
        }
    }

    // MARK: - Appearance

    private func appearanceCard(vm: SettingsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x5) {
            SectionLabel("Appearance")
            SegmentedControl(options: ["Light", "Dark", "System"], selection: themeBinding(vm: vm))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }

    /// Maps the design's Light/Dark/System labels onto `UserPreferences.ThemeMode`
    /// (whose "auto" case is presented as "System").
    private func themeBinding(vm: SettingsViewModel) -> Binding<String> {
        Binding(
            get: {
                switch vm.themeMode {
                case .light: return "Light"
                case .dark:  return "Dark"
                case .auto:  return "System"
                }
            },
            set: { newValue in
                switch newValue {
                case "Light": vm.themeMode = .light
                case "Dark":  vm.themeMode = .dark
                default:      vm.themeMode = .auto
                }
            }
        )
    }

    // MARK: - Toggle rows

    private func iCloudRow(vm: SettingsViewModel) -> some View {
        settingRow(
            title: "Sync trips with iCloud",
            subtitle: vm.iCloudSyncStatus.displayTitle
        ) {
            // iCloud sync is system-controlled — the switch reflects state but is not tappable.
            DTDToggle(isOn: .constant(vm.iCloudSyncStatus.isActive), accessibilityLabel: "iCloud sync")
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func notificationsRow(vm: SettingsViewModel) -> some View {
        if vm.notificationPermissionDenied {
            settingRow(
                title: "Milestone notifications",
                subtitle: "Enable notifications in iOS Settings"
            ) {
                DTDButton("Open Settings", variant: .secondary, full: false) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } else {
            settingRow(
                title: "Milestone notifications",
                subtitle: "100 days, one week, and more"
            ) {
                DTDToggle(
                    isOn: Binding(
                        get: { vm.milestoneNotificationsEnabled },
                        set: { newValue in Task { await vm.setMilestoneNotifications(enabled: newValue) } }
                    ),
                    accessibilityLabel: "Milestone notifications"
                )
            }
        }
    }

    private func settingRow<Trailing: View>(
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: DTDSpacing.x6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(DTDColor.textPrimary)
                Text(subtitle)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
            }
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    // MARK: - About

    private func aboutCard(vm: SettingsViewModel) -> some View {
        VStack(spacing: 0) {
            aboutRow(label: "Version", value: Text(vm.appVersion).foregroundStyle(DTDColor.textMuted))
            Divider().overlay(DTDColor.hairline)
            if let privacyURL = URL(string: "https://thinkupllc.com/privacy") {
                Link(destination: privacyURL) {
                    aboutRow(label: "Privacy policy", value: chevron)
                }
            }
            Divider().overlay(DTDColor.hairline)
            if let supportURL = URL(string: "https://thinkupllc.com/support") {
                Link(destination: supportURL) {
                    aboutRow(label: "Support", value: chevron)
                }
            }
        }
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }

    private var chevron: Text {
        Text("›").foregroundStyle(DTDColor.textMuted)
    }

    private func aboutRow(label: String, value: Text) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(DTDColor.textPrimary)
            Spacer(minLength: 0)
            value.font(DTDFont.body)
        }
        .padding(.vertical, DTDSpacing.x6)
        .contentShape(Rectangle())
    }

    // MARK: - Disclaimer (5.2.1 — verbatim, queried by RebrandQATests)

    private var disclaimer: some View {
        Text("Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company.")
            .font(DTDFont.prose)
            .foregroundStyle(DTDColor.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DTDSpacing.x2)
            .accessibilityIdentifier("about.disclaimer")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}
