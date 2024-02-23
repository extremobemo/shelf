//
//  DrawerView.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/16/23.
//

import Foundation
import SwiftUI
struct RootNavigationView: View {
  
  @ObservedObject private var shelfModel: ShelfModel
  private var platforms: [Shelf]
  private var shelves: [Shelf]
  
  let gamecount: String
  
  @State private var selectedGames: [Game] = []
  @State private var shelfName: String = ""
  @State private var presentAlert = false
  @State var showingScanner = false
  @State var selection: Shelf? = Shelf(name: "All", platform_id: 0, customShelf: nil)
  @State var showingSection1 = true
  @State var showingSection2 = true
  @State var selectingDestination = false
  
  @State var sortByYear = false
  @State var selectMode = false
  
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
    self.shelves = shelfModel.getAllCustomShelves()
    self.gamecount = String(shelfModel.games.count)
  }
    
  var body: some View {
    NavigationSplitView() {
      
      List(selection: $selection) {
        Section(){
          if showingSection1 {
            ForEach(platforms, id: \.self) { plat in
              HStack {
                Text(PlatformLookup.getPlaformName(platformID: plat.platform_id!) ?? "All")
                Spacer()
                Capsule()
                  .fill(Color(UIColor.systemGray5))
                  .overlay(
                    Text(String(self.shelfModel.getGameCountForPlatform(platform: plat.platform_id!)))
                      .font(.system(size: 12, weight: .medium))
                  )
                  .frame(width: 36, height: 24, alignment: .center)
                Image(systemName: "chevron.right")
              }
            }
          }
        } header: {
          Text("Catalogue")
        }
        
        Section(
        ){
          if showingSection2 {
            ForEach(shelves, id: \.self) { shelf in
              HStack {
                Text(shelf.name!).contextMenu {
                  Button(action: {
                    CoreDataManager.shared.persistentStoreContainer.viewContext.delete(shelf.customShelf!)
                    try? CoreDataManager.shared.persistentStoreContainer.viewContext.save()
                    CoreDataManager.shared.persistentStoreContainer.viewContext.refreshAllObjects()
                  }) {
                    Text("Delete")
                  }
                  
                  Button(action: {
                    // Action for Rename button
                  }) {
                    Text("Rename")
                  }
                }
                Spacer()
                Capsule()
                  .fill(Color(UIColor.systemGray5))
                  .overlay(
                    Text(String(shelf.customShelf?.game_ids?.count ?? 0))
                      .font(.system(size: 12, weight: .medium))
                  )
                  .frame(width: 36, height: 24, alignment: .center)
                Image(systemName: "chevron.right")
              }
            }
                }
        } header: {
          Text("Custom Shelves")
        }
      }
      .navigationTitle("Shelf").toolbar {
        ToolbarItem() {
          Menu {
            Button(action: {
              presentAlert = true
            }) {
              HStack {
                Text("New Shelf")
                Image(systemName: "plus")
              }
            }
          } label: {
            Button(action: {
              presentAlert = true
            }) {
              Image(systemName: "list.dash")
            }.alert("Create new", isPresented: $presentAlert, actions: {
              // Any view other than Button would be ignored
              TextField("Custom Name", text: $shelfName)
              Button("Cancel", action: {})
              Button("Create", action: {
                Task {
                  await shelfModel.createNewShelf(shelfName: shelfName)
                }
              })
          }, message: {
              // Any view other than Text would be ignored
              //TextField("TextField", text: .constant("Enter name for custom shelf"))
          })
          }
        }
      }.listStyle(.sidebar)
    }
  detail: {
    CatalogueView(shelfModel: shelfModel,
                  shelf: selection ?? Shelf(name: nil, platform_id: nil, customShelf: nil),
                  showingScanner: $showingScanner,
                  selectMode: $selectMode,
                  sortByYear: $sortByYear,
                  selectedGames: $selectedGames).navigationTitle((PlatformLookup.getPlaformName(platformID:
                                                                                            selection?.platform_id ?? 0) ?? selection?.customShelf?.name) ?? "All").toolbar {
      ToolbarItem() {
        Menu {
          
          if !selectMode {
            Button(action: {
              showingScanner = true
            }) {
              HStack {
                Text("Scan Game")
                Image(systemName: "barcode.viewfinder")
              }
              
            }
            
            Button(action: {
              selectMode = true
            }) {
              HStack {
                Text("Select")
                Image(systemName: "checkmark.circle")
              }
              
            }
            
            Button(action: {
              sortByYear = !sortByYear
            }) {
              HStack {
                Text("Sort by Year")
                Image(systemName: "calendar.day.timeline.leading")
              }
            }
          } else {
            Button(role: .destructive) {
              selectMode = false
            } label: {
              Text("Cancel")
          }
          
          Button(action: {
            sortByYear = !sortByYear
          }) {
            HStack {
              Text("Sort by Year")
              Image(systemName: "calendar.day.timeline.leading")
            }
          }
            Button(action: {
              selectingDestination = true
            }) {
              HStack {
                Text("Add to...")
                Image(systemName: "plus")
              }
              
            }
        }

        } label: {
          Button(action: { }) {
            Image(systemName: "ellipsis.circle")
          }
        }
        .id(UUID())
      }
    }
  }.sheet(isPresented: $selectingDestination) {
    NavigationView {
        VStack {
          List(){
            ForEach(shelves, id: \.self) { shelf in
              Button(action: {
                shelfModel.addGamesToShelf(shelf: shelf, games: selectedGames)
                selectingDestination = false
                selectMode = false
              }) {
                HStack {
                  Text(shelf.name!)
                  Spacer()
                  Image(systemName: "plus")
                }
              }
            }
          }
        }
        .navigationTitle("Add to...")
        .navigationBarItems(trailing: Button("Cancel",
                                             action: {}))
    }

  }
  }
  
}

