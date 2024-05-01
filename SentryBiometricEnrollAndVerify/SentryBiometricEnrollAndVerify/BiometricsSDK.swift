//
//  BiometricsSDK.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import SentryBiometricSDK
import Foundation
import CoreNFC


public final class BiometricSDK {
    private typealias SmartCardCallback = (UnsafePointer<UInt8>?, UInt32, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt32>) -> Void

    /// Reason for this property and method to be static - is compatability with C-closures.
    /// We call `LibSdkInit` each time before calling some JCWWallet library method, and pass callback to handle command
    /// This callback is `@convention(c)` callback, that restricts other context in it (such as Swift classes)
    /// For this, to avoid such restriction - this method that is used in `convention(c)` callback - made Global to not depend on Swift entities
    private static var tag: NFCISO7816Tag?

    private static func swiftCallback(_ dataIn: UnsafeMutablePointer<UInt8>?, _ dataInLen: UInt32, _ dataOut: UnsafeMutablePointer<UInt8>?, _ dataOutLen: UnsafeMutablePointer<UInt32>?) -> Int32 {




//       guard let dataInArray = dataIn?.toArray(lenght: dataInLen) else {
        guard let dataIn = dataIn else {
            return -1
        }

        var returnStatus: Int32 = 0
        let semaphore = DispatchSemaphore(value: 0)
        let dataInArray = Array(UnsafeBufferPointer(start: dataIn, count: Int(dataInLen)))
        let data = Data(dataInArray)

        // print the data being sent has a hexadecimal string
        print(">>> Tag Sending => \(data.toHex())")


        guard let command = NFCISO7816APDU(data: data) else {
            // TODO: Do better here
            print("!!! Invalid Parameter Length!!!")
//            let error = NFCReaderError(.readerErrorInvalidParameterLength)
//            completion(.failure(error))
            return -1
        }

        tag?.sendCommand(apdu: command) { response, sw1, sw2, error in
            let data = response + Data([sw1]) + Data([sw2])

            if let error = error {
                print(">>> Tag Send ERROR: \(error)")
                returnStatus = -1
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



//        tag?.sendCommand(data) { result in
//            switch result {
//            case .success(let data):
//                dataOutLen?.pointee = UInt32(data.count)
//
//                for (index, byte) in data.enumerated() {
//                    dataOut?.advanced(by: index).pointee = byte
//                }
//
//                print("<<< Tag Received <= \(data.toHex())")
//                semaphore.signal()
//
//            case .failure(let error):
//                print(">>> Tag Send ERROR: \(error)")
//                returnStatus = -1
//                print(error.localizedDescription)
//            }
//
////            semaphore.signal()
//        }

        semaphore.wait()

        return returnStatus
    }

    private let isSecure: Bool

    public init(isSecure: Bool) {
        self.isSecure = isSecure
    }

    func selectEnrollApplet(tag: NFCISO7816Tag) throws { //pin: [UInt8], tag: NFCISO7816Tag) throws {
        print("\n\n>>>>>>>>>>>>\nSentryBiometricSDK SELECT ENROLL")// - PIN: \(pin)")
//
//        if let oldTag = Self.tag, oldTag === tag {
//            print("\n\n>>> SentryBiometricSDK select enroll - Returning early, old tag === current tag")
//            return
//        }
        Self.tag = tag
//        let pinLenght = pin.count
//        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: pinLenght)
//        defer {
//            pointer.deallocate()
//        }
//
//        for i in 0..<pinLenght {
//            pointer.advanced(by: i).pointee = pin[i]
//        }
//
//        let response = LibSdkEnrollInit(pointer, Int32(pinLenght)) { dataIn, dataInLen, dataOut, dataOutLen in
//            return JCWWallet.swiftCallback(dataIn, dataInLen, dataOut, dataOutLen)
//        }
//
//        if response != 0 {
//            throw NSError(domain: "Init Biometric Applet Error.", code: Int(response))
//        }
        
        print("--== Getting Response")
        let response = LibSdkEnrollSelect() { dataIn, dataInLen, dataOut, dataOutLen in
            print("--== Have response, calling callback")
            return BiometricSDK.swiftCallback(dataIn, dataInLen, dataOut, dataOutLen)
        }
        
        print("Response: \(response)")
    }

    func initEnroll(pin: [UInt8], tag: NFCISO7816Tag) throws {
        print("\n\n>>>>>>>>>>>>\nBiometricSDK SELECT ENROLL - PIN: \(pin)")
        
        if let oldTag = Self.tag, oldTag === tag {
            print("\n\n>>> BiometricSDK select enroll - Returning early, old tag === current tag")
            return
        }
        
        Self.tag = tag
        let pinLength = pin.count
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: pinLength)
        
        defer {
            pointer.deallocate()
        }
        
        for i in 0..<pinLength {
            pointer.advanced(by: i).pointee = pin[i]
        }
        
        let response = LibSdkEnrollInit(pointer, Int32(pinLength)) { dataIn, dataInLen, dataOut, dataOutLen in
            return BiometricSDK.swiftCallback(dataIn, dataInLen, dataOut, dataOutLen)
        }
        
        if response != 0 {
            throw NSError(domain: "Init Biometric Applet Error.", code: Int(response))
        }
    }

    func finalizeEnroll() throws {
        print("\n\n<<<<<<<<<<<\nJCWWallet DESELECT ENROLL - \(Thread.current)")

        let response = LibSdkEnrollDeinit()
        if response != 0 {
            throw NSError(domain: "Deinit Biometric Applet Error.", code: Int(response))
        }
        Self.tag = nil
    }

}
