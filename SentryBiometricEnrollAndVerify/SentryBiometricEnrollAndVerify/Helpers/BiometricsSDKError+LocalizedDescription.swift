//
//  BiometricsSDKError+LocalizedDescription.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/7/24.
//

import Foundation
import SentrySDK

/**
 Provides a meaningful error message.
 */
extension SentrySDKError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
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
            case APDUResponseCode.noMatchFound.rawValue:
                return "(6300) No match found during qualification touch."
                
            case APDUResponseCode.pinIncorrectThreeTriesRemain.rawValue:
                return "(0x63C3) PIN incorrect, three tries remaining."
                
            case APDUResponseCode.pinIncorrectTwoTriesRemain.rawValue:
                return "(0x63C2) PIN incorrect, two tries remaining."
                
            case APDUResponseCode.pinIncorrectOneTriesRemain.rawValue:
                return "(0x63C1) PIN incorrect, one try remaining."
                
            case APDUResponseCode.pinIncorrectZeroTriesRemain.rawValue:
                return "(0x63C0) PIN incorrect, zero tries remaining, please use the appropriate script file to reset your card."

            case APDUResponseCode.wrongLength.rawValue:
                return "(0x6700) Length parameter incorrect."
                
            case APDUResponseCode.formatNotCompliant.rawValue:
                return "(0x6701) Command APDU format not compliant with this standard."
                
            case APDUResponseCode.lengthValueNotTheOneExpected.rawValue:
                return "(0x6702) The length parameter value is not the one expected."

            case APDUResponseCode.communicationFailure.rawValue:
                return "(6741) Non-specific communication failure."
                
            case APDUResponseCode.fingerRemoved.rawValue:
                return "(6745) Finger removed before scan completed."
                
            case APDUResponseCode.poorImageQuality.rawValue:
                return "(6747) Poor image quality."
                
            case APDUResponseCode.userTimeoutExpired.rawValue:
                return "(6748) User timeout expired."
                
            case APDUResponseCode.hostInterfaceTimeoutExpired.rawValue:
                return "(6749) Host interface timeout expired."
                
            case APDUResponseCode.conditionOfUseNotSatisfied.rawValue:
                return "(6985) Conditions of use not satisfied."
                
            case APDUResponseCode.notEnoughMemory.rawValue:
                return "(6A84) Not enough memory space in the file."

            case APDUResponseCode.wrongParameters.rawValue:
                return "(0x6B00) Parameter bytes are invalid."
                
            case APDUResponseCode.instructionByteNotSupported.rawValue:
                return "(0x6D00) Instruction byte not supported or invalid."
                
            case APDUResponseCode.classByteNotSupported.rawValue:
                return "(0x6E00) Class byte not supported or invalid."

            case APDUResponseCode.commandAborted.rawValue:
                return "(6F00) Command aborted – more exact diagnosis not possible (e.g., operating system error)."
                
            case APDUResponseCode.noPreciseDiagnosis.rawValue:
                return "(0x6F87) No precise diagnosis."
                
            case APDUResponseCode.cardDead.rawValue:
                return "(6FFF) Card dead (overuse)."

            default:
                return "Unknown Error Code: \(statusWord)"
            }
        }
    }
}
