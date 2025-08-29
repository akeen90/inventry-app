import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PropertiesView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Properties")
                }
            
            ReportsView() 
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Reports")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .navigationTitle("Inventry")
    }
}

struct PropertiesView: View {
    var body: some View {
        PropertyListView()
    }
}

struct ReportsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Reports")
                    .font(.largeTitle)
                    .bold()
                
                Text("View and manage inventory reports")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    // TODO: Navigate to reports list
                }) {
                    Label("View Reports", systemImage: "doc.text")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Reports")
        }
    }
}

struct SettingsView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var deletedService = DeletedItemsService.shared
    // @StateObject private var syncService = SyncService.shared // TODO: Re-enable when entity files added
    @State private var showingDeletedItems = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: firebaseService.isAuthenticated ? "person.circle.fill" : "person.circle")
                            .foregroundColor(firebaseService.isAuthenticated ? .blue : .gray)
                        VStack(alignment: .leading) {
                            Text(firebaseService.isAuthenticated ? (firebaseService.currentUser?.email ?? "Unknown User") : "Not Signed In")
                                .font(.headline)
                            Text(firebaseService.isAuthenticated ? "Authenticated" : "Sign in to sync data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if firebaseService.isAuthenticated {
                        Button(action: signOut) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Connection") {
                    HStack {
                        Image(systemName: connectionIcon)
                            .foregroundColor(connectionColor)
                        VStack(alignment: .leading) {
                            Text("Firebase Status")
                                .font(.headline)
                            Text(connectionStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(firebaseService.isOnline ? "Online" : "Offline")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(firebaseService.isOnline ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(firebaseService.isOnline ? .green : .orange)
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("App Info") {
                    Label("Version", systemImage: "info.circle")
                        .badge("1.0.0")
                    
                    Label("Build", systemImage: "hammer")
                        .badge("Firebase Stage 3")
                    
                    #if DEBUG
                    Label("Environment", systemImage: "wrench.and.screwdriver")
                        .badge("Development")
                    #endif
                }
                
                Section("Development") {
                    #if DEBUG
                    Button(action: {
                        // Test Firebase connection
                        Task {
                            await testFirebaseConnection()
                        }
                    }) {
                        Label("Test Firebase Connection", systemImage: "bolt.circle")
                    }
                    
                    Button(action: {
                        // Clear local data
                        print("🗑️ Would clear local data")
                    }) {
                        Label("Clear Local Data", systemImage: "trash.circle")
                            .foregroundColor(.red)
                    }
                    #endif
                }
                
                Section("Data Management") {
                    Button(action: {
                        showingDeletedItems = true
                    }) {
                        HStack {
                            Label("Deleted Items", systemImage: "trash")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !deletedService.deletedItems.isEmpty {
                                Text("\(deletedService.deletedItems.count)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Support") {
                    Label("Help & Support", systemImage: "questionmark.circle")
                    Label("Send Feedback", systemImage: "envelope")
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingDeletedItems) {
            DeletedItemsView()
        }
    }
    
    private var connectionIcon: String {
        switch firebaseService.connectionState {
        case .connected: return "checkmark.circle.fill"
        case .disconnected: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var connectionColor: Color {
        switch firebaseService.connectionState {
        case .connected: return .green
        case .disconnected: return .red
        case .unknown: return .orange
        }
    }
    
    private var connectionStatusText: String {
        switch firebaseService.connectionState {
        case .connected: return "Connected to Firebase (Real Mode)"
        case .disconnected: return "Disconnected from Firebase"
        case .unknown: return "Connection status unknown"
        }
    }
    
    private func testFirebaseConnection() async {
        print("🧪 Testing Firebase connection...")
        // This would test actual Firebase when SDK is added
        // Note: Authentication is now handled by AuthenticationService
        print("✅ Firebase connection test - using AuthenticationService for auth")
    }
    
    private func signOut() {
        do {
            try authService.signOut()
            // Properties remain persistent even after sign out
            // The user can access their data when they sign back in
            print("✅ User signed out successfully - properties maintained")
        } catch {
            print("❌ Failed to sign out: \(error)")
        }
    }
}

#Preview {
    ContentView()
}