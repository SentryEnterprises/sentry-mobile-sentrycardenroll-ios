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
    case connectionLost
    case connectionNotEstablished
    case incorrectCardFormat
    case wrongSeed
    case cardNotEnrolled
    case cardNotPersonalized
    case accountNotFound
    case securityViolation
}

typealias Callback<T, U> = (T) -> (U)
typealias VoidCallback = () -> ()
typealias SendCallback<T> = Callback<(), T>
typealias ReturnCallback<T> = Callback<T, ()>
typealias ReturnResultCallback<T> = ReturnCallback<Result<T, Error>>

final class JavaCardManager: NSObject {
    enum Status {
        case requireBiometricEnrollment
        case notPersonalized
    }
    
    private struct Constants {
        static let enrollPinCode: [UInt8] = .init(repeating: 1, count: 6)
    }

    typealias NFCResult = Result<NFCISO7816Tag, WalletError>
        
    static let shared = JavaCardManager()
    
    private var session: NFCReaderSession? 
    
    private var tag: NFCISO7816Tag?
    private var callback: ReturnCallback<NFCResult>?
   // private let jcwWallet = JCWWallet(isSecure: true)
    private let biometricSDK = BiometricSDK(isSecure: false)
    private override init() { }
    
//    func getCapabilities() async throws -> Capabilities {
//        var localError: Error?
//        defer {
//            callback = nil
//            if let localError {
//                invalidateSession((localError as NSError).domain)
//                try? jcwWallet.finalizeWallet()
//            } else {
//                invalidateSession()
//            }
//        }
//        
//        do {
//            let isoTag = try await establishConnection()
//            
//            session?.alertMessage = "Please hold your card close to iPhone. Creation might take some time"
//            
//            try jcwWallet.initWallet(tag: isoTag)
//            let capabilites = try jcwWallet.getCapabilities()
//            try jcwWallet.finalizeWallet()
//            return capabilites
//        } catch {
//            localError = error
//            throw error
//        }
//    }

//    func resetWallet() async throws {
//        var localError: Error?
//        defer {
//            callback = nil
//            if let localError {
//                try? jcwWallet.finalizeWallet()
//                invalidateSession((localError as NSError).domain)
//            } else {
//                invalidateSession()
//            }
//        }
//        
//        do {
//            let isoTag = try await establishConnection()
//            
//            session?.alertMessage = "Please hold your card close to iPhone. Creation might take some time"
//            
//            try jcwWallet.initWallet(tag: isoTag)
//            try jcwWallet.resetWallet()
//            try jcwWallet.finalizeWallet()
//        } catch {
//            localError = error
//            throw error
//        }
//    }
//
//    func createWallet(wordsCount: Int32, pincode: [UInt8] = []) async throws -> (String, [CryptoCurrency: String]) {
//        print("\n------------- Wallet Manager Create Wallet")
//        
//        var localError: Error?
//        defer {
//            callback = nil
//            if let localError {
//                invalidateSession((localError as NSError).domain)
//                try? jcwWallet.finalizeWallet()
//            } else {
//                invalidateSession()
//            }
//        }
//        
//        do {
//            print("     Establishing connection")
//            let isoTag = try await establishConnection()
//            let setupSessionMessage = { [weak session] (progress: Int) in
//                session?.alertMessage = "Creating... \(progress)%"
//            }
//            
//            print("     Initing wallet")
//            try jcwWallet.initWallet(tag: isoTag)
//            setupSessionMessage(28)
//            
//            print("     Getting capabilities")
//            let capabilites = try jcwWallet.getCapabilities()
//            setupSessionMessage(45)
//            if !capabilites.disablePin {
//                try jcwWallet.storePin(pin: pincode)
//            }
//            let seed = try jcwWallet.createWallet(wordCount: wordsCount)
//            setupSessionMessage(65)
//            
//            for currency in CryptoCurrency.allCases {
//                try jcwWallet.createAccount(account: Account(for: currency).accountInfo)
//            }
//            setupSessionMessage(81)
//            
//            let accounts = try jcwWallet.getWalletAccounts()
//            var addresses: [CryptoCurrency: String] = [:]
//            
//            for account in accounts.enumerated() {
//                try jcwWallet.selectAccount(index: Int32(account.offset))
//                let publicKey = try jcwWallet.getReceiveAddress()
//                let currency = try CryptoCurrency(id: account.element.currency)
//                addresses[currency] = publicKey
//            }
//            setupSessionMessage(100)
//            try jcwWallet.finalizeWallet()
//            
//            return (seed, addresses)
//        } catch {
//            localError = error
//            throw error
//        }
//    }
//    
//    func restore(seed: String, iteration: Iteration, pincode: [UInt8] = []) async throws -> [CryptoCurrency: String] {
//        var localError: Error?
//        defer {
//            callback = nil
//            if let localError {
//                try? jcwWallet.finalizeWallet()
//                invalidateSession((localError as NSError).domain)
//            } else {
//                invalidateSession()
//            }
//        }
//        
//        do {
//            let isoTag = try await establishConnection()
//            
//            let setupSessionMessage = { [weak session] (progress: Int) in
//                session?.alertMessage = "Restoring... \(progress)%"
//            }
//            
//            try jcwWallet.initWallet(tag: isoTag)
//            setupSessionMessage(28)
//            let capabilites = try jcwWallet.getCapabilities()
//            setupSessionMessage(45)
//            if !capabilites.disablePin {
//                try jcwWallet.storePin(pin: pincode)
//            }
////            try jcwWallet.restoreWallet(seed: seed, iterations: iteration.rawValue)
//            try jcwWallet.restoreWallet(seed: seed, iterations: Iteration.legacy.rawValue)
//            setupSessionMessage(65)
//            
//            for currency in CryptoCurrency.allCases {
//                try jcwWallet.createAccount(account: Account(for: currency).accountInfo)
//            }
//            setupSessionMessage(81)
//            
//            let accounts = try jcwWallet.getWalletAccounts()
//            var keys: [CryptoCurrency: String] = [:]
//            
//            for account in accounts.enumerated() {
//                try jcwWallet.selectAccount(index: Int32(account.offset))
//                let publicKey = try jcwWallet.getReceiveAddress()
//                let currency = try CryptoCurrency(id: account.element.currency)
//                keys[currency] = publicKey
//            }
//            setupSessionMessage(100)
//            try jcwWallet.finalizeWallet()
//            
//            return keys
//        } catch {
//            localError = error
//            throw error
//        }
//    }
    
