import SwiftUI

struct DeletedItemsView: View {
    @StateObject private var deletedService = DeletedItemsService.shared
    @State private var selectedProperty: UUID?
    @State private var searchText = ""
    @State private var selectedFilter: DeletedItemType?
    @State private var showingRestoreConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var itemToRestore: DeletedItem?
    @State private var itemToDelete: DeletedItem?
    @Environment(\.dismiss) private var dismiss
    
    var filteredItems: [DeletedItem] {
        var items = deletedService.deletedItems
        
        // Filter by selected property
        if let propertyId = selectedProperty {
            items = items.filter { $0.propertyId == propertyId }
        }
        
        // Filter by type
        if let type = selectedFilter {
            items = items.filter { $0.type == type }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            items = items.filter { item in
                item.propertyName.localizedCaseInsensitiveContains(searchText) ||
                (item.type == .room && (item.decode(as: Room.self)?.name.localizedCaseInsensitiveContains(searchText) ?? false)) ||
                (item.type == .inventoryItem && (item.decode(as: DeletedInventoryItem.self)?.item.name.localizedCaseInsensitiveContains(searchText) ?? false))
            }
        }
        
        return items.sorted { $0.deletedAt > $1.deletedAt }
    }
    
    var uniqueProperties: [(id: UUID, name: String)] {
        let properties = deletedService.deletedItems.map { ($0.propertyId, $0.propertyName) }
        let uniqueDict = Dictionary(properties, uniquingKeysWith: { first, _ in first })
        return uniqueDict.map { (id: $0.key, name: $0.value) }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if deletedService.deletedItems.isEmpty {
                    EmptyDeletedView()
                } else {
                    VStack(spacing: 0) {
                        // Filters
                        FilterSection(
                            selectedProperty: $selectedProperty,
                            selectedFilter: $selectedFilter,
                            uniqueProperties: uniqueProperties
                        )
                        
                        // Items List
                        List {
                            ForEach(filteredItems) { deletedItem in
                                DeletedItemRow(
                                    item: deletedItem,
                                    onRestore: {
                                        itemToRestore = deletedItem
                                        showingRestoreConfirmation = true
                                    },
                                    onPermanentDelete: {
                                        itemToDelete = deletedItem
                                        showingDeleteConfirmation = true
                                    }
                                )
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationTitle("Deleted Items")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search deleted items...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if !deletedService.deletedItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Clear All", role: .destructive) {
                                deletedService.clearAllDeleted()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Restore Item", isPresented: $showingRestoreConfirmation) {
                Button("Cancel", role: .cancel) {
                    itemToRestore = nil
                }
                Button("Restore") {
                    if let item = itemToRestore {
                        restoreItem(item)
                        itemToRestore = nil
                    }
                }
            } message: {
                if let item = itemToRestore {
                    Text("Restore this \(item.type.displayName.lowercased()) to its original location?")
                }
            }
            .alert("Permanently Delete", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    itemToDelete = nil
                }
                Button("Delete Forever", role: .destructive) {
                    if let item = itemToDelete {
                        deletedService.permanentlyDelete(item)
                        itemToDelete = nil
                    }
                }
            } message: {
                if let item = itemToDelete {
                    Text("Permanently delete this \(item.type.displayName.lowercased())? This action cannot be undone.")
                }
            }
        }
    }
    
    private func restoreItem(_ deletedItem: DeletedItem) {
        let result = deletedService.restoreItem(deletedItem)
        if result.success {
            // TODO: Implement actual restore to services
            print("✅ Item restored successfully")
            
            // For now, just show success
            // In the future, this would:
            // - Add property back to PropertyService
            // - Add room back to InventoryService
            // - Add item back to room in InventoryService
        } else {
            print("❌ Failed to restore item")
        }
    }
}

struct FilterSection: View {
    @Binding var selectedProperty: UUID?
    @Binding var selectedFilter: DeletedItemType?
    let uniqueProperties: [(id: UUID, name: String)]
    
    var body: some View {
        VStack(spacing: 12) {
            // Property Filter
            if !uniqueProperties.isEmpty {
                HStack {
                    Text("Property:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Property", selection: $selectedProperty) {
                        Text("All Properties").tag(UUID?.none)
                        ForEach(uniqueProperties, id: \.id) { property in
                            Text(property.name).tag(UUID?.some(property.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                }
            }
            
            // Type Filter
            HStack {
                Text("Type:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedFilter == nil,
                            action: { selectedFilter = nil }
                        )
                        
                        ForEach(DeletedItemType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.displayName,
                                isSelected: selectedFilter == type,
                                action: { selectedFilter = type }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct DeletedItemRow: View {
    let item: DeletedItem
    let onRestore: () -> Void
    let onPermanentDelete: () -> Void
    
    var body: some View {
        HStack {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.type.systemImage)
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                HStack {
                    Text(itemTitle)
                        .font(.headline)
                        .strikethrough(true, color: .secondary)
                    
                    Spacer()
                    
                    Text(item.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Property context
                if item.type != .property {
                    Text("From: \(item.propertyName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Room context for items
                if item.type == .inventoryItem,
                   let deletedInventoryItem = item.decode(as: DeletedInventoryItem.self) {
                    Text("Room: \(deletedInventoryItem.roomName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Deleted date
                Text("Deleted \(item.deletedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 8) {
                Button(action: onRestore) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: onPermanentDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var itemTitle: String {
        switch item.type {
        case .property:
            return item.decode(as: Property.self)?.name ?? "Unknown Property"
        case .room:
            return item.decode(as: Room.self)?.name ?? "Unknown Room"
        case .inventoryItem:
            return item.decode(as: DeletedInventoryItem.self)?.item.name ?? "Unknown Item"
        }
    }
}

struct EmptyDeletedView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "trash.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("No Deleted Items")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Items, rooms, and properties you delete will appear here for easy restoration")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DeletedItemsView()
}