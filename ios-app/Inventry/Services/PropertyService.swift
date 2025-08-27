import Foundation

@MainActor
class PropertyService: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let mockProperties: [Property] = {
        let landlord = Landlord(name: "Smith Property Ltd", email: "contact@smithproperties.co.uk")
        return [
            Property(name: "Victorian Terrace", address: "12 Baker Street, London SW1A 1AA", type: .house, landlord: landlord, inventoryType: .checkIn),
            Property(name: "City Centre Flat", address: "45 Manchester Road, Birmingham B1 1AA", type: .flat, landlord: landlord, inventoryType: .checkOut),
            Property(name: "Countryside Cottage", address: "Oak Lane, Cotswolds, Gloucestershire GL54 1AA", type: .house, landlord: landlord, inventoryType: .midTerm)
        ]
    }()
    
    init() {
        loadMockData()
    }
    
    func loadProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Replace with Firebase fetch
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            properties = mockProperties
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
        properties = mockProperties
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