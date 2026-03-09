import SwiftUI

// MARK: - Environment Key

private struct ParkThemeProviderKey: EnvironmentKey {
    // EnvironmentKey.defaultValue is a static requirement that cannot be @MainActor.
    // Using nonisolated(unsafe) is safe here because EnvironmentKey defaultValue is read
    // once at static-init time before any concurrent access can occur.
    nonisolated(unsafe) static let defaultValue: ParkThemeProvider = ParkThemeProvider()
}

extension EnvironmentValues {
    /// The active park theme provider. Views read colors, gradients, and assets from this.
    var parkThemeProvider: ParkThemeProvider {
        get { self[ParkThemeProviderKey.self] }
        set { self[ParkThemeProviderKey.self] = newValue }
    }
}

// MARK: - View modifier convenience

extension View {
    /// Injects a ParkThemeProvider into the environment for a subtree.
    func parkTheme(_ provider: ParkThemeProvider) -> some View {
        environment(\.parkThemeProvider, provider)
    }
}
