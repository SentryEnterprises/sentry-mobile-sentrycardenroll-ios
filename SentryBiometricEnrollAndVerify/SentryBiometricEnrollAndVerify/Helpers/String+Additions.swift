//
//  String+Additions.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import Foundation

extension String {
    /// Returns a localized version of the string.
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)")
    }
}
