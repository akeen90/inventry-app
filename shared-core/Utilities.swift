import Foundation

// MARK: - Date Extensions
extension Date {
    func formatForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formatForAPI() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    static func fromAPIString(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
}

// MARK: - Number Formatting
extension Double {
    func formatAsQuantity() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
    }
}

// MARK: - String Extensions
extension String {
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValidEmail: Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let phoneRegex = "^[+]?[\\d\\s\\-\\(\\)]{10,}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    func uniqueElements() -> [Element] {
        var seen: Set<Element.ID> = []
        return filter { element in
            if seen.contains(element.id) {
                return false
            } else {
                seen.insert(element.id)
                return true
            }
        }
    }
}

// MARK: - Result Extensions
extension Result where Success: Codable, Failure == Error {
    func toAPIResponse() -> APIResponse<Success> {
        switch self {
        case .success(let data):
            return APIResponse(data: data)
        case .failure(let error):
            let apiError = APIError(
                code: "internal_error",
                message: error.localizedDescription,
                details: nil
            )
            return APIResponse(error: apiError, message: error.localizedDescription)
        }
    }
}

// MARK: - Validation Helpers
struct ValidationError: LocalizedError {
    let field: String
    let message: String
    
    var errorDescription: String? {
        return "\(field): \(message)"
    }
}

class Validator {
    static func validateProperty(_ property: Property) throws {
        if property.name.trimmed().isEmpty {
            throw ValidationError(field: "name", message: "Property name is required")
        }
        
        if property.address.trimmed().isEmpty {
            throw ValidationError(field: "address", message: "Property address is required")
        }
        
        if property.client.name.trimmed().isEmpty {
            throw ValidationError(field: "client", message: "Client information is required")
        }
        
        if !property.client.email.isValidEmail {
            throw ValidationError(field: "client.email", message: "Valid email is required")
        }
    }
    
    static func validateRoom(_ room: Room) throws {
        if room.name.trimmed().isEmpty {
            throw ValidationError(field: "name", message: "Room name is required")
        }
    }
    
    static func validateInventoryItem(_ item: InventoryItem) throws {
        if item.name.trimmed().isEmpty {
            throw ValidationError(field: "name", message: "Item name is required")
        }
        
        if let value = item.estimatedValue, value < 0 {
            throw ValidationError(field: "estimatedValue", message: "Estimated value cannot be negative")
        }
    }
    
    static func validateClient(_ client: Client) throws {
        if client.name.trimmed().isEmpty {
            throw ValidationError(field: "name", message: "Client name is required")
        }
        
        if !client.email.isValidEmail {
            throw ValidationError(field: "email", message: "Valid email is required")
        }
        
        if let phone = client.phone, !phone.trimmed().isEmpty && !phone.isValidPhone {
            throw ValidationError(field: "phone", message: "Valid phone number is required")
        }
    }
    
    static func validateUser(_ user: User) throws {
        if user.name.trimmed().isEmpty {
            throw ValidationError(field: "name", message: "User name is required")
        }
        
        if !user.email.isValidEmail {
            throw ValidationError(field: "email", message: "Valid email is required")
        }
    }
}

// MARK: - Constants
struct AppConstants {
    // API Configuration
    static let apiBaseUrl = "https://api.inventry.com/v1"
    static let apiTimeout: TimeInterval = 30.0
    
    // Pagination
    static let defaultPageSize = 20
    static let maxPageSize = 100
    
    // File Uploads
    static let maxFileSize: Int64 = 10 * 1024 * 1024 // 10MB
    static let allowedImageTypes = ["jpg", "jpeg", "png", "heic", "webp"]
    static let allowedDocumentTypes = ["pdf", "doc", "docx", "txt"]
    
    // UI Constants
    static let defaultAnimationDuration: TimeInterval = 0.3
    static let longPressDelay: TimeInterval = 0.5
    
    // Cache
    static let imageCacheMaxSize: Int64 = 100 * 1024 * 1024 // 100MB
    static let cacheExpirationTime: TimeInterval = 24 * 60 * 60 // 24 hours
}

// MARK: - Error Handling
enum AppError: LocalizedError {
    case networkError(String)
    case validationError(String)
    case authenticationError(String)
    case fileError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .fileError(let message):
            return "File Error: \(message)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}