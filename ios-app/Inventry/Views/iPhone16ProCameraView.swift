import SwiftUI
import UIKit
import AVFoundation

// MARK: - iPhone 16 Pro Optimized Camera
struct iPhone16ProCameraView: UIViewControllerRepresentable {
    let onPhotoTaken: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> iPhone16ProCameraController {
        let controller = iPhone16ProCameraController()
        controller.onPhotoTaken = onPhotoTaken
        controller.onDismiss = { dismiss() }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: iPhone16ProCameraController, context: Context) {}
}

class iPhone16ProCameraController: UIViewController {
    var onPhotoTaken: ((UIImage) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var currentCamera: AVCaptureDevice!
    private var currentCameraInput: AVCaptureDeviceInput!
    
    private var shutterButton: UIButton!
    private var cancelButton: UIButton!
    private var isSetupComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Add loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.tag = 999
        view.addSubview(activityIndicator)
        
        setupCameraSafely()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Only start camera if setup is complete
        if isSetupComplete {
            startCamera()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    private func setupCameraSafely() {
        // Perform all camera setup on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            print("🎥 Starting iPhone 16 Pro camera setup...")
            
            // Check camera authorization first
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            guard authStatus == .authorized else {
                print("❌ Camera not authorized: \(authStatus.rawValue)")
                DispatchQueue.main.async {
                    self.showError("Camera access not authorized")
                }
                return
            }
            
            do {
                try self.setupCaptureSession()
                try self.setupCamera()
                try self.setupPhotoOutput()
                
                DispatchQueue.main.async {
                    self.setupUI()
                    self.isSetupComplete = true
                    
                    // Remove loading indicator
                    if let indicator = self.view.viewWithTag(999) {
                        indicator.removeFromSuperview()
                    }
                    
                    print("✅ iPhone 16 Pro camera setup complete")
                }
                
            } catch {
                print("❌ Camera setup error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showError("Camera setup failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setupCaptureSession() throws {
        captureSession = AVCaptureSession()
        
        // Use conservative session preset for stability
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
            print("✅ Using photo preset")
        } else if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
            print("⚠️ Using high preset (photo not available)")
        } else {
            captureSession.sessionPreset = .medium
            print("⚠️ Using medium preset (high not available)")
        }
    }
    
    private func setupCamera() throws {
        // Discover available cameras with iPhone 16 Pro specific types
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInTelephotoCamera
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .back
        )
        
        guard let camera = discoverySession.devices.first else {
            throw CameraError.noCameraAvailable
        }
        
        currentCamera = camera
        print("🎥 Using camera: \(camera.localizedName)")
        
        // Configure camera for optimal performance
        try camera.lockForConfiguration()
        
        // Set optimal focus mode
        if camera.isFocusModeSupported(.continuousAutoFocus) {
            camera.focusMode = .continuousAutoFocus
        }
        
        // Set optimal exposure
        if camera.isExposureModeSupported(.continuousAutoExposure) {
            camera.exposureMode = .continuousAutoExposure
        }
        
        // Set white balance
        if camera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            camera.whiteBalanceMode = .continuousAutoWhiteBalance
        }
        
        camera.unlockForConfiguration()
        
        // Create input
        currentCameraInput = try AVCaptureDeviceInput(device: camera)
        
        captureSession.beginConfiguration()
        
        guard captureSession.canAddInput(currentCameraInput) else {
            captureSession.commitConfiguration()
            throw CameraError.cannotAddInput
        }
        
        captureSession.addInput(currentCameraInput)
        captureSession.commitConfiguration()
        
        print("✅ Camera input configured")
    }
    
    private func setupPhotoOutput() throws {
        photoOutput = AVCapturePhotoOutput()
        
        // Configure for iPhone 16 Pro
        if #available(iOS 13.0, *) {
            photoOutput.maxPhotoQualityPrioritization = .balanced
        }
        
        captureSession.beginConfiguration()
        
        guard captureSession.canAddOutput(photoOutput) else {
            captureSession.commitConfiguration()
            throw CameraError.cannotAddOutput
        }
        
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        print("✅ Photo output configured")
    }
    
    private func setupUI() {
        // Camera preview
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Shutter button
        shutterButton = UIButton()
        shutterButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        shutterButton.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 40
        shutterButton.layer.borderWidth = 5
        shutterButton.layer.borderColor = UIColor.systemBlue.cgColor
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Cancel button
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        print("✅ UI setup complete")
    }
    
    private func startCamera() {
        guard isSetupComplete, !captureSession.isRunning else { 
            print("⚠️ Cannot start camera - setup incomplete or already running")
            return 
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            print("🎥 Camera started")
        }
    }
    
    private func stopCamera() {
        guard captureSession?.isRunning == true else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
            print("🛑 Camera stopped")
        }
    }
    
    @objc private func shutterTapped() {
        guard isSetupComplete else {
            print("❌ Camera not ready for capture")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        
        // Conservative settings for iPhone 16 Pro
        settings.flashMode = .auto
        
        // Disable HEIF on real device for compatibility
        if #available(iOS 11.0, *) {
            let availableFormats = photoOutput.availablePhotoCodecTypes
            if availableFormats.contains(.jpeg) {
                settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Visual feedback
        shutterButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.1) {
            self.shutterButton.transform = CGAffineTransform.identity
        }
        
        print("📸 Photo capture initiated")
    }
    
    @objc private func cancelTapped() {
        onDismiss?()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Camera Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onDismiss?()
        })
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
}

// MARK: - Photo Capture Delegate
extension iPhone16ProCameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Photo capture error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showError("Photo capture failed: \(error.localizedDescription)")
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Could not create image from photo data")
            DispatchQueue.main.async {
                self.showError("Could not process captured photo")
            }
            return
        }
        
        print("✅ Photo captured successfully")
        
        DispatchQueue.main.async { [weak self] in
            self?.onPhotoTaken?(image)
            self?.onDismiss?()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 Photo capture started")
    }
}

// MARK: - Camera Errors
enum CameraError: LocalizedError {
    case noCameraAvailable
    case cannotAddInput
    case cannotAddOutput
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "No camera available on this device"
        case .cannotAddInput:
            return "Cannot add camera input"
        case .cannotAddOutput:
            return "Cannot add photo output"
        }
    }
}

// MARK: - iPhone 16 Pro Photo Capture Button
struct iPhone16ProPhotoCaptureButton: View {
    let title: String
    let onPhotoTaken: (UIImage) -> Void
    @State private var showingCamera = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Button(action: {
            checkCameraPermission()
        }) {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            iPhone16ProCameraView(onPhotoTaken: onPhotoTaken)
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
    
    private func checkCameraPermission() {
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