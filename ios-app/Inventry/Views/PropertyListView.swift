import SwiftUI

struct PropertyListView: View {
    @StateObject private var propertyService = PropertyService()
    @State private var showingAddProperty = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(propertyService.properties) { property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
                        PropertyRowView(property: property)
                    }
                }
            }
            .refreshable {
                await propertyService.loadProperties()
            }
            .overlay {
                if propertyService.properties.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "house")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("No Properties")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Tap the + button to add your first property")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationTitle("Properties")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddProperty = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProperty) {
                AddPropertyView(propertyService: propertyService)
            }
            .alert("Error", isPresented: .constant(propertyService.errorMessage != nil)) {
                Button("OK") {
                    propertyService.errorMessage = nil
                }
            } message: {
                Text(propertyService.errorMessage ?? "")
            }
        }
    }
}

struct PropertyRowView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(property.name)
                    .font(.headline)
                
                Spacer()
                
                Text(property.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Text(property.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(property.type.displayName, systemImage: "house")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(property.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var statusColor: Color {
        switch property.status.color {
        case "gray": return .gray
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "red": return .red
        default: return .gray
        }
    }
}

struct AddPropertyView: View {
    @ObservedObject var propertyService: PropertyService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var address = ""
    @State private var selectedType = PropertyType.house
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Property Details") {
                    TextField("Property Name", text: $name)
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(2...4)
                    
                    Picker("Property Type", selection: $selectedType) {
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveProperty()
                        }
                    }
                    .disabled(isSubmitting || name.isEmpty || address.isEmpty)
                }
            }
            .disabled(isSubmitting)
        }
    }
    
    private func saveProperty() async {
        isSubmitting = true
        
        let defaultLandlord = Landlord(name: "Default Landlord", email: "default@example.com")
        let property = Property(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType,
            landlord: defaultLandlord,
            inventoryType: .checkIn
        )
        
        await propertyService.addProperty(property)
        
        if propertyService.errorMessage == nil {
            dismiss()
        }
        
        isSubmitting = false
    }
}

#Preview {
    PropertyListView()
}