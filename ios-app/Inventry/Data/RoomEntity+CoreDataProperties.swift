import Foundation
import CoreData

extension RoomEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: "RoomEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var inventoryReport: InventoryReportEntity?
    @NSManaged public var items: NSSet?
}

// MARK: Generated accessors for items
extension RoomEntity {
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: InventoryItemEntity)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: InventoryItemEntity)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}