import Foundation
import UIKit

class PhotoStorageService {
    static let shared = PhotoStorageService()
    
    private init() {
        createPhotosDirectoryIfNeeded()
    }
    
    // MARK: - Directory Management
    
    private var photosDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("InventryPhotos")
    }
    
    private func createPhotosDirectoryIfNeeded() {
        let url = photosDirectory
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                print("📁 Created photos directory: \(url.path)")
            } catch {
                print("❌ Failed to create photos directory: \(error)")
            }
        }
    }
    
    // MARK: - Photo Storage
    
    func savePhoto(_ image: UIImage, withId photoId: UUID) -> String? {
        let filename = "\(photoId.uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            let relativePath = "InventryPhotos/\(filename)"
            print("✅ Photo saved to: \(relativePath)")
            return relativePath
        } catch {
            print("❌ Failed to save photo: \(error)")
            return nil
        }
    }
    
    func loadPhoto(from relativePath: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(relativePath)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("❌ Photo file does not exist: \(relativePath)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            print("❌ Failed to load image from: \(relativePath)")
            return nil
        }
        
        return image
    }
    
    func deletePhoto(at relativePath: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(relativePath)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("✅ Photo deleted: \(relativePath)")
        } catch {
            print("❌ Failed to delete photo: \(error)")
        }
    }
    
    // MARK: - Photo Reference Management
    
    func savePhotoReference(_ image: UIImage) -> PhotoReference {
        let photoRef = PhotoReference(filename: "\(UUID().uuidString).jpg", originalImage: image)
        
        // Save the image to file system
        if let localPath = savePhoto(image, withId: photoRef.id) {
            var updatedPhotoRef = photoRef
            updatedPhotoRef.localPath = localPath
            return updatedPhotoRef
        }
        
        return photoRef
    }
    
    func loadPhotoForReference(_ photoRef: PhotoReference) -> UIImage? {
        // First try to return the in-memory image
        if let originalImage = photoRef.originalImage {
            return originalImage
        }
        
        // Then try to load from local path
        if let localPath = photoRef.localPath {
            let image = loadPhoto(from: localPath)
            return image
        }
        
        // Finally try remote URL (for future Firebase integration)
        if let remoteURL = photoRef.remoteURL {
            // TODO: Implement remote image loading
            print("🔄 Remote image loading not implemented yet: \(remoteURL)")
        }
        
        return nil
    }
    
    func cleanupOrphanedPhotos() {
        // TODO: Implement cleanup of photos that are no longer referenced
        print("🧹 Photo cleanup not implemented yet")
    }
}