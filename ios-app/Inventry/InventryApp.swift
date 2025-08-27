import SwiftUI
import FirebaseCore

@main
struct InventryApp: App {
    
    init() {
        FirebaseApp.configure()
        print("🏠 Inventry lettings app starting...")
        print("📋 Ready for property inventory management")
        print("🔥 Firebase configured successfully!")
        
        // Initialize mock data for development
        setupDevelopmentEnvironment()
    }
    
    private func setupDevelopmentEnvironment() {
        #if DEBUG
        print("🔧 Development mode - using mock Firebase services")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}