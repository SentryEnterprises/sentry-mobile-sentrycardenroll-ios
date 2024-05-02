//
//  JavaCardManager.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/30/24.
//

import Foundation
import CoreNFC
//import JCWWallet
//import BigInt

enum WalletError: Error {
    case unrecognisedError
//    case connectionLost
//    case connectionNotEstablished
    case incorrectCardFormat
//    case cardNotEnrolled
//    case cardNotPersonalized
//    case securityViolation
}

typealias Callback<T, U> = (T) -> (U)
typealias VoidCallback = () -> ()
typealias SendCallback<T> = Callback<(), T>
typealias ReturnCallback<T> = Callback<T, ()>
typealias ReturnResultCallback<T> = ReturnCallback<Result<T, Error>>

final class JavaCardManager: NSObject {
    let enrollPinCode: [UInt8] = .init(repeating: 1, count: 6)
    
    enum Status {
        case requireBiometricEnrollment
        case notPersonalized
    }
    
    typealias NFCResult = Result<NFCISO7816Tag, Error>
    
    static let shared = JavaCardManager()
    
    private var session: NFCReaderSession?
    
    private var tag: NFCISO7816Tag?
    private var callback: ReturnCallback<NFCResult>?
    private let biometricSDK = BiometricSDK(isSecure: false)
    private override init() { }
    
    
    func getEnrollmentStatus() async throws -> BiometricEnrollmentStatus  {
        print("=== GET ENROLLMENT STATUS")
        
        //        var localError: Error?
        
        defer {
            print("=== GET ENROLLMENT STATUS - EXIT (invalidates session)")
            callback = nil
            //            if let localError {
            //                invalidateSession((localError as NSError).domain)
            //            } else {
            invalidateSession()
            //            }
        }
        
        //let isoTag: NFCISO7816Tag
        //       do {
        print("=== GET ENROLLMENT STATUS - ESTABLISHING CONNECTION")
        let isoTag = try await establishConnection()
        //        } catch {
        //            localError = NSError(domain: "Connection Not Established Error", code: -1)
        //            throw WalletError.connectionNotEstablished
        //        }
        //
        //        do {
        //           try jcwWallet.initEnroll(pin: Constants.enrollPinCode, tag: isoTag)
        
        print("=== GET ENROLLMENT STATUS - INITIALIZING ENROLL APPLET")
        try biometricSDK.initEnroll(pin: enrollPinCode, tag: isoTag)
        
        print("=== GET ENROLLMENT STATUS - GETTING ENROLLMENT STATUS")
        let enrollStatus = try biometricSDK.getEnrollStatus()
        
        print("=== GET ENROLLMENT STATUS - RETURNING STATUS")
        return enrollStatus
        
        //        } catch {
        //            localError = error
        //            throw error
        //        }
    }
    
    
    
    
    
    
    
