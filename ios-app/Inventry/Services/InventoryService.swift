import Foundation

@MainActor
class InventoryService: ObservableObject {
    @Published var currentReport: InventoryReport?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadInventoryReport(for propertyId: UUID, type: InventoryType) {
        isLoading = true
        errorMessage = nil
        
        // Check if we already have a report for this property
        if let existingReport = currentReport, existingReport.propertyId == propertyId {
            isLoading = false
            return
        }
        
        // For now, create a new report or load from mock data
        Task {
            do {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                
                // Create new report if none exists
                let report = InventoryReport(propertyId: propertyId, inventoryType: type)
                
                // Add some sample rooms for demonstration
                var sampleRooms: [Room] = []
                
                // Living Room with sample items
                var livingRoom = Room(name: "Living Room", type: .livingRoom)
                livingRoom.items = [
                    InventoryItem(name: "3-Seater Sofa", category: .furniture, condition: .good),
                    InventoryItem(name: "Coffee Table", category: .furniture, condition: .fair),
                    InventoryItem(name: "TV Stand", category: .furniture, condition: .good),
                    InventoryItem(name: "Carpet", category: .flooring, condition: .good)
                ]
                sampleRooms.append(livingRoom)
                
                // Kitchen with sample items
                var kitchen = Room(name: "Kitchen", type: .kitchen)
                kitchen.items = [
                    InventoryItem(name: "Refrigerator", category: .appliances, condition: .good),
                    InventoryItem(name: "Oven", category: .appliances, condition: .excellent),
                    InventoryItem(name: "Kitchen Cabinets", category: .fixtures, condition: .good),
                    InventoryItem(name: "Worktop", category: .fixtures, condition: .fair)
                ]
                sampleRooms.append(kitchen)
                
                // Bedroom with sample items
                var bedroom = Room(name: "Master Bedroom", type: .bedroom)
                bedroom.items = [
                    InventoryItem(name: "Double Bed Frame", category: .furniture, condition: .good),
                    InventoryItem(name: "Wardrobe", category: .furniture, condition: .excellent),
                    InventoryItem(name: "Carpet", category: .flooring, condition: .good),
                    InventoryItem(name: "Curtains", category: .fixtures, condition: .fair)
                ]
                sampleRooms.append(bedroom)
                
                // Update report with sample rooms
                var updatedReport = report
                updatedReport.rooms = sampleRooms
                
                self.currentReport = updatedReport
                
            } catch {
                errorMessage = "Failed to load inventory: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func addRoom(_ room: Room) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Add the new room
            report.rooms.append(room)
            report.updatedAt = Date()
            
            self.currentReport = report
            
        } catch {
            errorMessage = "Failed to add room: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateRoom(_ room: Room) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Find and update the room
            if let index = report.rooms.firstIndex(where: { $0.id == room.id }) {
                report.rooms[index] = room
                report.updatedAt = Date()
                self.currentReport = report
            } else {
                errorMessage = "Room not found"
            }
            
        } catch {
            errorMessage = "Failed to update room: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteRoom(_ room: Room) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Remove the room
            report.rooms.removeAll { $0.id == room.id }
            report.updatedAt = Date()
            
            self.currentReport = report
            
        } catch {
            errorMessage = "Failed to delete room: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addItemToRoom(_ item: InventoryItem, roomId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Find the room and add the item
            if let roomIndex = report.rooms.firstIndex(where: { $0.id == roomId }) {
                report.rooms[roomIndex].items.append(item)
                report.rooms[roomIndex].updatedAt = Date()
                report.updatedAt = Date()
                self.currentReport = report
            } else {
                errorMessage = "Room not found"
            }
            
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateItemInRoom(_ item: InventoryItem, roomId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Find the room and update the item
            if let roomIndex = report.rooms.firstIndex(where: { $0.id == roomId }) {
                if let itemIndex = report.rooms[roomIndex].items.firstIndex(where: { $0.id == item.id }) {
                    report.rooms[roomIndex].items[itemIndex] = item
                    report.rooms[roomIndex].updatedAt = Date()
                    report.updatedAt = Date()
                    self.currentReport = report
                } else {
                    errorMessage = "Item not found in room"
                }
            } else {
                errorMessage = "Room not found"
            }
            
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteItemFromRoom(_ item: InventoryItem, roomId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Find the room and remove the item
            if let roomIndex = report.rooms.firstIndex(where: { $0.id == roomId }) {
                report.rooms[roomIndex].items.removeAll { $0.id == item.id }
                report.rooms[roomIndex].updatedAt = Date()
                report.updatedAt = Date()
                self.currentReport = report
            } else {
                errorMessage = "Room not found"
            }
            
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func saveSignature(_ signature: String, type: SignatureType) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            guard var report = currentReport else {
                errorMessage = "No active inventory report"
                isLoading = false
                return
            }
            
            // Save the signature
            switch type {
            case .landlord:
                report.landlordSignature = signature
            case .tenant:
                report.tenantSignature = signature
            }
            
            // Check if report is now complete
            if report.isComplete {
                report.completedAt = Date()
            }
            
            report.updatedAt = Date()
            self.currentReport = report
            
        } catch {
            errorMessage = "Failed to save signature: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func generatePDFReport() async -> Data? {
        // TODO: Implement PDF generation
        // For now, return nil
        return nil
    }
}

enum SignatureType {
    case landlord
    case tenant
}