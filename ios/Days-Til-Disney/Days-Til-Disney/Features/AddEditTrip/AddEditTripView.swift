import SwiftUI

struct AddEditTripView: View {
    let mode: AddEditTripMode
    let router: AppNavigationRouter

    @Environment(AppContainer.self) private var appContainer
    @State private var viewModel: AddEditTripViewModel?
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        Group {
            if let vm = viewModel {
                form(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(mode.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
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

    // MARK: - Form

    @ViewBuilder
    private func form(vm: AddEditTripViewModel) -> some View {
        Form {
            // Trip name.
            Section("Trip Name") {
                TextField("e.g. Smith Family Magic Adventure", text: Binding(
                    get: { vm.form.name },
                    set: { vm.form.name = $0 }
                ))
                .focused($isNameFieldFocused)
                .font(DTDFont.body)
                .accessibilityLabel("Trip name")
            }

            // Date pickers.
            Section("Trip Dates") {
                DatePicker(
                    "Start Date",
                    selection: Binding(
                        get: { vm.form.startDate },
                        set: { vm.form.startDate = $0 }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .font(DTDFont.body)

                DatePicker(
                    "End Date",
                    selection: Binding(
                        get: { vm.form.endDate },
                        set: { vm.form.endDate = $0 }
                    ),
                    in: vm.form.startDate...,
                    displayedComponents: .date
                )
                .font(DTDFont.body)
            }

            // Resort & park selector.
            Section("Destination") {
                ParkSelectorView(
                    selectedResort: Binding(
                        get: { vm.form.selectedResort },
                        set: { vm.form.selectedResort = $0 }
                    ),
                    selectedParks: Binding(
                        get: { vm.form.selectedParks },
                        set: { vm.form.selectedParks = $0 }
                    ),
                    onResortChange: { vm.resortDidChange(to: $0) }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            // Primary toggle.
            Section {
                Toggle(isOn: Binding(
                    get: { vm.form.isPrimary },
                    set: { vm.form.isPrimary = $0 }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Set as Primary Trip")
                            .font(DTDFont.body)
                        Text("Shows as the main countdown on your home screen.")
                            .font(DTDFont.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Error message.
            if let error = vm.saveError {
                Section {
                    Text(error)
                        .font(DTDFont.caption)
                        .foregroundStyle(.red)
                }
            }

            // Save button.
            Section {
                Button(action: {
                    isNameFieldFocused = false
                    Task { await vm.save() }
                }) {
                    if vm.isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Text("Saving...")
                                .font(DTDFont.headline)
                            Spacer()
                        }
                    } else {
                        Text(mode.isEditing ? "Save Changes" : "Create Trip")
                            .font(DTDFont.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(!vm.form.isValid || vm.isSaving)
                .foregroundStyle(vm.form.isValid ? Color.accentColor : Color.secondary)
            }
        }
        .onAppear { isNameFieldFocused = !mode.isEditing }
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
