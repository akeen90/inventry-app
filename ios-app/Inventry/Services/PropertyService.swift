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
}