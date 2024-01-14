//
//  String+Extensions.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/17/23.
//

import Foundation

extension String {

  private static let escapedChars = [
    (#"\0"#, "\0"),
    (#"\t"#, "\t"),
    (#"\n"#, "\n"),
    (#"\r"#, "\r"),
    (#"\""#, "\""),
    (#"\'"#, "\'"),
    (#"\\"#, "\\")
  ]

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
