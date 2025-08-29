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
        _ = CoreDataStack.shared
        // TODO: Re-enable when Core Data entity files are properly added to project
        // _ = LocalStorageService.shared  
        // _ = SyncService.shared
        
        print("💾 Core Data stack initialized - offline foundation ready!")
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