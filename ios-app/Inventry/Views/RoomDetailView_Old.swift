import SwiftUI
import UIKit
import AVFoundation
import CoreMedia

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
                    
                    QuickCameraButton(
                        onPhotoTaken: { image in
                            roomImages.append(image)
                        },
                        cameraMode: .room,
                        title: "Take Photo"
                    )
                }
                
                if roomImages.isEmpty && room.photos.isEmpty {
                    HStack {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("No room photos added yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Show existing photos from room model
                            ForEach(0..<room.photos.count, id: \.self) { index in
                                RoomPhotoThumbnail(photo: room.photos[index])
                            }
                            
                            // Show newly captured photos
                            ForEach(0..<roomImages.count, id: \.self) { index in
                                Image(uiImage: roomImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
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
                        QuickCameraButton(
                            onPhotoTaken: { image in
                                capturedImages.append(image)
                            },
                            cameraMode: .item,
                            title: "Take Photo"
                        )
                        
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
                        QuickCameraButton(
                            onPhotoTaken: { image in
                                capturedImages.append(image)
                            },
                            cameraMode: .item,
                            title: "Take Photo"
                        )
                        
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

// MARK: - Room Photo Components
struct RoomPhotoThumbnail: View {
    let photo: PhotoReference
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            if let image = photo.originalImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Loading...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

struct RoomCameraView: UIViewControllerRepresentable {
    let onPhotoTaken: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> RoomCameraController {
        let controller = RoomCameraController()
        controller.onPhotoTaken = onPhotoTaken
        controller.onDismiss = { dismiss() }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: RoomCameraController, context: Context) {}
}

class RoomCameraController: UIViewController {
    var onPhotoTaken: ((UIImage) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var currentCamera: AVCaptureDevice!
    private var currentCameraInput: AVCaptureDeviceInput!
    
    private var shutterButton: UIButton!
    private var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        print("🏠📷 Room Camera loading...")
        checkCameraPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("📷✅ Room camera authorized, setting up")
            setupCameraAndUI()
        case .denied:
            print("📷❌ Room camera denied")
            showAlert(title: "Camera Access Required", message: "Please enable camera access in Settings to take room photos.")
        case .restricted:
            print("📷⛔ Room camera restricted")
            showAlert(title: "Camera Restricted", message: "Camera access is restricted on this device.")
        case .notDetermined:
            print("📷❓ Room camera permission not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("📷✅ Room camera permission granted")
                        self.setupCameraAndUI()
                    } else {
                        print("📷❌ Room camera permission denied by user")
                        self.showAlert(title: "Camera Access Required", message: "Please enable camera access to take room photos.")
                    }
                }
            }
        @unknown default:
            print("📷❓ Unknown room camera permission status")
            showAlert(title: "Camera Error", message: "Unable to determine camera permissions.")
        }
    }
    
    private func setupCameraAndUI() {
        print("🔧 Setting up room camera session...")
        
        captureSession = AVCaptureSession()
        
        // Use high quality photo preset for room photos
        captureSession.sessionPreset = .photo
        print("📷 Using photo preset for high-quality room photos")
        
        // Try to get the best available camera (including ultra-wide for room photos)
        var camera: AVCaptureDevice?
        
        // First try ultra-wide camera for better room coverage
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            camera = ultraWideCamera
            print("📷 Using ultra-wide camera for room photos")
        } else if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            camera = wideCamera
            print("📷 Using wide camera for room photos")
        }
        
        guard let selectedCamera = camera else {
            print("❌ No suitable camera found for room photos")
            showAlert(title: "Camera Error", message: "Unable to access camera for room photos.")
            return
        }
        
        currentCamera = selectedCamera
        
        do {
            currentCameraInput = try AVCaptureDeviceInput(device: selectedCamera)
            
            if captureSession.canAddInput(currentCameraInput) {
                captureSession.addInput(currentCameraInput)
                print("✅ Added room camera input")
            } else {
                print("❌ Cannot add room camera input")
                return
            }
            
            photoOutput = AVCapturePhotoOutput()
            
            // Configure for maximum quality room photos (iOS 16+ modern API)
            if #available(iOS 16.0, *) {
                photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024) // 12MP
            } else {
                photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                print("✅ Added room photo output")
            } else {
                print("❌ Cannot add room photo output")
                return
            }
            
            setupPreviewAndUI()
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
                print("🎬 Room camera session started")
            }
            
        } catch {
            print("❌ Room camera setup error: \(error)")
            showAlert(title: "Camera Error", message: "Failed to set up room camera: \(error.localizedDescription)")
        }
    }
    
    private func setupPreviewAndUI() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        setupUI()
    }
    
    private func setupUI() {
        // Shutter button - optimized for room photos
        shutterButton = UIButton()
        shutterButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        shutterButton.center = CGPoint(x: view.center.x, y: view.frame.height - 120)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 40
        shutterButton.layer.borderWidth = 6
        shutterButton.layer.borderColor = UIColor.systemGreen.cgColor  // Green for room photos
        
        // Add inner circle
        let innerCircle = UIView()
        innerCircle.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = 30
        shutterButton.addSubview(innerCircle)
        
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Cancel button
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 20, y: 60, width: 80, height: 40)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cancelButton.layer.cornerRadius = 20
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Room photo specific info label
        let infoLabel = UILabel()
        infoLabel.frame = CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 30)
        infoLabel.text = "Capture room overview - Wide angle recommended"
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(infoLabel)
        
        // Grid overlay for better composition
        addGridOverlay()
    }
    
    private func addGridOverlay() {
        let gridView = UIView(frame: view.bounds)
        gridView.isUserInteractionEnabled = false
        gridView.alpha = 0.3
        
        // Horizontal lines
        for i in 1...2 {
            let line = UIView()
            line.backgroundColor = .white
            line.frame = CGRect(x: 0, y: gridView.frame.height / 3 * CGFloat(i), width: gridView.frame.width, height: 1)
            gridView.addSubview(line)
        }
        
        // Vertical lines  
        for i in 1...2 {
            let line = UIView()
            line.backgroundColor = .white
            line.frame = CGRect(x: gridView.frame.width / 3 * CGFloat(i), y: 0, width: 1, height: gridView.frame.height)
            gridView.addSubview(line)
        }
        
        view.addSubview(gridView)
        view.sendSubviewToBack(gridView)
    }
    
    @objc private func shutterTapped() {
        print("📸 Taking room photo...")
        
        shutterButton.isEnabled = false
        shutterButton.alpha = 0.5
        
        let photoSettings = AVCapturePhotoSettings()
        
        // Maximum quality for room overview photos (iOS 16+ modern API)
        if #available(iOS 16.0, *) {
            photoSettings.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
            photoSettings.photoQualityPrioritization = .quality
        } else {
            if photoOutput.isHighResolutionCaptureEnabled {
                photoSettings.isHighResolutionPhotoEnabled = true
            }
        }
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func cancelTapped() {
        print("❌ Room camera cancelled")
        cleanup()
        onDismiss?()
    }
    
    private func cleanup() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onDismiss?()
        })
        present(alert, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanup()
    }
}

