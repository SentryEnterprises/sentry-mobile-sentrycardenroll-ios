//
//  BiometricsSDK.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import SentryBiometricSDK
import Foundation
import CoreNFC

enum SwiftCallbackError: Int32 {
    case dataInIsNil = -1
    case invalidAPDUData = -2
    case sendCommandError = -3
}


final class BiometricSDK {
   // private typealias SmartCardCallback = (UnsafePointer<UInt8>?, UInt32, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt32>) -> Void
    
    private typealias APDUReturnResult = (data: Data, statusWord: Int)

    /// Reason for this property and method to be static - is compatability with C-closures.
    /// We call `LibSdkInit` each time before calling some JCWWallet library method, and pass callback to handle command
    /// This callback is `@convention(c)` callback, that restricts other context in it (such as Swift classes)
    /// For this, to avoid such restriction - this method that is used in `convention(c)` callback - made Global to not depend on Swift entities
    private static var tag: NFCISO7816Tag?
    
    private let isSecure: Bool

    public init(isSecure: Bool) {
        self.isSecure = isSecure
    }


    private static func swiftCallback(_ dataIn: UnsafeMutablePointer<UInt8>?, _ dataInLen: UInt32, _ dataOut: UnsafeMutablePointer<UInt8>?, _ dataOutLen: UnsafeMutablePointer<UInt32>?) -> Int32 {
        // sanity check to make sure the incoming data buffer isn't nil
        guard let dataIn = dataIn else {
            return SwiftCallbackError.dataInIsNil.rawValue
        }

        var returnStatus: Int32 = 0
        let semaphore = DispatchSemaphore(value: 0)
        let dataInArray = Array(UnsafeBufferPointer(start: dataIn, count: Int(dataInLen)))
        let data = Data(dataInArray)

        // print the data being sent as a hexadecimal string
        print(">>> Tag Sending => \(data.toHex())")


        guard let command = NFCISO7816APDU(data: data) else {
            return SwiftCallbackError.invalidAPDUData.rawValue
        }

        tag?.sendCommand(apdu: command) { response, sw1, sw2, error in
            let data = response + Data([sw1]) + Data([sw2])

            if let error = error {
                print(">>> Tag Send ERROR: \(error)")
                if let nfcError = error as? NFCReaderError {
                    returnStatus = Int32(nfcError.code.rawValue)
                } else {
                    returnStatus = SwiftCallbackError.sendCommandError.rawValue
                }
                print(error.localizedDescription)

            } else {
                dataOutLen?.pointee = UInt32(data.count)

                for (index, byte) in data.enumerated() {
                    dataOut?.advanced(by: index).pointee = byte
                }

                print("<<< Tag Received <= \(data.toHex())")
                semaphore.signal()
            }

            semaphore.signal()
        }

        semaphore.wait()

        return returnStatus
    }

    
    
    
//    private func selectEnrollApplet(tag: NFCISO7816Tag) async throws {
//        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Select Enroll Applet")
//        let selectCommand: [UInt8] = [0x00, 0xA4, 0x04, 0x00, 0x09, 0x49, 0x44, 0x45, 0x58, 0x5F, 0x4C, 0x5F, 0x01, 0x01, 0x00]
//        try await sendAndConfirm(apduCommand: selectCommand, to: tag)
//    }
//    
//    private func setPIN(pin: [UInt8], tag: NFCISO7816Tag) async throws {
//        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Set PIN - \(pin)")
//        
//        var setPINCommand: [UInt8] = [ 0x80, 0xE2, 0x08, 0x00, 0x0B, 0x90, 0x00, 0x08]
//        
//        try setPINCommand.append(contentsOf: constructPINBuffer(pin: pin))
//        
////        int bufferPointer = 8;      // starts at the 9th byte of the apdu_set_pin buffer below
////        int returnValue;
////        uint8_t bufferByte;
////        uint8_t apdu_set_pin[] = { 0x80, 0xE2, 0x08, 0x00, 0x0B, 0x90, 0x00, 0x08, 0x2F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
////        
////        // the PIN must be 4 - 7 characters in length
////        if (len < 4) return _SDK_ERROR_PIN_LENGTH_INVALID_;
////        if (len > 8) return _SDK_ERROR_PIN_LENGTH_INVALID_;
////        
////        // embed the actual PIN digits within the apdu command
////        apdu_set_pin[bufferPointer++] = (uint8_t)(0x20 + len);
////        for (int i = 0; i < len; i++)
////        {
////            bufferByte = pin[i];
////            if (bufferByte > 0x09) _SDK_ERROR_PIN_DIGIT_INVALID_;    // PIN digits must be in the range 0 - 9
////            if ((i & 0x01) == 0)
////            {
////                apdu_set_pin[bufferPointer] &= 0x0F;
////                apdu_set_pin[bufferPointer] |= (bufferByte << 4);
////            }
////            else
////            {
////                apdu_set_pin[bufferPointer] &= 0xF0;
////                apdu_set_pin[bufferPointer++] |= bufferByte;
////            }
////        }
//
//        try await sendAndConfirm(apduCommand: setPINCommand, to: tag)
//        
////        let data = Data(setPINCommand)
////        print("<<< Tag Sending <= \(data.toHex())")
////        
////        guard let command = NFCISO7816APDU(data: data) else {
////            throw NFCReaderError(.readerErrorInvalidParameter)
////            //return SwiftCallbackError.invalidAPDUData.rawValue
////        }
////        
////        let result = try await tag.sendCommand(apdu: command)
////        
////        let statusCode: Int = Int(result.1) << 8 + Int(result.2)
////        
////        let resultData = result.0 + Data([result.1]) + Data([result.2])
////        print("<<< Tag Received <= \(resultData.toHex())")
////        
////        if statusCode != 0x9000 {
////            throw NSError(domain: "Set PIN Error", code: statusCode)
////        }
//
////        apdu_enroll_out_len = 0;
////        returnValue = apdu_secure_channel(apdu_set_pin, sizeof(apdu_set_pin), apdu_enroll_out, &apdu_enroll_out_len);
////     //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
////     //   Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0) return returnValue;
////        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0x9000) return returnValue;
//
//        let setPT1Command: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x08, 0x01, 0x03]
//        try await sendAndConfirm(apduCommand: setPT1Command, to: tag)
//        
////        uint8_t apdu_set_ptl[] = { 0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x08, 0x01, 0x03};
////        apdu_enroll_out_len = 0;
////        returnValue = apdu_secure_channel(apdu_set_ptl, sizeof(apdu_set_ptl), apdu_enroll_out, &apdu_enroll_out_len);
////    //    if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
////    //    Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0) return returnValue;
////        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0x9000) return returnValue;
//
//        let setEnrollCommand: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x13, 0x01, 0xCB]
//        try await sendAndConfirm(apduCommand: setEnrollCommand, to: tag)
//
////        uint8_t apdu_set_enroll[] = { 0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x13, 0x01, 0xCB };
////        apdu_enroll_out_len = 0;
////        returnValue = apdu_secure_channel(apdu_set_enroll, sizeof(apdu_set_enroll), apdu_enroll_out, &apdu_enroll_out_len);
////     //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
////    //    Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0) return returnValue;
////        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0x9000) return returnValue;
//
//        let setLimitCommand: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x15, 0x01, 0xFF]
//        try await send(apduCommand: setLimitCommand, to: tag)
//        
////        uint8_t apdu_set_enroll_limit[] = { 0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x15, 0x01, 0xFF };
////        apdu_enroll_out_len = 0;
////        returnValue = apdu_secure_channel(apdu_set_enroll_limit, sizeof(apdu_set_enroll_limit), apdu_enroll_out, &apdu_enroll_out_len);
////     //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
////     //   Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0) return returnValue;
////        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0x9000) return returnValue;
//
//        let setStoreCommand: [UInt8] = [0x80, 0xE2, 0x88, 0x00, 0x00]
//        try await sendAndConfirm(apduCommand: setStoreCommand, to: tag)
//        
////        uint8_t apdu_set_store[] = { 0x80, 0xE2, 0x88, 0x00, 0x00};
////        apdu_enroll_out_len = 0;
////        returnValue = apdu_secure_channel(apdu_set_store, sizeof(apdu_set_store), apdu_enroll_out, &apdu_enroll_out_len);
////     //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
////      //  Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
////        if (returnValue != 0) return returnValue;
////        
////        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
////        return returnValue;
//    }
//    
//    private func verifyPIN(pin: [UInt8], tag: NFCISO7816Tag) async throws -> APDUReturnResult {
//        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Verify PIN - \(pin)")
//        var verifyPINCommand: [UInt8] = [0x80, 0x20, 0x00, 0x80, 0x08]
//        try verifyPINCommand.append(contentsOf: constructPINBuffer(pin: pin))
//        return try await send(apduCommand: verifyPINCommand, to: tag)
//    }

    
    func initializeEnroll(pin: [UInt8], tag: NFCISO7816Tag) async throws {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Initialize - PIN: \(pin)")
        
        if pin.count < 4 || pin.count > 7 {
            // TODO: Change
            throw NFCReaderError(.readerErrorInvalidParameterLength)
        }
        
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Select Enroll Applet")
        let selectCommand: [UInt8] = [0x00, 0xA4, 0x04, 0x00, 0x09, 0x49, 0x44, 0x45, 0x58, 0x5F, 0x4C, 0x5F, 0x01, 0x01, 0x00]
        try await sendAndConfirm(apduCommand: selectCommand, to: tag)

        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Verify PIN")
        var verifyPINCommand: [UInt8] = [0x80, 0x20, 0x00, 0x80, 0x08]
        try verifyPINCommand.append(contentsOf: constructPINBuffer(pin: pin))
        let returnData = try await send(apduCommand: verifyPINCommand, to: tag)
        
        if returnData.statusWord == APDUResponseCodes.conditionOfUseNotSatisfied.rawValue {
            print("\n\n>>>>>>>>>>>>SentryBiometricSDK Set PIN")
            var setPINCommand: [UInt8] = [ 0x80, 0xE2, 0x08, 0x00, 0x0B, 0x90, 0x00, 0x08]
            try setPINCommand.append(contentsOf: constructPINBuffer(pin: pin))
            try await sendAndConfirm(apduCommand: setPINCommand, to: tag)

            let setPT1Command: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x08, 0x01, 0x03]
            try await sendAndConfirm(apduCommand: setPT1Command, to: tag)

            let setEnrollCommand: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x13, 0x01, 0xCB]
            try await sendAndConfirm(apduCommand: setEnrollCommand, to: tag)

