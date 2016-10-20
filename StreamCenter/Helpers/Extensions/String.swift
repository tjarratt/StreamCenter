//
//  String.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-24.

import UIKit
import Foundation

extension String {
    func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.index(utf16.startIndex,
                                 offsetBy: nsRange.location,
                                 limitedBy: utf16.endIndex) ?? utf16.endIndex
        let to16 = from16.advanced(by: nsRange.length)

        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
}

extension String {
    subscript (r : NSRange) -> String {
        get {
            return self[rangeFromNSRange(r)!]
        }
    }
}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let subStart = characters.index(self.startIndex,
                                       offsetBy: r.lowerBound,
                                       limitedBy: self.endIndex) ?? self.endIndex
            let subEnd = characters.index(subStart,
                                          offsetBy: r.upperBound - r.lowerBound,
                                          limitedBy: self.endIndex) ?? self.endIndex

            let range : Range = subStart ..< subEnd
            return self.substring(with: range)
        }
    }
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    func substring(_ from: Int) -> String {
        let end = self.characters.count
        return self[from..<end]
    }
    func substring(_ from: Int, length: Int) -> String {
        let end = from + length + 1
        return self[from..<end]
    }
}

extension String {
    func toUIColorFromHex() -> UIColor {
        return UIColor(hexString: self)
    }
}

extension String {
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
}

extension String {
    static func randomStringWithLength(_ len: Int) -> String {
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString = ""

        for _ in (0 ..< len) {
            let length = UInt32(letters.characters.count)
            let rand = Int(arc4random_uniform(length))
            randomString.append(letters[letters.characters.index(letters.startIndex, offsetBy: rand)])
        }
        
        return randomString
    }
}

extension String {
    func sanitizedIRCString() -> String {
        //https://github.com/ircv3/ircv3-specifications/blob/master/core/message-tags-3.2.md#escaping-values
        return self
            .replacingOccurrences(of: "\\:", with: ";")
            .replacingOccurrences(of: "\\s", with: "")
            .replacingOccurrences(of: "\\\\", with: "\\")
            .replacingOccurrences(of: "\\r", with: "\r")
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
