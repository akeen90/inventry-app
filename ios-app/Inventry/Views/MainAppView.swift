import SwiftUI

struct MainAppView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    
    var body: some View {
        Group {
            if firebaseService.isAuthenticated {
                ContentView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: firebaseService.isAuthenticated)
    }
}

#Preview {
    MainAppView()
}