extension RoomCameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            self.shutterButton.isEnabled = true
            self.shutterButton.alpha = 1.0
        }
        
        if let error = error {
            print("📸❌ Room photo capture error: \(error)")
            DispatchQueue.main.async {
                self.showAlert(title: "Photo Error", message: "Failed to capture room photo: \(error.localizedDescription)")
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("📸❌ Failed to process room photo data")
            DispatchQueue.main.async {
                self.showAlert(title: "Photo Error", message: "Failed to process room photo.")
            }
            return
        }
        
        print("📸✅ Room photo captured successfully - Size: \(image.size)")
        
        DispatchQueue.main.async {
            self.cleanup()
            self.onPhotoTaken?(image)
            self.onDismiss?()
        }
    }
}

// MARK: - Custom Camera for Inventory Items
struct InventoryItemCameraView: UIViewControllerRepresentable {
    let onPhotoTaken: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> InventoryItemCameraController {
        let controller = InventoryItemCameraController()
        controller.onPhotoTaken = onPhotoTaken
        controller.onDismiss = { dismiss() }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: InventoryItemCameraController, context: Context) {}
}

class InventoryItemCameraController: UIViewController {
    var onPhotoTaken: ((UIImage) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var currentCamera: AVCaptureDevice!
    private var currentCameraInput: AVCaptureDeviceInput!
    
    private var shutterButton: UIButton!
    private var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        print("🏠📷 Inventory Item Camera loading...")
        checkCameraPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("📷✅ Camera authorized, setting up camera")
            setupCameraAndUI()
        case .denied:
            print("📷❌ Camera denied")
            showAlert(title: "Camera Access Required", message: "Please enable camera access in Settings to take photos.")
        case .restricted:
            print("📷⛔ Camera restricted")
            showAlert(title: "Camera Restricted", message: "Camera access is restricted on this device.")
        case .notDetermined:
            print("📷❓ Camera permission not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("📷✅ Camera permission granted")
                        self.setupCameraAndUI()
                    } else {
                        print("📷❌ Camera permission denied by user")
                        self.showAlert(title: "Camera Access Required", message: "Please enable camera access to take photos.")
                    }
                }
            }
        @unknown default:
            print("📷❓ Unknown camera permission status")
            showAlert(title: "Camera Error", message: "Unable to determine camera permissions.")
        }
    }
    
    private func setupCameraAndUI() {
        print("🔧 Setting up camera session...")
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo  // High resolution for inventory photos
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ No back camera found")
            showAlert(title: "Camera Error", message: "Unable to access camera.")
            return
        }
        
        print("📷 Found camera device: \(camera.localizedName)")
        currentCamera = camera
        
        do {
            currentCameraInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(currentCameraInput) {
                captureSession.addInput(currentCameraInput)
                print("✅ Added camera input")
            } else {
                print("❌ Cannot add camera input")
                return
            }
            
            photoOutput = AVCapturePhotoOutput()
            
            // Configure for high-quality photos (iOS 16+ modern API)
            if #available(iOS 16.0, *) {
                photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024) // 12MP
            } else {
                photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                print("✅ Added photo output")
            } else {
                print("❌ Cannot add photo output")
                return
            }
            
            setupPreviewAndUI()
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
                print("🎬 Camera session started")
            }
            
        } catch {
            print("❌ Camera setup error: \(error)")
            showAlert(title: "Camera Error", message: "Failed to set up camera: \(error.localizedDescription)")
        }
    }
    
    private func setupPreviewAndUI() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        setupUI()
    }
    
    private func setupUI() {
        // Shutter button - large and accessible
        shutterButton = UIButton()
        shutterButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        shutterButton.center = CGPoint(x: view.center.x, y: view.frame.height - 120)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 40
        shutterButton.layer.borderWidth = 6
        shutterButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Add inner circle for professional look
        let innerCircle = UIView()
        innerCircle.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = 30
        shutterButton.addSubview(innerCircle)
        
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Cancel button - top left
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 20, y: 60, width: 80, height: 40)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cancelButton.layer.cornerRadius = 20
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Camera info label
        let infoLabel = UILabel()
        infoLabel.frame = CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 30)
        infoLabel.text = "Tap to take high-resolution photo"
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(infoLabel)
    }
    
    @objc private func shutterTapped() {
        print("📸 Taking photo...")
        
        // Disable button during capture
        shutterButton.isEnabled = false
        shutterButton.alpha = 0.5
        
        // Configure photo settings for high quality
        let photoSettings = AVCapturePhotoSettings()
        
        // Enable high resolution and quality (iOS 16+ modern API)
        if #available(iOS 16.0, *) {
            photoSettings.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
            photoSettings.photoQualityPrioritization = .quality
        } else {
            if photoOutput.isHighResolutionCaptureEnabled {
                photoSettings.isHighResolutionPhotoEnabled = true
            }
        }
        
        // Take photo
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func cancelTapped() {
        print("❌ Camera cancelled")
        cleanup()
        onDismiss?()
    }
    
    private func cleanup() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onDismiss?()
        })
        present(alert, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanup()
    }
}

extension InventoryItemCameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Re-enable button
        DispatchQueue.main.async {
            self.shutterButton.isEnabled = true
            self.shutterButton.alpha = 1.0
        }
        
        if let error = error {
            print("📸❌ Photo capture error: \(error)")
            DispatchQueue.main.async {
                self.showAlert(title: "Photo Error", message: "Failed to capture photo: \(error.localizedDescription)")
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("📸❌ Failed to process photo data")
            DispatchQueue.main.async {
                self.showAlert(title: "Photo Error", message: "Failed to process captured photo.")
            }
            return
        }
        
        print("📸✅ Photo captured successfully - Size: \(image.size)")
        
        DispatchQueue.main.async {
            self.cleanup()
            self.onPhotoTaken?(image)
            self.onDismiss?()
        }
    }
}

// MARK: - Safe Image Picker (for photo library only)
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