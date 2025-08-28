import SwiftUI

struct ItemCameraTest: View {
    @State private var testImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Item Camera Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Test the WorkingCameraButton directly
                WorkingCameraButton(
                    title: "Test Item Camera",
                    allowMultiple: true,
                    onPhotosCaptured: { images in
                        testImages.append(contentsOf: images)
                        print("✅ Captured \(images.count) item photo(s)")
                    }
                )
                
                if !testImages.isEmpty {
                    Text("✅ \(testImages.count) photos captured")
                        .foregroundColor(.green)
                        .font(.headline)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(testImages.indices, id: \.self) { index in
                                Image(uiImage: testImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Camera Test")
        }
    }
}

#Preview {
    ItemCameraTest()
}
