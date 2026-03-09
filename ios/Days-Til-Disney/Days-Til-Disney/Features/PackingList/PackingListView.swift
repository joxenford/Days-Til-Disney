import SwiftUI

struct PackingListView: View {
    let tripID: UUID

    @Environment(AppContainer.self) private var appContainer
    @Environment(\.parkThemeProvider) private var themeProvider
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: PackingListViewModel?
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            GradientBackgroundView()
            StarFieldView()

            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .navigationTitle("Packing List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
            ProgressView().tint(.white)

        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.6))
                Text(message)
                    .font(DTDFont.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

        case .loaded(_, let sections):
            ScrollView {
                VStack(spacing: 20) {
                    progressHeader(vm: vm)

                    if sections.isEmpty {
                        emptyState(vm: vm)
                    } else {
                        ForEach(sections) { section in
                            sectionView(section: section, vm: vm)
                        }
                    }

                    if vm.isAddingItem {
                        addItemForm(vm: vm)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Progress header

    private func progressHeader(vm: PackingListViewModel) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(vm.totalChecked) of \(vm.totalItems) packed")
                        .font(DTDFont.titleSecondary)
                        .foregroundStyle(.white)
                    Text(progressLabel(checked: vm.totalChecked, total: vm.totalItems))
                        .font(DTDFont.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                // Circular progress indicator.
                CircularProgressView(
                    progress: vm.totalItems > 0
                        ? Double(vm.totalChecked) / Double(vm.totalItems)
                        : 0
                )
                .frame(width: 52, height: 52)
            }
            .padding(.horizontal, 20)

            // Linear progress bar.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(.white.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.disneyGold)
                        .frame(
                            width: vm.totalItems > 0
                                ? geo.size.width * CGFloat(vm.totalChecked) / CGFloat(vm.totalItems)
                                : 0,
                            height: 6
                        )
                        .animation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8), value: vm.totalChecked)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vm.totalChecked) of \(vm.totalItems) items packed")
    }

    // MARK: - Section

    private func sectionView(section: PackingSection, vm: PackingListViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header.
            HStack(spacing: 8) {
                Image(systemName: section.category.systemImageName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.disneyGold)
                    .accessibilityHidden(true)
                Text(section.category.displayName)
                    .font(DTDFont.captionBold)
                    .foregroundStyle(.white.opacity(0.75))
                    .textCase(.uppercase)
                    .kerning(0.5)
                Spacer()
                Text("\(section.checkedCount)/\(section.totalCount)")
                    .font(DTDFont.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Divider()
                .background(.white.opacity(0.1))
                .padding(.horizontal, 20)

            // Items.
            // H-6: .swipeActions() only works inside List rows. These rows live inside a
            // ScrollView/ForEach, so swipe actions are silently ignored. Replace with a
            // .contextMenu delete action that works in any container.
            ForEach(section.items) { item in
                PackingItemRow(item: item) {
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
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Empty state

    private func emptyState(vm: PackingListViewModel) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "bag.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.4))
            Text("Your packing list is empty")
                .font(DTDFont.titleSecondary)
                .foregroundStyle(.white)
            Text("Tap + to add your first item")
                .font(DTDFont.body)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Add item form

    private func addItemForm(vm: PackingListViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Item")
                .font(DTDFont.captionBold)
                .foregroundStyle(.white.opacity(0.75))
                .textCase(.uppercase)
                .kerning(0.5)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            // Item name input.
            TextField("Item name", text: Binding(
                get: { vm.newItemName },
                set: { vm.newItemName = $0 }
            ))
            .font(DTDFont.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .submitLabel(.done)
            .onSubmit { vm.addCustomItem() }

            // Category picker.
            Picker("Category", selection: Binding(
                get: { vm.newItemCategory },
                set: { vm.newItemCategory = $0 }
            )) {
                ForEach(PackingCategory.allCases) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .colorMultiply(Color.white.opacity(0.9))

            // Action buttons.
            HStack(spacing: 12) {
                Button("Cancel") {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                        vm.cancelAddItem()
                    }
                }
                .font(DTDFont.bodyMedium)
                .foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.opacity(0.08))
                )

                Button("Add Item") {
                    vm.addCustomItem()
                }
                .font(DTDFont.bodyMedium)
                .foregroundStyle(vm.newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? .white.opacity(0.3)
                    : Color.black
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(vm.newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.white.opacity(0.12)
                            : Color.disneyGold
                        )
                )
                .disabled(vm.newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Helpers

    private func progressLabel(checked: Int, total: Int) -> String {
        guard total > 0 else { return "Add items to get started" }
        if checked == total { return "All packed! You're ready for the magic." }
        let remaining = total - checked
        return "\(remaining) item\(remaining == 1 ? "" : "s") left to pack"
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 4) {
                // Reset button — only shown when list is loaded.
                if case .loaded = viewModel?.viewState {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .accessibilityLabel("Reset to defaults")
                }

                Button {
                    withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel?.beginAddItem()
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
                .accessibilityLabel("Add item")
            }
        }
    }
}

// MARK: - Packing Item Row

private struct PackingItemRow: View {
    let item: PackingItem
    let onToggle: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Checkmark circle.
                ZStack {
                    Circle()
                        .strokeBorder(
                            item.isChecked ? Color.disneyGold : .white.opacity(0.3),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)

                    if item.isChecked {
                        Circle()
                            .fill(Color.disneyGold)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
                .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: item.isChecked)

                // Item name.
                Text(item.name)
                    .font(DTDFont.body)
                    .foregroundStyle(item.isChecked ? .white.opacity(0.4) : .white)
                    .strikethrough(item.isChecked, color: .white.opacity(0.4))
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: item.isChecked)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityValue(item.isChecked ? "Checked" : "Unchecked")
        .accessibilityHint("Double tap to \(item.isChecked ? "uncheck" : "check")")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Circular Progress View

private struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.15), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.disneyGold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
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
