//
//  AppSettings.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/3/24.
//

import Foundation

/**
 Utility class to extract data from application settings.
 */
class AppSettings {
    
    static let PIN_NUMBER = "pin_number"
    static let BUILD_NUMBER = "build_number"
    static let VERSION_NUMBER = "version_number"
    
    /**
     Retrieves the PIN.
     
     - Returns: An array of `UInt8` containing the digits of the PIN.
     */
    class func getPIN() -> [UInt8] {
        let pinNumber = UserDefaults.standard.string(forKey: PIN_NUMBER)
        if let pinNumber = pinNumber {
            let pinDigits = pinNumber.compactMap { return UInt8(String($0)) }
            
            if pinDigits.count >= 6 {
                return Array(pinDigits[...5])
            } else {
                return pinDigits
            }
        } else {
            return [1, 2, 3, 4]
        }
    }
    
    /**
     Sets the version and build number so the user can see these in the Settings app.
     */
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: VERSION_NUMBER)
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: BUILD_NUMBER)
    }
}
