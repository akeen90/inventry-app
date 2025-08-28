import SwiftUI
import AVFoundation
import UIKit


struct PropertyDetailView: View {
    let property: Property
    @StateObject private var inventoryService = InventoryService()
    @State private var showingAddRoom = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Enhanced Property Header
                        ModernPropertyHeaderView(property: property)
                        
                        // Property Photo Section
                        PropertyPhotoSection()
                        
                        // Enhanced Inventory Progress
                        if let report = inventoryService.currentReport {
                            ModernInventoryProgressView(report: report)
                        }
                        
                        // Quick Action Buttons
                        QuickActionsView(
                            onAddRoom: { showingAddRoom = true },
                            onGenerateReport: { /* Generate PDF report */ },
                            canComplete: inventoryService.currentReport?.isComplete == true
                        )
                        
                        // Enhanced Rooms List
                        ModernRoomsListView(
                            rooms: inventoryService.currentReport?.rooms ?? [],
                            inventoryService: inventoryService,
                            onRoomTap: { room in
                                // Navigation will be handled by NavigationLink in ModernRoomsListView
                            }
                        )
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Inventory Inspection")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddRoom) {
                ModernAddRoomView(inventoryService: inventoryService)
            }
        }
        .onAppear {
            inventoryService.loadInventoryReport(for: property.id, type: property.inventoryType)
        }
    }
}

struct ModernPropertyHeaderView: View {
    let property: Property
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(property.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                Text(property.address)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        Spacer()
                        
                        // Property type icon
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: property.type == .house ? "house.fill" : property.type == .flat ? "building.2.fill" : "building.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Status badges
                    HStack(spacing: 12) {
                        GenericStatusBadge(
                            text: property.inventoryType.displayName,
                            color: .white,
                            backgroundColor: .white.opacity(0.2)
                        )
                        
                        GenericStatusBadge(
                            text: property.type.displayName,
                            color: .white.opacity(0.8),
                            backgroundColor: .white.opacity(0.1)
                        )
                        
                        Spacer()
                    }
                }
                .padding(20)
            }
            .cornerRadius(20)
            
            // Contact information card
            VStack(spacing: 16) {
                // Landlord info
                ContactInfoRow(
                    title: "Landlord",
                    name: property.landlord.name,
                    email: property.landlord.email,
                    icon: "person.badge.key.fill",
                    iconColor: .blue
                )
                
                if let tenant = property.tenant {
                    ContactInfoRow(
                        title: "Tenant",
                        name: tenant.name,
                        email: tenant.email,
                        icon: "person.fill",
                        iconColor: .green
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .padding(.top, -10) // Overlap with header
        }
    }
}

struct ContactInfoRow: View {
    let title: String
    let name: String
    let email: String?
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18, weight: .medium))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let email = email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Contact action
            }) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .clipShape(Circle())
            }
        }
    }
}

struct ModernInventoryProgressView: View {
    let report: InventoryReport
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Inspection Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Completion percentage circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: report.completionPercentage / 100.0)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 50, height: 50)
                        
                        Text(String(format: "%.0f%%", report.completionPercentage))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                
                // Progress details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(report.completedItems) of \(report.totalItems) items documented")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(
                                    width: geometry.size.width * (report.completionPercentage / 100.0),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            
            // Stats grid
            HStack(spacing: 12) {
                ProgressStatCard(
                    value: "\(report.rooms.count)",
                    label: "Rooms",
                    icon: "door.left.hand.open",
                    color: .blue
                )
                
                ProgressStatCard(
                    value: "\(report.totalItems)",
                    label: "Total Items",
                    icon: "list.bullet.rectangle",
                    color: .purple
                )
                
                ProgressStatCard(
                    value: report.landlordSignature != nil ? "Signed" : "Pending",
                    label: "Landlord",
                    icon: "person.badge.key",
                    color: report.landlordSignature != nil ? .green : .orange
                )
                
                ProgressStatCard(
                    value: report.tenantSignature != nil ? "Signed" : "Pending",
                    label: "Tenant",
                    icon: "person",
                    color: report.tenantSignature != nil ? .green : .orange
                )
            }
            .padding(.top, 12)
        }
    }
}

struct ProgressStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
}

struct QuickActionsView: View {
    let onAddRoom: () -> Void
    let onGenerateReport: () -> Void
    let canComplete: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ActionButton(
                    title: "Add Room",
                    subtitle: "Document a new room",
                    icon: "plus.rectangle",
                    color: .blue,
                    action: onAddRoom
                )
                
                ActionButton(
                    title: "Generate Report",
                    subtitle: "Create PDF report",
                    icon: "doc.text",
                    color: .purple,
                    action: onGenerateReport
                )
                
