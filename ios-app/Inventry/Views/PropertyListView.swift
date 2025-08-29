import SwiftUI

struct PropertyListView: View {
    @StateObject private var propertyService = PropertyService()
    @StateObject private var firebaseService = FirebaseService.shared
    @State private var showingAddProperty = false
    @State private var searchText = ""
    
    var filteredProperties: [Property] {
        if searchText.isEmpty {
            return propertyService.properties
        } else {
            return propertyService.properties.filter { property in
                property.name.localizedCaseInsensitiveContains(searchText) ||
                property.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Stats Section
                HeaderStatsView(properties: propertyService.properties)
                
                // Properties List
                if filteredProperties.isEmpty && propertyService.properties.isEmpty {
                    EmptyStateView(showingAddProperty: $showingAddProperty)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredProperties) { property in
                                NavigationLink(destination: PropertyDetailView(property: property, propertyService: propertyService)) {
                                    ModernPropertyRowView(property: property)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .searchable(text: $searchText, prompt: "Search properties...")
            .refreshable {
                await propertyService.refreshProperties()
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                Button {
                    showingAddProperty = true
                } label: {
                    Label("Add Property", systemImage: "plus")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            )
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
            .onAppear {
                Task {
                    await propertyService.loadProperties()
                }
            }
            // REMOVED: Problematic onChange that was causing properties to disappear
            // The .onAppear loading is sufficient for property management
        }
    }
}

struct HeaderStatsView: View {
    let properties: [Property]
    
    var stats: PropertyStats {
        PropertyStats(properties: properties)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total",
                    value: "\(stats.total)",
                    subtitle: "Properties",
                    color: .blue,
                    icon: "building.2"
                )
                
                StatCard(
                    title: "Active",
                    value: "\(stats.inProgress)",
                    subtitle: "In Progress",
                    color: .orange,
                    icon: "clock"
                )
                
                StatCard(
                    title: "Complete",
                    value: "\(stats.completed)",
                    subtitle: "Signed Off",
                    color: .green,
                    icon: "checkmark.circle"
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct ModernPropertyRowView: View {
    let property: Property
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Property Icon with Completion Indicator
                ZStack {
                    // Show property photo if available, otherwise show icon with progress ring
                    if let propertyPhoto = property.propertyPhoto,
                       let image = propertyPhoto.loadImage() {
                        // Property Photo
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(statusColor, lineWidth: 2)
                            )
                    } else {
                        // Icon with subtle progress ring for incomplete properties
                        if property.hasInventoryData && property.inventoryProgress < 100 {
                            Circle()
                                .stroke(statusColor.opacity(0.2), lineWidth: 2)
                                .frame(width: 64, height: 64)
                            
                            // Completion Progress Ring - thinner and more subtle
                            Circle()
                                .trim(from: 0, to: CGFloat(property.inventoryProgress) / 100.0)
                                .stroke(statusColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 64, height: 64)
                                .rotationEffect(.degrees(-90))
                        }
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [statusColor, statusColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: propertyIcon)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    // Completion Badge for 100% complete - works for both photo and icon
                    if property.inventoryProgress == 100 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 18, height: 18)
                                        .shadow(radius: 2)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 6, y: 6)
                            }
                        }
                        .frame(width: 60, height: 60)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(property.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        StatusBadge(status: property.status)
                    }
                    
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        Label(property.type.displayName, systemImage: "house.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if property.hasInventoryData {
                            Label("\(property.totalInventoryItems) items", systemImage: "list.bullet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(property.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            
            // Progress Bar (Mock Progress)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Inspection Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(property.inventoryProgress)% Complete")
                        .font(.caption)
                        .foregroundColor(statusColor)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: Double(property.inventoryProgress) / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: statusColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
    
    private var statusColor: Color {
        // Use completion status if inventory data is available
        if property.hasInventoryData {
            let progress = property.inventoryProgress
            switch progress {
            case 0..<25: return .red.opacity(0.8)      // Very low progress
            case 25..<50: return .orange               // Low progress  
            case 50..<75: return .yellow               // Medium progress
            case 75..<100: return .blue                // High progress
            case 100: return .green                    // Complete
            default: return .gray
            }
        } else {
            // Fall back to property status colors
            switch property.status {
            case .draft: return .gray
            case .inProgress: return .orange
            case .completed: return .green
            case .approved: return .blue
            case .archived: return .purple
            }
        }
    }
    
    private var propertyIcon: String {
        switch property.type {
        case .house: return "house.fill"
        case .flat: return "building.fill"
        case .studio: return "building.2.fill"
        case .bedsit: return "bed.double.fill"
        case .maisonette: return "building.2.crop.circle.fill"
        case .bungalow: return "house.circle.fill"
        case .commercial: return "building.columns.fill"
        case .other: return "questionmark.square.fill"
        }
    }
    
}

struct StatusBadge: View {
    let status: PropertyStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.15))
            )
            .foregroundColor(statusColor)
            .overlay(
                Capsule()
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var statusColor: Color {
        switch status {
        case .draft: return .gray
        case .inProgress: return .orange
        case .completed: return .green
        case .approved: return .blue
        case .archived: return .purple
        }
    }
}

struct EmptyStateView: View {
    @Binding var showingAddProperty: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "building.2")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    Text("Welcome to Inventry")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Start building your property portfolio by adding your first property inventory.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Button {
                showingAddProperty = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Your First Property")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

struct PropertyStats {
    let total: Int
    let inProgress: Int
    let completed: Int
    
    init(properties: [Property]) {
        self.total = properties.count
        self.inProgress = properties.filter { $0.status == .inProgress }.count
        self.completed = properties.filter { $0.status == .completed }.count
    }
}

struct AddPropertyView: View {
    @ObservedObject var propertyService: PropertyService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var address = ""
    @State private var selectedType = PropertyType.house
    @State private var selectedInventoryType = InventoryType.checkIn
    @State private var isSubmitting = false
    
    var isValidForm: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Add New Property")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Create a new property inventory to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Property Name
                        ModernTextFieldView(
                            title: "Property Name",
                            text: $name,
                            placeholder: "e.g. Victorian Terrace",
                            icon: "building.2"
                        )
                        
                        // Address
                        ModernTextFieldView(
                            title: "Property Address",
                            text: $address,
                            placeholder: "Full address including postcode",
                            icon: "location",
                            isMultiline: true
                        )
                        
                        // Property Type
                        ModernPickerView(
                            title: "Property Type",
                            selection: $selectedType,
                            icon: "house"
                        )
                        
                        // Inventory Type
                        ModernSegmentedView(
                            title: "Inventory Type",
                            selection: $selectedInventoryType,
                            icon: "doc.text"
                        )
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await saveProperty()
                            }
                        } label: {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "plus")
                                }
                                Text(isSubmitting ? "Creating..." : "Create Property")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: isValidForm ? [.blue, .purple] : [.gray.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: isValidForm ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isValidForm || isSubmitting)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
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
            inventoryType: selectedInventoryType
        )
        
