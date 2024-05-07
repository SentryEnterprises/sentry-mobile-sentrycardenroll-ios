//
//  JavaCardManager.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import Foundation
import CoreNFC

final class JavaCardManager: NSObject {
    private let enrollPinCode: [UInt8] = AppSettings.getPIN()

    static let shared = JavaCardManager()
    
    private var session: NFCReaderSession?
    
    private var tag: NFCISO7816Tag?
    private var callback: ((Result<NFCISO7816Tag, Error>) -> Void)?
    private let biometricSDK = BiometricSDK()
    
    private override init() { }
    
    
    func getEnrollmentStatus() async throws -> BiometricEnrollmentStatus  {
        print("=== GET ENROLLMENT STATUS")
        
        defer {
            print("=== GET ENROLLMENT STATUS - EXIT (invalidates session)")
            invalidateSession()
        }
        
        print("=== GET ENROLLMENT STATUS - ESTABLISHING CONNECTION")
        let isoTag = try await establishConnection()
        
        print("=== GET ENROLLMENT STATUS - INITIALIZING ENROLL APPLET")
        try await biometricSDK.initializeEnroll(pin: enrollPinCode, tag: isoTag)
        
        print("=== GET ENROLLMENT STATUS - GETTING ENROLLMENT STATUS")
        let enrollStatus = try await biometricSDK.getEnrollmentStatus(tag: isoTag)
        
        print("=== GET ENROLLMENT STATUS - RETURNING STATUS: \(enrollStatus)")
        return enrollStatus
    }
    
    func validateBiometrics() async throws -> Bool {
        print("=== VALIDATE BIOMETRICS")
        
        defer {
            print("=== VALIDATE BIOMETRICS - EXIT (invalidates session)")
            invalidateSession()
        }
        
        print("=== VALIDATE BIOMETRICS - ESTABLISHING CONNECTION")
        let isoTag = try await establishConnection()
        
        print("=== VALIDATE BIOMETRICS - INITIALIZING ENROLL APPLET")
        try await biometricSDK.initializeEnroll(pin: enrollPinCode, tag: isoTag)
        
        print("=== VALIDATE BIOMETRICS - VALIDATE FINGERPRINT")
        let result = try await biometricSDK.getBiometricVerification(tag: isoTag)
        return result
    }
    
    func enrollBiometric(connected: (Bool) -> Void, stepFinished: (UInt8, UInt8) -> Void) async throws  {
        print("=== ENROLL BIOMETRIC")
        
        defer {
            print("=== ENROLL BIOMETRIC - EXIT (invalidates session)")
            invalidateSession()
        }
        
        print("=== ENROLL BIOMETRIC - ESTABLISHING CONNECTION")
        let isoTag: NFCISO7816Tag
        do {
            isoTag = try await establishConnection()
            connected(true)
        } catch (let error) {
            connected(false)
            throw error
        }
        
        print("=== ENROLL BIOMETRIC - INITIALIZING ENROLL APPLET")
        try await biometricSDK.initializeEnroll(pin: enrollPinCode, tag: isoTag)
        
        print("=== ENROLL BIOMETRIC - GETTING ENROLLMENT STATUS")
        let enrollStatus = try await biometricSDK.getEnrollmentStatus(tag: isoTag)
        
        let maximumSteps = enrollStatus.enrolledTouches + enrollStatus.remainingTouches
        var progress = updateProgress(oldProgress: 0, newProgress: 0)
        var enrollmentsLeft = maximumSteps
        
        print("=== ENROLL BIOMETRIC - \n     MaxSteps: \(maximumSteps)\n     Progress: \(progress)\n     Remaining: \(enrollmentsLeft)")
        
        while enrollmentsLeft > 0 {
            print("=== ENROLL BIOMETRIC - Enrolling, Remaining: \(enrollmentsLeft)")
            
            let remainingEnrollments = try await biometricSDK.enrollScanFingerprint(tag: isoTag)
            if remainingEnrollments <= 0 {
                try await biometricSDK.verifyEnrolledFingerprint(tag: isoTag)
            }
            enrollmentsLeft = remainingEnrollments
            
            print("=== ENROLL BIOMETRIC - \n     Remaining: \(enrollmentsLeft)")
            
            let currentStep = maximumSteps - enrollmentsLeft
            
            let currentStepDouble = Double(currentStep)
            let maximumStepsDouble = Double(maximumSteps)
            progress = updateProgress(oldProgress: progress, newProgress: UInt8(currentStepDouble / maximumStepsDouble * 100))
            
            print("=== ENROLL BIOMETRIC - \n     Progress: \(progress)")
            
            stepFinished(currentStep, maximumSteps)
            
            print("=== ENROLL BIOMETRIC - \n     CurrentStep: \(currentStep)")
        }
        
        print("=== ENROLL BIOMETRIC - Enrollment Complete")
    }
    

    
    private func updateProgress(oldProgress: UInt8, newProgress: UInt8) -> UInt8 {
        let diff = newProgress - oldProgress
       
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

    private func establishConnection() async throws -> NFCISO7816Tag {
        if session != nil {
            print("``` Have Session ```")
            if let tag {
                print("``` Have Tag```")
                return tag
            } else {
                print("!!! NO TAG !!!")
                session?.invalidate()
                throw BiometricsSDKError.connectedWithoutTag
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
            session?.alertMessage = "Place your card under the top of the phone to establish connection."
            session?.begin()
            print("``` Returning from establishConnection() ```")
        }
    }
    
    private func invalidateSession(_ errorMessage: String = "") {
        print(" *** Invalidating Session ***")
        if errorMessage.isEmpty {
            session?.invalidate()
        } else {
            session?.invalidate(errorMessage: errorMessage)
        }
    }
}

extension JavaCardManager: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("----- Tag Reader Session - Active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("----- Tag Reader Session - Invalidated with error: \(error)")
        callback?(.failure(error))
        self.session = nil
        callback = nil
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
        
        guard let cardTag = tag, case let .iso7816(isoTag) = cardTag else {
            callback?(.failure(BiometricsSDKError.incorrectTagFormat))
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

