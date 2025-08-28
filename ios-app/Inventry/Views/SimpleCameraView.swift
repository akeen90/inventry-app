import SwiftUI
import UIKit
import AVFoundation

// MARK: - Ultra-Simple Camera View for iPhone 16 Pro Stability
struct SimpleCameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Ultra-conservative settings for maximum stability
        picker.sourceType = .camera
        picker.allowsEditing = false  // Disable editing to prevent crashes
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        picker.showsCameraControls = true
        
        // iPhone 16 Pro specific: Disable any advanced features
        if #available(iOS 17.0, *) {
            // Don't set any iOS 17+ specific properties that might cause issues
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates to prevent instability
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SimpleCameraView
        
        init(_ parent: SimpleCameraView) {
            self.parent = parent
            super.init()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Get the original image (no editing to avoid crashes)
            let image = info[.originalImage] as? UIImage
            
            // Immediately dismiss and return result on main thread
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self.parent.onImageCaptured(image)
                    self.parent.dismiss()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self.parent.onImageCaptured(nil)
                    self.parent.dismiss()
                }
            }
        }
        
        // Handle any navigation controller errors
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            // Ensure we're on main thread
            DispatchQueue.main.async {
                // No additional operations to prevent crashes
            }
        }
    }
}

// MARK: - Minimal Photo Capture Interface
struct MinimalPhotoCaptureView: View {
    @Binding var capturedImages: [PhotoReference]
    let itemName: String
    let roomName: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingCamera = false
    @State private var showingLibrary = false
    @State private var cameraAvailable = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Simple header
                VStack(spacing: 12) {
                    Text("📷 Take Photos")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(itemName) - \(roomName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Simple action buttons
                VStack(spacing: 20) {
                    Button(action: {
                        takePhoto()
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Take Photo")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(cameraAvailable ? Color.blue : Color.gray)
                        .cornerRadius(16)
                    }
                    .disabled(!cameraAvailable)
                    
                    Button(action: {
                        showingLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Choose from Library")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                
                // Simple photo list
                if !capturedImages.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(capturedImages) { photo in
                                SimplePhotoRow(photo: photo)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No photos taken yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                checkCameraAvailability()
            }
            .fullScreenCover(isPresented: $showingCamera) {
                SimpleCameraView { image in
                    if let image = image {
                        let photoRef = PhotoReference(
                            filename: "photo_\(UUID().uuidString).jpg",
                            originalImage: image
                        )
                        capturedImages.append(photoRef)
                    }
                }
            }
            .sheet(isPresented: $showingLibrary) {
                SimpleImagePicker(sourceType: .photoLibrary) { image in
                    if let image = image {
                        let photoRef = PhotoReference(
                            filename: "photo_\(UUID().uuidString).jpg",
                            originalImage: image
                        )
                        capturedImages.append(photoRef)
                    }
                }
            }
            .alert("Camera Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func checkCameraAvailability() {
        cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    private func takePhoto() {
        // Check permissions first
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showingCamera = true
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    } else {
                        alertMessage = "Camera permission is required to take photos. Please enable it in Settings."
                        showingAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            alertMessage = "Camera permission is required. Please enable it in Settings > Privacy & Security > Camera."
            showingAlert = true
            
        @unknown default:
            alertMessage = "Camera not available."
            showingAlert = true
        }
    }
}

// MARK: - Simple Photo Row
struct SimplePhotoRow: View {
    let photo: PhotoReference
    
    var body: some View {
        HStack {
            // Thumbnail
            Group {
                if let image = photo.originalImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Photo")
                    .font(.headline)
                
                Text(DateFormatter.localizedString(from: photo.createdAt, dateStyle: .none, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Simple Image Picker (Reuse from SafeCameraView.swift)
struct MinimalImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false  // Disable editing for stability
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MinimalImagePicker
        
        init(_ parent: MinimalImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self.parent.onImagePicked(image)
                    self.parent.dismiss()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self.parent.onImagePicked(nil)
                    self.parent.dismiss()
                }
            }
        }
    }
}