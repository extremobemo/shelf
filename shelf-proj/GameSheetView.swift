//
//  GameSheetView.swift
//  shelf-proj
//
//  Created by Bemo on 9/7/22.
//

import SwiftUI
import Foundation


var desc = ""
struct GameSheetView: View {
    @Environment(\.dismiss) var dismiss
    var image: String
    var gameName: String
    var body: some View {
        Image(image).resizable()
            .aspectRatio(contentMode: .fit).frame(maxWidth: 600)
        Button("Press to dismiss") {
            dismiss()
        }.frame(height: 60)
        .font(.title)
        .padding()
        Text(getGameJSON(gameName:gameName))
        Text(desc)
    }
}

func getGameJSON(gameName: String) -> String {
    struct GameJSON: Codable {
        let game_id: Int
        let description: String

    }
    struct GamesJSON: Decodable {
        //let game_id: Int
        let games: [GameJSON]
    }
    
    var gameDesc: String = ""
    var base_url = "https://api.mobygames.com/v1/games?title="
    var gameName2 = gameName.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil)
    gameName2 = gameName2.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "FAIL"
    base_url.append(gameName2)
    base_url.append("&limit=1&api_key=PkyJXO8u7RGOkbno4uf3Aw==")
    
    let url = URL(string: base_url)

    var responseJson: String = ""
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                responseJson = (String(decoding: jsonData, as: UTF8.self))
                let jsonData = responseJson.data(using: .utf8)!
                let gamejson = try! JSONDecoder().decode(GamesJSON.self, from: jsonData)
                desc = gamejson.games[0].description
            } else {
                print("json data malformed")
            }
        } else if let error = error {
            print("HTTP Request Failed \(error)")
        }
    }

    task.resume()
    print(responseJson)
    return gameDesc
}
