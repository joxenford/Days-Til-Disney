import SwiftUI

struct AddEditTripView: View {
    let mode: AddEditTripMode
    let router: AppNavigationRouter

    @Environment(AppContainer.self) private var appContainer
    @State private var viewModel: AddEditTripViewModel?
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        ZStack {
            DTDColor.bg
                .ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    form(vm: vm)
                } else {
                    ProgressView().tint(DTDColor.accentInteractive)
                }
            }
        }
        .navigationTitle(mode.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar { toolbarContent }
        .task {
            let vm = AddEditTripViewModel.make(mode: mode, from: appContainer)
            viewModel = vm
            await vm.onAppear()
        }
        // Observe didSaveSuccessfully at the top level so the modifier is always
        // active and not gated behind the optional unwrap inside the Group.
        .onChange(of: viewModel?.didSaveSuccessfully) { _, saved in
            if saved == true { router.navigateBack() }
        }
    }

    // MARK: - Toolbar (Cancel / title / Save)

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") { router.navigateBack() }
                .font(DTDFont.body)
                .foregroundStyle(DTDColor.textMuted)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            if let vm = viewModel {
                saveButton(vm: vm)
            }
        }
    }

    @ViewBuilder
    private func saveButton(vm: AddEditTripViewModel) -> some View {
        Button {
            isNameFieldFocused = false
            Task { await vm.save() }
        } label: {
            if vm.isSaving {
                ProgressView().tint(DTDColor.textPrimary)
            } else {
                Text("Save")
                    .font(DTDFont.bodyStrong)
                    .foregroundStyle(DTDColor.textPrimary)
                    .opacity(vm.form.isValid ? 1 : 0.45)
            }
        }
        .disabled(!vm.form.isValid || vm.isSaving)
        // Label reconciliation: visible text is "Save" but the UITest queries "Create Trip".
        .accessibilityLabel(mode.isEditing ? "Save Changes" : "Create Trip")
    }

    // MARK: - Form

    @ViewBuilder
    private func form(vm: AddEditTripViewModel) -> some View {
        ScrollView {
            VStack(spacing: DTDSpacing.tileGap) {
                nameCard(vm: vm)
                dateCards(vm: vm)

                ParkSelectorView(
                    selectedResort: Binding(
                        get: { vm.form.selectedResort },
                        set: { vm.form.selectedResort = $0 }
                    ),
                    selectedParks: Binding(
                        get: { vm.form.selectedParks },
                        set: { vm.form.selectedParks = $0 }
                    ),
                    onResortChange: { vm.resortDidChange(to: $0) },
                    onTogglePark: { vm.togglePark($0) }
                )

                primaryToggle(vm: vm)

                if let error = vm.saveError {
                    Text(error)
                        .font(DTDFont.prose)
                        .foregroundStyle(DTDColor.waitLong)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, DTDSpacing.gutter)
            .padding(.top, DTDSpacing.x7)
            // Family (a) — clamp to ~680 and centre on regular-width iPad; no-op on compact.
            .dtdContentColumn()
        }
        .onAppear { isNameFieldFocused = !mode.isEditing }
    }

    // MARK: - Cards

    private func nameCard(vm: AddEditTripViewModel) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x3) {
            SectionLabel("Trip name")
            TextField("Smith Family Magic Adventure", text: Binding(
                get: { vm.form.name },
                set: { vm.form.name = $0 }
            ))
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .tracking(-0.4)
            .foregroundStyle(DTDColor.textPrimary)
            .tint(DTDColor.accentInteractive)
            .focused($isNameFieldFocused)
            .accessibilityLabel("Trip name")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }

    private func dateCards(vm: AddEditTripViewModel) -> some View {
        HStack(spacing: DTDSpacing.tileGap) {
            dateCard(
                label: "From",
                selection: Binding(
                    get: { vm.form.startDate },
                    set: { vm.form.startDate = $0 }
                ),
                range: (mode.isEditing ? vm.form.startDate : Date())...
            )
            dateCard(
                label: "To",
                selection: Binding(
                    get: { vm.form.endDate },
                    set: { vm.form.endDate = $0 }
                ),
                range: vm.form.startDate...
            )
        }
    }

    private func dateCard(label: String, selection: Binding<Date>, range: PartialRangeFrom<Date>) -> some View {
        VStack(alignment: .leading, spacing: DTDSpacing.x2) {
            SectionLabel(label)
            DatePicker("", selection: selection, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(DTDColor.accentInteractive)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DTDSpacing.x8)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }

    private func primaryToggle(vm: AddEditTripViewModel) -> some View {
        HStack(spacing: DTDSpacing.x6) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Primary countdown")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(DTDColor.textPrimary)
                Text("Shows big on the home screen")
                    .font(DTDFont.prose)
                    .foregroundStyle(DTDColor.textMuted)
            }
            Spacer(minLength: 0)
            DTDToggle(
                isOn: Binding(
                    get: { vm.form.isPrimary },
                    set: { vm.form.isPrimary = $0 }
                ),
                accessibilityLabel: "Primary countdown"
            )
        }
        .padding(.vertical, DTDSpacing.x7)
        .padding(.horizontal, DTDSpacing.x9)
        .background(DTDColor.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: DTDRadius.tile, style: .continuous))
    }
}

// MARK: - Preview

#Preview("Add Trip") {
    NavigationStack {
        AddEditTripView(mode: .add, router: AppNavigationRouter())
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}

#Preview("Edit Trip") {
    NavigationStack {
        AddEditTripView(mode: .edit(tripID: Trip.preview.id), router: AppNavigationRouter())
            .environment(AppContainer(modelContainer: SwiftDataContainer.preview))
    }
}
