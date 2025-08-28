import SwiftUI

struct AddressPickerView: View {
    @StateObject private var addressService = AddressService()
    @State private var searchText = ""
    @State private var showManualEntry = false
    @State private var selectedAddress: AddressService.AddressSuggestion?
    
    // Manual entry fields
    @State private var manualLine1 = ""
    @State private var manualLine2 = ""
    @State private var manualTown = ""
    @State private var manualCounty = ""
    @State private var manualPostcode = ""
    
    let onAddressSelected: (AddressService.AddressSuggestion) -> Void
    let onManualAddress: (String, String, String, String, String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Search Header
                VStack(spacing: 16) {
                    TextField("Enter postcode or address", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .onChange(of: searchText) { newValue in
                            addressService.searchAddresses(query: newValue)
                        }
                    
                    HStack {
                        Button("Search Addresses") {
                            addressService.searchAddresses(query: searchText)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("Manual Entry") {
                            showManualEntry = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Results List
                if addressService.isLoading {
                    ProgressView("Searching addresses...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if addressService.suggestions.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView {
                        Label("No addresses found", systemImage: "house.slash")
                    } description: {
                        Text("Try searching with a different postcode or address. You can also enter the address manually.")
                    } actions: {
                        Button("Enter Manually") {
                            showManualEntry = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(addressService.suggestions) { suggestion in
                        AddressRowView(suggestion: suggestion) {
                            selectedAddress = suggestion
                            onAddressSelected(suggestion)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Select Address")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showManualEntry) {
                ManualAddressEntryView(
                    line1: $manualLine1,
                    line2: $manualLine2,
                    town: $manualTown,
                    county: $manualCounty,
                    postcode: $manualPostcode
                ) {
                    onManualAddress(manualLine1, manualLine2, manualTown, manualCounty, manualPostcode)
                    showManualEntry = false
                }
            }
        }
    }
}

struct AddressRowView: View {
    let suggestion: AddressService.AddressSuggestion
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.line1)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let line2 = suggestion.line2, !line2.isEmpty {
                    Text(line2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(suggestion.postTown)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(suggestion.postcode)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ManualAddressEntryView: View {
    @Binding var line1: String
    @Binding var line2: String
    @Binding var town: String
    @Binding var county: String
    @Binding var postcode: String
    
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Address Details")) {
                    TextField("Address Line 1*", text: $line1)
                    TextField("Address Line 2", text: $line2)
                    TextField("Town/City*", text: $town)
                    TextField("County", text: $county)
                    TextField("Postcode*", text: $postcode)
                        .textCase(.uppercase)
                }
                
                Section {
                    Button("Save Address") {
                        onSave()
                    }
                    .disabled(line1.isEmpty || town.isEmpty || postcode.isEmpty)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Usage Example
struct AddressPickerExampleView: View {
    @State private var selectedAddress: String = ""
    @State private var showAddressPicker = false
    
    var body: some View {
        VStack {
            Button("Select Property Address") {
                showAddressPicker = true
            }
            .buttonStyle(.borderedProminent)
            
            if !selectedAddress.isEmpty {
                Text("Selected: \(selectedAddress)")
                    .padding()
            }
        }
        .sheet(isPresented: $showAddressPicker) {
            AddressPickerView(
                onAddressSelected: { address in
                    selectedAddress = address.formattedAddress
                    showAddressPicker = false
                },
                onManualAddress: { line1, line2, town, county, postcode in
                    var components = [line1]
                    if !line2.isEmpty { components.append(line2) }
                    components.append(town)
                    if !county.isEmpty { components.append(county) }
                    components.append(postcode)
                    selectedAddress = components.joined(separator: ", ")
                    showAddressPicker = false
                }
            )
        }
    }
}

#Preview {
    AddressPickerExampleView()
}