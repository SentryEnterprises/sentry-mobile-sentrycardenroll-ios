//
//  OptionsViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import CoreNFC
import SentrySDK

/**
 Simple options screen for this example app.
 */
class OptionsViewController: UITableViewController {
    // MARK: - Private Properties
    
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())

    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Options"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            if let vc = UIStoryboard(name: "ResetBiometricData", bundle: .main).instantiateViewController(withIdentifier: "ResetBiometricData") as? ResetBiometricDataViewController {
                vc.loadViewIfNeeded()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            if let vc = UIStoryboard(name: "VersionInformation", bundle: .main).instantiateViewController(withIdentifier: "VersionInformation") as? VersionInformationViewController {
                vc.loadViewIfNeeded()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
