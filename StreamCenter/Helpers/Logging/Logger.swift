//
//  Logger.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-28.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

struct Logger {
    static let dateFormatter = DateFormatter(format: "HH:mm:ss")
    static var level : LogLevel = .error
    
    static func Info<Object>(_ object : Object, _ file : String = #file, _ function : String = #function, _ line : Int = #line) {
        let level = LogLevel.info
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.lightGreen("\t>> \(text)\n"), terminator: "")
        }
        
    }
    
    static func Debug<Object>(_ object : Object, _ file : String = #file, _ function : String = #function, _ line : Int = #line) {
        let level = LogLevel.debug
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.green("\t>> \(text)\n"), terminator: "")
        }
    }
    
    static func Warning<Object>(_ object : Object, _ file : String = #file, _ function : String = #function, _ line : Int = #line) {
        let level = LogLevel.warning
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.yellow("\t>> \(text)\n"), terminator: "")
        }
    }
    
    static func Error<Object>(_ object : Object, _ file : String = #file, _ function : String = #function, _ line : Int = #line) {
        let level = LogLevel.error
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.orange("\t>> \(text)\n"), terminator: "")
        }
    }
    
    static func Severe<Object>(_ object : Object, _ file : String = #file, _ function : String = #function, _ line : Int = #line) {
        let level = LogLevel.severe
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.red("\t>> \(text))\n"), terminator: "")
        }
    }
    
    fileprivate static func getPrefix(_ file : String, function : String, line : Int) -> String {
        let label = String(validatingUTF8 : __dispatch_queue_get_label(nil))!
        let time = dateFormatter.string(from: Date())
        
        return "[\(time)] @\(label) - \(file.fileName).\(function) - [\(line)]\n"
    }
    
    fileprivate static func escapeAndPrettify<Object>(_ object : Object) -> String {
        var s = "\(object)"
        
        if s.hasSuffix("\r\n"){
            s = s[0..<s.characters.count - 1]
        }
        
        if s.hasSuffix("\n"){
            s = s[0..<s.characters.count]
        }
        
        return s.replacingOccurrences(of: "\n", with: "\n\t>> ")
    }
    
}

enum LogLevel : Int {
    case info = 1,
    debug,
    warning,
    error,
    severe
}

func > (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue > right.rawValue
}
func >= (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue >= right.rawValue
}
func < (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue < right.rawValue
}
func <= (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue <= right.rawValue
}

private struct ColorLog {
    fileprivate static let ESCAPE = "\u{001b}["
    fileprivate static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    fileprivate static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    fileprivate static let RESET = ESCAPE + ";"      // Clear any foreground or background color
    
    static func infoColor<T>(_ object:T) -> String {
        return "\(ESCAPE)fg120,120,120;\(object)\(RESET)"
    }
    
    static func purple<T>(_ object:T) -> String {
        return "\(ESCAPE)fg160,32,240;\(object)\(RESET)"
    }
    
    static func lightGreen<T>(_ object:T) -> String {
        return "\(ESCAPE)fg0,180,180;\(object)\(RESET)"
    }
    
    static func green<T>(_ object:T) -> String {
        return "\(ESCAPE)fg0,150,0;\(object)\(RESET)"
    }
    
    static func yellow<T>(_ object:T) -> String {
        return "\(ESCAPE)fg255,190,0;\(object)\(RESET)"
    }
    
    static func orange<T>(_ object:T) -> String {
        return "\(ESCAPE)fg255,128,0;\(object)\(RESET)"
    }
    
    static func red<T>(_ object:T) -> String {
        return "\(ESCAPE)fg255,0,0;\(object)\(RESET)"
    }
    
}


private extension String {
    
    var ns : NSString {
        return self as NSString
    }
    var fileName: String {
        return self.ns.lastPathComponent.ns.deletingPathExtension
    }
    
}
