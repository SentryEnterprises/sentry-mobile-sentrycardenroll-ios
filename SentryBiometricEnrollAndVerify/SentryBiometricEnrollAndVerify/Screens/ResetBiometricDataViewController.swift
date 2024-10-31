//
//  ResetBiometricDataViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import CoreNFC
import SentrySDK

/**
 Reset biometric data screen. Provides functionality to reset biometric enrollment data. This will not be used in a production environment.
 */
class ResetBiometricDataViewController: UIViewController {
    // MARK: - Private Properties
    
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var resetInstructionsTitleLabel: UILabel!
    @IBOutlet weak var resetStepsLabel: UILabel!
    @IBOutlet weak var resetTitleLabel: UILabel!
    @IBOutlet weak var resetInstructionsLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var placeCard: UIImageView!
    @IBOutlet weak var placeCardLabel: UILabel!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var placeCardOutline: UIImageView!

    
    @IBAction func resetButtonTouched(_ sender: Any) {
        resetButton.isUserInteractionEnabled = false
        
        placeCard.isHidden = false
        placeCardOutline.isHidden = false
        arrowDown.isHidden = false
        arrowLeft.isHidden = false
        placeCardLabel.isHidden = false
        
        placeCard.image = UIImage(named: "card")
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
            self.placeCardOutline.layer.opacity = 0.1
        }

        resetData()
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "resetData.screen.navigationTitle".localized
        
        resetInstructionsLabel.text = "resetData.screen.instructions".localized
        resetButton.setTitle("resetData.screen.button".localized, for: .normal)
        resetTitleLabel.text = "resetData.screen.title".localized
        resetStepsLabel.text = "resetData.screen.steps".localized
        resetInstructionsTitleLabel.text = "resetData.screen.instructionsTitle".localized
        
        sentrySDK.connectionDelegate = self
    }
    
    
    // MARK: - Private Methods
    
    // resets biometric data on the card; the card is no longer enrolled after this method completes
    private func resetData() {
        Task { [weak self] in
            defer {
                self?.resetButton.isUserInteractionEnabled = true
                
                self?.placeCard.isHidden = true
                self?.placeCardOutline.isHidden = true
                self?.arrowDown.isHidden = true
                self?.arrowLeft.isHidden = true
                self?.placeCardLabel.isHidden = true
                self?.placeCardOutline.layer.removeAllAnimations()
                self?.placeCard.layer.removeAllAnimations()
            }
            
            do {
                // perform a biometric data reset on the card. starts NFC scanning.
                try await self?.sentrySDK.resetCard()
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "resetData.finished.title".localized, message: "resetData.finished.message".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
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
                    let alert = UIAlertController(title: "global.error".localized, message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}


extension ResetBiometricDataViewController: SentrySDKConnectionDelegate {
    func connected(session: NFCReaderSession, isConnected: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isConnected {
                print("*** Showing card connected ***")
                self?.placeCardOutline.isHidden = true
                self?.placeCardOutline.layer.removeAllAnimations()
                self?.arrowDown.isHidden = true
                self?.arrowLeft.isHidden = true
                self?.placeCardLabel.isHidden = true
                self?.placeCard.layer.opacity = 0.8
                self?.placeCard.image = UIImage(named: "card_highlight")
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                    self?.placeCard.layer.opacity = 0.5
                }
            } 
        }
    }
}
