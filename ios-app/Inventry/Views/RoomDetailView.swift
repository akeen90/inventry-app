import SwiftUI
import UIKit
import AVFoundation

// MARK: - Photo Gallery Components
struct PhotoGalleryView: View {
    let images: [UIImage]
    let onDelete: ((Int) -> Void)?
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        if images.isEmpty {
            EmptyPhotoView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("\(images.count) Photo\(images.count == 1 ? "" : "s")", systemImage: "photo.stack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(images.indices, id: \.self) { index in
                        PhotoThumbnailView(
                            image: images[index],
                            onDelete: onDelete != nil ? {
                                onDelete?(index)
                            } : nil
                        )
                    }
                }
            }
        }
    }
}

struct PhotoThumbnailView: View {
    let image: UIImage
    let onDelete: (() -> Void)?
    @State private var showingFullScreen = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .onTapGesture {
                    showingFullScreen = true
                }
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.red)
                                .frame(width: 24, height: 24)
                        )
                        .shadow(radius: 2)
                }
                .offset(x: 8, y: -8)
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            FullScreenPhotoView(image: image)
        }
    }
}

struct FullScreenPhotoView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct EmptyPhotoView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No photos added")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Tap the camera button to add photos")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundColor(.gray.opacity(0.3))
                )
        )
    }
}



struct RoomDetailView: View {
    let initialRoom: Room  // Changed to initialRoom
    @ObservedObject var inventoryService: InventoryService  // Changed from @StateObject to @ObservedObject
    @State private var showingAddItem = false
    @State private var selectedItem: InventoryItem?
    @Environment(\.dismiss) private var dismiss
    
    // Computed property to get the current room from inventoryService
    var room: Room {
        inventoryService.currentReport?.rooms.first(where: { $0.id == initialRoom.id }) ?? initialRoom
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Room Header
                    RoomHeaderView(room: room)
                    
                    // Items List
                    ItemsListView(
                        items: room.items,
                        onItemTap: { item in
                            selectedItem = item
                        },
                        onItemDelete: { item in
                            Task {
                                await deleteItem(item)
                            }
                        },
                        onToggleComplete: { item in
                            Task {
                                await inventoryService.updateItemInRoom(item, roomId: room.id)
                            }
                        }
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle(room.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        Task {
                            await saveRoomChanges()
                            dismiss()
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Complete Room", systemImage: "checkmark.circle") {
                        Task {
                            await markRoomComplete()
                        }
                    }
                    .disabled(room.items.isEmpty)
                    
                    Button("Add Item", systemImage: "plus") {
                        showingAddItem = true
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddInventoryItemView(
                    roomId: room.id,
                    inventoryService: inventoryService,
                    onSaveComplete: {
                        showingAddItem = false
                        print("🔄 Item saved - triggering UI refresh")
                        // Force UI update
                        inventoryService.objectWillChange.send()
                    }
                )
            }
            .sheet(item: $selectedItem) { item in
                EditInventoryItemView(
                    item: item,
                    roomId: room.id,
                    inventoryService: inventoryService,
                    onSaveComplete: {
                        selectedItem = nil
                        print("🔄 Item updated - triggering UI refresh")
                        // Force UI update
                        inventoryService.objectWillChange.send()
                    }
                )
            }
        }
        .onAppear {
            print("📍 RoomDetailView appeared for room: \(room.name)")
            print("📍 Room has \(room.items.count) items")
        }
        .onDisappear {
            print("📍 RoomDetailView disappearing - auto-saving changes")
            Task {
                await saveRoomChanges()
            }
        }
    }
    
    private func saveRoomChanges() async {
        print("💾 Auto-saving room changes for: \(room.name)")
        await inventoryService.updateRoom(room)
        
        if let error = inventoryService.errorMessage {
            print("❌ Failed to save room: \(error)")
        } else {
            print("✅ Room changes saved successfully")
        }
    }
    
    private func markRoomComplete() async {
        print("✅ Marking room as complete: \(room.name)")
        
        guard let report = inventoryService.currentReport else {
            print("❌ No active inventory report")
            return
        }
        
        // Find the room and mark all items as complete
        if let roomIndex = report.rooms.firstIndex(where: { $0.id == room.id }) {
            for item in report.rooms[roomIndex].items {
                var updatedItem = item
                updatedItem.isComplete = true
                updatedItem.updatedAt = Date()
                
                // Use the existing updateItemInRoom method to properly sync changes
                await inventoryService.updateItemInRoom(updatedItem, roomId: room.id)
            }
            
            print("✅ Room marked as complete with \(report.rooms[roomIndex].items.count) items")
            
            // Trigger UI refresh
            inventoryService.objectWillChange.send()
        }
    }
    
    private func deleteItem(_ item: InventoryItem) async {
        print("🗑️ Moving item to deleted folder: \(item.name)")
        
        // Move to deleted folder
        let deletedService = DeletedItemsService.shared
        let propertyId = UUID() // TODO: Pass actual property ID from parent
        let propertyName = "Current Property" // TODO: Pass actual property name from parent
        deletedService.deleteInventoryItem(item, roomName: room.name, propertyId: propertyId, propertyName: propertyName)
        
        // Remove from inventory service
        await inventoryService.deleteItemFromRoom(item, roomId: room.id)
        
        if let error = inventoryService.errorMessage {
            print("❌ Failed to delete item: \(error)")
        } else {
            print("✅ Item moved to deleted folder successfully")
            // Trigger UI refresh
            inventoryService.objectWillChange.send()
        }
    }
}

struct RoomHeaderView: View {
    let room: Room
    @State private var roomImages: [UIImage] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: room.type.systemImage)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(room.type.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(room.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(room.completedItemsCount) of \(room.itemCount) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    ProgressView(value: room.completionPercentage / 100.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    Text(String(format: "%.0f%%", room.completionPercentage))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(minWidth: 40)
                }
            }
            
            // Room Photos Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Room Photos")
                        .font(.headline)
                    
                    Spacer()
                    
                    WorkingCameraButton(
                        title: "Take Photos",
                        allowMultiple: true,
                        onPhotosCaptured: { images in
                            roomImages.append(contentsOf: images)
                        }
                    )
                }
                