        await propertyService.addProperty(property)
        
        if propertyService.errorMessage == nil {
            dismiss()
        }
        
        isSubmitting = false
    }
}

struct ModernTextFieldView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isMultiline = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            
            Group {
                if isMultiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(2...4)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(text.isEmpty ? Color(.systemGray4) : .blue, lineWidth: 1)
            )
        }
    }
}

struct ModernPickerView: View {
    let title: String
    @Binding var selection: PropertyType
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker(title, selection: $selection) {
                ForEach(PropertyType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: iconForPropertyType(type))
                        Text(type.displayName)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    private func iconForPropertyType(_ type: PropertyType) -> String {
        switch type {
        case .house: return "house.fill"
        case .flat: return "building.fill"
        case .studio: return "building.2.fill"
        case .bedsit: return "bed.double.fill"
        case .maisonette: return "building.2.crop.circle.fill"
        case .bungalow: return "house.circle.fill"
        case .commercial: return "building.columns.fill"
        case .other: return "questionmark.square.fill"
        }
    }
}

struct ModernSegmentedView: View {
    let title: String
    @Binding var selection: InventoryType
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                // Current Selection Display
                HStack {
                    Text(selection.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                // Wheel Picker
                Picker(title, selection: $selection) {
                    ForEach(InventoryType.allCases, id: \.self) { type in
                        Text(type.displayName)
                            .font(.body)
                            .tag(type)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
                .clipped()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    PropertyListView()
}