import SwiftUI

struct AddressAutocompleteView: View {
    let title: String
    @Binding var address: String
    let placeholder: String
    let icon: String
    
    @StateObject private var addressFinder = AddressFinderService()
    @State private var showingSuggestions = false
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                // Address Text Field
                TextField(placeholder, text: $searchText, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .lineLimit(2...4)
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(showingSuggestions && !addressFinder.suggestions.isEmpty ? 0 : 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: showingSuggestions && !addressFinder.suggestions.isEmpty ? 0 : 12)
                            .stroke(searchText.isEmpty ? Color(.systemGray4) : .blue, lineWidth: 1)
                    )
                    .onChange(of: searchText) { oldValue, newValue in
                        address = newValue
                        
                        if newValue != oldValue {
                            addressFinder.searchAddresses(query: newValue)
                            showingSuggestions = !newValue.isEmpty && isTextFieldFocused
                        }
                    }
                    .onChange(of: isTextFieldFocused) { oldValue, newValue in
                        if newValue {
                            showingSuggestions = !searchText.isEmpty
                        } else {
                            // Delay hiding suggestions to allow selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingSuggestions = false
                            }
                        }
                    }
                
                // Address Suggestions
                if showingSuggestions && !addressFinder.suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(addressFinder.suggestions.prefix(5)) { suggestion in
                            AddressSuggestionRow(
                                suggestion: suggestion,
                                onSelect: {
                                    Task {
                                        // Get full address details
                                        if let fullAddress = await addressFinder.getFullAddress(for: suggestion) {
                                            await MainActor.run {
                                                searchText = fullAddress
                                                address = fullAddress
                                                showingSuggestions = false
                                                isTextFieldFocused = false
                                                addressFinder.clearSuggestions()
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            
            // Search Status
            if addressFinder.isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Finding addresses...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            searchText = address
        }
    }
}

struct AddressSuggestionRow: View {
    let suggestion: AddressSuggestion
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !suggestion.subtitle.isEmpty {
                        Text(suggestion.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Color(.systemGray6)
                .opacity(0)
        )
        .onHover { isHovered in
            // Add hover effect for better UX
        }
    }
}

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    @State var address = ""
    
    return VStack {
        AddressAutocompleteView(
            title: "Property Address",
            address: $address,
            placeholder: "Start typing an address...",
            icon: "location"
        )
        
        Text("Selected: \(address)")
            .padding()
    }
    .padding()
}