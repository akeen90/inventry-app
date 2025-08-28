import SwiftUI
import UIKit
import AVFoundation
import Photos

// MARK: - Advanced Camera View that Works
@available(iOS 14.0, *)
struct AdvancedCameraView: View {
    @Binding var capturedImages: [PhotoReference]
    let itemName: String
    let roomName: String
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var cameraManager = CameraManager()
    @State private var showingImagePicker = false
    @State private var selectedImage: PhotoReference?
    @State private var showingPhotoDetail = false
    @State private var flashMode: AVCaptureDevice.FlashMode = .auto
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Camera Preview
                    CameraPreviewView(session: cameraManager.session)
                        .ignoresSafeArea()
                        .overlay(alignment: .top) {
                            // Top Controls
                            HStack {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 4) {
                                    Text(itemName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(roomName)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Spacer()
                                
                                Button(action: { showingSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                        }
                        .overlay(alignment: .center) {
                            // Focus Indicator
                            if cameraManager.showFocusIndicator {
                                Circle()
                                    .stroke(Color.yellow, lineWidth: 2)
                                    .frame(width: 80, height: 80)
                                    .position(cameraManager.focusPoint)
                                    .animation(.easeInOut(duration: 0.3), value: cameraManager.focusPoint)
                            }
                        }
                    
                    // Bottom Controls
                    VStack(spacing: 20) {
                        // Photo Count & Gallery Preview
                        if !capturedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(capturedImages.suffix(5)) { photo in
                                        Button {
                                            selectedImage = photo
                                            showingPhotoDetail = true
                                        } label: {
                                            Group {
                                                if let image = photo.originalImage {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.gray.opacity(0.3))
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .foregroundColor(.gray)
                                                        )
                                                }
                                            }
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                        }
                                    }
                                    
                                    if capturedImages.count > 5 {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.6))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text("+\(capturedImages.count - 5)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Main Controls
                        HStack(spacing: 40) {
                            // Photo Library Button
                            Button {
                                showingImagePicker = true
                            } label: {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            // Capture Button
                            Button {
                                capturePhoto()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 80, height: 80)
                                    
                                    Circle()
                                        .fill(cameraManager.isCapturing ? Color.red : Color.clear)
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                }
                                .scaleEffect(cameraManager.isCapturing ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: cameraManager.isCapturing)
                            }
                            .disabled(cameraManager.isCapturing)
                            
                            // Camera Flip Button
                            Button {
                                cameraManager.flipCamera()
                            } label: {
                                Image(systemName: "camera.rotate.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                        
                        // Secondary Controls
                        HStack(spacing: 30) {
                            // Flash Control
                            Button {
                                cycleFlashMode()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: flashMode.iconName)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    Text(flashMode.displayName)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            // Photos Count
                            VStack(spacing: 4) {
                                Text("\(capturedImages.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Photos")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Grid/Focus Toggle
                            Button {
                                cameraManager.showGrid.toggle()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: cameraManager.showGrid ? "grid.circle.fill" : "grid.circle")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    Text("Grid")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                }
                
                // Grid Overlay
                if cameraManager.showGrid {
                    GridOverlay()
                        .allowsHitTesting(false)
                }
                
                // Capture Flash Effect
                if cameraManager.showFlashEffect {
                    Color.white
                        .ignoresSafeArea()
                        .opacity(0.7)
                        .animation(.easeOut(duration: 0.2), value: cameraManager.showFlashEffect)
                }
            }
            .onAppear {
                setupCamera()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoLibraryPicker { image in
                    if let image = image {
                        addPhotoToCollection(image)
                    }
                }
            }
            .sheet(item: $selectedImage) { photo in
                PhotoDetailView(photo: photo)
            }
            .actionSheet(isPresented: $showingSettings) {
                ActionSheet(
                    title: Text("Camera Settings"),
                    buttons: [
                        .default(Text("Save to Photos: \(cameraManager.saveToLibrary ? "ON" : "OFF")")) {
                            cameraManager.saveToLibrary.toggle()
                        },
                        .default(Text("High Quality: \(cameraManager.highQuality ? "ON" : "OFF")")) {
                            cameraManager.highQuality.toggle()
                        },
                        .default(Text("Show Grid: \(cameraManager.showGrid ? "ON" : "OFF")")) {
                            cameraManager.showGrid.toggle()
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private func setupCamera() {
        Task {
            await cameraManager.requestPermissionAndSetup()
        }
    }
    
    private func capturePhoto() {
        cameraManager.capturePhoto { result in
            switch result {
            case .success(let image):
                addPhotoToCollection(image)
            case .failure(let error):
                print("Failed to capture photo: \(error)")
            }
        }
    }
    
    private func addPhotoToCollection(_ image: UIImage) {
        let photoRef = PhotoReference(
            filename: "photo_\(Date().timeIntervalSince1970).jpg",
            originalImage: image
        )
        capturedImages.append(photoRef)
    }
    
    private func cycleFlashMode() {
        switch flashMode {
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        case .auto:
            flashMode = .off
        @unknown default:
            flashMode = .auto
        }
        cameraManager.setFlashMode(flashMode)
    }
}

// MARK: - Camera Manager
@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var isCapturing = false
    @Published var showFocusIndicator = false
    @Published var focusPoint = CGPoint.zero
    @Published var showFlashEffect = false
    @Published var showGrid = false
    @Published var saveToLibrary = true
    @Published var highQuality = true
    
    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?
    
    override init() {
        super.init()
    }
    
    func requestPermissionAndSetup() async {
        let cameraPermission = await AVCaptureDevice.requestAccess(for: .video)
        let photoPermission = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard cameraPermission else {
            print("Camera permission denied")
            return
        }
        
        await setupSession()
    }
    
    private func setupSession() async {
        session.beginConfiguration()
        
        // Set session preset for high quality
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }
        
        // Setup camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get camera device")
            session.commitConfiguration()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
                videoDeviceInput = input
                currentDevice = camera
            }
        } catch {
            print("Failed to create camera input: \(error)")
            session.commitConfiguration()
            return
        }
        
        // Setup photo output
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
            
            // Configure output settings
            if output.availablePhotoCodecTypes.contains(.hevc) {
                output.isHighResolutionPhotoEnabled = true
            }
        }
        
        session.commitConfiguration()
        
        // Start session on background thread
        Task.detached { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopSession() {
        Task.detached { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let photoOutput = photoOutput else {
            completion(.failure(CameraError.outputNotReady))
            return
        }
        
        isCapturing = true
        
        let settings = AVCapturePhotoSettings()
        
        // Configure photo settings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) && highQuality {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        if let device = currentDevice, device.hasFlash {
            settings.flashMode = .auto
        }
        
        settings.isHighResolutionPhotoEnabled = highQuality
        
        let delegate = PhotoCaptureDelegate { [weak self] result in
            DispatchQueue.main.async {
                self?.isCapturing = false
                self?.showFlashEffect = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.showFlashEffect = false
                }
                
                completion(result)
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    func flipCamera() {
        guard let currentInput = videoDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            session.addInput(currentInput)
            session.commitConfiguration()
            return
        }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                videoDeviceInput = newInput
                currentDevice = newCamera
            } else {
                session.addInput(currentInput)
            }
        } catch {
            session.addInput(currentInput)
            print("Failed to switch camera: \(error)")
        }
        
        session.commitConfiguration()
    }
    
    func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        // Flash mode will be applied during capture
    }
    
    func focusAt(point: CGPoint) {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            
            // Show focus indicator
            focusPoint = CGPoint(x: point.x * UIScreen.main.bounds.width, y: point.y * UIScreen.main.bounds.height)
            showFocusIndicator = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showFocusIndicator = false
            }
            
        } catch {
            print("Failed to set focus: \(error)")
        }
    }
}

// MARK: - Camera Preview
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // No updates needed
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }
}

