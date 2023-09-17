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
  
  func buildGame(gameID: String, platformID: String, completion: @escaping (Data?) -> Void) -> Void {
    
    
    if let entityDescription = NSEntityDescription.entity(forEntityName: "Game", in: CoreDataManager.shared.persistentStoreContainer.viewContext) {
      let newPerson = NSManagedObject(entity: entityDescription, insertInto: nil) as! Game // Assuming "Person" is your NSManagedObject subclass
      
      newPerson.desc = "John Doe"
      newPerson.title = "Test Title"
      newPerson.moby_id = Int64(gameID) ?? 0

      getDescription(gameID: gameID){ desc, screenshots in
        newPerson.desc = desc
        newPerson.screenshots = screenshots
      }

      // Prevent API throttling. This is an issue, we something async, loading icon on homescreen until
      // ALL info if fetched.
      do {
        sleep(2)
      }
      
      getCoverArt(gameID: gameID, platformID: platformID) { url, backurl in
        
        if let data = try? Data(contentsOf: url!) {
          // Create Image and Update Image View
          newPerson.cover_art = data

          if let data = try? Data(contentsOf: backurl!) {
            newPerson.back_cover_art = data
          }

          let context =  CoreDataManager.shared.persistentStoreContainer.viewContext
          context.perform {
            context.insert(newPerson)
          }

          // Should this completion be called here? Why not try async/await instead of callback hell
          completion(data)
        }

        do {
          try self.saveCoreDataContext()
        } catch UnknownError.unknown(let description) {
          // Handle the unknown error
          print("Unknown error occurred: \(description)")
        } catch {
          // Handle any other errors
          print("An error occurred: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func getDescription(gameID: String, completionBlock: @escaping (String, [Data]) -> Void) -> Void {

    var description: String = ""
    let get_desc_url = URL(string:"https://api.mobygames.com/v1/games/\(gameID)?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!
    
    let task2 = URLSession.shared.dataTask(with: get_desc_url) { data, response, error in
      if let _ = data {
        let test = String(data: data!, encoding: String.Encoding.utf8) as String?
        let dict = test?.toJSON() as? [String:AnyObject]
        
        guard let desc = dict!["description"] as? String? else {
          return
        }
        var screenshots: [Data] = []

        if let sampleScreenshots = dict!["sample_screenshots"] as? [AnyObject] {
          for object in sampleScreenshots {
            if let screenshotDict = object as? [String: Any] {
              for (key, value) in screenshotDict {
                if key == "image" {
                  if let urlString = value as? String, let url = URL(string: urlString) {
                    do {
                      try screenshots.append(Data(contentsOf: url))
                    }
                    catch {
                        // Handle the error when downloading the image
                        print("Error downloading image: \(error)")
                    }
                  }
                }
              }
            }
          }
        }

        description = desc!
        description = description.stripOutHtml()!.unescaped
        
        completionBlock(description, screenshots)

      } else if let error = error {
        print("HTTP Request Failed \(error)")
      }
    }
    
    task2.resume()
  }
  
  func getCoverArt(gameID: String, platformID: String, completionBlock: @escaping (URL?, URL?) -> Void) {
    let get_desc_url = URL(string:"https://api.mobygames.com/v1/games/\(gameID)/platforms/\(platformID)/covers?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!
    
    let task2 = URLSession.shared.dataTask(with: get_desc_url) { data, response, error in
      if let _ = data {
        let test = String(data: data!, encoding: String.Encoding.utf8) as String?
        if let jsonData = test?.data(using: .utf8) {
          do {
            let responseData = try JSONDecoder().decode(ResponseData.self, from: jsonData)
            
            if let firstCoverGroup = responseData.cover_groups.first,
               let firstCover = firstCoverGroup.covers.first {
              let coverURL = firstCover.image
              completionBlock(coverURL, firstCoverGroup.covers[1].image)
            } else {
              completionBlock(nil, nil) // No cover URL found
            }
          } catch {
            print("Error decoding JSON: \(error)")
            completionBlock(nil, nil) // Error occurred
          }
        } else if let error = error {
          print("HTTP Request Failed \(error)")
          completionBlock(nil, nil) // Error occurred
        }
      } else {
        completionBlock(nil, nil) // Error occurred
      }
    }
    
    task2.resume()
  }
}

    
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    func stripOutHtml() -> String? {
        do {
            guard let data = self.data(using: .unicode) else {
                return nil
            }
            let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            return attributed.string
        } catch {
            return nil
        }
    }

    private static let escapedChars = [
        (#"\0"#, "\0"),
        (#"\t"#, "\t"),
        (#"\n"#, "\n"),
        (#"\r"#, "\r"),
        (#"\""#, "\""),
        (#"\'"#, "\'"),
        (#"\\"#, "\\")
    ]
    var escaped: String {
        self.unicodeScalars.map { $0.escaped(asASCII: false) }.joined()
    }
    var asciiEscaped: String {
        self.unicodeScalars.map { $0.escaped(asASCII: true) }.joined()
    }
    var unescaped: String {
        var result: String = self
        String.escapedChars.forEach {
            result = result.replacingOccurrences(of: $0.0, with: $0.1)
        }
        return result
    }
}
