import SwiftUI

// MARK: - Modern Photo Gallery Component
struct PhotoGalleryView: View {
    let images: [UIImage]
    let onDelete: ((Int) -> Void)?
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        if images.isEmpty {
            EmptyPhotoView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("\(images.count) Photo\(images.count == 1 ? "" : "s")", systemImage: "photo.stack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(images.indices, id: \.self) { index in
                        PhotoThumbnailView(
                            image: images[index],
                            onDelete: onDelete != nil ? {
                                onDelete?(index)
                            } : nil
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Photo Thumbnail with Delete
struct PhotoThumbnailView: View {
    let image: UIImage
    let onDelete: (() -> Void)?
    @State private var showingFullScreen = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Photo
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .onTapGesture {
                    showingFullScreen = true
                }
            
            // Delete button
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.red)
                                .frame(width: 24, height: 24)
                        )
                        .shadow(radius: 2)
                }
                .offset(x: 8, y: -8)
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            FullScreenPhotoView(image: image)
        }
    }
}

// MARK: - Full Screen Photo View
struct FullScreenPhotoView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 1), 4)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                withAnimation(.spring()) {
                                    scale = min(max(scale, 1), 3)
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            scale = scale > 1 ? 1 : 2
                        }
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Empty Photo View
struct EmptyPhotoView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No photos added")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Tap the camera button to add photos")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundColor(.gray.opacity(0.3))
                )
        )
    }
}

// MARK: - Compact Photo Row (for smaller spaces)
struct CompactPhotoRow: View {
    let images: [UIImage]
    let maxVisible: Int = 4
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(images.prefix(maxVisible).indices, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(radius: 1)
                    )
            }
            
            if images.count > maxVisible {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 60, height: 60)
                    
                    Text("+\(images.count - maxVisible)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Photo Section for Forms
struct PhotoFormSection: View {
    @Binding var images: [UIImage]
    let title: String
    let allowMultiple: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                if !images.isEmpty {
                    Text("\(images.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            if images.isEmpty {
                EmptyPhotoView()
            } else {
                PhotoGalleryView(
                    images: images,
                    onDelete: { index in
                        images.remove(at: index)
                    }
                )
            }
            
            HStack(spacing: 12) {
                WorkingCameraButton(
                    title: "Camera",
                    icon: "camera.fill",
                    allowMultiple: allowMultiple,
                    onPhotosCaptured: { newImages in
                        images.append(contentsOf: newImages)
                    }
                )
                
                Button(action: {
                    // Photo library action
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Library")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
