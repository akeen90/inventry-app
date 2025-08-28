import Foundation
import UIKit
import PDFKit

class PDFGenerationService {
    static let shared = PDFGenerationService()
    
    private init() {}
    
    func generatePropertyReport(for property: Property) -> Data? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // US Letter size
        
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            
            let pageRect = context.pdfContextBounds
            var currentY: CGFloat = 50
            
            // Title
            currentY = drawTitle("Property Inspection Report", at: CGPoint(x: 50, y: currentY), pageWidth: pageRect.width - 100)
            currentY += 30
            
            // Property Information
            currentY = drawSectionHeader("Property Information", at: CGPoint(x: 50, y: currentY))
            currentY += 20
            
            let propertyInfo = [
                ("Property Name:", property.name),
                ("Address:", property.address),
                ("Type:", property.type.displayName),
                ("Inventory Type:", property.inventoryType.displayName),
                ("Status:", property.status.displayName),
                ("Created:", formatDate(property.createdAt)),
                ("Last Updated:", formatDate(property.updatedAt))
            ]
            
            for (label, value) in propertyInfo {
                currentY = drawInfoRow(label: label, value: value, at: CGPoint(x: 50, y: currentY))
                currentY += 20
            }
            
            currentY += 20
            
            // Rooms Summary
            if let inventoryReport = property.inventoryReport, !inventoryReport.rooms.isEmpty {
                currentY = drawSectionHeader("Rooms Summary", at: CGPoint(x: 50, y: currentY))
                currentY += 20
                
                for room in inventoryReport.rooms {
                    currentY = drawRoomSummary(room: room, at: CGPoint(x: 50, y: currentY), pageWidth: pageRect.width - 100)
                    currentY += 10
                    
                    // Check if we need a new page
                    if currentY > pageRect.height - 100 {
                        context.beginPage()
                        currentY = 50
                    }
                }
            }
            
            // Overall Assessment
            currentY += 30
            if currentY > pageRect.height - 150 {
                context.beginPage()
                currentY = 50
            }
            
            currentY = drawSectionHeader("Overall Assessment", at: CGPoint(x: 50, y: currentY))
            currentY += 20
            
            let overallCondition = calculateOverallCondition(for: property)
            currentY = drawInfoRow(label: "Overall Condition:", value: overallCondition, at: CGPoint(x: 50, y: currentY))
            
            // Footer
            let footerY = pageRect.height - 50
            drawFooter(at: CGPoint(x: 50, y: footerY), pageWidth: pageRect.width - 100)
        }
        
        return pdfData
    }
    
    // MARK: - Drawing Helper Methods
    
    private func drawTitle(_ title: String, at point: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let font = UIFont.boldSystemFont(ofSize: 24)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        let rect = CGRect(x: point.x, y: point.y, width: pageWidth, height: 30)
        attributedString.draw(in: rect)
        
        // Draw underline
        let underlineY = point.y + 35
        let path = UIBezierPath()
        path.move(to: CGPoint(x: point.x, y: underlineY))
        path.addLine(to: CGPoint(x: point.x + pageWidth, y: underlineY))
        path.lineWidth = 2.0
        UIColor.black.setStroke()
        path.stroke()
        
        return point.y + 40
    }
    
    private func drawSectionHeader(_ header: String, at point: CGPoint) -> CGFloat {
        let font = UIFont.boldSystemFont(ofSize: 18)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedString = NSAttributedString(string: header, attributes: attributes)
        let rect = CGRect(x: point.x, y: point.y, width: 400, height: 25)
        attributedString.draw(in: rect)
        
        return point.y + 25
    }
    
    private func drawInfoRow(label: String, value: String, at point: CGPoint) -> CGFloat {
        let labelFont = UIFont.boldSystemFont(ofSize: 12)
        let valueFont = UIFont.systemFont(ofSize: 12)
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: UIColor.black
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: valueFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        // Draw label
        let labelString = NSAttributedString(string: label, attributes: labelAttributes)
        let labelRect = CGRect(x: point.x, y: point.y, width: 120, height: 20)
        labelString.draw(in: labelRect)
        
        // Draw value
        let valueString = NSAttributedString(string: value, attributes: valueAttributes)
        let valueRect = CGRect(x: point.x + 130, y: point.y, width: 350, height: 20)
        valueString.draw(in: valueRect)
        
        return point.y + 20
    }
    
    private func drawRoomSummary(room: Room, at point: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14)
        let boldFont = UIFont.boldSystemFont(ofSize: 14)
        
        var currentY = point.y
        
        // Room name and type
        let roomHeader = "\(room.name) (\(room.type.rawValue))"
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.black
        ]
        
        let headerString = NSAttributedString(string: roomHeader, attributes: headerAttributes)
        let headerRect = CGRect(x: point.x, y: currentY, width: pageWidth, height: 20)
        headerString.draw(in: headerRect)
        currentY += 25
        
        // Room condition summary
        let conditionSummary = generateRoomConditionSummary(room: room)
        let conditionAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]
        
        let conditionString = NSAttributedString(string: conditionSummary, attributes: conditionAttributes)
        let conditionRect = CGRect(x: point.x + 20, y: currentY, width: pageWidth - 20, height: 40)
        conditionString.draw(in: conditionRect)
        currentY += 50
        
        return currentY
    }
    
    private func drawFooter(at point: CGPoint, pageWidth: CGFloat) {
        let font = UIFont.systemFont(ofSize: 10)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.lightGray
        ]
        
        let footerText = "Generated by Inventry App on \(formatDate(Date()))"
        let attributedString = NSAttributedString(string: footerText, attributes: attributes)
        let rect = CGRect(x: point.x, y: point.y, width: pageWidth, height: 15)
        attributedString.draw(in: rect)
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func calculateOverallCondition(for property: Property) -> String {
        guard let inventoryReport = property.inventoryReport else {
            return "No inventory data available"
        }
        
        if inventoryReport.rooms.isEmpty {
            return "No rooms inspected"
        }
        
        // Simple condition calculation based on room conditions
        let totalRooms = inventoryReport.rooms.count
        var goodCount = 0
        var fairCount = 0
        var poorCount = 0
        
        for room in inventoryReport.rooms {
            // This is a simplified condition assessment
            // In a real app, you'd have actual condition data
            let itemCount = room.items.count
            if itemCount > 5 {
                goodCount += 1
            } else if itemCount > 2 {
                fairCount += 1
            } else {
                poorCount += 1
            }
        }
        
        if goodCount >= totalRooms * 2/3 {
            return "Good"
        } else if goodCount + fairCount >= totalRooms * 2/3 {
            return "Fair"
        } else {
            return "Needs Attention"
        }
    }
    
    private func generateRoomConditionSummary(room: Room) -> String {
        let itemCount = room.items.count
        if itemCount == 0 {
            return "No items recorded"
        } else if itemCount == 1 {
            return "1 item recorded"
        } else {
            return "\(itemCount) items recorded"
        }
    }
    
    // MARK: - Public Methods for PDF Export
    
    func savePDFToDocuments(pdfData: Data, fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    func sharePDF(pdfData: Data, fileName: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error creating temporary PDF file: \(error)")
            return nil
        }
    }
}