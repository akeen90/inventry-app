import Foundation
import MapKit
import Combine

class AddressFinderService: NSObject, ObservableObject {
    @Published var suggestions: [AddressSuggestion] = []
    @Published var isSearching = false
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsOnly
        searchCompleter.pointOfInterestFilter = .excludingAll
        searchCompleter.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.5, longitude: -2.0), // UK center
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    }
    
    func searchAddresses(query: String) {
        guard !query.isEmpty else {
            suggestions = []
            isSearching = false
            return
        }
        
        isSearching = true
        searchCompleter.queryFragment = query
    }
    
    func clearSuggestions() {
        suggestions = []
        isSearching = false
        searchCompleter.queryFragment = ""
    }
    
    func getFullAddress(for suggestion: AddressSuggestion) async -> String? {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = suggestion.fullAddress
        
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            if let placemark = response.mapItems.first?.placemark {
                return formatFullAddress(from: placemark)
            }
        } catch {
            print("❌ Failed to get full address: \(error)")
        }
        
        return suggestion.fullAddress
    }
    
    private func formatFullAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressFinderService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results.map { result in
                AddressSuggestion(
                    title: result.title,
                    subtitle: result.subtitle,
                    fullAddress: "\(result.title), \(result.subtitle)"
                )
            }
            self.isSearching = false
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("❌ Address search failed: \(error)")
            self.isSearching = false
            self.suggestions = []
        }
    }
}

// MARK: - AddressSuggestion Model

struct AddressSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let fullAddress: String
    
    var displayText: String {
        if subtitle.isEmpty {
            return title
        }
        return "\(title), \(subtitle)"
    }
}