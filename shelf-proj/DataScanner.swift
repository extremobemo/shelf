//
//  DataScanner.swift
//  shelf-proj
//
//  Created by Bemo on 9/26/22.
//

import Foundation
import SwiftUI
import VisionKit
import AVKit
import SafariServices
import WebKit


struct DataScanner: UIViewControllerRepresentable {
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScanner

        init(_ parent: DataScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]){
        print(addedItems)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                print("text: \(text.transcript)")
            case .barcode(let barcode):
                dataScanner.dismiss(animated: true)
                var game_name: String
                
                print("barcode: \(barcode.payloadStringValue ?? "unknown")")
                let base_url = "https://www.pricecharting.com/search-products?type=videogames&q="
                
                var upc = barcode.payloadStringValue!
                upc.remove(at: upc.startIndex)
                let final_url = base_url.appending(String(upc))
                let url = URL(string: final_url)!
                let request = URLRequest(url: url)
                
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let _ = data {
                        let test = response?.url?.absoluteString.split(separator: "/").map { String($0) }
                        let game = test?[4].split(separator: "?").map { String($0) }
                        let system = test?[3]
                        self.parent.game = game?[0]
                    } else if let error = error {
                        print("HTTP Request Failed \(error)")
                    }
                }
                
                task.resume()

                // url = "https://www.pricecharting.com/search-products?type=videogames&q={}".format(barcode)
            default:
                print("unexpected item")
            }
            
            let get_desc_url = URL(string:"https://api.mobygames.com/v1/games/60443?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!
            
            let task2 = URLSession.shared.dataTask(with: get_desc_url) { data, response, error in
                if let _ = data {
                    let test = String(data: data!, encoding: String.Encoding.utf8) as String?
                    print(test)
                    //let game = test?[4].split(separator: "?").map { String($0) }
                    //let system = test?[3]
                    //self.parent.game = game?[0]
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                }
            }
            
            task2.resume()

            // TODO: Clean up this function, move this file
        }
    }
    @Binding var game: String?
    
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
        Coordinator(self)
    }
}
