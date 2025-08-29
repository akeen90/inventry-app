import Foundation
import Combine

@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()
    
    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    @Published var syncError: String?
    
    private let firebaseService = FirebaseService.shared
    private let localStorageService = LocalStorageService.shared
    private let authService = AuthenticationService.shared
    
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 60.0 // 60 seconds
    
    private init() {
        print("🔄 SyncService initializing...")
        startPeriodicSync()
        
        // Listen to auth state changes
        authService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.startPeriodicSync()
                } else {
                    self?.stopPeriodicSync()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func manualSync() async {
        guard authService.isAuthenticated else {
            print("⚠️ Cannot sync: User not authenticated")
            return
        }
        
        await performSync()
    }
    
    // MARK: - Private Methods
    
    private func startPeriodicSync() {
        guard authService.isAuthenticated else { return }
        
        stopPeriodicSync() // Clear any existing timer
        
        print("⏰ Starting periodic sync every \(syncInterval) seconds")
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performSync()
            }
        }
        
        // Perform initial sync
        Task {
            await performSync()
        }
    }
    
    private func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
        print("⏹️ Stopped periodic sync")
    }
    
    private func performSync() async {
        guard !isSyncing else {
            print("⚠️ Sync already in progress, skipping")
            return
        }
        
        guard authService.isAuthenticated else {
            print("⚠️ Cannot sync: User not authenticated")
            return
        }
        
        isSyncing = true
        syncError = nil
        
        print("🔄 Starting sync...")
        
        // Step 1: Upload local changes to Firebase
        await uploadLocalChanges()
        
        // Step 2: Download latest changes from Firebase
        await downloadRemoteChanges()
        
        lastSyncTime = Date()
        print("✅ Sync completed successfully at \(lastSyncTime!)")
        
        isSyncing = false
    }
    
    private func uploadLocalChanges() async {
        let propertiesNeedingUpload = await localStorageService.getPropertiesNeedingUpload()
        
        print("⬆️ Uploading \(propertiesNeedingUpload.count) local changes to Firebase")
        
        for property in propertiesNeedingUpload {
            do {
                try await firebaseService.saveProperty(property)
                await localStorageService.markPropertySynced(property.id)
                print("✅ Uploaded property: \(property.name)")
            } catch {
                print("❌ Failed to upload property \(property.name): \(error.localizedDescription)")
                // Continue with next property instead of failing entire sync
            }
        }
    }
    
    private func downloadRemoteChanges() async {
        print("⬇️ Downloading latest changes from Firebase")
        
        do {
            let remoteProperties = try await firebaseService.loadProperties()
            print("📥 Downloaded \(remoteProperties.count) properties from Firebase")
            
            // Update local storage with remote changes
            // This implements a simple "server wins" conflict resolution
            for remoteProperty in remoteProperties {
                await localStorageService.saveProperty(remoteProperty)
                await localStorageService.markPropertySynced(remoteProperty.id)
            }
            
            print("✅ Updated local storage with remote changes")
        } catch {
            print("❌ Failed to download remote changes: \(error.localizedDescription)")
            // Don't throw - just log and continue
        }
    }
    
    // MARK: - Conflict Resolution
    
    private func resolveConflict(local: Property, remote: Property) -> Property {
        // Simple conflict resolution: use the most recently updated property
        if local.updatedAt > remote.updatedAt {
            print("🔀 Conflict resolved: Using local version of \(local.name)")
            return local
        } else {
            print("🔀 Conflict resolved: Using remote version of \(remote.name)")
            return remote
        }
    }
    
    // MARK: - Connection Status
    
    func getSyncStatus() -> String {
        if isSyncing {
            return "Syncing..."
        } else if let lastSync = lastSyncTime {
            let formatter = RelativeDateTimeFormatter()
            formatter.dateTimeStyle = .named
            return "Last synced \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
        } else {
            return "Never synced"
        }
    }
    
    var isOnline: Bool {
        return firebaseService.isOnline
    }
    
    deinit {
        syncTimer?.invalidate()
        syncTimer = nil
    }
}