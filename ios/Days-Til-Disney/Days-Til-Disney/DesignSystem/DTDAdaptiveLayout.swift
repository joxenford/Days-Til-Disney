import SwiftUI

/// iPad Toy Box adaptation — the size-class hybrid from
/// `docs/design/toy-box-redesign/ipad-adaptation.md`.
///
/// Two families, chosen by the container's **width** size class:
/// - **Compact** (Slide Over / narrow Split View): render the iPhone view unchanged.
/// - **Regular** (full-screen iPad / wide Split View): either a max-width single column
///   (family a) or a two-column canvas (family b).
///
/// Whitespace and column count grow on iPad; components never do. One park panel per screen.

// MARK: - Family (a): constrained single column

extension View {
    /// Family (a) — form/reading screens (Add Trip, Settings, Welcome, Packing, Milestone).
    /// At **regular** width, clamps the content column to `maxContentWidth` (~680) and centres it,
    /// surplus becomes neutral margin. At **compact** width this is a no-op — the iPhone view
    /// renders unchanged. Apply to the content column *inside* the ScrollView, never to the
    /// background or the ScrollView itself.
    func dtdContentColumn(_ maxWidth: CGFloat = DTDPadLayout.maxContentWidth) -> some View {
        modifier(DTDContentColumn(maxWidth: maxWidth))
    }
}

private struct DTDContentColumn: ViewModifier {
    let maxWidth: CGFloat
    @Environment(\.horizontalSizeClass) private var hSize

    func body(content: Content) -> some View {
        if hSize == .regular {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            content
        }
    }
}

// MARK: - Family (b): two-column canvas

/// Family (b) — dashboard screens (Home, Trip Detail, Park Dashboard).
///
/// **Compact:** one scrolling column — `lead` then `trailing`, same order/spacing as the
/// iPhone view (pass the existing single-column body here so compact stays byte-identical).
///
/// **Regular:** a two-column `HStack` driven off the GeometryReader **container** width.
/// Lead column holds the sole `ParkPanel` (capped at `panelColMax`, ~40% of container);
/// trailing column holds the neutral stack (remainder minus the column gap). Each column
/// scrolls independently.
struct DTDTwoColumnCanvas<Lead: View, Trailing: View>: View {
    @ViewBuilder var lead: () -> Lead
    @ViewBuilder var trailing: () -> Trailing
    /// The single-column (compact / iPhone) body. Kept verbatim so compact never changes.
    @ViewBuilder var compact: () -> AnyView
    /// Pull-to-refresh for the regular-width columns. The compact body owns its own
    /// `.refreshable`; without this the two-column path silently loses the gesture.
    var refresh: (() async -> Void)? = nil

    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        if hSize == .regular {
            regular
        } else {
            compact()
        }
    }

    private var regular: some View {
        GeometryReader { geo in
            // Columns computed from the actual container width (correct under Split View /
            // Stage Manager), never a fraction of the full screen.
            let container = geo.size.width
            let margin = min(DTDPadLayout.gutterScreen + (container > 1000 ? DTDPadLayout.space24 - DTDPadLayout.gutterScreen : 0), DTDPadLayout.space24)
            let available = container - margin * 2 - DTDPadLayout.colGap
            let leadWidth = min(DTDPadLayout.panelColMax, available * 0.42)
            let trailingWidth = available - leadWidth

            HStack(alignment: .top, spacing: DTDPadLayout.colGap) {
                ScrollView {
                    lead()
                        .frame(width: leadWidth, alignment: .leading)
                        .padding(.top, DTDSpacing.x7)
                        .padding(.bottom, 40)
                }
                .refreshableIfAvailable(refresh)
                ScrollView {
                    trailing()
                        .frame(width: trailingWidth, alignment: .leading)
                        .padding(.top, DTDSpacing.x7)
                        .padding(.bottom, 40)
                }
                .refreshableIfAvailable(refresh)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, margin)
        }
    }
}

private extension View {
    /// `.refreshable` only when a handler was supplied — passing nil leaves the
    /// ScrollView gesture-free rather than installing a no-op refresh control.
    @ViewBuilder
    func refreshableIfAvailable(_ action: (() async -> Void)?) -> some View {
        if let action {
            self.refreshable { await action() }
        } else {
            self
        }
    }
}
