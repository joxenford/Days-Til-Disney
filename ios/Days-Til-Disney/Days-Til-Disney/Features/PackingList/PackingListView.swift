import SwiftUI

struct PackingListView: View {
    let tripID: UUID

    @Environment(AppContainer.self) private var appContainer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: PackingListViewModel?
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView().tint(DTDColor.accentInteractive)
                }
            }
        }
        .navigationTitle("Packing list")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar { toolbarContent }
        .task {
            let vm = PackingListViewModel.make(tripID: tripID, from: appContainer)
            viewModel = vm
            await vm.onAppear()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel?.saveError != nil },
            set: { if !$0 { viewModel?.clearSaveError() } }
        )) {
            Button("OK", role: .cancel) { viewModel?.clearSaveError() }
        } message: {
            Text(viewModel?.saveError ?? "")
        }
        .confirmationDialog(
            "Reset to Defaults",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset List", role: .destructive) {
                viewModel?.resetToDefaults()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all custom items and uncheck everything. Your park-specific defaults will be restored.")
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func contentView(vm: PackingListViewModel) -> some View {
        switch vm.viewState {
        case .loading:
            ProgressView().tint(DTDColor.accentInteractive)

        case .error(let message):
            VStack(spacing: DTDSpacing.x7) {
                Text("Something went wrong")
                    .font(DTDFont.title)
                    .foregroundStyle(DTDColor.textPrimary)
                Text(message)
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

        case .loaded(let trip, let sections):
            ScrollView {
                VStack(spacing: DTDSpacing.tileGap) {
                    summaryPanel(vm: vm, trip: trip)

                    ForEach(sections) { section in
                        sectionCard(section: section, vm: vm)
                    }

                    if vm.isAddingItem {
                        addItemForm(vm: vm)
                    } else {
                        addOwnItemFooter(vm: vm)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, DTDSpacing.gutter)
                .padding(.top, DTDSpacing.x7)
            }
        }
    }

    // MARK: - Summary panel (the one ParkPanel)

    private func summaryPanel(vm: PackingListViewModel, trip: Trip) -> some View {
        let done = vm.totalChecked
        let total = vm.totalItems
        return ParkPanel(park: trip.primaryPark) {
            VStack(alignment: .leading, spacing: DTDSpacing.x5) {
                HStack(alignment: .lastTextBaseline) {
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        // ponytail: 64/800 packing summary numeral has no Numeral role — hand-rolled.
                        Text("\(done)")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .tracking(-4)
                            .foregroundStyle(.white)
                        Text("/\(total)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer(minLength: 0)
                    Text("\(max(0, total - done)) to go")
                        .font(DTDFont.prose)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                }
                DTDProgressBar(value: done, total: total, tone: .gold, height: 10)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(done) of \(total) items packed")
    }

    // MARK: - Category card

    private func sectionCard(section: PackingSection, vm: PackingListViewModel) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x5) {
            HStack {
                SectionLabel(section.category.displayName)
                Spacer(minLength: 0)
                Text("\(section.checkedCount)/\(section.totalCount)")
                    .font(DTDFont.prose)
                    .fontWeight(.semibold)
                    .foregroundStyle(DTDColor.textMuted)
            }

            VStack(spacing: DTDSpacing.x5) {
                ForEach(section.items) { item in
                    DTDCheckbox(item.name, checked: item.isChecked) {
                        vm.toggleItem(item)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.25)) {
                                vm.deleteItem(item)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }

    // MARK: - Add-your-own footer

    private func addOwnItemFooter(vm: PackingListViewModel) -> some View {
        Button {
            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                vm.beginAddItem()
            }
        } label: {
            HStack(spacing: DTDSpacing.x5) {
                Text("+")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                Text("Add your own item")
                    .font(DTDFont.bodyStrong)
                Spacer(minLength: 0)
            }
            .foregroundStyle(DTDColor.textMuted)
            .padding(.vertical, DTDSpacing.x7)
            .padding(.horizontal, DTDSpacing.x9)
            .contentShape(Rectangle())
        }
        .buttonStyle(DTDPressStyle())
        .accessibilityLabel("Add your own item")
    }

    // MARK: - Add item form

    private func addItemForm(vm: PackingListViewModel) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x5) {
            SectionLabel("New item")

            TextField("Item name", text: Binding(
                get: { vm.newItemName },
                set: { vm.newItemName = $0 }
            ))
            .font(DTDFont.bodyStrong)
            .foregroundStyle(DTDColor.textPrimary)
            .tint(DTDColor.accentInteractive)
            .padding(.vertical, DTDSpacing.x5)
            .padding(.horizontal, DTDSpacing.x6)
            .background(DTDColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DTDRadius.control, style: .continuous))
            .submitLabel(.done)
            .onSubmit { vm.addCustomItem() }

            HStack {
                Text("Category")
                    .font(DTDFont.body)
                    .foregroundStyle(DTDColor.textMuted)
                Spacer(minLength: 0)
                Picker("Category", selection: Binding(
                    get: { vm.newItemCategory },
                    set: { vm.newItemCategory = $0 }
                )) {
                    ForEach(PackingCategory.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .tint(DTDColor.accentInteractive)
            }

            HStack(spacing: DTDSpacing.x5) {
                DTDButton("Cancel", variant: .secondary) {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                        vm.cancelAddItem()
                    }
                }
                DTDButton("Add item") {
                    vm.addCustomItem()
                }
                .opacity(vm.newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                .disabled(vm.newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: DTDSpacing.x3) {
                if case .loaded = viewModel?.viewState {
                    DTDIconButton(glyph: "↻", accessibilityLabel: "Reset to defaults") {
                        showResetConfirmation = true
                    }
                }
                DTDIconButton(glyph: "+", accessibilityLabel: "Add item", tone: .loud) {
                    withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel?.beginAddItem()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PackingListView(tripID: Trip.preview.id)
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
            .environment(\.parkThemeProvider, ParkThemeProvider.preview())
    }
}
