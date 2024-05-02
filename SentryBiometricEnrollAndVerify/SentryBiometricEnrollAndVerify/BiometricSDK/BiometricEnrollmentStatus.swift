//
//  BiometricEnrollmentStatus.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/1/24.
//

import Foundation

enum BiometricMode: UInt8 {
    case enrollment = 0
    case verificationWithTopUp = 1
    case verificationWithoutTopUp = 2
}
struct BiometricEnrollmentStatus {
    public let maximumFingerprints: UInt8 // usually 1, due to only 1 finger can be saved on card for now
    public let enrolledTouches: UInt8 // from 0 to 6
    public let remainingTouches: UInt8 // from 0 to 6
    public let mode: BiometricMode // is in Enrollment or Verification mode
}
