import Foundation
import SwiftUI
import VisionKit
import AVKit
import SafariServices
import WebKit
import CoreData

struct DataScanner: UIViewControllerRepresentable {
  private var shelfModel: ShelfModel
  @ObservedObject var viewModel: DataScannerViewModel
  
  init(shelfModel: ShelfModel, viewModel: DataScannerViewModel) {
    self.shelfModel = shelfModel
    self.viewModel = viewModel
  }
  
  class Coordinator: NSObject, DataScannerViewControllerDelegate {
    var parent: DataScanner
    
    init(parent: DataScanner) {
      self.parent = parent
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]){
      searchGameByBarcode(item: addedItems[0])
      dataScanner.dismiss(animated: true)
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
      searchGameByBarcode(item: item)
      dataScanner.dismiss(animated: true)
    }
    
    func searchGameByBarcode(item: RecognizedItem) {
      switch item {
      case .barcode(let barcode):
        var upc = barcode.payloadStringValue!
        upc.remove(at: upc.startIndex)
        
        let url = URL(string: ("https://www.pricecharting.com/search-products?type=videogames&q=" + upc))
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
          if let _ = data {
            // Please make this cleaner and safer.
            let test = response?.url?.absoluteString.split(separator: "/").map { String($0) }
            let game = test?[4].split(separator: "?").map { String($0) }
            DispatchQueue.main.async {
              self.parent.viewModel.scannedGameTitle = game![0]
              self.parent.viewModel.scannedGamePlatform = test![3]
            }
          }
        }
        task.resume()
      default:
        return
      }
    }
  }
  
  func makeUIViewController(context: Context) -> DataScannerViewController {
    let scanner = DataScannerViewController(
      recognizedDataTypes: [.barcode()],
      qualityLevel: .fast,
      recognizesMultipleItems: false,
      isHighFrameRateTrackingEnabled: true,
      isGuidanceEnabled: true,
      isHighlightingEnabled: true
    )
    scanner.delegate = context.coordinator
    try? scanner.startScanning()
    return scanner
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    // Update the view controller if needed
  }
}