    func enrollBiometric(connected: ReturnCallback<Bool>, stepFinished: ReturnCallback<UInt8>) async throws  {
        print("=== ENROLL BIOMETRIC")
        
        var localError: Error?
        defer {
            print("=== ENROLL BIOMETRIC - EXIT (invalidates session)")
            callback = nil
            invalidateSession()
            biometricSDK.finalizeEnroll()
            
//            if let localError {
//                try? jcwWallet.finalizeEnroll()
//                invalidateSession((localError as NSError).domain)
//            } else {
//                invalidateSession()
//            }
        }
        
        print("=== ENROLL BIOMETRIC - ESTABLISHING CONNECTION")
        let isoTag: NFCISO7816Tag
        do {
            isoTag = try await establishConnection()
            connected(true)
        } catch (let error) {
            connected(false)
 //           localError = NSError(domain: "Connection Not Established Error", code: -1)
            throw error
        }
  
        
  //      let isoTag = try await establishConnection()

        do {
//            try jcwWallet.initEnroll(pin: Constants.enrollPinCode, tag: isoTag)
//            let enrollStatus = try jcwWallet.getEnrollStatus()
  
            print("=== ENROLL BIOMETRIC - INITIALIZING ENROLL APPLET")
            try biometricSDK.initEnroll(pin: enrollPinCode, tag: isoTag)
            
            print("=== ENROLL BIOMETRIC - GETTING ENROLLMENT STATUS")
            let enrollStatus = try biometricSDK.getEnrollStatus()

            let maximumSteps = enrollStatus.enrolledTouches + enrollStatus.remainingTouches
            
//            let updateProgress = { [weak self] (oldProgress: UInt8, newProgress: UInt8) in
//                let diff = newProgress - oldProgress
//                let text = { (percentValue: String) in
//                    if percentValue == "0" {
//                        return "Place and lift your thumb at different angles on your card’s sensor."
//                    } else {
//                        return "Scanning \(percentValue)%"
//                    }
//                }
//                
//                guard diff > 0 else {
//                    self?.session?.alertMessage = text(oldProgress.description)
//                    return
//                }
//                
//                let duration = 0.5 // Total animation duration in seconds
//                let updateInterval = duration / Double(diff)
//                
//                var currentValue = oldProgress
//                while currentValue <= newProgress {
//                    self?.session?.alertMessage = text(currentValue.description)
//                    Thread.sleep(forTimeInterval: updateInterval)
//                    currentValue += 1
//                }
//            }
//            
            var progress = updateProgress(oldProgress: 0, newProgress: 0)
            
            //var progress: UInt8 = 0
//            {
//                didSet {
//                    updateProgress(oldProgress: oldValue, newProgress: progress)
//                }
//            }
            
            var enrollmentsLeft = maximumSteps
//            {
//                didSet {
//                    let currentStep = maximumSteps - enrollmentsLeft
//                    stepFinished(currentStep)
//                    
//                    let currentStepDouble = Double(currentStep)
//                    let maximumStepsDouble = Double(maximumSteps)
//                    progress = UInt8(currentStepDouble / maximumStepsDouble * 100)
//                }
//            }
            
//            progress = 0
            
            //            if enrollStatus.enrolled > 0 {
            //                // One reenrol to remove fingerprints and enroll first fingerprint.
            //                // Then `enroll` for rest five times
            //                enrollmentsLeft = try jcwWallet.reenroll()
            //            }
            
            print("=== ENROLL BIOMETRIC - \n     MaxSteps: \(maximumSteps)\n     Progress: \(progress)\n     Remaining: \(enrollmentsLeft)")
            
            while enrollmentsLeft > 0 {
                print("=== ENROLL BIOMETRIC - Enrolling, Remaining: \(enrollmentsLeft)")
            
                let remainingEnrollments = try biometricSDK.enrollFingerprint()
                if remainingEnrollments <= 0 {
                    try biometricSDK.verifyEnroll(pin: enrollPinCode)
                    
                    // TODO: This ignores qualification touches, we may need this in the future
                }
                enrollmentsLeft = remainingEnrollments
                
                print("=== ENROLL BIOMETRIC - \n     Remaining: \(enrollmentsLeft)")
                
                let currentStep = maximumSteps - enrollmentsLeft
                stepFinished(currentStep)
                
                print("=== ENROLL BIOMETRIC - \n     CurrentStep: \(currentStep)")
                
                let currentStepDouble = Double(currentStep)
                let maximumStepsDouble = Double(maximumSteps)
                progress = updateProgress(oldProgress: progress, newProgress: UInt8(currentStepDouble / maximumStepsDouble * 100))
                
                print("=== ENROLL BIOMETRIC - \n     Progress: \(progress)")
            }
            
            print("=== ENROLL BIOMETRIC - Enrollment Finished, finalizing")
            biometricSDK.finalizeEnroll()
            
//            print("     Getting capabilities")
//            let capabilites = try jcwWallet.getCapabilities()
//            //        setupSessionMessage(45)
//            if !capabilites.disablePin {
//                try jcwWallet.storePin(pin: .init(repeating: 1, count: 6))
//            }
            
            print("=== ENROLL BIOMETRIC - Enrollment Complete")
            stepFinished(100)   // awful hack
            
        } catch {
            localError = error
            throw error
        }
    }
    
    func validateBiometrics(invalidating: Bool = true) async throws {
        //        var localError: Error?
        //        defer {
        //            callback = nil
        //            if let localError {
        //                try? jcwWallet.finalizeWallet()
        //                invalidateSession((localError as NSError).domain)
        //            } else if invalidating {
        //                invalidateSession()
        //            }
        //        }
        //
        //        do {
        //            let isoTag = try await establishConnection()
        //
        //            try jcwWallet.initWallet(tag: isoTag)
        //            try jcwWallet.cvmVerifyFingerprint()
        //            try jcwWallet.finalizeWallet()
        //        } catch {
        //            localError = error
        //            throw error
        //        }
    }
    
