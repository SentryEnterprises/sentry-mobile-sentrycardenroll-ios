//
//  AppDelegate.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
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

