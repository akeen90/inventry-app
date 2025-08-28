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
        // TODO: Initialize Core Data stack (files need to be added to Xcode project)
        // _ = CoreDataStack.shared
        // _ = LocalStorageService.shared  
        // _ = SyncService.shared
        
        print("💾 Local storage services ready to initialize (need project file updates)")
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