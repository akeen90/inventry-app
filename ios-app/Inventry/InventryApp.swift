import SwiftUI
// TODO: Add Firebase packages via Swift Package Manager, then uncomment:
// import FirebaseCore

@main
struct InventryApp: App {
    
    init() {
        // TODO: Uncomment when Firebase packages are added via Swift Package Manager
        // FirebaseApp.configure()
        print("🏠 Inventry lettings app starting...")
        print("📋 Ready for property inventory management")
        
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