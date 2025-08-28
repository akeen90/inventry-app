import SwiftUI
import UIKit
import AVFoundation

// MARK: - Modern iOS-Native Camera Implementation
struct ModernCameraView: UIViewControllerRepresentable {
    let onPhotoTaken: (UIImage) -> Void
    let cameraMode: CameraMode
    @Environment(\.dismiss) private var dismiss
    
    enum CameraMode {
        case item
        case room
        
        var title: String {
            switch self {
            case .item: return "Take Item Photo"
            case .room: return "Take Room Photo"
            }
        }
        
        var instructions: String {
            switch self {
            case .item: return "Focus on the specific item"
            case .room: return "Capture the entire room view"
            }
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.cameraDevice = .rear
        
        // Modern iOS camera configuration
        if #available(iOS 13.0, *) {
            picker.overrideUserInterfaceStyle = .dark
        }
        
        // Try to use the best camera for the mode
        if cameraMode == .room {
            // For room photos, try ultra-wide if available
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                picker.cameraDevice = .rear
                // Note: UIImagePickerController doesn't directly support ultra-wide selection
                // but iOS will automatically use the best camera for the situation
            }
        }
        
        // High-quality capture
        picker.cameraCaptureMode = .photo
        picker.cameraFlashMode = .auto
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Update camera title if needed
        uiViewController.title = cameraMode.title
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ModernCameraView
        
        init(_ parent: ModernCameraView) {
            self.parent = parent
            super.init()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            // Get the highest quality image available
            var finalImage: UIImage?
            
            // Try edited image first (if user cropped/edited)
            if let editedImage = info[.editedImage] as? UIImage {
                finalImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                finalImage = originalImage
            }
            
            // Process and optimize the image
            if let image = finalImage {
                let optimizedImage = optimizeImage(image, for: parent.cameraMode)
                
                DispatchQueue.main.async {
                    self.parent.onPhotoTaken(optimizedImage)
                    self.parent.dismiss()
                }
            } else {
                print("❌ Failed to get image from camera")
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                self.parent.dismiss()
            }
        }
        
        private func optimizeImage(_ image: UIImage, for mode: ModernCameraView.CameraMode) -> UIImage {
            // Optimize image based on camera mode
            let targetSize: CGSize
            
            switch mode {
            case .room:
                // Room photos can be slightly smaller since they're overview shots
                targetSize = CGSize(width: 2048, height: 1536)
            case .item:
                // Item photos should be high resolution for detail
                targetSize = CGSize(width: 2048, height: 1536)
            }
            
            return resizeImage(image, to: targetSize) ?? image
        }
        
        private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
            let size = image.size
            
            // Don't upscale images
            if size.width <= targetSize.width && size.height <= targetSize.height {
                return image
            }
            
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            let ratio = min(widthRatio, heightRatio)
            
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: newSize))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}

// MARK: - Enhanced Camera View with Instructions
struct EnhancedCameraView: View {
    let onPhotoTaken: (UIImage) -> Void
    let cameraMode: ModernCameraView.CameraMode
    @State private var showingCamera = false
    @State private var showingPermissionAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Camera preview area
            ZStack {
                Color.black
                
                VStack(spacing: 20) {
                    // Camera icon
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.7))
                    
                    VStack(spacing: 8) {
                        Text(cameraMode.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(cameraMode.instructions)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Open Camera") {
                        checkCameraPermission()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(25)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $showingCamera) {
            ModernCameraView(
                onPhotoTaken: onPhotoTaken,
                cameraMode: cameraMode
            )
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Please enable camera access in Settings to take photos for your inventory.")
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .denied, .restricted:
            showingPermissionAlert = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    } else {
                        showingPermissionAlert = true
                    }
                }
            }
        @unknown default:
            showingPermissionAlert = true
        }
    }
    
    private func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - Quick Camera Button for Inline Use
struct QuickCameraButton: View {
    let onPhotoTaken: (UIImage) -> Void
    let cameraMode: ModernCameraView.CameraMode
    let title: String
    
    @State private var showingCamera = false
    
    var body: some View {
        Button(action: {
            showingCamera = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "camera")
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.blue)
        }
        .sheet(isPresented: $showingCamera) {
            ModernCameraView(
                onPhotoTaken: onPhotoTaken,
                cameraMode: cameraMode
            )
        }
    }
}