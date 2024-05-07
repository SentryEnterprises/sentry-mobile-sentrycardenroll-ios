//
//  BiometricsSDK.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import Foundation
import CoreNFC

final class BiometricSDK {
    private typealias APDUReturnResult = (data: Data, statusWord: Int)

    
    func initializeEnroll(pin: [UInt8], tag: NFCISO7816Tag) async throws {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Initialize - PIN: \(pin)")
        
        if pin.count < 4 || pin.count > 6 {
            throw BiometricsSDKError.pinLengthOutOfBounds
        }
        
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Select Enroll Applet")
        try await sendAndConfirm(apduCommand: APDUCommands.selectCommand, to: tag)

        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Verify PIN")
        let returnData = try await send(apduCommand: APDUCommands.verifyPINCommand(pin: pin), to: tag)
        
        if returnData.statusWord == APDUResponseCodes.conditionOfUseNotSatisfied.rawValue {
            print("\n\n>>>>>>>>>>>>SentryBiometricSDK Set PIN")
            try await sendAndConfirm(apduCommand: APDUCommands.setPINCommand(pin: pin), to: tag)

            try await sendAndConfirm(apduCommand: APDUCommands.setPT1Command, to: tag)

            try await sendAndConfirm(apduCommand: APDUCommands.setEnrollCommand, to: tag)

            try await send(apduCommand: APDUCommands.setLimitCommand, to: tag)

            try await sendAndConfirm(apduCommand: APDUCommands.setStoreCommand, to: tag)
            
            // after setting the PIN, make sure the enrollment app is selected
            try await sendAndConfirm(apduCommand: APDUCommands.selectCommand, to: tag)
            
            // verify the PIN again
            try await sendAndConfirm(apduCommand: APDUCommands.verifyPINCommand(pin: pin), to: tag)
        } else {
            if returnData.statusWord != APDUResponseCodes.operationSuccessful.rawValue {
                throw BiometricsSDKError.apduCommandError(returnData.statusWord)
                //throw NSError(domain: "APDU Command Error", code: returnData.statusWord)
            }
        }
    }

    func getEnrollmentStatus(tag: NFCISO7816Tag) async throws -> BiometricEnrollmentStatus {
        print("\\n\n>>>>>>>>>>>>SentryBiometricSDK Get Enrollment Status")
        
        let returnData = try await send(apduCommand: APDUCommands.getEnrollStatusCommand, to: tag)
                
        let dataArray = returnData.data.withUnsafeBytes { bufferPtr in
            guard let srcPointer = bufferPtr.baseAddress else {
               return [UInt8]()
            }

            //Bind the memory to the type
            let count = bufferPtr.count
            let typedPointer: UnsafePointer<UInt8> = srcPointer.bindMemory(to: UInt8.self, capacity: count)
            let buffer = UnsafeBufferPointer(start: typedPointer, count: count)
            return Array<UInt8>(buffer)
        }
        
        if dataArray.count < 40 {
            throw BiometricsSDKError.enrollmentStatusBufferTooSmall
        }
        
        let maxNumberOfFingers = dataArray[31]
        let enrolledTouches = dataArray[32]
        let remainingTouches = dataArray[33]
        let mode = dataArray[39]

        let biometricMode: BiometricMode = mode == 0 ? .enrollment : .verification
        
        return BiometricEnrollmentStatus(
            maximumFingers: maxNumberOfFingers,
            enrolledTouches: enrolledTouches,
            remainingTouches: remainingTouches,
            mode: biometricMode
        )
    }
    
    func getBiometricVerification(tag: NFCISO7816Tag) async throws -> Bool {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Get Biometric Verification")
        
        let returnData = try await send(apduCommand: APDUCommands.getBiometricVerifyCommand, to: tag)
        
        if returnData.statusWord == APDUResponseCodes.operationSuccessful.rawValue {
            return true
        }
        
        if returnData.statusWord == APDUResponseCodes.noMatchFound.rawValue {
            return false
        }
        
        //throw NSError(domain: "Validate Fingerprint Error.", code: Int(returnData.statusWord))
        throw BiometricsSDKError.apduCommandError(returnData.statusWord)
    }

    func enrollScanFingerprint(tag: NFCISO7816Tag) async throws -> UInt8 {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Enroll fingerprint")
        
        // note: the last byte indicates the finger number; this will need updating if/when 2 fingers are supported
        try await sendAndConfirm(apduCommand: APDUCommands.processFingerprintCommand, to: tag)
        
        let enrollmentStatus = try await getEnrollmentStatus(tag: tag)
        return enrollmentStatus.remainingTouches
    }
    
    // used only during the enrollment process
    func verifyEnrolledFingerprint(tag: NFCISO7816Tag) async throws {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Verify Enroll")
        try await sendAndConfirm(apduCommand: APDUCommands.verifyCommand, to: tag)
    }

    @discardableResult private func sendAndConfirm(apduCommand: [UInt8], to tag: NFCISO7816Tag) async throws -> APDUReturnResult {
        let returnData = try await send(apduCommand: apduCommand, to: tag)
        
        if returnData.statusWord != APDUResponseCodes.operationSuccessful.rawValue {
            throw BiometricsSDKError.apduCommandError(returnData.statusWord)
            //throw NSError(domain: "APDU Command Error", code: result.statusWord)
        }

        return returnData
    }
    
    @discardableResult private func send(apduCommand: [UInt8], to tag: NFCISO7816Tag) async throws -> APDUReturnResult {
        print("\n\n---------- Sending -----------")
        
        let data = Data(apduCommand)
        print(">>> Tag Sending => \(data.toHex())")
        
        guard let command = NFCISO7816APDU(data: data) else {
            throw BiometricsSDKError.invalidAPDUCommand
        }
        
        let result = try await tag.sendCommand(apdu: command)
        
        let resultData = result.0 + Data([result.1]) + Data([result.2])
        print("<<< Tag Received <= \(resultData.toHex())")
        
        let statusWord: Int = Int(result.1) << 8 + Int(result.2)
        return APDUReturnResult(data: result.0, statusWord: statusWord)
    }
}

/**
 Helper extension to print a data buffer as a hexadecimal string.
 */
extension Data {
    /**
     Prints the data buffer as a hexadecimal string.
     */
    func toHex() -> String {
        map { return String(format:"%02X", $0) }.joined(separator: "").uppercased()
    }
}
