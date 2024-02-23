//
//  MobyGamesApi.swift
//  shelf-proj
//
//  Created by Bemo on 8/12/23.
//

import Foundation
import WebKit
import CoreData


class MobyGamesApi {
  // The API class probably shouldnt write directly to iCloud, rather return data to ShelfModel for it to handle.
  
  let context = CoreDataManager.shared.persistentStoreContainer.viewContext
  
  enum UnknownError: Error {
    case unknown(description: String)
  }
  
  struct Cover: Codable {
    let comments: String?
    let description: String?
    let height: Int
    let image: URL
    let scan_of: String
    let thumbnail_image: URL
    let width: Int
  }
  
  struct CoverGroup: Codable {
    let comments: String?
    let countries: [String]
    let covers: [Cover]
  }
  
  struct ResponseData: Codable {
    let cover_groups: [CoverGroup]
  }
  
  
  // Maybe this func makes more sense in ShelfModel ...
  func buildGame(gameID: String, platformID: String, platformString: String) async -> Void {
    if let entityDescription = NSEntityDescription.entity(forEntityName: "Game", in: CoreDataManager.shared.persistentStoreContainer.viewContext) {
      let newGame = NSManagedObject(entity: entityDescription, insertInto: nil) as! Game

      do {
        let descriptionItems = try await getDescription(gameID: gameID, platID: platformID)
        do { sleep(1) } // Prevent API throttling
        let coverArtItems = try await getCoverArt(gameID: gameID, platformID: platformID)
        
        newGame.moby_id = Int64(gameID) ?? 0
        newGame.platform_id = platformID
        newGame.desc = descriptionItems.0
        newGame.screenshots = descriptionItems.1
        newGame.title = descriptionItems.2
        newGame.base_genre = descriptionItems.3
        newGame.perspective = descriptionItems.4
        newGame.gameplayElems = descriptionItems.5
        newGame.releaseYear = descriptionItems.6
        newGame.cover_art = try? Data(contentsOf: coverArtItems.0!)
        newGame.back_cover_art = try? Data(contentsOf: coverArtItems.1!)
        
        newGame.platform_id = platformID
        
        await self.context.perform {
          self.context.insert(newGame)
        }
        
        try self.context.save()
      } catch {
        // UnknownError.unknown(description: "Error building CoreData Game object")
      }
    }
  }
  
  func extractYear(from dateString: String) -> Int? {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set the locale to ensure consistent date parsing
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set the timezone to GMT for consistent results

      // Define an array of date formats to try
      let dateFormats = [
          "yyyy/M/d",
          "yyyy",
          "yyyy-MM",
          "yyyy-MM-d"
          // Add more formats if needed
      ]

      // Loop through each date format and attempt to parse the date
      for format in dateFormats {
          dateFormatter.dateFormat = format
          if let date = dateFormatter.date(from: dateString) {
              // Date successfully parsed, extract the year
              let calendar = Calendar.current
              let year = calendar.component(.year, from: date)
              return year
          }
      }

      // Unable to parse the date with any of the specified formats
      return nil
  }

  // Example usage:
 
  
  func getDescription(gameID: String, platID: String) async throws -> (String, [Data], String, String, String, String, Int64) {
    var screenshots: [Data] = []
    
    let getDescURL = URL(string: "https://api.mobygames.com/v1/games/\(gameID)?format=normal&api_key=moby_tWADxWI4LPPc4Sze3gF4w8cb9Mi")!
    
    let (data, _) = try await URLSession.shared.data(from: getDescURL)
    
    let test = String(data: data, encoding: .utf8) as String?
    let dict = test?.toJSON() as? [String: AnyObject]
    
    let desc = dict?["description"] as? String
    var base_genre: String = ""
    var perspectives: [String] = []
    var releaseYear: Int64 = 0
    
    if let platforms = dict?["platforms"] as? [[String: Any]] {
      for plat in platforms {
        if plat["platform_id"] as? Int == Int(platID) {
          print("MATCHED PLAT ID!!!!!")
          if let year = extractYear(from: (plat["first_release_date"] as? String)!) {
            print("Year: \(year)")
            releaseYear = Int64(year)
          } else {
              print("Unable to extract year.")
          }
          print()
        }
      }
    }
    
    var gameplaycats: [String] = []
    if let genres = dict?["genres"] as? [[String: Any]] {
      for genre in genres {
        let basecat = genre["genre_category"] as? String
        if basecat == "Basic Genres" {
          base_genre = genre["genre_name"] as? String ?? "Not Available"
        }
        
        if basecat == "Perspective" {
          perspectives.append(genre["genre_name"] as? String ?? "Not Available")
        }
        
        else {
          gameplaycats.append(genre["genre_name"] as? String ?? "Not Available")
        }
        
      }
    } else {
      print("Genres is nil or not in the expected format.")
    }
    
    let perspective = (perspectives.map{String($0)}.joined(separator: ", "))
    
    let gameplay = gameplaycats.map{String($0)}.joined(separator: ", ")
    
    if let sampleScreenshots = dict?["sample_screenshots"] as? [AnyObject] {
      for object in sampleScreenshots {
        if let screenshotDict = object as? [String: Any] {
          for (key, value) in screenshotDict {
            if key == "image" {
              if let urlString = value as? String, let url = URL(string: urlString) {
                do {
                  if let imageData = try? Data(contentsOf: url) {
                    screenshots.append(imageData)
                  }
                }
              }
            }
          }
        }
      }
    }
    
    let title = dict?["title"] as? String
    return (desc!, screenshots, title!, base_genre, perspective, gameplay, releaseYear)
  }
  
  func getCoverArt(gameID: String, platformID: String) async throws -> (URL?, URL?) {
    let getDescURL = URL(string: "https://api.mobygames.com/v1/games/\(gameID)/platforms/\(platformID)/covers?format=normal&api_key=moby_tWADxWI4LPPc4Sze3gF4w8cb9Mi")!
    
    let (data, _) = try await URLSession.shared.data(from: getDescURL)
    
    let test = String(data: data, encoding: .utf8)
    
    guard let jsonData = test?.data(using: .utf8) else {
      throw UnknownError.unknown(description: "Error getting json data from cover art request")
    }
    
    do {
      let responseData = try JSONDecoder().decode(ResponseData.self, from: jsonData)
      
      if let firstCoverGroup = responseData.cover_groups.first,
         let firstCover = firstCoverGroup.covers.first {
        let coverURL = firstCover.image
        return (coverURL, firstCoverGroup.covers[1].image)
      } else {
        return (nil, nil) // No cover URL found
      }
    } catch {
      print("Error decoding JSON: \(error)")
      //throw SomeError("Error decoding JSON")
    }
    return (nil, nil)
  }
}
