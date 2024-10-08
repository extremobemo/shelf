//
//  GameSheetView.swift
//  shelf-proj
//
//  Created by Bemo on 9/7/22.
//

import SwiftUI
import CoreData
import Foundation

struct AspectRatioImageView: View {
  let uiImage: UIImage
  private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
  
  var body: some View {
    GeometryReader { geo in
      ZStack {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .clipShape(RoundedRectangle(cornerRadius: 12))
       
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: geo.frame(in: .global).size.width, height: geo.frame(in: .global).size.height)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
          .background(.regularMaterial)
      }
    }
  }
}

struct GameSheetView: View {
  
  private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
  
  @Environment(\.dismiss) var dismiss
  @State private var assetType = 0
  var game: Game
  @State var textHeight: CGFloat = 0
  var body: some View {
    GeometryReader { geo in
      
      ScrollView(content: {
        VStack(alignment: .leading) {
          
          if let screenshots = game.screenshots, let physical_media = game.cover_art {
            if assetType == 0 {
              if physical_media.count > 1 {
                CoverKitView(front: UIImage(data: physical_media[0])!, back: UIImage(data: physical_media[1])!).frame(height: getCarouselHeight())
                      .frame(height: getCarouselHeight())
              } else {
                HStack {
                  Spacer()
                  Text("NTSC box art not available")
                  Spacer()
                }.frame(height: getCarouselHeight(), alignment: .center)
              }
            } else {
              if screenshots.count > 0 {
                CarouselView(images: screenshots)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                  .frame(height: geo.frame(in: .global).size.height)
                  .frame(maxHeight: getCarouselHeight())
              } else {
                HStack {
                  Spacer()
                  Text("Screenshots not available")
                  Spacer()
                }.frame(height: getCarouselHeight(), alignment: .center)
              }
            }
            
            Spacer().frame(height: 16)

            Picker("What is your favorite color?", selection: $assetType) {
                Text("Box").tag(0)
                Text("Screenshots").tag(1)
            }.pickerStyle(.segmented)
          }
          
          Spacer().frame(height: 24)
          
          Text("Information").font(.title).fontWeight(.bold).foregroundStyle(.white).padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
          Spacer()
          VStack {
            HStack {
              Text("Release").foregroundStyle(.white)
              Spacer()
              Text(String(game.releaseYear)).foregroundStyle(.white)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Divider()
            HStack {
              Text("Genre").foregroundStyle(.white)
              Spacer()
              Text(game.base_genre ?? "Not available").foregroundStyle(.white)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Divider()
            HStack {
              Text("Perspective").foregroundStyle(.white)
              Spacer()
              Text(game.perspective ?? "Not available").foregroundStyle(.white)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Divider()
            
            HStack(alignment: .top) {
              Text("Gameplay").foregroundStyle(.white)
              Spacer()
              Text(game.gameplayElems ?? "Not available").frame(width: 200, height: 48) //150 iphone, 350 ipad
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.white)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
          }.padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
          
          Spacer().frame(height: 16)
          
          Text("Description").font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(height: 24)
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
          
          AttributedText(game.desc!, HTMLFormatter(), delegate: nil)
          .frame(minHeight: 1)
          .padding(EdgeInsets(top: 0, leading: 12, bottom: 12, trailing: 8))
        }
        .padding(EdgeInsets(top: 0.0, leading: 12.0, bottom: 16.0, trailing: 12.0))
        .font(.subheadline)
        .foregroundStyle(.secondary)
        Text("Data provided by MobyGames.").font(.footnote).foregroundStyle(.gray)
      }).navigationTitle(game.title!).navigationBarTitleDisplayMode(.large).toolbar {
        ToolbarItem() {
          
          Menu {
            ShareLink(item: URL(string: "https://www.mobygames.com/game/" + String(game.moby_id))!)
            
           
              Button(action: {
                if let url = URL(string: "https://www.mobygames.com/game/" + String(game.moby_id)) {
                            UIApplication.shared.open(url)
                        }
              }) {
                HStack {
                  Text("View on MobyGames")
                  Image(systemName: "safari")
                }
              }
            
            
          } label: {
            Button(action: {  }) {
              Image(systemName: "ellipsis.circle")
            }
          }
        }
      }
      .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      
    }
  }
  
  private func getCarouselHeight() -> CGFloat {
    if idiom == .pad {
      return 550
    } else {
      return 300
    }
  }
}













protocol StringFormatter {
  func format(string: String) -> NSAttributedString?
}

struct AttributedText: UIViewRepresentable {
  typealias UIViewType = UITextView
  
  @State
  private var attributedText: NSAttributedString?
  private let text: String
  private let formatter: StringFormatter
  private var delegate: UITextViewDelegate?
  
  init(_ text: String, _ formatter: StringFormatter, delegate: UITextViewDelegate? = nil) {
    self.text = text
    self.formatter = formatter
    self.delegate = delegate
  }
  
  func makeUIView(context: Context) -> UIViewType {
    let view = ContentTextView()
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.contentInset = .zero
    view.textContainer.lineFragmentPadding = 0
    view.delegate = delegate
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = false
    view.invalidateIntrinsicContentSize()
    return view
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    guard let attributedText = attributedText else {
      generateAttributedText()
      return
    }
    
    uiView.attributedText = attributedText
    uiView.invalidateIntrinsicContentSize()
  }
  
  private func generateAttributedText() {
    guard attributedText == nil else { return }
    // create attributedText on main thread since HTML formatter will crash SwiftUI
    DispatchQueue.main.async {
      self.attributedText = self.formatter.format(string: self.text)
    }
  }
  
  /// ContentTextView
  /// subclass of UITextView returning contentSize as intrinsicContentSize
  private class ContentTextView: UITextView {
    override var canBecomeFirstResponder: Bool { false }
    
    override var intrinsicContentSize: CGSize {
      return CGSize(width: contentSize.width + textContainerInset.left + textContainerInset.right,
                    height: (contentSize.height + textContainerInset.top + textContainerInset.bottom) * 1.1)
    }
    
    init() {
      super.init(frame: .zero, textContainer: nil)
      setupAutoResizingMask()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAutoResizingMask() {
      autoresizingMask = [.flexibleHeight]
    }
  }}
class HTMLFormatter: StringFormatter {
  func format(string: String) -> NSAttributedString? {
    var final: NSAttributedString?
    guard let data = string.data(using: .utf8) else { return nil }
    do {
      let attributedText = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
      
      // Apply the font attribute to the entire attributed string
      let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
      mutableAttributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: attributedText.length))
      mutableAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: attributedText.length))
      
      
      // Create a range that covers the entire string
      
      final = mutableAttributedText.attributedSubstring(from:  NSRange(location: 0, length: mutableAttributedText.string.count))
      // Now use 'mutableAttributedText' for further use
    } catch {
      print("Error converting HTML data to attributed string: \(error)")
    }
    
    return final
  }
}