                // Show photos in modern gallery
                PhotoGalleryView(
                    images: roomImages,
                    onDelete: { index in
                        roomImages.remove(at: index)
                    }
                )
            }
            
            if let notes = room.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.headline)
                    
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ItemsListView: View {
    let items: [InventoryItem]
    let onItemTap: (InventoryItem) -> Void
    let onItemDelete: (InventoryItem) -> Void
    let onToggleComplete: (InventoryItem) -> Void
    @State private var itemToDelete: InventoryItem?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items (\(items.count))")
                .font(.headline)
            
            if items.isEmpty {
                EmptyItemsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        ItemRowView(item: item, onToggleComplete: onToggleComplete)
                            .onTapGesture {
                                onItemTap(item)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    itemToDelete = item
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                    }
                }
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    onItemDelete(item)
                    itemToDelete = nil
                }
            }
        } message: {
            if let item = itemToDelete {
                Text("Are you sure you want to delete '\(item.name)'? This action cannot be undone.")
            }
        }
    }
}

// MARK: - PhotoReference Gallery Components
struct PhotoReferenceGalleryView: View {
    let photoReferences: [PhotoReference]
    let onDelete: ((Int) -> Void)?
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        if photoReferences.isEmpty {
            EmptyPhotoView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("\(photoReferences.count) Photo\(photoReferences.count == 1 ? "" : "s")", systemImage: "photo.stack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(photoReferences.indices, id: \.self) { index in
                        PhotoReferenceThumbnailView(
                            photoReference: photoReferences[index],
                            onDelete: onDelete != nil ? {
                                onDelete?(index)
                            } : nil
                        )
                    }
                }
            }
        }
    }
}

