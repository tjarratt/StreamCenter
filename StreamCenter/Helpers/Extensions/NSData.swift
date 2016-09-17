//
//  NSData.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-17.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

extension Data {
    func hasSuffix(bytes: [UInt8]) -> Bool {
        if self.count < bytes.count { return false }
        let ptr = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        for (i, byte) in bytes.enumerated() {
            if ptr[self.count - bytes.count + i] != byte {
                return false
            }
        }
        return true
    }
}

extension NSMutableData {
    func appendBytes(bytes: [UInt8]) {
        if bytes.count > 0 {
            self.append(UnsafePointer<UInt8>(bytes), length: bytes.count)
        }
    }
    
    func replaceBytesInRange(_ range : NSRange, bytes : [UInt8]) {
        let ptr = UnsafePointer<UInt8>(bytes)
        self.replaceBytes(in: range, withBytes: ptr, length: bytes.count)
    }
}
