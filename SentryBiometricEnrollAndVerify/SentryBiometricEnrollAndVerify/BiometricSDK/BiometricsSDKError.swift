//
//  BiometricsSDKError.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import Foundation

/**
 Custom errors thrown by the `BiometricsSDK`, unrelated to NFC communication errors.
 */
enum BiometricsSDKError: Error {
    /// Individual PIN digits must be in the range 0 - 9.
    case pinDigitOutOfBounds
    
    /// The PIN must be between 4 - 6 characters in length.
    case pinLengthOutOfBounds
    
    /// The buffer returned from querying the card for its biometric enrollment status was unexpectedly too small.
    case enrollmentStatusBufferTooSmall
    
    /// The buffer used in the `NFCISO7816APDU` constructor was not a valid `APDU` command.
    case invalidAPDUCommand
    
    /// We have an NFC connection, but no NFC tag.
    case connectedWithoutTag
    
    /// We have an NFC connection, but no ISO7816 tag.
    case incorrectTagFormat
    
    /// APDU specific error.
    case apduCommandError(Int)
}

/**
 Provides a meaningful error message.
 */
extension BiometricsSDKError: LocalizedError {
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .pinDigitOutOfBounds:
            return "Individual PIN digits must be in the range 0 - 9."
            
        case .pinLengthOutOfBounds:
            return "The PIN must be between 4 - 6 characters in length."
            
        case .enrollmentStatusBufferTooSmall:
            return "The buffer returned from querying the card for its biometric enrollment status was unexpectedly too small."
            
        case .invalidAPDUCommand:
            return "The buffer used in the `NFCISO7816APDU` constructor was not a valid `APDU` command."
            
        case .connectedWithoutTag:
            return "NFC connection to card exists, but no tag."
            
        case .incorrectTagFormat:
            return "NFC connection to card exists, but unable to detect ISO7816 format tag."
            
        case .apduCommandError(let statusWord):
            switch statusWord {
            case APDUResponseCodes.noMatchFound.rawValue:
                return "(6300) No match found during qualification touch."
                
            case APDUResponseCodes.pinIncorrectThreeTriesRemain.rawValue:
                return "(0x63C3) PIN incorrect, three tries remaining."
                
            case APDUResponseCodes.pinIncorrectTwoTriesRemain.rawValue:
                return "(0x63C2) PIN incorrect, two tries remaining."
                
            case APDUResponseCodes.pinIncorrectOneTriesRemain.rawValue:
                return "(0x63C1) PIN incorrect, one try remaining."
                
            case APDUResponseCodes.pinIncorrectZeroTriesRemain.rawValue:
                return "(0x63C0) PIN incorrect, zero tries remaining, please use the appropriate script file to reset your card."

            case APDUResponseCodes.wrongLength.rawValue:
                return "(0x6700) Length parameter incorrect."
                
            case APDUResponseCodes.formatNotCompliant.rawValue:
                return "(0x6701) Command APDU format not compliant with this standard."
                
            case APDUResponseCodes.lengthValueNotTheOneExpected.rawValue:
                return "(0x6702) The length parameter value is not the one expected."

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

            case APDUResponseCodes.wrongParameters.rawValue:
                return "(0x6B00) Parameter bytes are invalid."
                
            case APDUResponseCodes.instructionByteNotSupported.rawValue:
                return "(0x6D00) Instruction byte not supported or invalid."
                
            case APDUResponseCodes.classByteNotSupported.rawValue:
                return "(0x6E00) Class byte not supported or invalid."

            case APDUResponseCodes.commandAborted.rawValue:
                return "(6F00) Command aborted – more exact diagnosis not possible (e.g., operating system error)."
                
            case APDUResponseCodes.noPreciseDiagnosis.rawValue:
                return "(0x6F87) No precise diagnosis."
                
            case APDUResponseCodes.cardDead.rawValue:
                return "(6FFF) Card dead (overuse)."

            default:
                return "Unknown Error Code: \(statusWord)"
            }
        }
    }
}
