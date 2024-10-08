//
//  BiometricsSDKError+LocalizedDescription.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
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
        case .enrollCodeDigitOutOfBounds: return "sdkError.enrollCode.digitOutOfBounds".localized
            
        case .enrollCodeLengthOutOfBounds: return "sdkError.enrollCode.lengthOutOfBounds".localized
            
        case .enrollmentStatusBufferTooSmall: return "sdkError.enrollmentStatus.bufferTooSmall".localized
            
        case .invalidAPDUCommand: return "sdkError.invalidAPDUCommand".localized
            
        case .connectedWithoutTag: return "sdkError.connectedWithoutTag".localized
            
        case .incorrectTagFormat: return "sdkError.incorrectTagFormat".localized
            
        case .secureChannelInitializationError: return "sdkError.secureChannelInitializationError".localized
            
        case .cardOSVersionError: return "sdkError.cardOSVersionError".localized
            
        case .keyGenerationError: return "sdkError.keyGenerationError".localized
            
        case .sharedSecretExtractionError: return "sdkError.sharedSecretExtractionError".localized
            
        case .secureCommunicationNotSupported: return "sdkError.secureCommunicationNotSupported".localized
            
        case .dataSizeNotSupported: return "sdkError.dataSizeNotSupported".localized
            
        case .cvmAppletNotAvailable: return "sdkError.cvmApplet.notAvailable".localized
            
        case .cvmAppletBlocked: return "sdkError.cvmApplet.blocked".localized
            
        case .cvmAppletError: return "sdkError.cvmApplet.error".localized
            
        case .bioverifyAppletNotInstalled: return "sdkError.bioverifyApplet.notInstalled".localized
            
        case .bioVerifyAppletWrongVersion: return "sdkError.bioVerifyApplet.wrongVersion".localized
            
        case .enrollModeNotAvailable: return "sdkError.enrollModeNotAvailable".localized
            
        case .unsupportedEnrollAppletVersion: return "sdkError.enrollApplet.wrongVersion".localized

        case .enrollVerificationError: return "sdkError.enrollVerificationError".localized
      
        case .invalidFingerIndex: return "sdkError.invalidFingerIndex".localized

        case .apduCommandError(let statusWord):
            switch statusWord {
            case APDUResponseCode.noMatchFound.rawValue: return "sdkError.apduCommandError.noMatchFound".localized
                
            case APDUResponseCode.enrollCodeIncorrectThreeTriesRemain.rawValue: return "sdkError.apduCommandError.enrollCodeIncorrectThreeTriesRemain".localized
                
            case APDUResponseCode.enrollCodeIncorrectTwoTriesRemain.rawValue: return "sdkError.apduCommandErrorenrollCodeIncorrectTwoTriesRemain".localized
                
            case APDUResponseCode.enrollCodeIncorrectOneTriesRemain.rawValue: return "sdkError.apduCommandError.enrollCodeIncorrectOneTriesRemain".localized
                
            case APDUResponseCode.enrollCodeIncorrectZeroTriesRemain.rawValue: return "sdkError.apduCommandError.enrollCodeIncorrectZeroTriesRemain".localized

            case APDUResponseCode.wrongLength.rawValue: return "sdkError.apduCommandError.wrongLength".localized
                
            case APDUResponseCode.formatNotCompliant.rawValue: return "sdkError.apduCommandError.formatNotCompliant".localized
                
            case APDUResponseCode.lengthValueNotTheOneExpected.rawValue: return "sdkError.apduCommandError.lengthValueNotTheOneExpected".localized

            case APDUResponseCode.communicationFailure.rawValue: return "sdkError.apduCommandError.communicationFailure".localized
                
            case APDUResponseCode.fingerRemoved.rawValue: return "sdkError.apduCommandError.fingerRemoved".localized
                
            case APDUResponseCode.poorImageQuality.rawValue: return "sdkError.apduCommandError.poorImageQuality".localized
                
            case APDUResponseCode.userTimeoutExpired.rawValue: return "sdkError.apduCommandError.userTimeoutExpired".localized
                
            case APDUResponseCode.hostInterfaceTimeoutExpired.rawValue: return "sdkError.apduCommandError.hostInterfaceTimeoutExpired".localized
                
            case APDUResponseCode.conditionOfUseNotSatisfied.rawValue: return "sdkError.apduCommandError.conditionOfUseNotSatisfied".localized
                
            case APDUResponseCode.notEnoughMemory.rawValue: return "sdkError.apduCommandError.notEnoughMemory".localized

            case APDUResponseCode.wrongParameters.rawValue: return "sdkError.apduCommandError.wrongParameters".localized
                
            case APDUResponseCode.instructionByteNotSupported.rawValue: return "sdkError.apduCommandError.instructionByteNotSupported".localized
                
            case APDUResponseCode.classByteNotSupported.rawValue: return "sdkError.apduCommandError.classByteNotSupported".localized

            case APDUResponseCode.commandAborted.rawValue: return "sdkError.apduCommandError.commandAborted".localized
                
            case APDUResponseCode.noPreciseDiagnosis.rawValue: return "sdkError.apduCommandError.noPreciseDiagnosis".localized
                
            case APDUResponseCode.cardDead.rawValue: return "sdkError.apduCommandError.cardDead".localized

            case APDUResponseCode.calibrationError.rawValue: return "sdkError.apduCommandError.calibrationError".localized
                
            default: return "sdkError.apduCommandError.default".localized
            }
        }
    }
}
