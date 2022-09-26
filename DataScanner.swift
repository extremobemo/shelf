//
//  DataScanner.swift
//  shelf-proj
//
//  Created by Bemo on 9/26/22.
//

import Foundation
import SwiftUI
import VisionKit


struct DataScanner: UIViewControllerRepresentable {
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]){
        print(addedItems)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                print("text: \(text.transcript)")
            case .barcode(let barcode):
                print("barcode: \(barcode.payloadStringValue ?? "unknown")")
                let base_url = "https://www.pricecharting.com/search-products?type=videogames&q="
                
                var upc = barcode.payloadStringValue!
                upc.remove(at: upc.startIndex)
                let final_url = base_url.appending(String(upc))
                let url = URL(string: final_url)!
                let request = URLRequest(url: url)
                
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        print(response?.url)
                    } else if let error = error {
                        print("HTTP Request Failed \(error)")
                    }
                }
                
                task.resume()

                // url = "https://www.pricecharting.com/search-products?type=videogames&q={}".format(barcode)
            default:
                print("unexpected item")
            }
        }
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .fast,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true)
        
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
