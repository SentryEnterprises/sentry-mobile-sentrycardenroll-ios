# Sentry Biometric Enroll and Verify 📱🏷️ - Biometric fingerprint enrollment and verification
#### Backed with CoreNFC

## Aims
Provides a simplistic demonstration of enrolling a fingerprint onto a SentryCard and verifying the enrolled fingerprint, and can be used as a reference application for developers to integrate such functionality into their applications.

## Version
Unreleased - 0.2

## Environment

### Xcode Local
Tested on | Latest | Compatible
--------- | ------ | ----------
iOS       | 16     | >= 16

* Apple Watch is not supported. iPad / Mac is compatible with CoreNFC but there is no hardware to support this feature. *

### Xcode Cloud ☁️
Compatible ✅

*Xcode Cloud requires Apple Developer Program membership.*

## Requirements
This is meant for use with the SentryCard from Sentry Enterprises, with the Enroll applet from IDEX installed on the card. This repository includes the installEnroll.jcsh script file (in the Scripts directory) that will reset the SentryCard and install the Enroll applet. This script is meant for use with the JCShell available from IDEX. Expects the 'com.idex.enroll.cap' applet to be located at the path <current directory>/cap/com.idex.enroll.cap.


## Guide



###  IMPORTANT - ABOUT THE ENROLL CODE
The installEnroll.jcsh script does not set an enroll code on the card. If no enroll code is set, the application sets the enroll code to "1234" by default. This mobile app is compatible with any card that has the IDEX Enroll applet, which may have been installed with a different script that sets the enroll code. If the install script used to initialize the card includes setting the enroll code, this value MUST match the default enroll code value. If the install script does not set the enroll code, this application will set the enroll code to the default value. If the application starts getting `0x63CX` errors when scanning the card, this indicates that the enroll codes do not match.
 
Users can set the enroll code used by this application through the iPhone Settings application:

    1. Close the application (the application must be fully closed, not just in the background).
    2. Open Settings.
    3. Navigate to 'Sentry Enroll'.
    4. Enter the desired enroll code in the `Sentry Enroll Settings` box.
 
The enroll code MUST be 4-6 characters in length. Less than four (4) characters causes the app to throw an error. Any characters after the 6th are ignored.

## License
MIT

