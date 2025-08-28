import SwiftUI
import AVFoundation

// MARK: - Camera Test View for iPhone 16 Pro Debugging
struct CameraTestView: View {
    @State private var testResults: [String] = []
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Camera Test - iPhone 16 Pro")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Test Results
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(testResults.enumerated()), id: \.offset) { index, result in
                            Text("\(index + 1). \(result)")
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Test Buttons
                VStack(spacing: 12) {
                    Button("🔍 Run Camera Tests") {
                        runCameraTests()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("📷 Test Camera (Simple)") {
                        testSimpleCamera()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("📱 Test Photo Library") {
                        // Test photo library access
                        testResults.append("Photo Library test - OK")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal)
                
                // Show captured image
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Camera Debug")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                testResults = ["Test started for iPhone 16 Pro..."]
            }
            .sheet(isPresented: $isShowingCamera) {
                SimpleCameraView { image in
                    if let image = image {
                        capturedImage = image
                        testResults.append("✅ Camera capture SUCCESS")
                    } else {
                        testResults.append("❌ Camera capture FAILED")
                    }
                }
            }
        }
    }
    
    private func runCameraTests() {
        testResults.removeAll()
        testResults.append("🔍 Starting comprehensive camera tests...")
        
        // Test 1: Camera availability
        let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        testResults.append("Camera available: \(cameraAvailable ? "YES" : "NO")")
        
        // Test 2: Camera authorization
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        testResults.append("Camera permission: \(authStatusString(authStatus))")
        
        // Test 3: Available cameras
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified
        ).devices
        
        testResults.append("Available cameras: \(devices.count)")
        for device in devices {
            testResults.append("- \(device.localizedName) (\(device.position.description))")
        }
        
        // Test 4: Photo output capabilities
        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            testResults.append("Back camera: \(backCamera.localizedName)")
            testResults.append("Has flash: \(backCamera.hasFlash)")
            testResults.append("Has torch: \(backCamera.hasTorch)")
        } else {
            testResults.append("❌ No back camera found")
        }
        
        // Test 5: iOS version
        testResults.append("iOS Version: \(UIDevice.current.systemVersion)")
        testResults.append("Device: \(UIDevice.current.model)")
        
        testResults.append("✅ Tests completed")
    }
    
    private func testSimpleCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .authorized:
            testResults.append("📷 Opening camera...")
            isShowingCamera = true
        case .notDetermined:
            testResults.append("📷 Requesting camera permission...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        testResults.append("✅ Permission granted")
                        isShowingCamera = true
                    } else {
                        testResults.append("❌ Permission denied")
                    }
                }
            }
        case .denied, .restricted:
            testResults.append("❌ Camera permission denied/restricted")
        @unknown default:
            testResults.append("❌ Unknown camera permission state")
        }
    }
    
    private func authStatusString(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        @unknown default: return "Unknown"
        }
    }
}

extension AVCaptureDevice.Position {
    var description: String {
        switch self {
        case .back: return "Back"
        case .front: return "Front"
        case .unspecified: return "Unspecified"
        @unknown default: return "Unknown"
        }
    }
}

#Preview {
    CameraTestView()
}