import SwiftUI
import FirebaseCore

@main
struct InventryApp: App {
    
    init() {
        FirebaseApp.configure()
        print("🏠 Inventry lettings app starting...")
        print("📋 Ready for property inventory management")
        print("🔥 Firebase configured successfully!")
        
        // Initialize Core Data and sync services
        setupLocalStorage()
        setupDevelopmentEnvironment()
    }
    
    private func setupLocalStorage() {
        // Initialize Core Data stack
        _ = CoreDataStack.shared
        
        // Initialize local storage service
        _ = LocalStorageService.shared
        
        // Initialize sync service
        _ = SyncService.shared
        
        print("💾 Local storage and sync services initialized")
    }
    
    private func setupDevelopmentEnvironment() {
        #if DEBUG
        print("🔧 Development mode - using mock Firebase services")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
    }
}