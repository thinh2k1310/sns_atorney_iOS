//
//  DebugLog.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import Foundation
final class log {
    class func verbose(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension

        let cutFuntionName = function.firstIndex(of: "(")
        if let cutFuntionName = cutFuntionName {
            let functionName = function[..<cutFuntionName]
            print(" 💜 VERBOSE \(className):\(line) 🔹 \(functionName) 🔸 \(message)")
        } else {
            print(" 💜 VERBOSE \(className):\(line) 🔹 nil 🔸 \(message)")
        }
    }

    class func debug(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension

        let cutFuntionName = function.firstIndex(of: "(")
        if let cutFuntionName = cutFuntionName {
            let functionName = function[..<cutFuntionName]
            print(" 💚 DEBUG \(className):\(line) 🔹 \(functionName) 🔸 \(message)")
        } else {
            print(" 💚 DEBUG \(className):\(line) 🔹 nil 🔸 \(message)")
        }
    }

    class func info(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension

        let cutFuntionName = function.firstIndex(of: "(")
        if let cutFuntionName = cutFuntionName {
            let functionName = function[..<cutFuntionName]
            print(" 💙 INFO \(className):\(line) 🔹 \(functionName) 🔸 \(message)")
        } else {
            print(" 💙 INFO \(className):\(line) 🔹 nil 🔸 \(message)")
        }
    }

    class func warning(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension

        let cutFuntionName = function.firstIndex(of: "(")
        if let cutFuntionName = cutFuntionName {
            let functionName = function[..<cutFuntionName]
            print(" 💛 WARNING \(className):\(line) 🔹 \(functionName) 🔸 \(message)")
        } else {
            print(" 💛 WARNING \(className):\(line) 🔹 nil 🔸 \(message)")
        }
    }

    class func error(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension

        let cutFuntionName = function.firstIndex(of: "(")
        if let cutFuntionName = cutFuntionName {
            let functionName = function[..<cutFuntionName]
            print(" ❤️ ERROR \(className):\(line) 🔹 \(functionName) 🔸 \(message)")
        } else {
            print(" ❤️ ERROR \(className):\(line) 🔹 nil 🔸 \(message)")
        }
    }

    class func DLog(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension

        let cutFuntionName = function.firstIndex(of: "(")
        if let cutFuntionName = cutFuntionName {
            let functionName = function[..<cutFuntionName]
            NSLog("DEBUGG \(className):\(line) 🔹 \(functionName) 🔸 \(message)")
        } else {
            NSLog("DEBUGG \(className):\(line) 🔹 nil 🔸 \(message)")
        }
    }
}