    //    func firstTest() async throws {
    //        print("=== TEST")
    //        defer {
    //            callback = nil
    //        }
    //
    //        do {
    //            print("=== Establishing Connection")
    //            let isoTag = try await establishConnection()
    //            //try await establishConnection()
    //            //establishConnectionInstant()
    //
    //            print("=== Selecting applet")
    //            try biometricSDK.selectEnrollApplet(tag: isoTag)
    //            try biometricSDK.initEnroll(pin: enrollPinCode, tag: isoTag)
    //         //   try biometricSDK.initEnroll(pin: [1, 1, 1, 1, 1, 1], tag: isoTag)
    //
    //            print("=== Exiting TEST")
    //        } catch (let error) {
    //            print("ERROR: \(error)")
    //            throw error
    //        }
    //    }
    
    
    
    private func updateProgress(oldProgress: UInt8, newProgress: UInt8) -> UInt8 {
        let diff = newProgress - oldProgress
       
        let text = getText(percentValue: "0")
        
        // if no progress has been made, simply set the alert message and return
        guard diff > 0 else {
            session?.alertMessage = getText(percentValue: oldProgress.description)
            return newProgress
        }
        
        let duration = 0.3 // Total animation duration in seconds
        let updateInterval = duration / Double(diff)
        
        // just a simple trick to animate the percentage text change
        var currentValue = oldProgress
        while currentValue <= newProgress {
            session?.alertMessage = getText(percentValue: currentValue.description)
            Thread.sleep(forTimeInterval: updateInterval)
            currentValue += 1
        }
        
        return newProgress
    }
    
    private func getText(percentValue: String) -> String {
        if percentValue == "0" {
            return "Place and lift your thumb at different angles on your card’s sensor."
        } else {
            return "Scanning \(percentValue)%"
        }
    }
}


private extension JavaCardManager {
    func establishConnection() async throws -> NFCISO7816Tag {
        if session != nil {
            print("``` Have Session ```")
            if let tag {
                print("``` Have Tag```")
                return tag
            } else {
                print("!!! NO TAG !!!")
                session?.invalidate()
                throw WalletError.unrecognisedError // we have session but not tag?
            }
        }
        return try await withCheckedThrowingContinuation { continuation in
            callback = { result in
                switch result {
                case .success(let tag):
                    print("``` Success, got tag ```")
                    continuation.resume(returning: tag)
                case .failure(let error):
                    print("!!! FAIL: \(error) !!!")
                    continuation.resume(throwing: error)
                }
            }
            
            print("``` Starting Session ```")
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            session?.alertMessage = "Place your card under the top of the phone to establish connection"
            session?.begin()
            print("``` Returning from establishConnection() ```")
        }
    }
    
    func invalidateSession(_ errorMessage: String = "") {
        print(" *** Invalidating Session ***")
        if errorMessage.isEmpty {
            session?.invalidate()
        } else {
            session?.invalidate(errorMessage: errorMessage)
        }
        session = nil
        callback = nil
    }
}

extension JavaCardManager: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("----- Tag Reader Session - Active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("----- Tag Reader Session - Invalidated with error: \(error)")
        callback?(.failure(error))
        invalidateSession()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("----- Tag Reader Session - Detected Tag")
        let tag = tags.first(where: {
            switch $0 {
            case .iso7816:
                return true
            default:
                return false
            }
        })
        
        guard let cardTag = tag, case let .iso7816(isoTag) = tag else {
            callback?(.failure(WalletError.incorrectCardFormat))
            invalidateSession()
            return
        }
        
        session.connect(to: cardTag) { [weak self] error in
            if let error = error {
                print("----- Tag Reader Session - Connection error: \(error)")
                self?.callback?(.failure(error))
                self?.callback = nil
                self?.invalidateSession()
            } else {
                print("----- Tag Reader Session - Connection Made")
                self?.tag = isoTag
                self?.callback?(.success(isoTag))
                self?.callback = nil
            }
        }
    }
}