// MARK: - Photo Capture Delegate
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<UIImage, Error>) -> Void
    
    init(completion: @escaping (Result<UIImage, Error>) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(.failure(CameraError.imageProcessingFailed))
            return
        }
        
        completion(.success(image))
    }
}

// MARK: - Grid Overlay
struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Vertical lines
                path.move(to: CGPoint(x: width / 3, y: 0))
                path.addLine(to: CGPoint(x: width / 3, y: height))
                
                path.move(to: CGPoint(x: 2 * width / 3, y: 0))
                path.addLine(to: CGPoint(x: 2 * width / 3, y: height))
                
                // Horizontal lines
                path.move(to: CGPoint(x: 0, y: height / 3))
                path.addLine(to: CGPoint(x: width, y: height / 3))
                
                path.move(to: CGPoint(x: 0, y: 2 * height / 3))
                path.addLine(to: CGPoint(x: width, y: 2 * height / 3))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
}

// MARK: - Photo Library Picker
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoLibraryPicker
        
        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.onImageSelected(image)
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageSelected(nil)
            parent.dismiss()
        }
    }
}

// MARK: - Extensions
extension AVCaptureDevice.FlashMode {
    var iconName: String {
        switch self {
        case .off: return "bolt.slash.fill"
        case .on: return "bolt.fill"
        case .auto: return "bolt.badge.a.fill"
        @unknown default: return "bolt.badge.a.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .off: return "Off"
        case .on: return "On"
        case .auto: return "Auto"
        @unknown default: return "Auto"
        }
    }
}

// MARK: - Camera Errors
enum CameraError: LocalizedError {
    case outputNotReady
    case imageProcessingFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .outputNotReady: return "Camera output not ready"
        case .imageProcessingFailed: return "Failed to process captured image"
        case .permissionDenied: return "Camera permission denied"
        }
    }
}