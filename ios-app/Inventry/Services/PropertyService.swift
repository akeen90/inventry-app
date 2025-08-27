import Foundation

@MainActor
class PropertyService: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    private func getMockProperties(for userId: String) -> [Property] {
        let landlord = Landlord(name: "Smith Property Ltd", email: "contact@smithproperties.co.uk")
        
        // Different properties for different demo users
        switch userId {
        case "john.smith@example.com":
            return [
                Property(name: "Victorian Terrace", address: "12 Baker Street, London SW1A 1AA", type: .house, landlord: landlord, inventoryType: .checkIn, userId: userId),
                Property(name: "City Centre Flat", address: "45 Manchester Road, Birmingham B1 1AA", type: .flat, landlord: landlord, inventoryType: .checkOut, userId: userId),
                Property(name: "Mountain Cabin", address: "789 Pine Road, Aspen CO", type: .house, landlord: landlord, inventoryType: .midTerm, userId: userId)
            ]
        case "sarah.johnson@example.com":
            return [
                Property(name: "Downtown Office", address: "123 Business District, New York", type: .commercial, landlord: landlord, inventoryType: .checkIn, userId: userId),
                Property(name: "Beachfront Villa", address: "456 Ocean Drive, Miami FL", type: .house, landlord: landlord, inventoryType: .checkOut, userId: userId)
            ]
        case "admin@inventry.com":
            // Admin sees all properties
            let johnProperties = [
                Property(name: "Victorian Terrace", address: "12 Baker Street, London SW1A 1AA", type: .house, landlord: landlord, inventoryType: .checkIn, userId: "john.smith@example.com"),
                Property(name: "City Centre Flat", address: "45 Manchester Road, Birmingham B1 1AA", type: .flat, landlord: landlord, inventoryType: .checkOut, userId: "john.smith@example.com"),
                Property(name: "Mountain Cabin", address: "789 Pine Road, Aspen CO", type: .house, landlord: landlord, inventoryType: .midTerm, userId: "john.smith@example.com")
            ]
            let sarahProperties = [
                Property(name: "Downtown Office", address: "123 Business District, New York", type: .commercial, landlord: landlord, inventoryType: .checkIn, userId: "sarah.johnson@example.com"),
                Property(name: "Beachfront Villa", address: "456 Ocean Drive, Miami FL", type: .house, landlord: landlord, inventoryType: .checkOut, userId: "sarah.johnson@example.com")
            ]
            return johnProperties + sarahProperties + [
                Property(name: "Admin Test Property", address: "Admin Building, Corporate District", type: .commercial, landlord: landlord, inventoryType: .checkIn, userId: userId)
            ]
        default:
            return []
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
            guard let currentUserEmail = firebaseService.currentUser else {
                properties = []
                isLoading = false
                return
            }
            
            // For now, use mock data filtered by user
            // TODO: Replace with real Firebase fetch
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            properties = getMockProperties(for: currentUserEmail)
            
            print("🏠 Loaded \(properties.count) properties for user: \(currentUserEmail)")
            
        } catch {
            errorMessage = "Failed to load properties: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Replace with Firebase create
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            properties.append(property)
        } catch {
            errorMessage = "Failed to add property: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Replace with Firebase update
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            if let index = properties.firstIndex(where: { $0.id == property.id }) {
                properties[index] = property
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
            // TODO: Replace with Firebase delete
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            properties.removeAll { $0.id == property.id }
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