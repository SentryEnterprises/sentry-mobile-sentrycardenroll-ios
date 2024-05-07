//
//  APDUCommands.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/7/24.
//

import Foundation

/**
 Encapsulates the various `APDU` command bytes used throughout the SDK.
 */
enum APDUCommands {
    static let selectCommand: [UInt8] = [0x00, 0xA4, 0x04, 0x00, 0x09, 0x49, 0x44, 0x45, 0x58, 0x5F, 0x4C, 0x5F, 0x01, 0x01, 0x00]
    static let setPT1Command: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x08, 0x01, 0x03]
    static let setEnrollCommand: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x13, 0x01, 0xCB]
    static let setLimitCommand: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x15, 0x01, 0xFF]
    static let setStoreCommand: [UInt8] = [0x80, 0xE2, 0x88, 0x00, 0x00]
    static let getEnrollStatusCommand: [UInt8] = [0x00, 0x59, 0x04, 0x00, 0x01, 0x00]
    static let getBiometricVerifyCommand: [UInt8] = [0xED, 0x56, 0x00, 0x00, 0x01, 0x00]
    static let processFingerprintCommand: [UInt8] = [0x00, 0x59, 0x03, 0x00, 0x02, 0x00, 0x01]
    static let verifyCommand: [UInt8] = [0x00, 0x59, 0x00, 0x00, 0x01, 0x00]
    
    static func verifyPINCommand(pin: [UInt8]) throws -> [UInt8] {
        var verifyPINCommand: [UInt8] = [0x80, 0x20, 0x00, 0x80, 0x08]
        try verifyPINCommand.append(contentsOf: constructPINBuffer(pin: pin))
        return verifyPINCommand
    }

    static func setPINCommand(pin: [UInt8]) throws -> [UInt8] {
        var setPINCommand: [UInt8] = [ 0x80, 0xE2, 0x08, 0x00, 0x0B, 0x90, 0x00, 0x08]
        try setPINCommand.append(contentsOf: constructPINBuffer(pin: pin))
        return setPINCommand
    }

    /// Returns a padded buffer that contains the indicated PIN digits.
    private static func constructPINBuffer(pin: [UInt8]) throws -> [UInt8] {
        var bufferIndex = 1
        var PINBuffer: [UInt8] = [] // [0x80, 0x20, 0x00, 0x80, 0x08]
        PINBuffer.append(0x20 + UInt8(pin.count))
        PINBuffer.append(contentsOf: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        
        for index in 0..<pin.count {
            let digit = pin[index]
            if digit > 9 {
                throw BiometricsSDKError.pinDigitOutOfBounds
            }
            
            if index % 2 == 0 {
                PINBuffer[bufferIndex] &= 0x0F
                PINBuffer[bufferIndex] |= digit << 4
            } else {
                PINBuffer[bufferIndex] &= 0xF0
                PINBuffer[bufferIndex] |= digit
                bufferIndex = bufferIndex + 1
            }
        }

        return PINBuffer
    }
}
