//
//  GameSheetView.swift
//  shelf-proj
//
//  Created by Bemo on 9/7/22.
//

import SwiftUI
import Foundation

struct GameSheetView: View {
    @Environment(\.dismiss) var dismiss
    var image: String
    var body: some View {
        Image(image).resizable()
            .aspectRatio(contentMode: .fit).frame(maxWidth: 600)
        Button("Press to dismiss") {
            dismiss()
        }.frame(height: 60)
        .font(.title)
        .padding()
        Text(getGameJSON(gameName:"")).frame(width: 200, height: 200)
    }
}

func getGameJSON(gameName: String) -> String {
    let url = URL(string: "https://api.mobygames.com/v1/games?title=resident%20evil%207&limit=1&api_key=PkyJXO8u7RGOkbno4uf3Aw==")

    var responseJson: String = ""
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                responseJson = (String(decoding: jsonData, as: UTF8.self))
                print(responseJson)
            } else {
                print("json data malformed")
            }
        } else if let error = error {
            print("HTTP Request Failed \(error)")
        }
    }

    task.resume()
    print(responseJson)
    return responseJson
}