            let setLimitCommand: [UInt8] = [0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x15, 0x01, 0xFF]
            try await send(apduCommand: setLimitCommand, to: tag)

            let setStoreCommand: [UInt8] = [0x80, 0xE2, 0x88, 0x00, 0x00]
            try await sendAndConfirm(apduCommand: setStoreCommand, to: tag)
            
            // after setting the PIN, make sure the enrollment app is selected
            try await sendAndConfirm(apduCommand: selectCommand, to: tag)
            
            // verify the PIN again
            try await sendAndConfirm(apduCommand: verifyPINCommand, to: tag)
        }
        
//        do {
//            try await verifyPIN(pin: pin, tag: tag)
//        } catch (let error) {
//            let nsError = error as NSError
//            
//            // if the card responds with a 'condition not satisfied', then there isn't a PIN and we need to set one
//            if nsError.code == APDUResponseCodes.conditionOfUseNotSatisfied.rawValue {
//                try await setPIN(pin: pin, tag: tag)
//                try await selectEnrollApplet(tag: tag)
//                try await verifyPIN(pin: pin, tag: tag)
//            } else {
//                throw error
//            }
//        }

     /**
      
      int returnValue = lib_enroll_select();
      if (returnValue != 0x9000) return returnValue;
      
      // before we can get the enrollment status, we need to verify the PIN
      returnValue = lib_enroll_verify_pin(pin, len);
      if (returnValue == 0x6985)      // the applet returns 'conditions not satisfied' if there isn't a pin
      {
          // set the pin
          returnValue = lib_enroll_set_pin(pin, len);
          if (returnValue != 0x9000) return returnValue;
          
          // select the applet again
          returnValue = lib_enroll_select();
          if (returnValue != 0x9000) return returnValue;
          
          // verify the pin one more time
          returnValue = lib_enroll_verify_pin(pin, len);
      }

      
      */
    }

    func getEnrollmentStatus(tag: NFCISO7816Tag) async throws -> BiometricEnrollmentStatus {
        print("\\n\n>>>>>>>>>>>>SentryBiometricSDK Get Enrollment Status")
        
        let getEnrollStatusCommand: [UInt8] = [0x00, 0x59, 0x04, 0x00, 0x01, 0x00]
        let returnData = try await send(apduCommand: getEnrollStatusCommand, to: tag)
                
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
            // TODO:
            throw NSError(domain: "Data Error", code: -1)
        }
        
        let maxNumberOfFingers = dataArray[31]
        let enrolledTouches = dataArray[32]
        let remainingTouches = dataArray[33]
        let mode = dataArray[39]

        let biometricMode = BiometricMode(rawValue: mode)
        
        guard let biometricMode = biometricMode else {
            throw NSError(domain: "Unknown biometric mode", code: Int(mode))        // TODO: We want an error code here
        }
        
        return BiometricEnrollmentStatus(
            maximumFingerprints: maxNumberOfFingers,
            enrolledTouches: enrolledTouches,
            remainingTouches: remainingTouches,
            mode: biometricMode // 0 - enroll, 1 and 2 - verify
        )
    }
    
    func getBiometricVerification(tag: NFCISO7816Tag) async throws -> Bool {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Get Biometric Verification")
        
       // let response = LibSdkValidateFingerprint()
        
        let getBiometricVerifyCommand: [UInt8] = [0xED, 0x56, 0x00, 0x00, 0x01, 0x00]
        let returnData = try await send(apduCommand: getBiometricVerifyCommand, to: tag)
        
        if returnData.statusWord == APDUResponseCodes.operationSuccessful.rawValue {
            return true
        }
        
        if returnData.statusWord == APDUResponseCodes.noMatchFound.rawValue {
            return false
        }
        
        throw NSError(domain: "Validate Fingerprint Error.", code: Int(returnData.statusWord))
//
//        int returnValue = 0;
//        do
//        {
//            uint8_t apdu_verify[] = { 0xED, 0x56, 0x00, 0x00, 0x01, 0x00 };
//            apdu_enroll_out_len = 0;
//            returnValue = apdu_secure_channel(apdu_verify, sizeof(apdu_verify), apdu_enroll_out, &apdu_enroll_out_len);
//            
//            //      if (Ret != 0) return Ret;
//            //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
//            if (returnValue == 0) break;
//            if (returnValue == 1) continue;
//            return returnValue;
//        } while (1);
//        
//        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
//        return returnValue;
//
//        
//        // the finger on the sensor matches the one recorded during enrollment
//        if response == 0x9000 {
//            return true
//        }
//        
//        // the finger on the sensor does not match the one recorded during enrollment
//        if response == 0x6300 {
//            return false
//        }
//        
//        throw NSError(domain: "Validate Fingerprint Error.", code: Int(response))
    }

    func enrollScanFingerprint(tag: NFCISO7816Tag) async throws -> UInt8 {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Enroll fingerprint")
        
        // note: the last byte indicates the finger number; this will need updating if/when 2 fingers are supported
        let processFingerprintCommand: [UInt8] = [0x00, 0x59, 0x03, 0x00, 0x02, 0x00, 0x01]
        try await sendAndConfirm(apduCommand: processFingerprintCommand, to: tag)
        
        let enrollmentStatus = try await getEnrollmentStatus(tag: tag)
        return enrollmentStatus.remainingTouches
        
//        int returnValue = 0;
//        
//        do
//        {
//            uint8_t apdu_process[] = { 0x00, 0x59, 0x03, 0x00, 0x02, 0x00, 0x01 };
//            apdu_enroll_out_len = 0;
//            returnValue = apdu_secure_channel(apdu_process, sizeof(apdu_process), apdu_enroll_out, &apdu_enroll_out_len);
//            //      if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
//            //      Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
//            if (returnValue == 0) break;
//            if (returnValue == 1) continue;
//            return returnValue;
//        } while (1);
//        
//        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
//        if (returnValue != 0x9000) {
//            return returnValue;
//        }
//
//        uint8_t max_num_fingers[1];
//        uint8_t biometric_mode[1];
//        uint8_t enrolled_touches[1];
//        returnValue = lib_enroll_status(max_num_fingers, enrolled_touches, remaining_touches, biometric_mode);
//        //       if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
//        //       Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
//        //      if (Ret != 0) return Ret;
//        
//        
//        return returnValue;
//
        
//     //   let enrolled = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
//        let remainingEnrollments = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
//     //   let mode = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
//        
//        defer {
//     //       enrolled.deallocate()
//            remainingEnrollments.deallocate()
//    //        mode.deallocate()
//        }
//        
//        let response = LibSdkEnrollProcess(remainingEnrollments)
//        
//        if response != 0x9000 {
//            throw NSError(domain: "Finger Scan Error.", code: Int(response))
//        }
//        
//        return remainingEnrollments.pointee
    }
    
    // used only during the enrollment process
    func verifyEnrolledFingerprint(tag: NFCISO7816Tag) async throws {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK Verify Enroll")
        
        let verifyCommand: [UInt8] = [0x00, 0x59, 0x00, 0x00, 0x01, 0x00]
        try await sendAndConfirm(apduCommand: verifyCommand, to: tag)
        
//        int returnValue = 0;
//        do
//        {
//            uint8_t apdu_verify[] = { 0x00, 0x59, 0x00, 0x00, 0x01, 0x00 };
//            apdu_enroll_out_len = 0;
//            returnValue = apdu_secure_channel(apdu_verify, sizeof(apdu_verify), apdu_enroll_out, &apdu_enroll_out_len);
//            
//            //      if (Ret != 0) return Ret;
//            //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
//            if (returnValue == 0) break;
//            if (returnValue == 1) continue;
//            return returnValue;
//        } while (1);
//        
//        returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
//        return returnValue;

//        let response = LibSdkEnrollVerify()
//        
//        if response != 0x9000 {
//            throw NSError(domain: "Verify Enrollment Error.", code: Int(response))
//        }
    }

    @discardableResult private func sendAndConfirm(apduCommand: [UInt8], to tag: NFCISO7816Tag) async throws -> APDUReturnResult {
        let result = try await send(apduCommand: apduCommand, to: tag)
        
        if result.statusWord != 0x9000 {
            throw NSError(domain: "APDU Command Error", code: result.statusWord)
        }

        return result
    }
    
    @discardableResult private func send(apduCommand: [UInt8], to tag: NFCISO7816Tag) async throws -> APDUReturnResult {
        print("\n\n---------- Sending -----------")
        
        let data = Data(apduCommand)
        print(">>> Tag Sending => \(data.toHex())")
        
        guard let command = NFCISO7816APDU(data: data) else {
            // TODO: Change
            throw NFCReaderError(.readerErrorInvalidParameter)
            //return SwiftCallbackError.invalidAPDUData.rawValue
        }
        
        let result = try await tag.sendCommand(apdu: command)
        
        let statusCode: Int = Int(result.1) << 8 + Int(result.2)
        
        let resultData = result.0 + Data([result.1]) + Data([result.2])
        print("<<< Tag Received <= \(resultData.toHex())")
        
        return APDUReturnResult(data: result.0, statusWord: Int(result.1) << 8 + Int(result.2))
        
//        if statusCode != 0x9000 {
//            throw NSError(domain: "APDU Command Error", code: statusCode)
//        }
//        
//        return result.0
    }
    
    
    
    private func constructPINBuffer(pin: [UInt8]) throws -> [UInt8] {
        var bufferIndex = 1
        var PINBuffer: [UInt8] = [] // [0x80, 0x20, 0x00, 0x80, 0x08]
        PINBuffer.append(0x20 + UInt8(pin.count))
        PINBuffer.append(contentsOf: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        
        for index in 0..<pin.count {
            let digit = pin[index]
            if digit > 9 {
                // TODO:
                throw NFCReaderError(.readerErrorParameterOutOfBound)
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func initEnroll(pin: [UInt8], tag: NFCISO7816Tag) throws {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK INIT ENROLL - PIN: \(pin)")
        
        if let oldTag = Self.tag, oldTag === tag {
            print("\n\n>>> SentryBiometricSDK select enroll - Returning early, old tag === current tag")
            return
        }
        
        Self.tag = tag
        
        // create a C compatible byte buffer and copy the PIN into it
        let pinLength = pin.count
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: pinLength)
        defer {
            pointer.deallocate()
        }
        
        for i in 0..<pinLength {
            pointer.advanced(by: i).pointee = pin[i]
        }
        
        print("--== Getting Response")
        let response = LibSdkEnrollInit(pointer, Int32(pinLength)) { dataIn, dataInLen, dataOut, dataOutLen in
            print("--== Have response, calling callback")
            return BiometricSDK.swiftCallback(dataIn, dataInLen, dataOut, dataOutLen)
        }
        
        if response != 0x9000 {
            throw NSError(domain: "Init Biometric Applet Error.", code: Int(response))
        }
    }

    func getEnrollStatus() throws -> BiometricEnrollmentStatus {
        print("\\n\n>>>>>>>>>>>>SentryBiometricSDK .getEnrollStatus - \(Thread.current)")
        
        let numFingerprints = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        let enrolled = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        let remains = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        let mode = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        
        defer {
            numFingerprints.deallocate()
            enrolled.deallocate()
            remains.deallocate()
            mode.deallocate()
        }
        
        let response = LibSdkGetEnrollStatus(numFingerprints, enrolled, remains, mode)
        
        if response != 0x9000 {
            throw NSError(domain: "Get Enroll Status Error.", code: Int(response))
        }

//        if response != 0 {
//            throw NSError(domain: "Get Fingerprint Status Error.", code: Int(response))
//        }
        let biometricMode = BiometricMode(rawValue: mode.pointee)
        
        guard let biometricMode = biometricMode else {
            throw NSError(domain: "Unknown biometric mode", code: Int(mode.pointee))        // TODO: We want an error code here
        }
        
        return BiometricEnrollmentStatus(
            maximumFingerprints: numFingerprints.pointee,
            enrolledTouches: enrolled.pointee,
            remainingTouches: remains.pointee,
            mode: biometricMode // 0 - enroll, 1 and 2 - verify
        )
    }

    func enrollFingerprint() throws -> UInt8 {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK .EnrollFingerprint - \(Thread.current)")
        
     //   let enrolled = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        let remainingEnrollments = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
     //   let mode = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        
        defer {
     //       enrolled.deallocate()
            remainingEnrollments.deallocate()
    //        mode.deallocate()
        }
        
        let response = LibSdkEnrollProcess(remainingEnrollments)
        
        if response != 0x9000 {
            throw NSError(domain: "Finger Scan Error.", code: Int(response))
        }
        
        return remainingEnrollments.pointee
    }
    
    func verifyEnroll(pin: [UInt8]) throws {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK .verifyEnroll - \(Thread.current)")
        
        let response = LibSdkEnrollVerify()
        
        if response != 0x9000 {
            throw NSError(domain: "Verify Enrollment Error.", code: Int(response))
        }
    }

//    func validateFingerprint() throws -> Bool {
//        print("\n\n>>>>>>>>>>>>SentryBiometricSDK .verifyEnroll - \(Thread.current)")
//        
//        let response = LibSdkValidateFingerprint()
//        
//        // the finger on the sensor matches the one recorded during enrollment
//        if response == 0x9000 {
//            return true
//        }
//        
//        // the finger on the sensor does not match the one recorded during enrollment
//        if response == 0x6300 {
//            return false
//        }
//        
//        throw NSError(domain: "Validate Fingerprint Error.", code: Int(response))
//    }
    
    func finalizeEnroll() {
        print("\n\n>>>>>>>>>>>>SentryBiometricSDK DESELECT ENROLL - \(Thread.current)")
        LibSdkEnrollDeinit()
        Self.tag = nil
    }
}

// helper extension to print a data buffer as a hexadecimal string
extension Data {
    func toHex() -> String {
        map {
            return String(format:"%02X", $0)
        }.joined(separator: "").uppercased()
    }
}
