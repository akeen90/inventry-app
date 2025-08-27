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
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Demo User")
                                .font(.headline)
                            Text("demo@inventry.com")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("App") {
                    Label("Version", systemImage: "info.circle")
                        .badge("1.0.0")
                    
                    Label("Build", systemImage: "hammer")
                        .badge("1")
                }
                
                Section("Support") {
                    Label("Help & Support", systemImage: "questionmark.circle")
                    Label("Send Feedback", systemImage: "envelope")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}