                if canComplete {
                    ActionButton(
                        title: "Complete",
                        subtitle: "Finalize inventory",
                        icon: "checkmark.seal",
                        color: .green,
                        action: { /* Complete action */ }
                    )
                }
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernRoomsListView: View {
    let rooms: [Room]
    let inventoryService: InventoryService
    let onRoomTap: (Room) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Room Inspections")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !rooms.isEmpty {
                    Text("\(rooms.count) rooms")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            
            if rooms.isEmpty {
                ModernEmptyRoomsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(rooms) { room in
                        NavigationLink(destination: RoomDetailView(initialRoom: room, inventoryService: inventoryService)) {
                            ModernRoomCard(room: room)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct ModernRoomCard: View {
    let room: Room
    
    var roomTypeColor: Color {
        switch room.type {
        case .livingRoom, .diningRoom: return .blue
        case .bedroom: return .purple
        case .kitchen: return .orange
        case .bathroom: return .cyan
        case .utility, .garage: return .brown
        case .garden, .exterior: return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Room type icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [roomTypeColor, roomTypeColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: room.type.systemImage)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(room.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Status badge
                        if room.itemCount > 0 {
                            let statusColor: Color = room.completionPercentage == 100 ? .green : .blue
                            GenericStatusBadge(
                                text: room.completionPercentage == 100 ? "Complete" : "In Progress",
                                color: statusColor,
                                backgroundColor: statusColor.opacity(0.1)
                            )
                        }
                    }
                    
                    Text(room.type.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if room.itemCount > 0 {
                        HStack {
                            Text("\(room.completedItemsCount) of \(room.itemCount) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f%%", room.completionPercentage))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(roomTypeColor)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(LinearGradient(
                                        colors: [roomTypeColor, roomTypeColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(
                                        width: geometry.size.width * (room.completionPercentage / 100.0),
                                        height: 4
                                    )
                            }
                        }
                        .frame(height: 4)
                    } else {
                        Text("Ready to add items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
    }
}

struct ModernEmptyRoomsView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "door.left.hand.open")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("Ready to Start Inspection")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Add your first room to begin the property inventory process")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Helpful suggestions
            VStack(alignment: .leading, spacing: 12) {
                Text("Common rooms to start with:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(["Living Room", "Kitchen", "Bedroom"], id: \.self) { room in
                        Text(room)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

struct ModernAddRoomView: View {
    @ObservedObject var inventoryService: InventoryService
    @Environment(\.dismiss) private var dismiss
    
    @State private var roomName = ""
    @State private var selectedType = RoomType.livingRoom
    @State private var isSubmitting = false
    
    var roomTypeColor: Color {
        switch selectedType {
        case .livingRoom, .diningRoom: return .blue
        case .bedroom: return .purple
        case .kitchen: return .orange
        case .bathroom: return .cyan
        case .utility, .garage: return .brown
        case .garden, .exterior: return .green
        default: return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with preview
                        VStack(spacing: 20) {
                            // Room type preview
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(
                                        colors: [roomTypeColor, roomTypeColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                    .shadow(color: roomTypeColor.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: selectedType.systemImage)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text(roomName.isEmpty ? "New Room" : roomName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(selectedType.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(roomTypeColor)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form content
                        VStack(spacing: 20) {
                            // Room name input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Room Name")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter room name", text: $roomName)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                            }
                            
                            // Room type selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Room Type")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                    ForEach(RoomType.allCases, id: \.self) { type in
                                        RoomTypeSelectionCard(
                                            type: type,
                                            isSelected: selectedType == type,
                                            onSelect: { selectedType = type }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
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
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await addRoom()
                        }
                    }
                    .disabled(isSubmitting || roomName.isEmpty)
                    .foregroundColor(roomName.isEmpty ? .secondary : roomTypeColor)
                    .fontWeight(.semibold)
                }
            }
            .disabled(isSubmitting)
            .overlay {
                if isSubmitting {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: roomTypeColor))
                }
            }
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

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
    }
}

struct GenericStatusBadge: View {
    let text: String
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
            .foregroundColor(color)
    }
}

struct RoomTypeSelectionCard: View {
    let type: RoomType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var typeColor: Color {
        switch type {
        case .livingRoom, .diningRoom: return .blue
        case .bedroom: return .purple
        case .kitchen: return .orange
        case .bathroom: return .cyan
        case .utility, .garage: return .brown
        case .garden, .exterior: return .green
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? 
                              LinearGradient(colors: [typeColor, typeColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [typeColor.opacity(0.1), typeColor.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.systemImage)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : typeColor)
                }
                
                VStack(spacing: 2) {
                    Text(type.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? typeColor : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: isSelected ? typeColor.opacity(0.2) : .black.opacity(0.04), radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct PropertyPhotoSection: View {
    @State private var propertyImages: [UIImage] = []
    @State private var showingCamera = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Property Photos")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !propertyImages.isEmpty {
                    Text("\(propertyImages.count) photo\(propertyImages.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            
            if !propertyImages.isEmpty {
                // Show captured property photos in a modern grid
                PhotoGalleryView(
                    images: propertyImages,
                    onDelete: { index in
                        propertyImages.remove(at: index)
                    }
                )
            } else {
                // Placeholder for property photo
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "house.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("Add Property Photos")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Take photos of the property exterior")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    )
            }
            
            // Working Camera Button
            WorkingCameraButton(
                title: propertyImages.isEmpty ? "Take Property Photos" : "Add More Photos",
                allowMultiple: true,
                onPhotosCaptured: { images in
                    propertyImages.append(contentsOf: images)
                    print("✅ \(images.count) property photo(s) captured successfully")
                }
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
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