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
      //let newGame = Game(context: CoreDataManager.shared.persistentStoreContainer.viewContext)
      
      getDescription(gameID: gameID){ desc in
        //print(desc)
      }
      
      getCoverArt(gameID: gameID, platformID: platformID) { url in
        
        if let data = try? Data(contentsOf: url!) {
          // Create Image and Update Image View
          newPerson.cover_art = data
          let context =  CoreDataManager.shared.persistentStoreContainer.viewContext
          context.perform {
            context.insert(newPerson)
          }
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
  
  func getDescription(gameID: String, completionBlock: @escaping (String) -> Void) -> Void {
    
    var description: String = ""
    let get_desc_url = URL(string:"https://api.mobygames.com/v1/games/\(gameID)?format=normal&api_key=PkyJXO8u7RGOkbno4uf3Aw==")!
    
    let task2 = URLSession.shared.dataTask(with: get_desc_url) { data, response, error in
      if let _ = data {
        let test = String(data: data!, encoding: String.Encoding.utf8) as String?
        let dict = test?.toJSON() as? [String:AnyObject]
        
        guard let desc = dict!["description"] as! String? else {
          return
        }
        
        description = desc
        
        description = description.stripOutHtml()!.unescaped
        
        completionBlock(description)
        
      } else if let error = error {
        print("HTTP Request Failed \(error)")
      }
    }
    
    //task2.resume()
  }
  
  func getCoverArt(gameID: String, platformID: String, completionBlock: @escaping (URL?) -> Void) {
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
              completionBlock(coverURL)
            } else {
              completionBlock(nil) // No cover URL found
            }
          } catch {
            print("Error decoding JSON: \(error)")
            completionBlock(nil) // Error occurred
          }
        } else if let error = error {
          print("HTTP Request Failed \(error)")
          completionBlock(nil) // Error occurred
        }
      } else {
        completionBlock(nil) // Error occurred
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
