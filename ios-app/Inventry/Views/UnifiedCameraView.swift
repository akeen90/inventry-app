import SwiftUI
import UIKit
import AVFoundation
import Photos

// MARK: - Unified Camera View for iPhone 16 Pro
struct UnifiedCameraView: View {
    let mode: CameraMode
    let allowsMultiple: Bool
    let onPhotosCapture: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var cameraModel = CameraViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview or permission view
                if cameraModel.permissionGranted {
                    CameraPreviewView(session: cameraModel.session)
                        .ignoresSafeArea()
                        .onAppear {
                            cameraModel.startSession()
                        }
                        .onDisappear {
                            cameraModel.stopSession()
                        }
                } else {
                    CameraPermissionView(
                        onRequestPermission: {
                            cameraModel.requestPermission()
                        }
                    )
                }
                
                // Overlay UI
                VStack {
                    // Top bar
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        if allowsMultiple && !cameraModel.capturedImages.isEmpty {
                            HStack {
                                Text("\(cameraModel.capturedImages.count)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Image(systemName: "photo.stack")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                        }
                        
                        if cameraModel.hasMultipleCameras {
                            Button(action: {
                                cameraModel.switchCamera()
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Bottom controls
                    VStack(spacing: 20) {
                        // Mode indicator
                        Text(mode.instructions)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                        
                        // Captured images preview (if multiple allowed)
                        if allowsMultiple && !cameraModel.capturedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(cameraModel.capturedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: cameraModel.capturedImages[index])
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                            
                                            Button(action: {
                                                cameraModel.removeImage(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.clipShape(Circle()))
                                            }
                                            .offset(x: 5, y: -5)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 70)
                        }
                        
                        // Capture controls
                        HStack(spacing: 40) {
                            // Photo library button
                            Button(action: {
                                cameraModel.showingImagePicker = true
                            }) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            
                            // Shutter button
                            Button(action: {
                                cameraModel.capturePhoto()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .frame(width: 80, height: 80)
                                }
                            }
                            .scaleEffect(cameraModel.isCapturing ? 0.8 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: cameraModel.isCapturing)
                            .disabled(!cameraModel.isReady || cameraModel.isCapturing)
                            
                            // Done button (if multiple photos captured)
                            if allowsMultiple && !cameraModel.capturedImages.isEmpty {
                                Button(action: {
                                    onPhotosCapture(cameraModel.capturedImages)
                                    dismiss()
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                        .frame(width: 50, height: 50)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                            } else if !allowsMultiple && !cameraModel.capturedImages.isEmpty {
                                // Auto-close after single capture
                                Color.clear.frame(width: 50, height: 50)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            onPhotosCapture(cameraModel.capturedImages)
                                            dismiss()
                                        }
                                    }
                            } else {
                                Color.clear.frame(width: 50, height: 50)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                // Loading overlay
                if cameraModel.isProcessing {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text("Processing...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        )
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $cameraModel.showingImagePicker) {
                ImagePicker(
                    sourceType: .photoLibrary,
                    allowsMultiple: allowsMultiple
                ) { images in
                    cameraModel.capturedImages.append(contentsOf: images)
                    if !allowsMultiple && !images.isEmpty {
                        onPhotosCapture(images)
                        dismiss()
                    }
                }
            }
            .alert("Camera Error", isPresented: $cameraModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(cameraModel.errorMessage)
            }
        }
    }
}

// MARK: - Camera Mode
enum CameraMode {
    case property
    case room
    case item
    
    var title: String {
        switch self {
        case .property: return "Property Photo"
        case .room: return "Room Photo"
        case .item: return "Item Photo"
        }
    }
    
    var instructions: String {
        switch self {
        case .property: return "📷 Capture property exterior"
        case .room: return "📷 Capture entire room view"
        case .item: return "📷 Focus on specific item"
        }
    }
}

// MARK: - Camera View Model
class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImages: [UIImage] = []
    @Published var isReady = false
    @Published var isCapturing = false
    @Published var isProcessing = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var permissionGranted = false
    @Published var hasMultipleCameras = false
    @Published var showingImagePicker = false
    
    let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    self?.setupSession()
                }
            }
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Setup camera input
        if let device = getBestCamera(for: currentCameraPosition),
           let input = try? AVCaptureDeviceInput(device: device) {
            
            if session.canAddInput(input) {
                session.addInput(input)
                deviceInput = input
            }
            
            // Configure device for optimal performance
            try? device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        }
        
        // Setup photo output
        let output = AVCapturePhotoOutput()
        output.maxPhotoQualityPrioritization = .balanced
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
        }
        
        session.commitConfiguration()
        
        // Check for multiple cameras
        checkMultipleCameras()
        
        DispatchQueue.main.async {
            self.isReady = true
        }
    }
    
    private func getBestCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // iPhone 16 Pro specific camera selection
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,    // iPhone Pro models
            .builtInDualWideCamera,   // iPhone Pro Max
            .builtInWideAngleCamera,  // Standard
            .builtInTelephotoCamera   // Telephoto
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: position
        )
        
        return discoverySession.devices.first
    }
    
    private func checkMultipleCameras() {
        let frontCamera = getBestCamera(for: .front)
        let backCamera = getBestCamera(for: .back)
        hasMultipleCameras = (frontCamera != nil && backCamera != nil)
    }
    
    func startSession() {
        guard !session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopSession() {
        guard session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput, !isCapturing else { return }
        
        isCapturing = true
        
        let settings = AVCapturePhotoSettings()
        
        // Use JPEG for better compatibility
        if photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            settings.photoCodecType = .jpeg
        }
        
        // Enable flash if available
        if let device = deviceInput?.device, device.hasFlash {
            settings.flashMode = .auto
        }
        
        // Capture with highest quality
        settings.photoQualityPrioritization = .quality
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        guard hasMultipleCameras else { return }
        
        session.beginConfiguration()
        
        // Remove current input
        if let currentInput = deviceInput {
            session.removeInput(currentInput)
        }
        
        // Switch position
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // Add new input
        if let device = getBestCamera(for: currentCameraPosition),
           let input = try? AVCaptureDeviceInput(device: device) {
            
            if session.canAddInput(input) {
                session.addInput(input)
                deviceInput = input
            }
        }
        
        session.commitConfiguration()
    }
    
    func removeImage(at index: Int) {
        guard index < capturedImages.count else { return }
        capturedImages.remove(at: index)
    }
}

// MARK: - Photo Capture Delegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            DispatchQueue.main.async {
                self.isCapturing = false
            }
        }
        
        if let error = error {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to process photo"
                self.showError = true
            }
            return
        }
        
        // Process image for optimal quality
        let processedImage = processImage(image)
        
        DispatchQueue.main.async {
            self.capturedImages.append(processedImage)
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    private func processImage(_ image: UIImage) -> UIImage {
        // Optimize image size for storage and performance
        let maxDimension: CGFloat = 2048
        
        let size = image.size
        var newSize = size
        
        if size.width > maxDimension || size.height > maxDimension {
            let scale = min(maxDimension / size.width, maxDimension / size.height)
            newSize = CGSize(width: size.width * scale, height: size.height * scale)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let processedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return processedImage
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Camera Permission View
struct CameraPermissionView: View {
    let onRequestPermission: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                Text("Camera Access Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Allow camera access to take photos for your inventory items")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: onRequestPermission) {
                Text("Grant Access")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            
            Button(action: {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }) {
                Text("Open Settings")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

// MARK: - Image Picker for Photo Library
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let allowsMultiple: Bool
    let onImagesPicked: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagesPicked([image])
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Quick Camera Button Helper
struct UnifiedCameraButton: View {
    let title: String
    let mode: CameraMode
    let allowsMultiple: Bool
    let onPhotosCapture: ([UIImage]) -> Void
    
    @State private var showingCamera = false
    
    var body: some View {
        Button(action: {
            showingCamera = true
        }) {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title3)
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            UnifiedCameraView(
                mode: mode,
                allowsMultiple: allowsMultiple,
                onPhotosCapture: onPhotosCapture
            )
        }
    }
}
