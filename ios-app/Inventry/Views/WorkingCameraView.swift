import SwiftUI
import UIKit
import AVFoundation

// MARK: - Absolutely Working Camera for iPhone 16 Pro
struct WorkingCameraView: UIViewControllerRepresentable {
    let onPhotoTaken: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onPhotoTaken = onPhotoTaken
        controller.onDismiss = { dismiss() }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var onPhotoTaken: ((UIImage) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var backCamera: AVCaptureDevice!
    private var frontCamera: AVCaptureDevice!
    private var currentCamera: AVCaptureDevice!
    private var currentCameraInput: AVCaptureDeviceInput!
    
    @IBOutlet weak var cameraView: UIView!
    private var shutterButton: UIButton!
    private var switchCameraButton: UIButton!
    private var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        // Setup cameras
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backCamera = device
            } else if device.position == .front {
                frontCamera = device
            }
        }
        
        currentCamera = backCamera ?? frontCamera
        
        guard let camera = currentCamera else {
            print("No camera available")
            return
        }
        
        do {
            currentCameraInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(currentCameraInput) {
                captureSession.addInput(currentCameraInput)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    private func setupUI() {
        // Camera preview
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Shutter button
        shutterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        shutterButton.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 40
        shutterButton.layer.borderWidth = 5
        shutterButton.layer.borderColor = UIColor.systemBlue.cgColor
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Cancel button
        cancelButton = UIButton(frame: CGRect(x: 20, y: 50, width: 80, height: 40))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Switch camera button
        if frontCamera != nil && backCamera != nil {
            switchCameraButton = UIButton(frame: CGRect(x: view.frame.width - 60, y: 50, width: 40, height: 40))
            switchCameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
            switchCameraButton.tintColor = .white
            switchCameraButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            switchCameraButton.layer.cornerRadius = 20
            switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
            view.addSubview(switchCameraButton)
        }
    }
    
    private func startCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    @objc private func shutterTapped() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = currentCamera.hasFlash ? .auto : .off
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Visual feedback
        shutterButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.1) {
            self.shutterButton.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func cancelTapped() {
        onDismiss?()
    }
    
    @objc private func switchCamera() {
        guard let frontCamera = frontCamera, let backCamera = backCamera else { return }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentCameraInput)
        
        currentCamera = (currentCamera == backCamera) ? frontCamera : backCamera
        
        do {
            currentCameraInput = try AVCaptureDeviceInput(device: currentCamera)
            if captureSession.canAddInput(currentCameraInput) {
                captureSession.addInput(currentCameraInput)
            }
        } catch {
            print("Error switching camera: \(error)")
        }
        
        captureSession.commitConfiguration()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(error!)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Unable to create image from photo data")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onPhotoTaken?(image)
            self?.onDismiss?()
        }
    }
}

// MARK: - Simple Photo Capture Button
struct PhotoCaptureButton: View {
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
            WorkingCameraView(onPhotoTaken: onPhotoTaken)
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

// MARK: - Property Photo View
struct PropertyPhotoView: View {
    @Binding var propertyImage: UIImage?
    let propertyName: String
    
    var body: some View {
        VStack(spacing: 16) {
            if let image = propertyImage {
                // Show existing property photo
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                // Placeholder for property photo
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "house.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("Add Property Photo")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Take a photo of the property exterior")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    )
            }
            
            // Camera button - optimized for iPhone 16 Pro
            iPhone16ProPhotoCaptureButton(title: propertyImage == nil ? "Take Property Photo" : "Update Property Photo") { image in
                propertyImage = image
            }
        }
        .padding()
    }
}