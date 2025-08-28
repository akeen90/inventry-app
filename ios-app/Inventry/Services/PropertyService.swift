import Foundation

@MainActor
class PropertyService: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    private let localStorageService = LocalStorageService.shared
    
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
        loadMockData()
    }
    
    func loadProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user from Firebase
            guard let currentUser = firebaseService.currentUser else {
                properties = []
                isLoading = false
                return
            }
            
            let currentUserEmail = currentUser.email ?? "unknown@example.com"
            
            // First, load from local cache
            await MainActor.run {
                properties = localStorageService.cachedProperties
            }
            
            print("📱 Loaded \(properties.count) properties from local cache")
            
            // If local cache is empty, populate with mock data for development
            if properties.isEmpty {
                let mockProperties = getMockProperties(for: currentUserEmail)
                for property in mockProperties {
                    await localStorageService.saveProperty(property)
                }
                await MainActor.run {
                    properties = localStorageService.cachedProperties
                }
                print("🔧 Populated local storage with mock data: \(properties.count) properties")
            }
            
            print("🏠 Total properties loaded for user: \(currentUserEmail) - \(properties.count)")
            
        } catch {
            errorMessage = "Failed to load properties: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Save to local storage first
            await localStorageService.saveProperty(property)
            
            // Update local array
            await MainActor.run {
                properties = localStorageService.cachedProperties
            }
            
            print("✅ Property added to local storage: \(property.name)")
        } catch {
            errorMessage = "Failed to add property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Update last accessed time and save to local storage
            await localStorageService.updatePropertyAccess(property.id)
            await localStorageService.saveProperty(property)
            
            // Update local array
            await MainActor.run {
                properties = localStorageService.cachedProperties
            }
            
            print("✅ Property updated in local storage: \(property.name)")
        } catch {
            errorMessage = "Failed to update property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete from local storage
            await localStorageService.deleteProperty(property.id)
            
            // Update local array
            await MainActor.run {
                properties = localStorageService.cachedProperties
            }
            
            print("✅ Property deleted from local storage: \(property.name)")
        } catch {
            errorMessage = "Failed to delete property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func loadMockData() {
        // Load empty initially - will be populated when user signs in
        properties = []
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