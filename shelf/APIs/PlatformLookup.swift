//
//  PlatformLookup.swift
//  shelf-proj
//
//  Created by Bemo on 8/12/23.
//

import Foundation


class PlatformLookup {

  struct ResponseData: Decodable {
    var platforms: [Platform]
  }
  struct Platform : Decodable {
    var platform_id: Int
    var platform_name: String
  }

  private static func loadJson(filename fileName: String) -> [Platform]? {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
      do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonData = try decoder.decode(ResponseData.self, from: data)
        return jsonData.platforms
      } catch {
        print("error:\(error)")
      }
    }
    return nil
  }
  
  static func getAllPlatformNames() -> [(String, Int)] {
    
    let platforms = loadJson(filename: "platform_ids")
    return (platforms?.map { ($0.platform_name, $0.platform_id) })!
  }

  static func getPlatformID(platform: String) -> Int? {
    let platforms = loadJson(filename: "platform_ids")
      let test = platforms?.last(where: { $0.platform_name.lowercased().replacingOccurrences(of: " ", with: "-") == platform.lowercased().replacingOccurrences(of: " ", with: "-") })
    return test?.platform_id
  }
    
    static func getPlaformName(platformID: Int) -> String? {
      if (platformID == 0) {
        return nil
      }
        let platforms = loadJson(filename: "platform_ids")
        let test = platforms?.last(where: { $0.platform_id == platformID })
      return test?.platform_name ?? nil
    }
}
