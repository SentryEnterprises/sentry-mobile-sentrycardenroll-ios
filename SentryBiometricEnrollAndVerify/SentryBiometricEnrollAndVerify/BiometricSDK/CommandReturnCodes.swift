//
//  CommandReturnCodes.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/1/24.
//

import Foundation

enum CommandReturnCodes: UInt16 {
    case success = 0x9000
    case conditionsNotSatisfied = 0x6985
}
