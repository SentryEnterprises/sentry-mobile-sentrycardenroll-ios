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
extension NFCReaderError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch code {
        case .readerErrorUnsupportedFeature:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Error: Unsupported Feature."
            
        case .readerErrorSecurityViolation:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Error: Security Violation."
            
        case .readerErrorInvalidParameter:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Error: Invalid Parameter."
            
        case .readerErrorInvalidParameterLength:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Error: Invalid Parameter Length."
            
        case .readerErrorParameterOutOfBound:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Error: Parameter Out of Bounds."
            
        case .readerErrorRadioDisabled:
            return "The NFC communication hardware appears to be disabled.\n\n(\(code)) Reader Error: Radio Disabled."
            
        case .readerTransceiveErrorTagConnectionLost:
            return "Connection to the card was lost. Move the card away from the phone and try again.\n\n(\(code)) Reader Transceive Error: Tag Connection Lost."
            
        case .readerTransceiveErrorRetryExceeded:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Transceive Error: Retry Exceeded."
            
        case .readerTransceiveErrorTagResponseError:
            return "Connection made with the card, but the card did not respond. Move the card away from the phone and try again.\n\n(\(code)) Reader Transceive Error: Tag Response Error."
            
        case .readerTransceiveErrorSessionInvalidated:
            return "This card does not appear to have the correct applet installed. Please try a different card.\n\n(\(code)) Reader Transceive Error: Session Invalidated."
            
        case .readerTransceiveErrorTagNotConnected:
            return "Connection made with the card, but the card did not respond. Move the card away from the phone and try again.\n\n(\(code)) Reader Transceive Error: Tag Not Connected."
            
        case .readerTransceiveErrorPacketTooLong:
            return "Connection made with the card, but the card did not respond in the expected manner. Move the card away from the phone and try again.\n\n(\(code)) Reader Transceive Error: Packet Too Long."
            
        case .readerSessionInvalidationErrorUserCanceled:
            return "The user cancelled the connection.\n\n(\(code)) Reader Session Error: User Cancelled."
            
        case .readerSessionInvalidationErrorSessionTimeout:
            return "No compatible device was detected within the time limit.\n\n(\(code)) Reader Session Error: Session Timeout."
            
        case .readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
            return "The communication session was terminated unexpectedly. Move the card away from the phone and try again.\n\n(\(code)) Reader Session Error: Session Terminated Unexpectedly."
            
        case .readerSessionInvalidationErrorSystemIsBusy:
            return "The NFC reader needs more time to reset. Move the card away from the phone and try again.\n\n(\(code)) Reader Session Error: System is Busy."
            
            
        // Note: The following errors are associated with NDEF tag reading and writing, which is not supported
        // by this SDK but are included for completeness.
            
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
