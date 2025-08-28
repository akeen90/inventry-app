import SwiftUI

struct MainAppView: View {
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                ContentView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Sign Out") {
                                do {
                                    try authService.signOut()
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }
                        }
                    }
            } else {
                LoginView()
            }
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}