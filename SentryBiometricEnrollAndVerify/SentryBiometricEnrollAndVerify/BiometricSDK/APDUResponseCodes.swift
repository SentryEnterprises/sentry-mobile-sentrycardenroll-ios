//
//  APDUResponseCodes.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import Foundation

/**
 Common `APDU` command responses.
 */
enum APDUResponseCodes: Int {
    case operationSuccessful = 0x9000
    
    case noMatchFound = 0x6300
    case pinIncorrectThreeTriesRemain = 0x63C3
    case pinIncorrectTwoTriesRemain = 0x63C2
    case pinIncorrectOneTriesRemain = 0x63C1
    case pinIncorrectZeroTriesRemain = 0x63C0
    case wrongLength = 0x6700
    case formatNotCompliant = 0x6701
    case lengthValueNotTheOneExpected = 0x6702
    case communicationFailure = 0x6741
    case fingerRemoved = 0x6745
    case poorImageQuality = 0x6747
    case userTimeoutExpired = 0x6748
    case hostInterfaceTimeoutExpired = 0x6749
    case conditionOfUseNotSatisfied = 0x6985
    case notEnoughMemory = 0x6A84
    case wrongParameters = 0x6B00
    case instructionByteNotSupported = 0x6D00
    case classByteNotSupported = 0x6E00
    case commandAborted = 0x6F00
    case noPreciseDiagnosis = 0x6F87
    case cardDead = 0x6FFF
}
