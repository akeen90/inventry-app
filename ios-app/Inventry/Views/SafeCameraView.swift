import SwiftUI
import UIKit
import AVFoundation

// MARK: - Safe Camera Implementation
struct SafeCameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> SafeCameraViewController {
        let viewController = SafeCameraViewController()
        viewController.onImageCaptured = onImageCaptured
        viewController.onDismiss = { dismiss() }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SafeCameraViewController, context: Context) {
        // No updates needed
    }
}

class SafeCameraViewController: UIViewController {
    var onImageCaptured: ((UIImage?) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?
    
    private lazy var shutterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        button.layer.cornerRadius = 40
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 6
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.addTarget(self, action: #selector(dismissCamera), for: .touchUpInside)
        return button
    }()
    
    private lazy var flipCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // Check permissions first
        checkCameraPermissions()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
    
    deinit {
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { [weak self] in
                self?.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            showPermissionAlert()
        }
    }
    
    private func setupCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert()
            return
        }
        
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else {
            showCameraErrorAlert("Failed to create camera session")
            return
        }
        
        // Configure session for photo quality
        captureSession.beginConfiguration()
        
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        } else {
            captureSession.sessionPreset = .high
        }
        
        // Setup camera input
        do {
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                throw CameraError.deviceUnavailable
            }
            
            currentDevice = backCamera
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                throw CameraError.inputError
            }
        } catch {
            captureSession.commitConfiguration()
            showCameraErrorAlert("Failed to setup camera: \(error.localizedDescription)")
            return
        }
        
        // Setup photo output
        photoOutput = AVCapturePhotoOutput()
        guard let photoOutput = photoOutput else {
            captureSession.commitConfiguration()
            showCameraErrorAlert("Failed to create photo output")
            return
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            captureSession.commitConfiguration()
            showCameraErrorAlert("Failed to add photo output")
            return
        }
        
        captureSession.commitConfiguration()
        
        // Setup preview layer
        setupPreviewLayer()
        
        // Start session on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    private func setupPreviewLayer() {
        guard let captureSession = captureSession else { return }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        
        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
        }
    }
    
    private func setupUI() {
        // Add buttons to view
        view.addSubview(shutterButton)
        view.addSubview(cancelButton)
        view.addSubview(flipCameraButton)
        
        // Layout constraints
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Shutter button - centered at bottom
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shutterButton.widthAnchor.constraint(equalToConstant: 80),
            shutterButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Cancel button - top left
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Flip camera button - top right
            flipCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 44),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
    }
    
    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else {
            showCameraErrorAlert("Photo output not available")
            return
        }
        
        // Disable button to prevent multiple captures
        shutterButton.isEnabled = false
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.shutterButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shutterButton.transform = CGAffineTransform.identity
            }
        }
        
        // Configure photo settings
        let photoSettings = AVCapturePhotoSettings()
        
        // Use HEIF if available, otherwise JPEG
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }
        
        // Enable flash if available
        if currentDevice?.hasFlash == true {
            photoSettings.flashMode = .auto
        }
        
        // Capture photo
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func flipCamera() {
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Remove current input
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            captureSession.removeInput(currentInput)
        }
        
        // Determine new camera position
        let newPosition: AVCaptureDevice.Position = (currentDevice?.position == .back) ? .front : .back
        
        // Setup new input
        do {
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                throw CameraError.deviceUnavailable
            }
            
            currentDevice = newCamera
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
            } else {
                throw CameraError.inputError
            }
        } catch {
            // If switching fails, try to restore the original camera
            if let originalCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    currentDevice = originalCamera
                    let originalInput = try AVCaptureDeviceInput(device: originalCamera)
                    if captureSession.canAddInput(originalInput) {
                        captureSession.addInput(originalInput)
                    }
                } catch {
                    print("Failed to restore original camera: \(error)")
                }
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    @objc private func dismissCamera() {
        onDismiss?()
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Please enable camera access in Settings to take photos.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.onDismiss?()
        })
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showCameraUnavailableAlert() {
        let alert = UIAlertController(
            title: "Camera Unavailable",
            message: "The camera is not available on this device.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.onDismiss?()
        })
        
        present(alert, animated: true)
    }
    
    private func showCameraErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Camera Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.onDismiss?()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Photo Capture Delegate
extension SafeCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Re-enable shutter button
        DispatchQueue.main.async {
            self.shutterButton.isEnabled = true
        }
        
        if let error = error {
            DispatchQueue.main.async {
                self.showCameraErrorAlert("Failed to capture photo: \(error.localizedDescription)")
            }
            return
        }
        
        // Convert photo to UIImage
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.showCameraErrorAlert("Failed to process captured photo")
            }
            return
        }
        
        // Return captured image
        DispatchQueue.main.async {
            self.onImageCaptured?(image)
            self.onDismiss?()
        }
    }
}

// MARK: - Camera Errors
enum CameraError: LocalizedError {
    case deviceUnavailable
    case inputError
    case outputError
    
    var errorDescription: String? {
        switch self {
        case .deviceUnavailable:
            return "Camera device unavailable"
        case .inputError:
            return "Failed to setup camera input"
        case .outputError:
            return "Failed to setup camera output"
        }
    }
}

// MARK: - SwiftUI Wrapper for Safe Camera
struct SafePhotoCaptureView: View {
    @Binding var capturedImages: [PhotoReference]
    let itemName: String
    let roomName: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: PhotoReference?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingPhotoDetail = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                Text("Document \(itemName)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Room: \(roomName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button("📷 Take Photo") {
                        checkCameraPermissionAndOpen()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("📱 Choose from Library") {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                // Photos Grid
                if !capturedImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(capturedImages) { photo in
                                PhotoThumbnail(photo: photo) {
                                    selectedImage = photo
                                    showingPhotoDetail = true
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No photos captured yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Photo Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                SafeCameraView { image in
                    if let image = image {
                        let photoRef = PhotoReference(
                            filename: "photo_\(UUID().uuidString).jpg",
                            originalImage: image
                        )
                        capturedImages.append(photoRef)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                SimpleImagePicker(sourceType: sourceType) { image in
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
            .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            } message: {
                Text("Please enable camera access in Settings to take photos.")
            }
        }
    }
    
    private func checkCameraPermissionAndOpen() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
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
        case .denied, .restricted:
            showingPermissionAlert = true
        @unknown default:
            showingPermissionAlert = true
        }
    }
}

// MARK: - Simple Photo Thumbnail
struct PhotoThumbnail: View {
    let photo: PhotoReference
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Simple Image Picker (Fallback)
struct SimpleImagePicker: UIViewControllerRepresentable {
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
        let parent: SimpleImagePicker
        
        init(_ parent: SimpleImagePicker) {
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