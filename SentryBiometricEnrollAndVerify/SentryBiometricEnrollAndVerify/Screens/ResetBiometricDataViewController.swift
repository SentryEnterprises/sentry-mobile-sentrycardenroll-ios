//
//  ResetBiometricDataViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/9/24.
//

import UIKit
import CoreNFC
import SentrySDK

/**
 Reset biometric data screen. Provides functionality to reset biometric enrollment data. This will not be used in a production environment.
 */
class ResetBiometricDataViewController: UIViewController {
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func resetButtonTouched(_ sender: Any) {
        resetButton.isUserInteractionEnabled = false
        resetData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Reset Biometric Data"
    }
    
    // resets biometric data on the card; the card is no longer enrolled after this method completes
    private func resetData() {
        Task { [weak self] in
            defer {
                self?.resetButton.isUserInteractionEnabled = true
            }
            
            do {
                // perform a biometric data reset on the card. starts NFC scanning.
                try await self?.sentrySDK.resetCard()
                
                let alert = UIAlertController(title: "Data Reset", message: "Biometric data reset. This card is no longer enrolled.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } catch (let error) {
                print("!!! Error resetting biometric data: \(error)")
                
                var errorMessage = error.localizedDescription
                
                if let readerError = error as? NFCReaderError {
                    errorMessage = readerError.errorDescription ?? error.localizedDescription
                }
                
                if let sdkError = error as? SentrySDKError {
                    errorMessage = sdkError.errorDescription ?? error.localizedDescription
                }
                
                let errorCode = (error as NSError).code
                
                // if the user cancelled or the session timed out, don't display this as an error
                if errorCode != NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue && errorCode != NFCReaderError.readerSessionInvalidationErrorSessionTimeout.rawValue {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
