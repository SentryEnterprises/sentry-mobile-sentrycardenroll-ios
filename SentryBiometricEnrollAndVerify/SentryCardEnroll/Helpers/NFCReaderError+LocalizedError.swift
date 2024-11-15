//
//  NFCReaderError+LocalizedError.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import Foundation
import CoreNFC

/**
 Helper extension provided mainly as an aid in debugging.
 */
extension NFCReaderError: @retroactive LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch code {
        case .readerErrorUnsupportedFeature: return "nfcReader.error.unsupportedFeature".localized
            
        case .readerErrorSecurityViolation: return "nfcReader.error.securityViolation".localized
            
        case .readerErrorInvalidParameter: return "nfcReader.error.invalidParameter".localized
            
        case .readerErrorInvalidParameterLength: return "nfcReader.error.invalidParameterLength".localized
            
        case .readerErrorParameterOutOfBound: return "nfcReader.error.parameterOutOfBound".localized
            
        case .readerErrorRadioDisabled: return "nfcReader.error.radioDisabled".localized
            
        case .readerTransceiveErrorTagConnectionLost: return "nfcReader.transeiveError.tagConnectionLost".localized
            
        case .readerTransceiveErrorRetryExceeded: return "nfcReader.transeiveError.retryExceeded".localized
            
        case .readerTransceiveErrorTagResponseError: return "nfcReader.transeiveError.tagResponseError".localized
            
        case .readerTransceiveErrorSessionInvalidated: return "nfcReader.transeiveError.sessionInvalidated".localized
            
        case .readerTransceiveErrorTagNotConnected: return "nfcReader.transeiveError.tagNotConnected".localized
            
        case .readerTransceiveErrorPacketTooLong: return "nfcReader.transeiveError.packetTooLong".localized
            
        case .readerSessionInvalidationErrorUserCanceled: return "nfcReader.sessionInvalidationError.userCanceled".localized
            
        case .readerSessionInvalidationErrorSessionTimeout: return "nfcReader.sessionInvalidationError.sessionTimeout".localized
            
        case .readerSessionInvalidationErrorSessionTerminatedUnexpectedly: return "nfcReader.sessionInvalidationError.sessionTerminatedUnexpectedly".localized
            
        case .readerSessionInvalidationErrorSystemIsBusy: return "nfcReader.sessionInvalidationError.systemIsBusy".localized
            
        default: return "nfcReader.defaultError".localized
        }
    }
}
