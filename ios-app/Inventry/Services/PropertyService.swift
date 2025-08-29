import Foundation

@MainActor
class PropertyService: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    // private let localStorageService = LocalStorageService.shared // TODO: Re-enable when Core Data files are added to project
    
    // CRITICAL: JSON-based persistence as immediate fix
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var propertiesFileURL: URL {
        documentsDirectory.appendingPathComponent("properties.json")
    }
    
    // CRITICAL: Save properties to JSON file
    private func savePropertiesToDisk() {
        do {
            let data = try JSONEncoder().encode(properties)
            try data.write(to: propertiesFileURL)
            print("✅ Properties saved to disk: \(properties.count) properties")
        } catch {
            print("❌ Failed to save properties to disk: \(error)")
            errorMessage = "Failed to save data: \(error.localizedDescription)"
        }
    }
    
    // CRITICAL: Load properties from JSON file - NO FALLBACKS
    private func loadPropertiesFromDisk() -> [Property] {
        do {
            let data = try Data(contentsOf: propertiesFileURL)
            let savedProperties = try JSONDecoder().decode([Property].self, from: data)
            print("✅ Properties loaded from persistent storage: \(savedProperties.count) properties")
            return savedProperties
        } catch {
            print("💾 No saved properties file found - starting with empty storage")
            return []
        }
    }
    
    // Helper enum for inventory progress levels
    private enum InventoryProgressLevel {
        case low, medium, high
    }
    
    private func getMockProperties(for userId: String) -> [Property] {
        let landlord = Landlord(name: "Smith Property Ltd", email: "contact@smithproperties.co.uk")
        
        // Different properties for different demo users
        switch userId {
        case "john.smith@example.com":
            return [
                createPropertyWithInventory(name: "Victorian Terrace", address: "12 Baker Street, London SW1A 1AA", type: .house, landlord: landlord, inventoryType: .checkIn, userId: userId, progressLevel: .high),
                createPropertyWithInventory(name: "City Centre Flat", address: "45 Manchester Road, Birmingham B1 1AA", type: .flat, landlord: landlord, inventoryType: .checkOut, userId: userId, progressLevel: .medium),
                createPropertyWithInventory(name: "Mountain Cabin", address: "789 Pine Road, Aspen CO", type: .house, landlord: landlord, inventoryType: .midTerm, userId: userId, progressLevel: .low)
            ]
        case "sarah.johnson@example.com":
            return [
                createPropertyWithInventory(name: "Downtown Office", address: "123 Business District, New York", type: .commercial, landlord: landlord, inventoryType: .checkIn, userId: userId, progressLevel: .medium),
                createPropertyWithInventory(name: "Beachfront Villa", address: "456 Ocean Drive, Miami FL", type: .house, landlord: landlord, inventoryType: .checkOut, userId: userId, progressLevel: .high)
            ]
        case "admin@inventry.com":
            // Admin sees all properties
            let johnProperties = [
                createPropertyWithInventory(name: "Victorian Terrace", address: "12 Baker Street, London SW1A 1AA", type: .house, landlord: landlord, inventoryType: .checkIn, userId: "john.smith@example.com", progressLevel: .high),
                createPropertyWithInventory(name: "City Centre Flat", address: "45 Manchester Road, Birmingham B1 1AA", type: .flat, landlord: landlord, inventoryType: .checkOut, userId: "john.smith@example.com", progressLevel: .medium),
                createPropertyWithInventory(name: "Mountain Cabin", address: "789 Pine Road, Aspen CO", type: .house, landlord: landlord, inventoryType: .midTerm, userId: "john.smith@example.com", progressLevel: .low)
            ]
            let sarahProperties = [
                createPropertyWithInventory(name: "Downtown Office", address: "123 Business District, New York", type: .commercial, landlord: landlord, inventoryType: .checkIn, userId: "sarah.johnson@example.com", progressLevel: .medium),
                createPropertyWithInventory(name: "Beachfront Villa", address: "456 Ocean Drive, Miami FL", type: .house, landlord: landlord, inventoryType: .checkOut, userId: "sarah.johnson@example.com", progressLevel: .high)
            ]
            return johnProperties + sarahProperties + [
                createPropertyWithInventory(name: "Admin Test Property", address: "Admin Building, Corporate District", type: .commercial, landlord: landlord, inventoryType: .checkIn, userId: userId, progressLevel: .medium)
            ]
        default:
            return []
        }
    }
    
    // Helper function to create properties with inventory data
    private func createPropertyWithInventory(name: String, address: String, type: PropertyType, landlord: Landlord, inventoryType: InventoryType, userId: String, progressLevel: InventoryProgressLevel) -> Property {
        var property = Property(name: name, address: address, type: type, landlord: landlord, inventoryType: inventoryType, userId: userId)
        
        // Create inventory report
        var report = InventoryReport(propertyId: property.id, inventoryType: inventoryType)
        
        // Add rooms based on property type
        var rooms: [Room] = []
        
        switch type {
        case .house:
            rooms = createHouseRooms(progressLevel: progressLevel)
        case .flat, .studio:
            rooms = createFlatRooms(progressLevel: progressLevel)
        case .commercial:
            rooms = createCommercialRooms(progressLevel: progressLevel)
        default:
            rooms = createDefaultRooms(progressLevel: progressLevel)
        }
        
        report.rooms = rooms
        property.inventoryReport = report
        
        // Set property status based on progress
        switch progressLevel {
        case .low:
            property.status = .draft
        case .medium:
            property.status = .inProgress
        case .high:
            property.status = .completed
        }
        
        return property
    }
    
    private func createHouseRooms(progressLevel: InventoryProgressLevel) -> [Room] {
        var livingRoom = Room(name: "Living Room", type: .livingRoom)
        livingRoom.items = createLivingRoomItems(progressLevel: progressLevel)
        
        var kitchen = Room(name: "Kitchen", type: .kitchen)
        kitchen.items = createKitchenItems(progressLevel: progressLevel)
        
        var masterBedroom = Room(name: "Master Bedroom", type: .bedroom)
        masterBedroom.items = createBedroomItems(progressLevel: progressLevel)
        
        var bathroom = Room(name: "Main Bathroom", type: .bathroom)
        bathroom.items = createBathroomItems(progressLevel: progressLevel)
        
        var hallway = Room(name: "Hallway", type: .hallway)
        hallway.items = createHallwayItems(progressLevel: progressLevel)
        
        return [livingRoom, kitchen, masterBedroom, bathroom, hallway]
    }
    
    private func createFlatRooms(progressLevel: InventoryProgressLevel) -> [Room] {
        var livingRoom = Room(name: "Living Room", type: .livingRoom)
        livingRoom.items = createLivingRoomItems(progressLevel: progressLevel)
        
        var kitchen = Room(name: "Kitchen", type: .kitchen)
        kitchen.items = createKitchenItems(progressLevel: progressLevel)
        
        var bedroom = Room(name: "Bedroom", type: .bedroom)
        bedroom.items = createBedroomItems(progressLevel: progressLevel)
        
        var bathroom = Room(name: "Bathroom", type: .bathroom)
        bathroom.items = createBathroomItems(progressLevel: progressLevel)
        
        return [livingRoom, kitchen, bedroom, bathroom]
    }
    
    private func createCommercialRooms(progressLevel: InventoryProgressLevel) -> [Room] {
        var mainArea = Room(name: "Main Office Area", type: .other)
        mainArea.items = createOfficeItems(progressLevel: progressLevel)
        
        var reception = Room(name: "Reception", type: .other)
        reception.items = createReceptionItems(progressLevel: progressLevel)
        
        var bathroom = Room(name: "Bathroom", type: .bathroom)
        bathroom.items = createBathroomItems(progressLevel: progressLevel)
        
        return [mainArea, reception, bathroom]
    }
    
    private func createDefaultRooms(progressLevel: InventoryProgressLevel) -> [Room] {
        var mainRoom = Room(name: "Main Area", type: .other)
        mainRoom.items = createBasicItems(progressLevel: progressLevel)
        
        return [mainRoom]
    }
    
    private func createLivingRoomItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "3-Seater Sofa", category: .furniture, condition: .good),
            InventoryItem(name: "Coffee Table", category: .furniture, condition: .fair),
            InventoryItem(name: "TV Stand", category: .furniture, condition: .good),
            InventoryItem(name: "Carpet", category: .flooring, condition: .good),
            InventoryItem(name: "Curtains", category: .fixtures, condition: .fair),
            InventoryItem(name: "Light Fitting", category: .lighting, condition: .excellent)
        ]
        
        // Mark items as complete based on progress level
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createKitchenItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Refrigerator", category: .appliances, condition: .good),
            InventoryItem(name: "Oven", category: .appliances, condition: .excellent),
            InventoryItem(name: "Kitchen Cabinets", category: .fixtures, condition: .good),
            InventoryItem(name: "Worktop", category: .fixtures, condition: .fair),
            InventoryItem(name: "Kitchen Sink", category: .plumbing, condition: .good),
            InventoryItem(name: "Tiled Floor", category: .flooring, condition: .excellent)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createBedroomItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Double Bed Frame", category: .furniture, condition: .good),
            InventoryItem(name: "Wardrobe", category: .furniture, condition: .excellent),
            InventoryItem(name: "Bedside Tables", category: .furniture, condition: .good),
            InventoryItem(name: "Carpet", category: .flooring, condition: .good),
            InventoryItem(name: "Window Blinds", category: .fixtures, condition: .fair)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createBathroomItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Bath Tub", category: .plumbing, condition: .good),
            InventoryItem(name: "Toilet", category: .plumbing, condition: .excellent),
            InventoryItem(name: "Wash Basin", category: .plumbing, condition: .good),
            InventoryItem(name: "Shower", category: .plumbing, condition: .fair),
            InventoryItem(name: "Bathroom Mirror", category: .fixtures, condition: .good),
            InventoryItem(name: "Tiled Floor", category: .flooring, condition: .excellent)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createHallwayItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Front Door", category: .doors, condition: .good),
            InventoryItem(name: "Coat Hooks", category: .fixtures, condition: .fair),
            InventoryItem(name: "Hallway Light", category: .lighting, condition: .good),
            InventoryItem(name: "Laminate Flooring", category: .flooring, condition: .excellent)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createOfficeItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Office Desks", category: .furniture, condition: .good),
            InventoryItem(name: "Office Chairs", category: .furniture, condition: .fair),
            InventoryItem(name: "Filing Cabinets", category: .furniture, condition: .good),
            InventoryItem(name: "Carpet Tiles", category: .flooring, condition: .excellent),
            InventoryItem(name: "Air Conditioning", category: .heating, condition: .good),
            InventoryItem(name: "Fire Extinguisher", category: .security, condition: .excellent)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createReceptionItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Reception Desk", category: .furniture, condition: .excellent),
            InventoryItem(name: "Visitor Chairs", category: .furniture, condition: .good),
            InventoryItem(name: "Reception Lighting", category: .lighting, condition: .good)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func createBasicItems(progressLevel: InventoryProgressLevel) -> [InventoryItem] {
        var items = [
            InventoryItem(name: "Floor covering", category: .flooring, condition: .good),
            InventoryItem(name: "Wall condition", category: .walls, condition: .fair),
            InventoryItem(name: "Light fittings", category: .lighting, condition: .good)
        ]
        
        markItemsComplete(items: &items, progressLevel: progressLevel)
        return items
    }
    
    private func markItemsComplete(items: inout [InventoryItem], progressLevel: InventoryProgressLevel) {
        let completionRatio: Double
        
        switch progressLevel {
        case .low:
            completionRatio = 0.2 // 20% complete
        case .medium:
            completionRatio = 0.6 // 60% complete
        case .high:
            completionRatio = 0.9 // 90% complete
        }
        
        let itemsToComplete = Int(Double(items.count) * completionRatio)
        
        for i in 0..<itemsToComplete {
            items[i].isComplete = true
        }
    }
    
    init() {
        // Start with empty properties - will load from persistent storage when needed
        properties = []
    }
    
    func loadProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // NEVER CLEAR PROPERTIES - they should persist across all states
            
            // If we already have properties, keep them and skip reload
            if !properties.isEmpty {
                print("🏠 Properties already exist (\(properties.count)) - maintaining persistence")
                isLoading = false
                return
            }
            
            // Get current user from Firebase
            guard let currentUser = firebaseService.currentUser else {
                print("⚠️ User not available - maintaining empty state until authentication")
                isLoading = false
                return
            }
            
            let currentUserEmail = currentUser.email ?? "unknown@example.com"
            
            // CRITICAL: ONLY load from disk - NO mock data fallback
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            // Load saved properties from disk
            let savedProperties = loadPropertiesFromDisk()
            properties = savedProperties
            
            print("💾 Loaded properties from persistent storage: \(properties.count) properties for user: \(currentUserEmail)")
            
            if properties.isEmpty {
                print("📝 No saved properties found - user will start with empty list")
            }
            
        } catch {
            errorMessage = "Failed to load properties: \(error.localizedDescription)"
            print("❌ Property loading error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func addProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay
            
            // Add to memory
            properties.append(property)
            
            // CRITICAL: Save to disk immediately
            savePropertiesToDisk()
            print("💾 Property added and saved to disk: \(property.name)")
        } catch {
            errorMessage = "Failed to add property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay
            
            // Update in memory
            if let index = properties.firstIndex(where: { $0.id == property.id }) {
                properties[index] = property
                
                // CRITICAL: Save to disk immediately
                savePropertiesToDisk()
                print("💾 Property updated and saved to disk: \(property.name)")
            } else {
                errorMessage = "Property not found for update"
            }
        } catch {
            errorMessage = "Failed to update property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Replace with Firebase delete + local storage
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            properties.removeAll { $0.id == property.id }
        } catch {
            errorMessage = "Failed to delete property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    
    // MARK: - Inspection Workflow
    
    func startInspection(for property: Property) async throws -> Property {
        isLoading = true
        defer { isLoading = false }
        
        var updatedProperty = property
        updatedProperty.status = .inProgress
        updatedProperty.updatedAt = Date()
        
        await updateProperty(updatedProperty)
        return updatedProperty
    }
    
    func completeInspection(for property: Property) async throws -> Property {
        isLoading = true
        defer { isLoading = false }
        
        var updatedProperty = property
        updatedProperty.status = .completed
        updatedProperty.updatedAt = Date()
        
        await updateProperty(updatedProperty)
        return updatedProperty
    }
    
    func generateDefaultRooms(for property: Property) async throws -> [Room] {
        // Create default rooms based on property type
        var defaultRooms: [Room] = []
        
        switch property.type {
        case .flat, .studio:
            defaultRooms = [
                Room(name: "Living Room", type: .livingRoom),
                Room(name: "Bedroom", type: .bedroom),
                Room(name: "Kitchen", type: .kitchen),
                Room(name: "Bathroom", type: .bathroom)
            ]
        case .house:
            defaultRooms = [
                Room(name: "Living Room", type: .livingRoom),
                Room(name: "Kitchen", type: .kitchen),
                Room(name: "Dining Room", type: .diningRoom),
                Room(name: "Master Bedroom", type: .bedroom),
                Room(name: "Bedroom 2", type: .bedroom),
                Room(name: "Bathroom", type: .bathroom),
                Room(name: "Hallway", type: .hallway)
            ]
        default:
            defaultRooms = [
                Room(name: "Main Area", type: .other),
                Room(name: "Bathroom", type: .bathroom)
            ]
        }
        
        return defaultRooms
    }
    
    // MARK: - Data Management
    
    func refreshProperties() async {
        // Refresh properties without clearing existing ones
        // This maintains data integrity while updating from server
        isLoading = true
        
        do {
            guard let currentUser = firebaseService.currentUser else {
                print("⚠️ User not available - cannot refresh properties")
                isLoading = false
                return
            }
            
            let currentUserEmail = currentUser.email ?? "unknown@example.com"
            
            // TODO: Replace with real Firebase fetch + merge with local changes
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            let freshProperties = getMockProperties(for: currentUserEmail)
            
            // Merge fresh data with existing properties (preserve local changes)
            // For now, just update if we got fresh data
            if !freshProperties.isEmpty {
                properties = freshProperties
                print("🔄 Properties refreshed: \(properties.count) properties")
            }
            
        } catch {
            errorMessage = "Failed to refresh properties: \(error.localizedDescription)"
            print("❌ Property refresh error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Report Generation
    
    func generateInventoryReport(for property: Property, rooms: [Room] = []) async throws -> InventoryReport {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual report generation
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate report generation
        
        var report = InventoryReport(propertyId: property.id, inventoryType: property.inventoryType)
        report.rooms = rooms
        return report
    }
}

enum PropertyServiceError: LocalizedError {
    case inspectionIncomplete([String])
    case roomNotFound
    case invalidProperty
    
    var errorDescription: String? {
        switch self {
        case .inspectionIncomplete(let roomNames):
            return "Inspection incomplete for rooms: \(roomNames.joined(separator: ", "))"
        case .roomNotFound:
            return "Room not found"
        case .invalidProperty:
            return "Invalid property data"
        }
    }
}