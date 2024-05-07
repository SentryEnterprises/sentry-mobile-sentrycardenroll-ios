//
//  NFCReaderError+LocalizedError.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/2/24.
//

import Foundation
import CoreNFC

/**
 Helper extension provided mainly as an aid in debugging.
 */
extension NFCReaderError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch code {
        case .readerErrorUnsupportedFeature:
            return "(\(code)) Reader Error: Unsupported Feature."
            
        case .readerErrorSecurityViolation:
            return "(\(code)) Reader Error: Security Violation."
            
        case .readerErrorInvalidParameter:
            return "(\(code)) Reader Error: Invalid Parameter."
            
        case .readerErrorInvalidParameterLength:
            return "(\(code)) Reader Error: Invalid Parameter Length."
            
        case .readerErrorParameterOutOfBound:
            return "(\(code)) Reader Error: Parameter Out of Bounds."
            
        case .readerErrorRadioDisabled:
            return "(\(code)) Reader Error: Radio Disabled."
            
        case .readerTransceiveErrorTagConnectionLost:
            return "(\(code)) Reader Transceive Error: Tag Connection Lost."
            
        case .readerTransceiveErrorRetryExceeded:
            return "(\(code)) Reader Transceive Error: Retry Exceeded."
            
        case .readerTransceiveErrorTagResponseError:
            return "(\(code)) Reader Transceive Error: Tag Response Error."
            
        case .readerTransceiveErrorSessionInvalidated:
            return "(\(code)) Reader Transceive Error: Session Invalidated."
            
        case .readerTransceiveErrorTagNotConnected:
            return "(\(code)) Reader Transceive Error: Tag Not Connected."
            
        case .readerTransceiveErrorPacketTooLong:
            return "(\(code)) Reader Transceive Error: Packet Too Long."
            
        case .readerSessionInvalidationErrorUserCanceled:
            return "(\(code)) Reader Session Error: User Cancelled."
            
        case .readerSessionInvalidationErrorSessionTimeout:
            return "(\(code)) Reader Session Error: Session Timeout."
            
        case .readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
            return "(\(code)) Reader Session Error: Session Terminated Unexpectedly."
            
        case .readerSessionInvalidationErrorSystemIsBusy:
            return "(\(code)) Reader Session Error: System is Busy."
            
        case .readerSessionInvalidationErrorFirstNDEFTagRead:
            return "(\(code)) Reader Session Error: First NDEF tag read."
            
        case .tagCommandConfigurationErrorInvalidParameters:
            return "(\(code)) Tag Command Configuration Error: Invalid Parameters."
            
        case .ndefReaderSessionErrorTagNotWritable:
            return "(\(code)) NDEF Reader session Error: Tag Not Writable."
            
        case .ndefReaderSessionErrorTagUpdateFailure:
            return "(\(code)) NDEF Reader session Error: Tag Update Failure."
            
        case .ndefReaderSessionErrorTagSizeTooSmall:
            return "(\(code)) NDEF Reader session Error: Tag Size Too Small."
            
        case .ndefReaderSessionErrorZeroLengthMessage:
            return "(\(code)) NDEF Reader session Error: Zero Length Message."
            
        default:
            return "(\(code)) Reader Error: Unknown Error Code"
        }
    }
}
