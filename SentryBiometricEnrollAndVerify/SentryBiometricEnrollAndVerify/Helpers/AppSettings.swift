//
//  AppSettings.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

/**
 IMPORTANT - ABOUT THE ENROLL CODE
 -----------------------
 If the install script used to initialize the card includes setting the enroll code, this value MUST match the default enroll code value below. If the install script
 does not set the enroll code, this application will set the enroll code to the default value. If the application starts getting `0x63CX` errors when scanning
 the card, this indicates that the enroll codes do not match.
 
 Users can set the enroll code used by this application through the iPhone Settings application:
    1. Close the application (the application must be fully closed, not just in the background).
    2. Open Settings.
    3. Navigate to 'Sentry Enroll'.
    4. Enter the desired enroll code in the `Sentry Enroll Settings` box.
 
    NOTE: The enroll code MUST be 4-6 characters in length. Less than four (4) characters causes the app to throw an error. Any characters after
    the 6th are ignored.
 */

import Foundation

/**
 Utility class to extract data from application settings.
 */
class AppSettings {
    
    // The default enroll code value. If the enroll code is set on the card, this value must match.
    static let DEFAULT_ENROLL_CODE: [UInt8] = [1, 2, 3, 4]
    
    static let CODE_NUMBER = "code_number"
    static let BUILD_NUMBER = "build_number"
    static let VERSION_NUMBER = "version_number"
    static let SECURE_COMMUNICATION = "secure_communication"
    
    /**
     Retrieves the enroll code.
     
     - Returns: An array of `UInt8` containing the digits of the enroll code.
     */
    class func getEnrollCode() -> [UInt8] {
        let enrollCode = UserDefaults.standard.string(forKey: CODE_NUMBER)
        if let enrollCode = enrollCode {
            let codeDigits = enrollCode.compactMap { return UInt8(String($0)) }
            
            if codeDigits.count >= 6 {
                return Array(codeDigits[...5])
            } else {
                return codeDigits
            }
        } else {
            return DEFAULT_ENROLL_CODE
        }
    }
    
    /**
     Retrieves the secure communication setting.
     
     - Returns: `True` if secure communication is selected, otherwise `false`.
     */
    class func getSecureCommunicationSetting() -> Bool {
        if !UserDefaults.standard.dictionaryRepresentation().keys.contains(SECURE_COMMUNICATION) {
            UserDefaults.standard.set(true, forKey: SECURE_COMMUNICATION)
        }
        
        let isSecure = UserDefaults.standard.bool(forKey: SECURE_COMMUNICATION)
        return isSecure
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
    
    class func getVersionAndBuildNumber() -> String {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(version).\(build)"
    }
}
