//
//  APDUResponseCodes.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/2/24.
//

import Foundation

/**
 Common `APDU` command responses.
 */
enum APDUResponseCodes: Int {
    case noMatchFound = 0x6300
    case communicationFailure = 0x6741
    case fingerRemoved = 0x6745
    case poorImageQuality = 0x6747
    case userTimeoutExpired = 0x6748
    case hostInterfaceTimeoutExpired = 0x6749
    case conditionOfUseNotSatisfied = 0x6985
    case notEnoughMemory = 0x6A84
    case commandAborted = 0x6F00
    case cardDead = 0x6FFF
}
