import SwiftUI
import UIKit

struct RoomDetailView: View {
    let room: Room
    @StateObject private var inventoryService = InventoryService()
    @State private var showingAddItem = false
    @State private var selectedItem: InventoryItem?
    @Environment(\.dismiss) private var dismiss
    
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
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Item", systemImage: "plus") {
                        showingAddItem = true
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddInventoryItemView(
                    roomId: room.id,
                    inventoryService: inventoryService
                )
            }
            .sheet(item: $selectedItem) { item in
                EditInventoryItemView(
                    item: item,
                    roomId: room.id,
                    inventoryService: inventoryService
                )
            }
        }
    }
}

struct RoomHeaderView: View {
    let room: Room
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)
            
            if items.isEmpty {
                EmptyItemsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        ItemRowView(item: item)
                            .onTapGesture {
                                onItemTap(item)
                            }
                    }
                }
            }
        }
    }
}

struct ItemRowView: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            // Completion Status
            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(item.isComplete ? .green : .gray)
            
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
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var selectedCategory = ItemCategory.furniture
    @State private var selectedCondition = ItemCondition.good
    @State private var description = ""
    @State private var notes = ""
    @State private var capturedImages: [UIImage] = []
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var isSubmitting = false
    
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
                    if capturedImages.isEmpty {
                        Text("No photos added")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<capturedImages.count, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: capturedImages[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button {
                                            capturedImages.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white, in: Circle())
                                        }
                                        .offset(x: 5, y: -5)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    HStack {
                        Button("Take Photo", systemImage: "camera") {
                            showingCamera = true
                        }
                        
                        Button("Choose from Library", systemImage: "photo") {
                            showingImagePicker = true
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await addItem()
                        }
                    }
                    .disabled(isSubmitting || itemName.isEmpty)
                }
            }
            .disabled(isSubmitting)
        }
        .sheet(isPresented: $showingCamera) {
            SafeImagePickerView(sourceType: .camera) { image in
                if let image = image {
                    capturedImages.append(image)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            SafeImagePickerView(sourceType: .photoLibrary) { image in
                if let image = image {
                    capturedImages.append(image)
                }
            }
        }
    }
    
    private func addItem() async {
        isSubmitting = true
        
        var newItem = InventoryItem(
            name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            condition: selectedCondition
        )
        
        if !description.isEmpty {
            newItem.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if !notes.isEmpty {
            newItem.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Add photos
        newItem.photos = capturedImages.map { image in
            PhotoReference(
                filename: "item_\(newItem.id.uuidString)_\(UUID().uuidString).jpg"
            )
        }
        
        await inventoryService.addItemToRoom(newItem, roomId: roomId)
        
        if inventoryService.errorMessage == nil {
            dismiss()
        }
        
        isSubmitting = false
    }
}

struct EditInventoryItemView: View {
    let item: InventoryItem
    let roomId: UUID
    @ObservedObject var inventoryService: InventoryService
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName: String
    @State private var selectedCategory: ItemCategory
    @State private var selectedCondition: ItemCondition
    @State private var description: String
    @State private var notes: String
    @State private var isComplete: Bool
    @State private var capturedImages: [UIImage] = []
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var isSubmitting = false
    
    init(item: InventoryItem, roomId: UUID, inventoryService: InventoryService) {
        self.item = item
        self.roomId = roomId
        self.inventoryService = inventoryService
        
        _itemName = State(initialValue: item.name)
        _selectedCategory = State(initialValue: item.category)
        _selectedCondition = State(initialValue: item.condition)
        _description = State(initialValue: item.description ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _isComplete = State(initialValue: item.isComplete)
        _capturedImages = State(initialValue: [])
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
                    if item.photos.isEmpty && capturedImages.isEmpty {
                        Text("No photos added")
                            .foregroundColor(.secondary)
                    } else {
                        if !item.photos.isEmpty {
                            Text("\(item.photos.count) existing photo\(item.photos.count != 1 ? "s" : "")")
                                .foregroundColor(.secondary)
                        }
                        
                        if !capturedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<capturedImages.count, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: capturedImages[index])
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            Button {
                                                capturedImages.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white, in: Circle())
                                            }
                                            .offset(x: 5, y: -5)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    
                    HStack {
                        Button("Take Photo", systemImage: "camera") {
                            showingCamera = true
                        }
                        
                        Button("Choose from Library", systemImage: "photo") {
                            showingImagePicker = true
                        }
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
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await updateItem()
                        }
                    }
                    .disabled(isSubmitting || itemName.isEmpty)
                }
            }
            .disabled(isSubmitting)
        }
        .sheet(isPresented: $showingCamera) {
            SafeImagePickerView(sourceType: .camera) { image in
                if let image = image {
                    capturedImages.append(image)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            SafeImagePickerView(sourceType: .photoLibrary) { image in
                if let image = image {
                    capturedImages.append(image)
                }
            }
        }
    }
    
    private func updateItem() async {
        isSubmitting = true
        
        var updatedItem = item
        updatedItem.name = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.category = selectedCategory
        updatedItem.condition = selectedCondition
        updatedItem.description = description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.notes = notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.isComplete = isComplete
        updatedItem.updatedAt = Date()
        
        // Add any new photos to existing photos
        if !capturedImages.isEmpty {
            let newPhotos = capturedImages.map { image in
                PhotoReference(
                    filename: "item_\(updatedItem.id.uuidString)_\(UUID().uuidString).jpg"
                )
            }
            updatedItem.photos.append(contentsOf: newPhotos)
        }
        
        await inventoryService.updateItemInRoom(updatedItem, roomId: roomId)
        
        if inventoryService.errorMessage == nil {
            dismiss()
        }
        
        isSubmitting = false
    }
}

// MARK: - Safe Image Picker
struct SafeImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        let coordinator = makeCoordinator()
        
        // Basic setup with safety checks
        picker.delegate = coordinator
        picker.allowsEditing = true
        
        // Check source type availability
        if sourceType == .camera {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                // Safe camera configuration
                picker.cameraFlashMode = .auto
                picker.showsCameraControls = true
            } else {
                print("📷 Camera not available, falling back to photo library")
                picker.sourceType = .photoLibrary
            }
        } else {
            picker.sourceType = sourceType
        }
        
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
            super.init()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            
            DispatchQueue.main.async {
                self.parent.onImagePicked(image)
                self.parent.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                self.parent.onImagePicked(nil)
                self.parent.dismiss()
            }
        }
    }
}

#Preview {
    let sampleRoom = Room(name: "Living Room", type: .livingRoom)
    return RoomDetailView(room: sampleRoom)
}