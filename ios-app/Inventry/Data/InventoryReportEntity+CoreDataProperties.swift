import Foundation
import CoreData

extension InventoryReportEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InventoryReportEntity> {
        return NSFetchRequest<InventoryReportEntity>(entityName: "InventoryReportEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var completionPercentage: Double
    @NSManaged public var totalItems: Int32
    @NSManaged public var completedItems: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var property: PropertyEntity?
    @NSManaged public var rooms: NSSet?
}

// MARK: Generated accessors for rooms
extension InventoryReportEntity {
    
    @objc(addRoomsObject:)
    @NSManaged public func addToRooms(_ value: RoomEntity)
    
    @objc(removeRoomsObject:)
    @NSManaged public func removeFromRooms(_ value: RoomEntity)
    
    @objc(addRooms:)
    @NSManaged public func addToRooms(_ values: NSSet)
    
    @objc(removeRooms:)
    @NSManaged public func removeFromRooms(_ values: NSSet)
}