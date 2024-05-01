////
////  NFCSessionManager.swift
////  SentryBiometricEnrollAndVerify
////
////  Created by John Ayres on 4/29/24.
////
//
//import Foundation
//import CoreNFC
//
//enum BiometricEnrollAndVerifyError: Error {
//    case unrecognisedError
////    case connectionLost
//    case connectionNotEstablished
//    case incorrectCardFormat
////    case cardNotEnrolled
////    case cardNotPersonalized
////    case accountNotFound
////    case securityViolation
//}
//
//class NFCSessionManager: NSObject {
//    
//    // TODO: Research
//    //typealias NFCResult = Result<NFCISO7816Tag, Error>
//    typealias Callback<T, U> = (T) -> (U)
//    typealias ReturnCallback<T> = Callback<T, ()>
//    
//    private var session: NFCReaderSession?
////    {
////        didSet {
////            if session == nil {
////                NotificationCenter.default.post(name: .TagReaderSessionHasFinished, object: nil)
////            } else {
////                NotificationCenter.default.post(name: .TagReaderSessionHasStarted, object: nil)
////            }
////        }
////    }
//    
//    private var tag: NFCISO7816Tag?
//    private var callback: ReturnCallback<Result<NFCISO7816Tag, Error>>?
//
//    
//    
//    func establishConnection() async throws -> NFCISO7816Tag {
//        print("----- NFCSessionManager Establish Connection")
//        
//        if session != nil {
//            print("``` Have Session ```")
//            if let tag {
//                print("``` Have Tag```")
//                return tag
//            } else {
//                print("!!! NO TAG !!!")
//                session?.invalidate()
//                throw BiometricEnrollAndVerifyError.unrecognisedError // we have session but not tag?       // TODO: Should we have an unrecognized error?
//            }
//        }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            callback = { result in
//                switch result {
//                case .success(let tag):
//                    print("``` Success, got tag ```")
//                    continuation.resume(returning: tag)
//                case .failure(let error):
//                    print("!!! FAIL: \(error) !!!")
//                    continuation.resume(throwing: error)
//                }
//            }
//            
//            print("----- NFCSessionManager Starting Session")
//            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
//            session?.alertMessage = "Place your card under the top of the phone to establish connection"
//            session?.begin()
//        }
//    }
//    
//    
//    // TODO: check if this parameter is needed
//    func invalidateSession(_ errorMessage: String = "") {
//        if errorMessage.isEmpty {
//            session?.invalidate()
//        } else {
//            session?.invalidate(errorMessage: errorMessage)
//        }
//        session = nil
//        callback = nil
//    }
//}
//
//extension NFCSessionManager: NFCTagReaderSessionDelegate {
//    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
//        print("----- NFCSessionManager Tag Reader Session - Active")
//    }
//    
//    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
//        print("----- NFCSessionManager Tag Reader Session - Invalidated with error: \(error)")
//        callback?(.failure(error))
//        invalidateSession()
//    }
//    
//    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
//        print("----- NFCSessionManager Tag Reader Session - Detected Tag")
//        
//        // find all ISO 7816 tags
//        let tag = tags.first(where: {
//            switch $0 {
//            case .iso7816:
//                return true
//            default:
//                return false
//            }
//        })
//        
//        // do we have an ISO 7816 tag?
//        guard let cardTag = tag, case let .iso7816(isoTag) = tag else {
//            callback?(.failure(BiometricEnrollAndVerifyError.incorrectCardFormat))
//            invalidateSession()
//            return
//        }
//        
//        // if we have the correct tag, connect to it
//        session.connect(to: cardTag) { [weak self] error in
//            if let error = error {
//                print("----- NFCSessionManager Tag Reader Session - Connection error: \(error)")
//                self?.callback?(.failure(error))
//                self?.callback = nil
//                self?.invalidateSession()
//                
//            } else {
//                print("----- NFCSessionManager Tag Reader Session - Connection Made")
//                self?.tag = isoTag
//                self?.callback?(.success(isoTag))
//                self?.callback = nil
//            }
//        }
//    }
//}
//
