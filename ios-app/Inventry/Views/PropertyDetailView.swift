import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @StateObject private var inventoryService = InventoryService()
    @State private var showingAddRoom = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Property Header
                    PropertyHeaderView(property: property)
                    
                    // Inventory Progress
                    if let report = inventoryService.currentReport {
                        InventoryProgressView(report: report)
                    }
                    
                    // Rooms List
                    RoomsListView(
                        rooms: inventoryService.currentReport?.rooms ?? [],
                        onRoomTap: { room in
                            // Navigation will be handled by NavigationLink in RoomsListView
                        }
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Property Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Room", systemImage: "plus.rectangle") {
                            showingAddRoom = true
                        }
                        
                        Button("Generate Report", systemImage: "doc.text") {
                            // Generate PDF report
                        }
                        
                        if inventoryService.currentReport?.isComplete == true {
                            Button("Complete Inventory", systemImage: "checkmark.seal") {
                                // Mark as complete
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddRoom) {
                AddRoomView(inventoryService: inventoryService)
            }
        }
        .onAppear {
            inventoryService.loadInventoryReport(for: property.id, type: property.inventoryType)
        }
    }
}

struct PropertyHeaderView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(property.inventoryType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    
                    Text(property.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                Label("Landlord", systemImage: "person.badge.key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(property.landlord.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            if let tenant = property.tenant {
                HStack {
                    Label("Tenant", systemImage: "person")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(tenant.name)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InventoryProgressView: View {
    let report: InventoryReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inventory Progress")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(report.completedItems) of \(report.totalItems) items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ProgressView(value: report.completionPercentage / 100.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                
                Spacer()
                
                Text(String(format: "%.0f%%", report.completionPercentage))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Label("\(report.rooms.count) Rooms", systemImage: "door.left.hand.open")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if report.landlordSignature != nil {
                    Label("Landlord Signed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if report.tenantSignature != nil {
                    Label("Tenant Signed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RoomsListView: View {
    let rooms: [Room]
    let onRoomTap: (Room) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Rooms")
                    .font(.headline)
                
                Spacer()
                
                if !rooms.isEmpty {
                    Text("\(rooms.count) rooms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if rooms.isEmpty {
                EmptyRoomsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(rooms) { room in
                        NavigationLink(destination: RoomDetailView(room: room)) {
                            RoomRowView(room: room)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct RoomRowView: View {
    let room: Room
    
    var body: some View {
        HStack {
            Image(systemName: room.type.systemImage)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                
                Text(room.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if room.itemCount > 0 {
                    Text("\(room.completedItemsCount) of \(room.itemCount) items complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if room.itemCount > 0 {
                    Text(String(format: "%.0f%%", room.completionPercentage))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(room.completionPercentage == 100 ? .green : .orange)
                    
                    ProgressView(value: room.completionPercentage / 100.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 60)
                } else {
                    Text("No items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct EmptyRoomsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "door.left.hand.open")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Rooms Added")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Add rooms to start creating your inventory")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AddRoomView: View {
    @ObservedObject var inventoryService: InventoryService
    @Environment(\.dismiss) private var dismiss
    
    @State private var roomName = ""
    @State private var selectedType = RoomType.livingRoom
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Room Details") {
                    TextField("Room Name", text: $roomName)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Room Type", selection: $selectedType) {
                        ForEach(RoomType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.systemImage)
                                .tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Add Room")
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
                            await addRoom()
                        }
                    }
                    .disabled(isSubmitting || roomName.isEmpty)
                }
            }
            .disabled(isSubmitting)
        }
    }
    
    private func addRoom() async {
        isSubmitting = true
        
        let room = Room(
            name: roomName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType
        )
        
        await inventoryService.addRoom(room)
        
        if inventoryService.errorMessage == nil {
            dismiss()
        }
        
        isSubmitting = false
    }
}

#Preview {
    let landlord = Landlord(name: "Smith Property Ltd", email: "contact@smithproperties.co.uk")
    let property = Property(
        name: "Victorian Terrace",
        address: "12 Baker Street, London SW1A 1AA",
        type: .house,
        landlord: landlord,
        inventoryType: .checkIn
    )
    
    return PropertyDetailView(property: property)
}