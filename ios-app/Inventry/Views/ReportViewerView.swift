import SwiftUI
import PDFKit

// MARK: - Professional Report Viewer
struct ProfessionalReportViewerView: View {
    let report: InventoryReport
    let property: Property
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var pdfDocument: PDFDocument?
    @State private var isGeneratingPDF = false
    @State private var selectedFormat: ExportFormat = .pdf
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if let pdfDocument = pdfDocument {
                    // PDF Viewer
                    PDFViewerRepresentable(document: pdfDocument)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding()
                } else {
                    // Report Preview
                    ScrollView {
                        VStack(spacing: 24) {
                            // Report Header
                            ReportHeaderView(report: report, property: property)
                            
                            // Report Statistics
                            ReportStatsView(report: report)
                            
                            // Rooms Overview
                            ReportRoomsOverview(report: report)
                            
                            // Generate PDF Section
                            GeneratePDFSection(
                                isGenerating: isGeneratingPDF,
                                onGenerate: generatePDF
                            )
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Inventory Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Share Report", systemImage: "square.and.arrow.up") {
                            showingShareSheet = true
                        }
                        
                        Button("Export Options", systemImage: "doc.badge.gearshape") {
                            showingExportOptions = true
                        }
                        
                        Button("Print", systemImage: "printer") {
                            // Print functionality
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(selectedFormat: $selectedFormat)
            }
        }
        .onAppear {
            // Auto-generate PDF if report is complete
            if report.isComplete && pdfDocument == nil {
                generatePDF()
            }
        }
    }
    
    private func generatePDF() {
        isGeneratingPDF = true
        
        // In a real implementation, this would generate an actual PDF
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Create a mock PDF document
            let pdfDoc = PDFDocument()
            if let pdfPage = PDFPage() {
                pdfDoc.insert(pdfPage, at: 0)
            }
            
            self.pdfDocument = pdfDoc
            self.isGeneratingPDF = false
        }
    }
}

// MARK: - Report Header
struct ReportHeaderView: View {
    let report: InventoryReport
    let property: Property
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Property Inventory Report")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(property.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(property.address)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Report type icon
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Report metadata
                    HStack(spacing: 20) {
                        ReportMetadataItem(
                            label: "Type",
                            value: report.inventoryType.displayName,
                            icon: "tag.fill"
                        )
                        
                        ReportMetadataItem(
                            label: "Date",
                            value: DateFormatter.shortDate.string(from: report.createdAt),
                            icon: "calendar"
                        )
                        
                        ReportMetadataItem(
                            label: "Status",
                            value: report.isComplete ? "Complete" : "In Progress",
                            icon: report.isComplete ? "checkmark.circle.fill" : "clock.fill"
                        )
                    }
                }
                .padding(20)
            }
            .cornerRadius(20)
        }
    }
}

struct ReportMetadataItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Report Statistics
struct ReportStatsView: View {
    let report: InventoryReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Report Summary")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ReportStatCard(
                    value: "\(report.rooms.count)",
                    label: "Rooms",
                    icon: "door.left.hand.open",
                    color: .blue
                )
                
                ReportStatCard(
                    value: "\(report.totalItems)",
                    label: "Items",
                    icon: "list.bullet.rectangle",
                    color: .purple
                )
                
                ReportStatCard(
                    value: String(format: "%.0f%%", report.completionPercentage),
                    label: "Complete",
                    icon: "chart.pie.fill",
                    color: .green
                )
                
                ReportStatCard(
                    value: report.isComplete ? "✓" : "⏳",
                    label: report.isComplete ? "Signed" : "Pending",
                    icon: "signature",
                    color: report.isComplete ? .green : .orange
                )
            }
        }
    }
}

struct ReportStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Rooms Overview
struct ReportRoomsOverview: View {
    let report: InventoryReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Room Details")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(report.rooms.count) rooms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(report.rooms) { room in
                    ReportRoomCard(room: room)
                }
            }
        }
    }
}

struct ReportRoomCard: View {
    let room: Room
    
    var roomTypeColor: Color {
        switch room.type {
        case .livingRoom, .diningRoom: return .blue
        case .bedroom: return .purple
        case .kitchen: return .orange
        case .bathroom: return .cyan
        case .utility, .garage: return .brown
        case .garden, .exterior: return .green
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Room icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(roomTypeColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: room.type.systemImage)
                    .font(.title3)
                    .foregroundColor(roomTypeColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(room.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(room.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Text(room.type.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if room.itemCount > 0 {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(roomTypeColor)
                                .frame(
                                    width: geometry.size.width * (room.completionPercentage / 100.0),
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(room.completedItemsCount) of \(room.itemCount) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Generate PDF Section
struct GeneratePDFSection: View {
    let isGenerating: Bool
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PDF Report")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // PDF Generation Card
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [.red.opacity(0.1), .orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "doc.richtext.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Professional PDF Report")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Generate a comprehensive PDF report with photos and detailed inventory information")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: onGenerate) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "doc.badge.plus")
                                    .font(.headline)
                            }
                            
                            Text(isGenerating ? "Generating..." : "Generate PDF Report")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isGenerating ? [.gray, .gray.opacity(0.8)] : [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(isGenerating)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 8) {
                        PDFFeatureRow(icon: "photo.on.rectangle", feature: "High-resolution photos")
                        PDFFeatureRow(icon: "list.bullet", feature: "Detailed item inventory")
                        PDFFeatureRow(icon: "signature", feature: "Digital signatures")
                        PDFFeatureRow(icon: "doc.badge.checkmark", feature: "Professional formatting")
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                )
            }
        }
    }
}

struct PDFFeatureRow: View {
    let icon: String
    let feature: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(feature)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Export Options
enum ExportFormat: String, CaseIterable {
    case pdf = "PDF"
    case word = "Word Document" 
    case excel = "Excel Spreadsheet"
    case json = "JSON Data"
    
    var icon: String {
        switch self {
        case .pdf: return "doc.richtext"
        case .word: return "doc.text"
        case .excel: return "tablecells"
        case .json: return "doc.badge.gearshape"
        }
    }
}

struct ExportOptionsView: View {
    @Binding var selectedFormat: ExportFormat
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Export Options")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // Format selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose Format")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(ExportFormat.allCases, id: \.rawValue) { format in
                            ExportFormatCard(
                                format: format,
                                isSelected: selectedFormat == format,
                                onSelect: { selectedFormat = format }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Export button
                Button(action: {
                    // Export logic here
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                        
                        Text("Export as \(selectedFormat.rawValue)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportFormatCard: View {
    let format: ExportFormat
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? 
                              LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [.gray.opacity(0.1), .gray.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: format.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(format.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? .blue : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.04), radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PDF Viewer
struct PDFViewerRepresentable: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension InventoryType {
    var displayName: String {
        switch self {
        case .checkIn: return "Check-In"
        case .checkOut: return "Check-Out" 
        case .midTerm: return "Mid-Term"
        case .maintenance: return "Maintenance"
        case .renewal: return "Renewal"
        }
    }
}