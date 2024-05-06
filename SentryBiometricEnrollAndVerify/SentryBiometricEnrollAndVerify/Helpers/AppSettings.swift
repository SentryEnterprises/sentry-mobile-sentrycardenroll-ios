//
//  AppSettings.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/3/24.
//

/**
 IMPORTANT - ABOUT THE PIN
 -----------------------
 If the install script used to initialize the card includes setting the PIN, this value MUST match the default PIN value below. If the install script
 does not set the PIN, this application will set the PIN to the default value. If the application starts getting `0x63CX` errors when scanning
 the card, this indicates that the PINs do not match.
 
 Users can set the PIN used by this application through the iPhone Settings application:
    1. Close the application (the application must be fully closed, not just in the background).
    2. Open Settings.
    3. Navigate to 'Sentry Enroll'.
    4. Enter the desired PIN in the `Sentry Enroll Settings` box.
 
    NOTE: The PIN MUST be 4-6 characters in length. Less than four (4) characters causes the app to throw an error. Any characters after
    the 6th are ignored.
 */

import Foundation

/**
 Utility class to extract data from application settings.
 */
class AppSettings {
    
    // The default PIN value. If the PIN is set on the card, this value must match.
    static let DEFAULT_PIN: [UInt8] = [1, 2, 3, 4]
    
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
            return DEFAULT_PIN
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
