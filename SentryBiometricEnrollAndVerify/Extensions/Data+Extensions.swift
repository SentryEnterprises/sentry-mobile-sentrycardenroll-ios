//
//  Data+Extensions.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import Foundation

extension Data {
    func toHex() -> String {
        map {
            return String(format:"%02X", $0)
        }.joined(separator: "").uppercased()
    }
}
