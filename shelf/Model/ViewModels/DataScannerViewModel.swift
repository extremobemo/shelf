//
//  DataScannerViewModel.swift
//  shelf
//
//  Created by Bemo on 8/17/24.
//

import SwiftUI

class DataScannerViewModel: ObservableObject {
  @Published var scannedGameTitle: String = ""
  @Published var scannedGamePlatform: String?
}
