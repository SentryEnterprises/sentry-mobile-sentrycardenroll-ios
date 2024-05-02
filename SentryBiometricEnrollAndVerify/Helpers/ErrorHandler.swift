//
//  ErrorHandler.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/2/24.
//

import Foundation
import CoreNFC

class ErrorHandler {
    func getErrorMessage(error: Error) -> String? {
        
        let nsError = error as NSError
            
        switch nsError.code {
        case Int(SwiftCallbackError.dataInIsNil.rawValue):
            return "(\(nsError.code)) Tag communication callback function received an input buffer that is nil."
            
        case Int(SwiftCallbackError.commandAPDUInvalidParameterLength.rawValue):
            return "(\(nsError.code)) Unable to create ISO 7816 APDU command."
            
        case Int(SwiftCallbackError.sendCommandError.rawValue):
            return "(\(nsError.code)) Unable to send APDU command."

        case NFCReaderError.readerErrorUnsupportedFeature.rawValue:
            return "(\(nsError.code)) Reader Error: Unsupported Feature."

        case NFCReaderError.readerErrorSecurityViolation.rawValue:
            return "(\(nsError.code)) Reader Error: Security Violation."

        case NFCReaderError.readerErrorInvalidParameter.rawValue:
            return "(\(nsError.code)) Reader Error: Invalid Parameter."

        case NFCReaderError.readerErrorInvalidParameterLength.rawValue:
            return "(\(nsError.code)) Reader Error: Invalid Parameter Length."

        case NFCReaderError.readerErrorParameterOutOfBound.rawValue:
            return "(\(nsError.code)) Reader Error: Parameter Out of Bounds."

        case NFCReaderError.readerErrorRadioDisabled.rawValue:
            return "(\(nsError.code)) Reader Error: Radio Disabled."

        case NFCReaderError.readerTransceiveErrorTagConnectionLost.rawValue:
            return "(\(nsError.code)) Reader Transceive Error: Tag Connection Lost."

        case NFCReaderError.readerTransceiveErrorRetryExceeded.rawValue:
            return "(\(nsError.code)) Reader Transceive Error: Retry Exceeded."

        case NFCReaderError.readerTransceiveErrorTagResponseError.rawValue:
            return "(\(nsError.code)) Reader Transceive Error: Tag Response Error."

        case NFCReaderError.readerTransceiveErrorSessionInvalidated.rawValue:
            return "(\(nsError.code)) Reader Transceive Error: Session Invalidated."

        case NFCReaderError.readerTransceiveErrorTagNotConnected.rawValue:
            return "(\(nsError.code)) Reader Transceive Error: Tag Not Connected."

        case NFCReaderError.readerTransceiveErrorPacketTooLong.rawValue:
            return "(\(nsError.code)) Reader Transceive Error: Packet Too Long."

        case NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue:
            return nil // "(\(nsError.code)) Reader Session Error: User Cancelled."

        case NFCReaderError.readerSessionInvalidationErrorSessionTimeout.rawValue:
            return nil // "(\(nsError.code)) Reader Session Error: Session Timeout."

        case NFCReaderError.readerSessionInvalidationErrorSessionTerminatedUnexpectedly.rawValue:
            return "(\(nsError.code)) Reader Session Error: Session Terminated Unexpectedly."

        case NFCReaderError.readerSessionInvalidationErrorSystemIsBusy.rawValue:
            return "(\(nsError.code)) Reader Session Error: System is Busy."

        case NFCReaderError.readerSessionInvalidationErrorFirstNDEFTagRead.rawValue:
            return "(\(nsError.code)) Reader Session Error: First NDEF tag read."

        case NFCReaderError.tagCommandConfigurationErrorInvalidParameters.rawValue:
            return "(\(nsError.code)) Tag Command Configuration Error: Invalid Parameters."

        case NFCReaderError.ndefReaderSessionErrorTagNotWritable.rawValue:
            return "(\(nsError.code)) NDEF Reader session Error: Tag Not Writable."

        case NFCReaderError.ndefReaderSessionErrorTagUpdateFailure.rawValue:
            return "(\(nsError.code)) NDEF Reader session Error: Tag Update Failure."

        case NFCReaderError.ndefReaderSessionErrorTagSizeTooSmall.rawValue:
            return "(\(nsError.code)) NDEF Reader session Error: Tag Size Too Small."

        case NFCReaderError.ndefReaderSessionErrorZeroLengthMessage.rawValue:
            return "(\(nsError.code)) NDEF Reader session Error: Zero Length Message."

        case APDUResponseCodes.noMatchFound.rawValue:
            return "(6300) No match found during qualification touch."
            
        case APDUResponseCodes.communicationFailure.rawValue:
            return "(6741) Non-specific communication failure."
            
        case APDUResponseCodes.fingerRemoved.rawValue:
            return "(6745) Finger removed before scan completed."
            
        case APDUResponseCodes.poorImageQuality.rawValue:
            return "(6747) Poor image quality."
            
        case APDUResponseCodes.userTimeoutExpired.rawValue:
            return "(6748) User timeout expired."
            
        case APDUResponseCodes.hostInterfaceTimeoutExpired.rawValue:
            return "(6749) Host interface timeout expired."
            
        case APDUResponseCodes.conditionOfUseNotSatisfied.rawValue:
            return "(6985) Conditions of use not satisfied."
            
        case APDUResponseCodes.notEnoughMemory.rawValue:
            return "(6A84) Not enough memory space in the file."

        default:
            return "Unknown Error Code: \(nsError.code)"
        }
    }
}
