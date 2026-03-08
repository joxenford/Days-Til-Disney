import SwiftUI

// MARK: - Environment Key

private struct ParkThemeProviderKey: EnvironmentKey {
    static let defaultValue: ParkThemeProvider = ParkThemeProvider()
}

extension EnvironmentValues {
    /// The active park theme provider. Views read colors, gradients, and assets from this.
    var parkTheme: ParkThemeProvider {
        get { self[ParkThemeProviderKey.self] }
        set { self[ParkThemeProviderKey.self] = newValue }
    }
}

// MARK: - View modifier convenience

extension View {
    /// Injects a ParkThemeProvider into the environment for a subtree.
    func parkTheme(_ provider: ParkThemeProvider) -> some View {
        environment(\.parkTheme, provider)
    }
}
