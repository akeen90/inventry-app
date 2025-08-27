import SwiftUI
import UIKit
import AVFoundation

// MARK: - Modern Photo Capture Interface
struct ModernPhotoCaptureView: View {
    @Binding var capturedImages: [PhotoReference]
    let itemName: String
    let roomName: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: PhotoReference?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingPhotoDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        PhotoCaptureHeaderView(itemName: itemName, roomName: roomName)
                        
                        // Quick Action Buttons
                        PhotoCaptureActionsView(
                            onCameraCapture: { 
                                sourceType = .camera
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    showingCamera = true
                                }
                            },
                            onPhotoLibrary: { 
                                sourceType = .photoLibrary
                                showingImagePicker = true
                            }
                        )
                        
                        // Photo Grid
                        if !capturedImages.isEmpty {
                            PhotoGridView(
                                images: capturedImages,
                                onImageTap: { image in
                                    selectedImage = image
                                    showingPhotoDetail = true
                                },
                                onDeleteImage: { image in
                                    capturedImages.removeAll { $0.id == image.id }
                                }
                            )
                        } else {
                            EmptyPhotoStateView()
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Photo Documentation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(capturedImages.count) photos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ModernImagePickerView(sourceType: sourceType) { image in
                    if let image = image {
                        let photoRef = PhotoReference(
                            filename: "photo_\(UUID().uuidString).jpg",
                            originalImage: image
                        )
                        capturedImages.append(photoRef)
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                ModernCameraView { image in
                    if let image = image {
                        let photoRef = PhotoReference(
                            filename: "photo_\(UUID().uuidString).jpg",
                            originalImage: image
                        )
                        capturedImages.append(photoRef)
                    }
                }
            }
            .sheet(item: $selectedImage) { image in
                PhotoDetailView(photo: image)
            }
        }
    }
}

// MARK: - Photo Capture Header
struct PhotoCaptureHeaderView: View {
    let itemName: String
    let roomName: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Document \(itemName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Room: \(roomName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Tips section
            VStack(alignment: .leading, spacing: 8) {
                Text("📸 Photo Tips")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 4) {
                    PhotoTipRow(icon: "lightbulb.fill", tip: "Use good lighting", color: .orange)
                    PhotoTipRow(icon: "viewfinder", tip: "Capture multiple angles", color: .blue)
                    PhotoTipRow(icon: "ruler", tip: "Include reference objects for scale", color: .green)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
    }
}

struct PhotoTipRow: View {
    let icon: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(tip)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Photo Capture Actions
struct PhotoCaptureActionsView: View {
    let onCameraCapture: () -> Void
    let onPhotoLibrary: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Photos")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                PhotoActionButton(
                    title: "Camera",
                    subtitle: "Take new photo",
                    icon: "camera.fill",
                    color: .blue,
                    isAvailable: UIImagePickerController.isSourceTypeAvailable(.camera),
                    action: onCameraCapture
                )
                
                PhotoActionButton(
                    title: "Photo Library",
                    subtitle: "Choose existing",
                    icon: "photo.on.rectangle",
                    color: .purple,
                    isAvailable: true,
                    action: onPhotoLibrary
                )
            }
        }
    }
}

struct PhotoActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isAvailable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: isAvailable ? action : {}) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: isAvailable ? [color, color.opacity(0.8)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isAvailable ? .white : .gray)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isAvailable ? .primary : .secondary)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: isAvailable ? .black.opacity(0.06) : .clear, radius: 8, x: 0, y: 2)
            )
            .opacity(isAvailable ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
    }
}

// MARK: - Photo Grid View
struct PhotoGridView: View {
    let images: [PhotoReference]
    let onImageTap: (PhotoReference) -> Void
    let onDeleteImage: (PhotoReference) -> Void
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Captured Photos")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(images.count) photos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(images) { photoRef in
                    PhotoThumbnailCard(
                        photo: photoRef,
                        onTap: { onImageTap(photoRef) },
                        onDelete: { onDeleteImage(photoRef) }
                    )
                }
            }
        }
    }
}

struct PhotoThumbnailCard: View {
    let photo: PhotoReference
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            // Photo thumbnail
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
                .frame(height: 140)
                .overlay(
                    Group {
                        if let image = photo.originalImage {
                            // Display actual image if available
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } else {
                            // Placeholder when no image available
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text(photo.filename)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Delete button with improved design
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDelete) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(8)
                }
                Spacer()
            }
            
            // Photo info overlay
            VStack {
                Spacer()
                HStack {
                    Text(formatDate(photo.createdAt))
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding(8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Empty Photo State
struct EmptyPhotoStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "camera.badge.ellipsis")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("No Photos Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Capture photos to document this item's condition")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Enhanced Image Picker with Safe Error Handling
struct ModernImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        let coordinator = makeCoordinator()
        
        // Basic setup
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
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ModernImagePickerView
        
        init(_ parent: ModernImagePickerView) {
            self.parent = parent
            super.init()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Get image safely
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            
            // Always dismiss on main thread
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

// MARK: - Modern Camera View
struct ModernCameraView: View {
    let onImageCaptured: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ModernImagePickerView(sourceType: .camera, onImagePicked: onImageCaptured)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - Enhanced Photo Detail View
struct PhotoDetailView: View {
    let photo: PhotoReference
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Full-size photo with zoom and pan support
                    Group {
                        if let image = photo.originalImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                let delta = value / lastScale
                                                lastScale = value
                                                scale = min(max(scale * delta, 0.5), 4.0) // Limit scale between 0.5x and 4x
                                            }
                                            .onEnded { _ in
                                                lastScale = 1.0
                                            },
                                        
                                        DragGesture()
                                            .onChanged { value in
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                offset = newOffset
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                            }
                                    )
                                )
                                .onTapGesture(count: 2) {
                                    // Double tap to zoom
                                    withAnimation(.spring()) {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            scale = 2.0
                                        }
                                    }
                                }
                        } else {
                            // Placeholder when no image available
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray5))
                                .aspectRatio(4/3, contentMode: .fit)
                                .overlay(
                                    VStack(spacing: 16) {
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 64))
                                            .foregroundColor(.blue)
                                        
                                        VStack(spacing: 8) {
                                            Text(photo.filename)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text("Image not available")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                )
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    // Photo info
                    VStack(spacing: 8) {
                        Text(photo.filename)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Created: \(formatDate(photo.createdAt))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if photo.originalImage != nil {
                            Button("Share", systemImage: "square.and.arrow.up") {
                                // Share the image
                                sharePhoto()
                            }
                            
                            Button("Save to Library", systemImage: "square.and.arrow.down") {
                                // Save to photo library
                                savePhotoToLibrary()
                            }
                        }
                        
                        Button("View Info", systemImage: "info.circle") {
                            // Show photo info
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func sharePhoto() {
        guard let image = photo.originalImage else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    private func savePhotoToLibrary() {
        guard let image = photo.originalImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // In a real app, you'd want to request permission first and show feedback
        print("📷 Photo saved to library")
    }
}

// MARK: - Legacy ImagePickerView (keep for compatibility)
struct ImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
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