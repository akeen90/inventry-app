import Foundation
import Combine

// UK Address Service using Ideal Postcodes API (free tier available)
class AddressService: ObservableObject {
    
    struct AddressSuggestion: Identifiable, Codable {
        let id = UUID()
        let line1: String
        let line2: String?
        let line3: String?
        let postTown: String
        let county: String?
        let postcode: String
        let uprn: String?
        
        var formattedAddress: String {
            var components = [line1]
            if let line2 = line2, !line2.isEmpty { components.append(line2) }
            if let line3 = line3, !line3.isEmpty { components.append(line3) }
            components.append(postTown)
            if let county = county, !county.isEmpty { components.append(county) }
            components.append(postcode)
            return components.joined(separator(", ")
        }
    }
    
    @Published var suggestions: [AddressSuggestion] = []
    @Published var isLoading = false
    
    private let apiKey = "YOUR_API_KEY" // Get free key from ideal-postcodes.co.uk
    private let baseURL = "https://api.ideal-postcodes.co.uk/v1"
    
    func searchAddresses(query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        
        isLoading = true
        
        // If query looks like a postcode, search by postcode
        if isPostcode(query) {
            searchByPostcode(query)
        } else {
            // Otherwise search by address text
            searchByText(query)
        }
    }
    
    private func searchByPostcode(_ postcode: String) {
        let cleanPostcode = postcode.uppercased().replacingOccurrences(of: " ", with: "")
        guard let url = URL(string: "\(baseURL)/postcodes/\(cleanPostcode)?api_key=\(apiKey)") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data, error == nil else { return }
                
                do {
                    let result = try JSONDecoder().decode(PostcodeResponse.self, from: data)
                    self?.suggestions = result.result.map { address in
                        AddressSuggestion(
                            line1: address.line_1,
                            line2: address.line_2,
                            line3: address.line_3,
                            postTown: address.post_town,
                            county: address.county,
                            postcode: address.postcode,
                            uprn: address.uprn
                        )
                    }
                } catch {
                    print("Failed to decode postcode response: \(error)")
                }
            }
        }.resume()
    }
    
    private func searchByText(_ text: String) {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/addresses?q=\(encodedText)&api_key=\(apiKey)&limit=10") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data, error == nil else { return }
                
                do {
                    let result = try JSONDecoder().decode(AddressSearchResponse.self, from: data)
                    self?.suggestions = result.result.hits.map { hit in
                        AddressSuggestion(
                            line1: hit.address.line_1,
                            line2: hit.address.line_2,
                            line3: hit.address.line_3,
                            postTown: hit.address.post_town,
                            county: hit.address.county,
                            postcode: hit.address.postcode,
                            uprn: hit.address.uprn
                        )
                    }
                } catch {
                    print("Failed to decode address search response: \(error)")
                }
            }
        }.resume()
    }
    
    private func isPostcode(_ text: String) -> Bool {
        let postcodeRegex = "^[A-Z]{1,2}[0-9R][0-9A-Z]? ?[0-9][A-Z]{2}$"
        return text.uppercased().range(of: postcodeRegex, options: .regularExpression) != nil
    }
}

// MARK: - API Response Models
private struct PostcodeResponse: Codable {
    let result: [PostcodeAddress]
}

private struct AddressSearchResponse: Codable {
    let result: SearchResult
}

private struct SearchResult: Codable {
    let hits: [AddressHit]
}

private struct AddressHit: Codable {
    let address: PostcodeAddress
}

private struct PostcodeAddress: Codable {
    let uprn: String
    let line_1: String
    let line_2: String?
    let line_3: String?
    let post_town: String
    let county: String?
    let postcode: String
}