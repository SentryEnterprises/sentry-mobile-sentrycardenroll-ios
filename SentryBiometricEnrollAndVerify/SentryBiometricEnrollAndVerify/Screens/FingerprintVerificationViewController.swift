//
//  FingerprintVerificationViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import Lottie
import CoreNFC
import SentrySDK

/**
 Fingerprint verification screen. Scans the card, and performs a biometric validation of the finger on the fingerprint sensor against the fingerprints recorded on the card.
 */
class FingerprintVerificationViewController: UIViewController {
    // MARK: - Private Properties
    
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())

    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var placeCardHereLabel: UILabel!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var placeCardOutline: UIImageView!
    @IBOutlet weak var placeCard: UIImageView!
    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // sets up the Lottie animation (does not affect actual functionality)
    @IBOutlet weak var lottieAnimationViewContainer: UIView! {
        didSet {
            let animationView = LottieAnimationView(name: "attach_card")
            animationView.loopMode = .loop
            
            animationView.translatesAutoresizingMaskIntoConstraints = false
            lottieAnimationViewContainer.addSubview(animationView)
            
            animationView.leadingAnchor.constraint(equalTo: lottieAnimationViewContainer.leadingAnchor).isActive = true
            animationView.trailingAnchor.constraint(equalTo: lottieAnimationViewContainer.trailingAnchor).isActive = true
            animationView.topAnchor.constraint(equalTo: lottieAnimationViewContainer.topAnchor).isActive = true
            animationView.bottomAnchor.constraint(equalTo: lottieAnimationViewContainer.bottomAnchor).isActive = true
            
            animationView.play()
        }
    }
    
    // starts the scanning functionality
    @IBAction func verifyButtonTouched(_ sender: Any) {
        scanCardButton.isUserInteractionEnabled = false
        
        placeCard.layer.opacity = 0.0
        placeCard.isHidden = false
        placeCardOutline.layer.opacity = 0.0
        placeCardOutline.isHidden = false
        arrowDown.layer.opacity = 0.0
        arrowDown.isHidden = false
        arrowLeft.layer.opacity = 0.0
        arrowLeft.isHidden = false
        placeCardHereLabel.layer.opacity = 0.0
        placeCardHereLabel.isHidden = false
        placeCard.image = UIImage(named: "card")
        
        placeCard.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: -self.placeCard.bounds.height)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.placeCard.layer.opacity = self.traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
            self.placeCardOutline.layer.opacity = 1.0
            self.arrowDown.layer.opacity = 1.0
            self.arrowLeft.layer.opacity = 1.0
            self.placeCardHereLabel.layer.opacity = 1.0
            
            self.placeCard.transform = CGAffineTransform.identity
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                self.placeCardOutline.layer.opacity = 0.1
            }
            
            self.verifyFingerprint()
        })
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "fingerprintVerification.screen.navigationTitle".localized
        
        sentrySDK.connectionDelegate = self
        
        instructionsTitleLabel.text = "fingerprintVerification.screen.instructionsTitle".localized
        instructionsLabel.text = "fingerprintVerification.screen.instructions".localized
        scanCardButton.setTitle("fingerprintVerification.screen.button".localized, for: .normal)
        placeCardHereLabel.text = "global.placeCardHere".localized
        sentrySDK.cardCommunicationErrorText = "nfcScanning.communicationError".localized
        sentrySDK.establishConnectionText = "nfcScanning.establishConnection".localized
    }
    
    
    // MARK: - Private Methods
    
    // scans the card and performs a fingerprint validation
    private func verifyFingerprint() {
        Task { [weak self] in
            defer {
                self?.scanCardButton.isUserInteractionEnabled = true
                
                self?.placeCard.isHidden = true
                self?.placeCardOutline.isHidden = true
                self?.arrowDown.isHidden = true
                self?.arrowLeft.isHidden = true
                self?.placeCardHereLabel.isHidden = true
                self?.placeCardOutline.layer.removeAllAnimations()
                self?.placeCard.layer.removeAllAnimations()
            }

            do {
                var title = ""
                var instructions = ""
                
                // perform a biometric validation on the card. starts NFC scanning.
                if let result = try await self?.sentrySDK.validateFingerprint() {
                    // update UI elements based on the validation result
                    if result == .matchValid {
                        title = "fingerprintVerification.status.matchedTitle".localized
                        instructions = "fingerprintVerification.status.matchedInstructions".localized
                    } else if result == .matchFailed{
                        title = "fingerprintVerification.status.matchFailTitle".localized
                        instructions = "fingerprintVerification.status.matchFailInstructions".localized
                    } else {
                        title = "fingerprintVerification.status.notEnrolled".localized
                        instructions = "fingerprintVerification.status.notEnrolledInstructions".localized
                    }
                    
                    let alert = UIAlertController(title: title, message: instructions, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            } catch (let error) {
                print("!!! Error validating fingerprint: \(error)")
                
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


extension FingerprintVerificationViewController: SentrySDKConnectionDelegate {
    func connected(session: NFCReaderSession, isConnected: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isConnected {
                print("*** Showing card connected ***")
                session.alertMessage = "fingerprintVerification.status.placeFinger".localized
                
                self?.placeCardOutline.isHidden = true
                self?.placeCardOutline.layer.removeAllAnimations()
                self?.arrowDown.isHidden = true
                self?.arrowLeft.isHidden = true
                self?.placeCardHereLabel.isHidden = true
                self?.placeCard.layer.opacity = 0.8
                self?.placeCard.image = UIImage(named: "card_highlight")
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                    self?.placeCard.layer.opacity = 0.5
                }
            } else {
                print("*** Showing card not connected ***")
                session.alertMessage = "global.positionCard".localized
                
                self?.placeCard.layer.removeAllAnimations()
                self?.placeCard.layer.opacity = self?.traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
                self?.placeCardOutline.isHidden = false
                self?.arrowDown.isHidden = false
                self?.arrowLeft.isHidden = false
                self?.placeCardHereLabel.isHidden = false
                self?.placeCardOutline.layer.opacity = 1.0
                self?.placeCard.image = UIImage(named: "card")
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                    self?.placeCardOutline.layer.opacity = 0.1
                }
            }
        }
    }
}
