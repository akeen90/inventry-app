import Foundation
import FirebaseCore
import FirebaseAuth  
import FirebaseFirestore
import FirebaseStorage

enum FirebaseError: Error {
    case userNotAuthenticated
    case dataEncodingFailed
    case dataDecodingFailed
    
    var localizedDescription: String {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .dataEncodingFailed:
            return "Failed to encode data"
        case .dataDecodingFailed:
            return "Failed to decode data"
        }
    }
}

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    // Firebase instances
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Use AuthenticationService as single source of truth
    private let authService = AuthenticationService.shared
    
    @Published var isOnline = false
    @Published var connectionState: ConnectionState = .unknown
    
    // Computed properties that delegate to AuthenticationService
    var isAuthenticated: Bool {
        return authService.isAuthenticated
    }
    
    var currentUser: User? {
        return authService.currentUser
    }
    
    enum ConnectionState {
        case connected
        case disconnected
        case unknown
    }
    
    private init() {
        print("🔥 FirebaseService initializing...")
        
        setupFirebaseListeners()
    }
    
    private func setupMockMode() {
        print("📱 Using Firebase mock mode for development")
        connectionState = .connected
        isOnline = true
        // Authentication state is now handled by AuthenticationService
    }
    
    private func setupFirebaseListeners() {
        // Enable offline persistence with modern API
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: NSNumber(value: FirestoreCacheSizeUnlimited))
        db.settings = settings
        
        // Set initial connection state
        connectionState = .connected
        isOnline = true
        
        print("🔥 Firebase listeners configured with offline persistence enabled")
        print("🔗 Using AuthenticationService for auth state management")
    }
    
    // MARK: - Authentication is handled by AuthenticationService
    
    // MARK: - User-specific Data Operations
    private func getUserPath() throws -> String {
        guard let userID = authService.userID else {
            print("❌ No authenticated user found")
            throw FirebaseError.userNotAuthenticated
        }
        return "users/\(userID)"
    }
    
    // MARK: - Firestore Operations
    func saveProperty(_ property: Property) async throws {
        guard let userID = authService.userID else {
            print("❌ Cannot save property: No authenticated user")
            throw FirebaseError.userNotAuthenticated
        }
        
        print("🔄 Saving property '\(property.name)' for user \(userID)")
        
        do {
            let propertyData = try encodeProperty(property)
            try await db.collection("users").document(userID)
                .collection("properties").document(property.id.uuidString)
                .setData(propertyData)
            print("✅ Property saved to Firestore for user \(userID): \(property.name)")
        } catch {
            print("❌ Failed to save property: \(error.localizedDescription)")
            throw error
        }
    }
    
    func loadProperties() async throws -> [Property] {
        guard let userID = authService.userID else {
            print("❌ Cannot load properties: No authenticated user")
            throw FirebaseError.userNotAuthenticated
        }
        
        print("🔄 Loading properties for user \(userID)")
        
        do {
            let snapshot = try await db.collection("users").document(userID)
                .collection("properties").getDocuments()
            var properties: [Property] = []
            
            for document in snapshot.documents {
                if let property = try? decodeProperty(from: document.data()) {
                    properties.append(property)
                }
            }
            
            print("✅ Loaded \(properties.count) properties from Firestore for user \(userID)")
            return properties
        } catch {
            print("❌ Failed to load properties: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteProperty(_ propertyId: String) async throws {
        guard let userID = authService.userID else {
            print("❌ Cannot delete property: No authenticated user")
            throw FirebaseError.userNotAuthenticated
        }
        
        print("🔄 Deleting property \(propertyId) for user \(userID)")
        
        do {
            try await db.collection("users").document(userID)
                .collection("properties").document(propertyId).delete()
            print("✅ Property deleted from Firestore for user \(userID): \(propertyId)")
        } catch {
            print("❌ Failed to delete property: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Storage Stubs
    func uploadImage(_ imageData: Data, path: String) async throws -> String {
        // TODO: Replace with Firebase Storage
        print("Stub: Would upload image to path: \(path)")
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "https://stub.example.com/\(path)"
    }
    
    func uploadImages(_ imageDataArray: [Data], basePath: String) async throws -> [String] {
        // TODO: Replace with Firebase Storage batch upload
        print("Stub: Would upload \(imageDataArray.count) images to path: \(basePath)")
        var urls: [String] = []
        for (index, _) in imageDataArray.enumerated() {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s per image
            urls.append("https://stub.example.com/\(basePath)/image_\(index).jpg")
        }
        return urls
    }
    
    // MARK: - Real Firebase Implementation (Commented until SDK is added)
    /*
    // MARK: - Real Authentication
    func signInReal(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.currentUser = result.user.email
            }
            print("✅ Successfully signed in: \(result.user.email ?? "No email")")
        } catch {
            print("❌ Sign in failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signUpReal(email: String, password: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.currentUser = result.user.email
            }
            print("✅ Successfully created user: \(result.user.email ?? "No email")")
        } catch {
            print("❌ Sign up failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOutReal() throws {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
            }
            print("👤 Successfully signed out")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Real Firestore Operations
    func savePropertyReal(_ property: Property) async throws {
        do {
            let propertyData = try encodeProperty(property)
            try await db.collection("properties").document(property.id.uuidString).setData(propertyData)
            print("✅ Property saved to Firestore: \(property.name)")
        } catch {
            print("❌ Failed to save property: \(error.localizedDescription)")
            throw error
        }
    }
    
    func loadPropertiesReal() async throws -> [Property] {
        do {
            let snapshot = try await db.collection("properties").getDocuments()
            var properties: [Property] = []
            
            for document in snapshot.documents {
                if let property = try? decodeProperty(from: document.data()) {
                    properties.append(property)
                }
            }
            
            print("✅ Loaded \(properties.count) properties from Firestore")
            return properties
        } catch {
            print("❌ Failed to load properties: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deletePropertyReal(_ propertyId: String) async throws {
        do {
            try await db.collection("properties").document(propertyId).delete()
            print("✅ Property deleted from Firestore: \(propertyId)")
        } catch {
            print("❌ Failed to delete property: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Real Storage Operations
    func uploadImageReal(_ imageData: Data, path: String) async throws -> String {
        do {
            let storageRef = storage.reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await storageRef.putData(imageData, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL()
            
            print("✅ Image uploaded to Firebase Storage: \(path)")
            return downloadURL.absoluteString
        } catch {
            print("❌ Failed to upload image: \(error.localizedDescription)")
            throw error
        }
    }
    
    func uploadImagesReal(_ imageDataArray: [Data], basePath: String) async throws -> [String] {
        var urls: [String] = []
        
        for (index, imageData) in imageDataArray.enumerated() {
            let imagePath = "\(basePath)/image_\(index)_\(UUID().uuidString).jpg"
            let url = try await uploadImageReal(imageData, path: imagePath)
            urls.append(url)
        }
        
        print("✅ Uploaded \(urls.count) images to Firebase Storage")
        return urls
    }
    
    // MARK: - Offline Sync
    func syncOfflineDataReal() async throws {
        guard isOnline else {
            print("📱 Device offline, data will sync when connection is restored")
            return
        }
        
        // Firebase Firestore automatically handles offline sync
        // This method is for any additional sync logic we might need
        try await db.enableNetwork()
        print("🔄 Offline data synced with Firebase")
    }
    
    // MARK: - Helper Methods
    private func encodeProperty(_ property: Property) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(property)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: 1, userInfo: nil)
        }
        return dict
    }
    
    private func decodeProperty(from data: [String: Any]) throws -> Property {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Property.self, from: jsonData)
    }
    */
    
    // MARK: - Inspection Workflow Stubs
    func saveInspectionData(_ property: Property, isOffline: Bool = false) async throws {
        print("Stub: Would save inspection data for property: \(property.name), offline: \(isOffline)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func syncOfflineData() async throws {
        print("Stub: Would sync offline data to Firebase")
        try await Task.sleep(nanoseconds: 3_000_000_000)
    }
    
    func createInspectionChecklistItems(for roomType: RoomType) async throws -> [String] {
        print("Stub: Would load checklist items for room type: \(roomType.rawValue)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return sample checklist items based on room type
        switch roomType {
        case .kitchen:
            return [
                "Oven condition and cleanliness",
                "Refrigerator condition", 
                "Kitchen cabinets and doors",
                "Sink and taps",
                "Kitchen worktops",
                "Kitchen flooring"
            ]
        case .bathroom:
            return [
                "Toilet condition and cleanliness",
                "Bath/shower condition",
                "Bathroom tiles",
                "Bathroom suite",
                "Mirror and lighting"
            ]
        case .livingRoom, .bedroom:
            return [
                "Carpet condition",
                "Wall condition", 
                "Windows and frames",
                "Light fixtures",
                "Power sockets and switches"
            ]
        default:
            return [
                "General condition",
                "Cleanliness"
            ]
        }
    }
    
    // MARK: - Helper Methods
    private func encodeProperty(_ property: Property) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(property)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FirebaseError.dataEncodingFailed
        }
        return dict
    }
    
    private func decodeProperty(from data: [String: Any]) throws -> Property {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Property.self, from: jsonData)
    }
}