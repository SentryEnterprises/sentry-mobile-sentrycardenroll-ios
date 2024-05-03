//
//  AppDelegate.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Note: This simply sets the version and build number to the current values
        AppSettings.setVersionAndBuildNumber()

        return true
    }
}

