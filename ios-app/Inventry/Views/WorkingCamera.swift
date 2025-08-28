import SwiftUI
import AVFoundation
import UIKit

// MARK: - Actual Working Camera View
struct ActualCameraView: UIViewControllerRepresentable {
    let onPhotosCaptured: ([UIImage]) -> Void
    let allowMultiple: Bool
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onPhotosCaptured = onPhotosCaptured
        controller.allowMultiple = allowMultiple
        controller.onDismiss = {
            dismiss()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// MARK: - Camera View Controller
class CameraViewController: UIViewController {
    var onPhotosCaptured: (([UIImage]) -> Void)?
    var onDismiss: (() -> Void)?
    var allowMultiple = true
    
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var capturedImages: [UIImage] = []
    
    // UI Elements
    private var shutterButton: UIButton!
    private var cancelButton: UIButton!
    private var doneButton: UIButton!
    private var photoCountLabel: UILabel!
    private var photoPreviewStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        checkCameraPermission()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if !granted {
                    DispatchQueue.main.async {
                        self?.showPermissionAlert()
                    }
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to take photos",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.onDismiss?()
        })
        present(alert, animated: true)
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.sessionPreset = .photo
        
        // Setup camera input
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        // Setup photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    private func setupUI() {
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        cancelButton.layer.cornerRadius = 8
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Photo count label
        photoCountLabel = UILabel()
        photoCountLabel.text = ""
        photoCountLabel.textColor = .white
        photoCountLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        photoCountLabel.layer.cornerRadius = 8
        photoCountLabel.layer.masksToBounds = true
        photoCountLabel.textAlignment = .center
        photoCountLabel.translatesAutoresizingMaskIntoConstraints = false
        photoCountLabel.isHidden = true
        view.addSubview(photoCountLabel)
        
        // Shutter button
        shutterButton = UIButton(type: .custom)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 35
        shutterButton.layer.borderWidth = 5
        shutterButton.layer.borderColor = UIColor.white.cgColor
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Done button
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor.systemGreen
        doneButton.layer.cornerRadius = 25
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        // Photo preview stack
        photoPreviewStack = UIStackView()
        photoPreviewStack.axis = .horizontal
        photoPreviewStack.spacing = 10
        photoPreviewStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoPreviewStack)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Photo count
            photoCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            photoCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            photoCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            photoCountLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Shutter button
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Done button
            doneButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            doneButton.widthAnchor.constraint(equalToConstant: 50),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Photo preview
            photoPreviewStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            photoPreviewStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            photoPreviewStack.bottomAnchor.constraint(equalTo: shutterButton.topAnchor, constant: -20),
            photoPreviewStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopSession() {
        captureSession?.stopRunning()
    }
    
    @objc private func cancelTapped() {
        onDismiss?()
    }
    
    @objc private func shutterTapped() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Animate shutter button
        UIView.animate(withDuration: 0.1, animations: {
            self.shutterButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shutterButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func doneTapped() {
        onPhotosCaptured?(capturedImages)
        onDismiss?()
    }
    
    private func updateUI() {
        let count = capturedImages.count
        
        if count > 0 {
            photoCountLabel.text = "  \(count) photo\(count == 1 ? "" : "s")  "
            photoCountLabel.isHidden = false
            
            if allowMultiple {
                doneButton.isHidden = false
            }
        } else {
            photoCountLabel.isHidden = true
            doneButton.isHidden = true
        }
        
        // Update preview stack
        photoPreviewStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for image in capturedImages.suffix(5) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true
            imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            photoPreviewStack.addArrangedSubview(imageView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

// MARK: - Photo Capture Delegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(error!)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error: Could not create image from data")
            return
        }
        
        capturedImages.append(image)
        updateUI()
        
        // If single photo mode, automatically finish
        if !allowMultiple {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.onPhotosCaptured?(self.capturedImages)
                self.onDismiss?()
            }
        }
    }
}

// MARK: - Working Camera Button (Updated)
struct WorkingCameraButton: View {
    let title: String
    let icon: String = "camera.fill"
    let allowMultiple: Bool
    let onPhotosCaptured: ([UIImage]) -> Void
    
    @State private var showingCamera = false
    
    var body: some View {
        Button(action: {
            showingCamera = true
        }) {
            HStack {
                Image(systemName: icon)
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
        .sheet(isPresented: $showingCamera) {
            NativeCameraPickerView(
                allowsMultiple: allowMultiple,
                onPhotosCaptured: onPhotosCaptured
            )
        }
    }
}

// MARK: - Simple Camera View
struct SimpleCameraView: View {
    let allowsMultiple: Bool
    let onPhotosCaptured: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Loading Camera...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .onAppear {
                showingImagePicker = true
            }
            .navigationTitle("Take Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            NativeCameraPickerView(
                allowsMultiple: allowsMultiple,
                onPhotosCaptured: onPhotosCaptured
            )
        }
    }
}

// MARK: - Native Camera Picker
struct NativeCameraPickerView: UIViewControllerRepresentable {
    let allowsMultiple: Bool
    let onPhotosCaptured: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        // Always try camera first, fallback to photo library if unavailable
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = .rear
            picker.cameraCaptureMode = .photo
            picker.cameraFlashMode = .auto
        } else {
            picker.sourceType = .photoLibrary
        }
        
        if #available(iOS 13.0, *) {
            picker.overrideUserInterfaceStyle = .dark
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: NativeCameraPickerView
        
        init(_ parent: NativeCameraPickerView) {
            self.parent = parent
            super.init()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var finalImage: UIImage?
            
            if let editedImage = info[.editedImage] as? UIImage {
                finalImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                finalImage = originalImage
            }
            
            if let image = finalImage {
                let optimizedImage = resizeImage(image, to: CGSize(width: 2048, height: 1536)) ?? image
                
                DispatchQueue.main.async {
                    self.parent.onPhotosCaptured([optimizedImage])
                    self.parent.dismiss()
                }
            } else {
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
        
        private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
            let size = image.size
            
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

// MARK: - Image Picker (for Simulator)
struct ImagePickerView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
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
            let image = info[.originalImage] as? UIImage
            parent.onImagePicked(image)
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            parent.dismiss()
        }
    }
}