struct PhotoReferenceThumbnailView: View {
    let photoReference: PhotoReference
    let onDelete: (() -> Void)?
    @State private var showingFullScreen = false
    @State private var loadedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12)
                    .onTapGesture {
                        showingFullScreen = true
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
            
            if onDelete != nil {
                Button(action: {
                    onDelete?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.red))
                        .font(.system(size: 24))
                }
                .offset(x: 8, y: -8)
            }
        }
        .onAppear {
            loadImage()
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let image = loadedImage {
                FullScreenPhotoView(image: image)
            }
        }
    }
    
    private func loadImage() {
        if let image = photoReference.loadImage() {
            self.loadedImage = image
        }
    }
}

struct ItemRowView: View {
    let item: InventoryItem
    let onToggleComplete: ((InventoryItem) -> Void)?
    
    init(item: InventoryItem, onToggleComplete: ((InventoryItem) -> Void)? = nil) {
        self.item = item
        self.onToggleComplete = onToggleComplete
    }
    
    var body: some View {
        HStack {
            // Completion Status - Greyed out tick that lights up when complete
            Button(action: {
                var updatedItem = item
                updatedItem.isComplete.toggle()
                onToggleComplete?(updatedItem)
            }) {
                Image(systemName: "checkmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(item.isComplete ? .green : .gray.opacity(0.4))
                    .background(
                        Circle()
                            .fill(item.isComplete ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .frame(width: 28, height: 28)
                    )
                    .scaleEffect(item.isComplete ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: item.isComplete)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .strikethrough(item.isComplete)
                    
                    Spacer()
                    
                    // Condition Badge
                    Text(item.condition.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(conditionColor.opacity(0.2))
                        .foregroundColor(conditionColor)
                        .cornerRadius(8)
                }
                
                Text(item.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Photos and Notes indicators
                HStack(spacing: 12) {
                    if !item.photos.isEmpty {
                        Label("\(item.photos.count)", systemImage: "camera")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if let notes = item.notes, !notes.isEmpty {
                        Label("Notes", systemImage: "note.text")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Text(item.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
    
    private var conditionColor: Color {
        switch item.condition.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
}

struct EmptyItemsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Items Added")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Add items to complete this room's inventory")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AddInventoryItemView: View {
    let roomId: UUID
    @ObservedObject var inventoryService: InventoryService
    let onSaveComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var selectedCategory = ItemCategory.furniture
    @State private var selectedCondition = ItemCondition.good
    @State private var description = ""
    @State private var notes = ""
    @State private var capturedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $itemName)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.displayName).tag(condition)
                        }
                    }
                }
                
                Section("Description") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Notes") {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Photos") {
                    PhotoGalleryView(
                        images: capturedImages,
                        onDelete: { index in
                            capturedImages.remove(at: index)
                        }
                    )
                    
                    WorkingCameraButton(
                        title: "Take Photos",
                        allowMultiple: true,
                        onPhotosCaptured: { images in
                            capturedImages.append(contentsOf: images)
                        }
                    )
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await saveItem()
                            }
                        }
                        .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .fontWeight(.semibold)
                    }
                }
            }
            .disabled(isSubmitting)
            .overlay(
                Group {
                    if isSubmitting {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .overlay(
                                VStack(spacing: 20) {
                                    ProgressView()
                                    Text("Saving item...")
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 10)
                            )
                    }
                }
            )
        }
        .alert("Error Saving Item", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveItem() async {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        isSubmitting = true
        
        print("✅ Saving item: \(trimmedName)")
        
        var newItem = InventoryItem(
            name: trimmedName,
            category: selectedCategory,
            condition: selectedCondition
        )
        
        if !description.isEmpty {
            newItem.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if !notes.isEmpty {
            newItem.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Add photos and save them to storage
        newItem.photos = capturedImages.map { image in
            PhotoReference.create(from: image)
        }
        
        print("✅ Item created with ID: \(newItem.id)")
        
        // Save the item
        await inventoryService.addItemToRoom(newItem, roomId: roomId)
        
        // Check if save was successful
        if let error = inventoryService.errorMessage {
            print("❌ Save failed: \(error)")
            errorMessage = error
            showError = true
            isSubmitting = false
        } else {
            print("✅ Item saved successfully!")
            // Close the sheet
            dismiss()
            // Notify parent view
            onSaveComplete()
        }
    }
}

struct EditInventoryItemView: View {
    let item: InventoryItem
    let roomId: UUID
    @ObservedObject var inventoryService: InventoryService
    let onSaveComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName: String
    @State private var selectedCategory: ItemCategory
    @State private var selectedCondition: ItemCondition
    @State private var description: String
    @State private var notes: String
    @State private var isComplete: Bool
    @State private var capturedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(item: InventoryItem, roomId: UUID, inventoryService: InventoryService, onSaveComplete: @escaping () -> Void) {
        self.item = item
        self.roomId = roomId
        self.inventoryService = inventoryService
        self.onSaveComplete = onSaveComplete
        
        _itemName = State(initialValue: item.name)
        _selectedCategory = State(initialValue: item.category)
        _selectedCondition = State(initialValue: item.condition)
        _description = State(initialValue: item.description ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _isComplete = State(initialValue: item.isComplete)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $itemName)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.displayName).tag(condition)
                        }
                    }
                }
                
                Section("Description") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Notes") {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Status") {
                    Toggle("Mark as Complete", isOn: $isComplete)
                }
                
                Section("Photos") {
                    // Show existing photos from the item with delete option
                    if !item.photos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Existing Photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            PhotoReferenceGalleryView(
                                photoReferences: item.photos,
                                onDelete: { index in
                                    // Remove from item's photos array
                                    var updatedItem = item
                                    updatedItem.photos.remove(at: index)
                                    // Update the item in the service
                                    Task {
                                        await inventoryService.updateItemInRoom(updatedItem, roomId: roomId)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Show newly captured images
                    if !capturedImages.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            PhotoGalleryView(
                                images: capturedImages,
                                onDelete: { index in
                                    capturedImages.remove(at: index)
                                }
                            )
                        }
                    }
                    
                    WorkingCameraButton(
                        title: "Add Photos",
                        allowMultiple: true,
                        onPhotosCaptured: { images in
                            capturedImages.append(contentsOf: images)
                        }
                    )
                }
                
                Section {
                    Button(role: .destructive) {
                        Task {
                            await deleteItem()
                        }
                    } label: {
                        Label("Delete Item", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await updateItem()
                            }
                        }
                        .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .fontWeight(.semibold)
                    }
                }
            }
            .disabled(isSubmitting)
            .overlay(
                Group {
                    if isSubmitting {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .overlay(
                                VStack(spacing: 20) {
                                    ProgressView()
                                    Text("Saving changes...")
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 10)
                            )
                    }
                }
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func updateItem() async {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        isSubmitting = true
        
        print("✅ Updating item: \(trimmedName)")
        
        var updatedItem = item
        updatedItem.name = trimmedName
        updatedItem.category = selectedCategory
        updatedItem.condition = selectedCondition
        updatedItem.description = description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.notes = notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.isComplete = isComplete
        updatedItem.updatedAt = Date()
        
        // Add any new photos and save them to storage
        if !capturedImages.isEmpty {
            let newPhotos = capturedImages.map { image in
                PhotoReference.create(from: image)
            }
            updatedItem.photos.append(contentsOf: newPhotos)
        }
        
        await inventoryService.updateItemInRoom(updatedItem, roomId: roomId)
        
        if let error = inventoryService.errorMessage {
            print("❌ Update failed: \(error)")
            errorMessage = error
            showError = true
            isSubmitting = false
        } else {
            print("✅ Item updated successfully!")
            dismiss()
            onSaveComplete()
        }
    }
    
    private func deleteItem() async {
        isSubmitting = true
        
        await inventoryService.deleteItemFromRoom(item, roomId: roomId)
        
        if let error = inventoryService.errorMessage {
            errorMessage = error
            showError = true
            isSubmitting = false
        } else {
            dismiss()
            onSaveComplete()
        }
    }
}

// MARK: - Safe Image Picker
struct SafeImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SafeImagePickerView
        
        init(_ parent: SafeImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.onImagePicked(image)
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            parent.dismiss()
        }
    }
}
