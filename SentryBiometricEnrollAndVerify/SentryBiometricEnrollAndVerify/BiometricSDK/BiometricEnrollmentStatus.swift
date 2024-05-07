//
//  BiometricEnrollmentStatus.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/1/24.
//

import Foundation

/**
 Indicates the card's biometric mode.
 */
enum BiometricMode: UInt8 {
    case enrollment = 0                 // the card is in enrollment mode and will accept fingerprint enrollment commands
    case verificationWithTopUp = 1      // the card is in verification mode
    case verificationWithoutTopUp = 2   // the card is in verification mode
}

/**
 Encapsulates the information returned from querying the card for its enrollment status.
 */
struct BiometricEnrollmentStatus {
    public let maximumFingerprints: UInt8   // usually 1, due to only 1 finger can be saved on the card for now
    public let enrolledTouches: UInt8       // from 0 to 6
    public let remainingTouches: UInt8      // from 0 to 6
    public let mode: BiometricMode          // Enrollment or Verification mode
}
