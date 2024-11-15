# SentryCard Enroll 📱🏷️ - Biometric fingerprint enrollment and verification
#### Backed with CoreNFC

## Aims
Provides a simplistic demonstration of enrolling a fingerprint onto a SentryCard and verifying the enrolled fingerprint, and can be used as a reference application for developers to integrate such functionality into their applications.

## Version
Release - 1.0.2

## Environment

### Xcode Local
Tested on | Latest | Compatible
--------- | ------ | ----------
iOS       | 16.5   | >= 16.5

* Apple Watch is not supported. iPad / Mac is compatible with CoreNFC but there is no hardware to support this feature. *

### Xcode Cloud ☁️
Compatible ✅

*Xcode Cloud requires Apple Developer Program membership.*

## Requirements
This is meant for use with the SentryCard from Sentry Enterprises. The SentryCard must contain the following Java Card applets:
1. The Enroll applet from IDEX (com.idex.enroll.cap).
2. The CVM applet from JNet (com.jnet.CDCVM.cap).
3. The [BioVerify applet](https://github.com/SentryEnterprises/sentry-applet-bioverify) from Sentry (com.sentry.bioverify.cap)

These applets should come pre-installed on SentryCards.



## Guide

###  IMPORTANT - ABOUT THE ENROLL CODE
If no enroll code is set, the application sets the enroll code to "111111" by default. This mobile app is compatible with any card that has the IDEX Enroll applet, which may have been installed with a different script that sets the enroll code. If the install script used to initialize the card includes setting the enroll code, this value MUST match the default enroll code value. If the install script does not set the enroll code, this application will set the enroll code to the default value. If the application starts getting `0x63CX` errors when scanning the card, this indicates that the enroll codes do not match.
 
Users can set the enroll code used by this application through the iPhone Settings application:

    1. Close the application (the application must be fully closed, not just in the background).
    2. Open Settings.
    3. Navigate to 'SentryCard Enroll'.
    4. Enter the desired enroll code in the `Sentry Enroll Settings` box.
 
The enroll code MUST be 4-6 characters in length. Less than four (4) characters causes the app to throw an error. Any characters after the 6th are ignored.

### JCShell Scripts
This repository includes an optional script for installing the IDEX Enroll applet, the JNet CVM applet, and the Sentry BioVerify applet onto a SentryCard.  For most developers, this is not necessary because these applets come pre-installed.  

This script is meant for use with the JCShell available from NXP. 

The installEnroll.jcsh script file (in the Scripts directory) will reset the SentryCard and install the required applets. The script expects the 'com.idex.enroll.cap', 'com.jne.CDCVM.cap', and 'com.sentry.bioverify.cap' applets to be located at the path <script launch directory>/cap/.  


## License
MIT
