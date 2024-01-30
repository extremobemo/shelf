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
        let descriptionItems = try await getDescription(gameID: gameID)
        do { sleep(1) } // Prevent API throttling
        let coverArtItems = try await getCoverArt(gameID: gameID, platformID: platformID)
        
        newGame.desc = descriptionItems.0
        newGame.screenshots = descriptionItems.1
        newGame.title = descriptionItems.2
        newGame.base_genre = descriptionItems.3
        newGame.perspective = descriptionItems.4
        newGame.gameplayElems = descriptionItems.5
        newGame.cover_art = try? Data(contentsOf: coverArtItems.0!)
        newGame.back_cover_art = try? Data(contentsOf: coverArtItems.1!)
        
        await self.context.perform {
          self.context.insert(newGame)
        }
        
        try self.context.save()
      } catch {
        // UnknownError.unknown(description: "Error building CoreData Game object")
      }
    }
  }
  
  func getDescription(gameID: String) async throws -> (String, [Data], String, String, String, String) {
    var screenshots: [Data] = []
    
    let getDescURL = URL(string: "https://api.mobygames.com/v1/games/\(gameID)?format=normal&api_key=moby_tWADxWI4LPPc4Sze3gF4w8cb9Mi")!
    
    let (data, _) = try await URLSession.shared.data(from: getDescURL)
    
    let test = String(data: data, encoding: .utf8) as String?
    let dict = test?.toJSON() as? [String: AnyObject]
    
    let desc = dict?["description"] as? String
    var base_genre: String = ""
    var perspectives: [String] = []
    
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
    return (desc!, screenshots, title!, base_genre, perspective, gameplay)
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
