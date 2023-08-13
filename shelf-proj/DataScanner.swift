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
import CoreData


struct DataScanner: UIViewControllerRepresentable {
    private var shelfModel: ShelfModel
    
    init(shelfModel: ShelfModel, game: Binding<String?>, platform_name: Binding<String?>) {
        self.shelfModel = shelfModel
        self._game = game
        self._platform_name = platform_name
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScanner
        @ObservedObject var viewModel: ShelfModel
        
        @Environment(\.managedObjectContext) private var viewContext

        init(_ parent: DataScanner, viewModel: ShelfModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]){
            // Unused (for now)
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
                        let test = response?.url?.absoluteString.split(separator: "/").map { String($0) }
                        let game = test?[4].split(separator: "?").map { String($0) }
                        
//                        let newGame = Game(context: self.parent.shelfModel.context)
//                        newGame.title = game![0]
                        
                        // ^^ VERY IMPORTANT LINES, MOVE TO buildGame()
                        self.parent.game = game![0]
                        self.parent.platform_name = test![3]
                        //self.viewModel.addGame()
                        do {
                            //try self.viewContext.save()
                            // Handle successful save
                        } catch {
                            // Handle save error
                        }
                        //let game2 = Game(context: self.viewModel.context)
//                        print(test)
//                        print(game)
                    } else if let error = error {
                        //print("HTTP Request Failed \(error)")
                    }
                }
                
                task.resume()

            default:
                return
            }
        }
    }
    
    @Binding var game: String?
    @Binding var platform_name: String?
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .fast, recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true, isHighlightingEnabled: true)
        
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: shelfModel)
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
    }
}