    func enrollBiometric(connected: ReturnCallback<Bool>, stepFinished: ReturnCallback<UInt8>) async throws  {
//        var localError: Error?
//        defer {
//            callback = nil
//            if let localError {
//                try? jcwWallet.finalizeEnroll()
//                invalidateSession((localError as NSError).domain)
//            } else {
//                invalidateSession()
//            }
//        }
//        
//        let isoTag: NFCISO7816Tag
//        do {
//            isoTag = try await establishConnection()
//            connected(true)
//        } catch {
//            connected(false)
//            localError = NSError(domain: "Connection Not Established Error", code: -1)
//            throw WalletError.connectionNotEstablished
//        }
//        
//        do {
//            try jcwWallet.initEnroll(pin: Constants.enrollPinCode, tag: isoTag)
//            
//            let enrollStatus = try jcwWallet.getEnrollStatus()
//            let maximumSteps = enrollStatus.enrolled + enrollStatus.remains
//            let updateProgress = { [weak self] (oldProgress: UInt8, newProgress: UInt8) in
//                let diff = newProgress - oldProgress
//                let text = { (percentValue: String) in
//                    if percentValue == "0" {
//                        return "Place and lift your thumb at different angles on your card’s sensor."
//                    } else {
//                        return "Scanning \(percentValue)%"
//                    }
//                }
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
//            var progress: UInt8 = 0 {
//                didSet {
//                    updateProgress(oldValue, progress)
//                }
//            }
//            var enrollmentsLeft: UInt8 = maximumSteps {
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
//            
//            if enrollStatus.enrolled > 0 {
//                // One reenrol to remove fingerprints and enroll first fingerprint.
//                // Then `enroll` for rest five times
//                enrollmentsLeft = try jcwWallet.reenroll()
//            }
//            
//            while enrollmentsLeft > 0 {
//                let _enrollmentsLeft = try jcwWallet.enroll()
//                if _enrollmentsLeft <= 0 {
//                    try jcwWallet.verifyEnroll()
//                }
//                enrollmentsLeft = _enrollmentsLeft
//            }
//            
//            try jcwWallet.finalizeEnroll()
//            
//            print("     Initing wallet")
//            try jcwWallet.initWallet(tag: isoTag)
//    //        setupSessionMessage(28)
//            
//            print("     Getting capabilities")
//            let capabilites = try jcwWallet.getCapabilities()
//    //        setupSessionMessage(45)
//            if !capabilites.disablePin {
//                try jcwWallet.storePin(pin: .init(repeating: 1, count: 6))
//            }
//            let seed = try jcwWallet.createWallet(wordCount: 12)
// //           setupSessionMessage(65)
//            
//            for currency in CryptoCurrency.allCases {
//                try jcwWallet.createAccount(account: Account(for: currency).accountInfo)
//            }
//  //          setupSessionMessage(81)
//            
//            let accounts = try jcwWallet.getWalletAccounts()
//            var addresses: [CryptoCurrency: String] = [:]
//            
//            for account in accounts.enumerated() {
//                try jcwWallet.selectAccount(index: Int32(account.offset))
//                let publicKey = try jcwWallet.getReceiveAddress()
//                let currency = try CryptoCurrency(id: account.element.currency)
//                addresses[currency] = publicKey
//            }
//   //         setupSessionMessage(100)
//            try jcwWallet.finalizeWallet()
//            
//            stepFinished(100)   // awful hack
//            
//        } catch {
//            localError = error
//            throw error
//        }
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
    
    func firstTest() async throws {
        print("=== TEST")
        defer {
            callback = nil
        }
        
        do {
            print("=== Establishing Connection")
            let isoTag = try await establishConnection()
            //try await establishConnection()
            //establishConnectionInstant()
            
            print("=== Selecting applet")
            try biometricSDK.selectEnrollApplet(tag: isoTag)
         //   try biometricSDK.initEnroll(pin: [1, 1, 1, 1, 1, 1], tag: isoTag)
            
            print("=== Exiting TEST")
        } catch (let error) {
            print("ERROR: \(error)")
            throw error
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
        callback?(.failure(.unrecognisedError))
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
            callback?(.failure(.incorrectCardFormat))
            invalidateSession()
            return
        }
        
        session.connect(to: cardTag) { [weak self] error in
            if let error = error {
                print("----- Tag Reader Session - Connection error: \(error)")
                self?.callback?(.failure(.connectionLost))
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

