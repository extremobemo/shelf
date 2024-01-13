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

  enum UnknownError: Error {
    case unknown(description: String)
  }

  func saveCoreDataContext() throws {
    let context = CoreDataManager.shared.persistentStoreContainer.viewContext

    do {
      try context.save()
    } catch let error {
      // Catch the specific Core Data error and rethrow it as an unknown error
      throw UnknownError.unknown(description: "Core Data save error: \(error.localizedDescription)")
    }
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

    func buildGame(gameID: String, platformID: String, platformString: String) async -> Void {

    if let entityDescription = NSEntityDescription.entity(forEntityName: "Game", in: CoreDataManager.shared.persistentStoreContainer.viewContext) {
      let newGame = NSManagedObject(entity: entityDescription, insertInto: nil) as! Game
      newGame.desc = "Test Description"
      newGame.title = "Test Title"
      newGame.moby_id = Int64(gameID) ?? 0
      newGame.platform_id = platformID

      do {
        let descriptionItems = try await getDescription(gameID: gameID)
        do { sleep(2) } // Prevent API throttling
        let coverArtItems = try await getCoverArt(gameID: gameID, platformID: platformID)

        newGame.title = descriptionItems.2
        newGame.base_genre = descriptionItems.3
        newGame.desc = descriptionItems.0
        newGame.screenshots = descriptionItems.1
        newGame.cover_art = try? Data(contentsOf: coverArtItems.0!)
        newGame.back_cover_art = try? Data(contentsOf: coverArtItems.1!)

        let context =  CoreDataManager.shared.persistentStoreContainer.viewContext
        await context.perform {
          context.insert(newGame)
        }
        try self.saveCoreDataContext()
      } catch {
        // UnknownError.unknown(description: "Error building CoreData Game object")
      }
    }
  }

  func getGameplayInfo(gameID: String) async throws -> (String) {
    var description: String = ""
    var screenshots: [Data] = []

    let getDescURL = URL(string: "https://api.mobygames.com/v1/games/\(gameID)?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!

    let (data, _) = try await URLSession.shared.data(from: getDescURL)

    let test = String(data: data, encoding: .utf8) as String?
    let dict = test?.toJSON() as? [String: AnyObject]

    let desc = dict?["genres"] as? String // else {
    //      throw UnknownError.unknown(description: "Description not found")
    //    }
    return ""
  }

  func getDescription(gameID: String) async throws -> (String, [Data], String, String) {
    var description: String = ""
    var screenshots: [Data] = []

    let getDescURL = URL(string: "https://api.mobygames.com/v1/games/\(gameID)?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!

    let (data, _) = try await URLSession.shared.data(from: getDescURL)

    let test = String(data: data, encoding: .utf8) as String?
    let dict = test?.toJSON() as? [String: AnyObject]

    let desc = dict?["description"] as? String // else {
//      throw UnknownError.unknown(description: "Description not found")
//    }
    let genres = dict?["genres"] as? [[String: Any]]

    
    var base_genre: String = ""
    var perspective: String = ""

    var gameplaycats: [String] = []
    if let genres = dict?["genres"] as? [[String: Any]] {
        for genre in genres {
          let basecat = genre["genre_category"] as? String
            if basecat == "Basic Genres" {
              base_genre = genre["genre_name"] as? String ?? "Not Available"
            }

          if basecat == "Perspective" {
            perspective = genre["genre_name"] as? String ?? "Not Available"
          }

          if basecat == "Gameplay" {
            gameplaycats.append(genre["genre_name"] as? String ?? "Not Available")
          }

        }
    } else {
        print("Genres is nil or not in the expected format.")
    }

    print(base_genre)
    print(perspective)

    print(gameplaycats)

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

    description = desc?.stripOutHtml()!.unescaped ?? ""
    let title = dict?["title"] as? String
    return (description, screenshots, title!, base_genre)
  }

  func getCoverArt(gameID: String, platformID: String) async throws -> (URL?, URL?) {
    let getDescURL = URL(string: "https://api.mobygames.com/v1/games/\(gameID)/platforms/\(platformID)/covers?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!

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
