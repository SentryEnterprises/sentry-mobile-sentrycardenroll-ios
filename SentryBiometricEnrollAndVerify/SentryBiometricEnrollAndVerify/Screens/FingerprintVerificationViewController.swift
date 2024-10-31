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
    private var currentTask: Task<Void, Error>?
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var unlockImage: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var placeCardHereLabel: UILabel!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var placeCardOutline: UIImageView!
    @IBOutlet weak var placeCard: UIImageView!
    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
   
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
        unlockImage.isHidden = true
        lockImage.isHidden = false
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
        
        placeCard.layer.opacity = 0.1
        unlockImage.isHidden = true

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
        if let currentTask = currentTask {
            print("********** Cancelling Task")
            currentTask.cancel()
        }
        
        currentTask = Task { [weak self] in
            Task { [weak self] in
                defer {
                    print("\n\n\n========== DEFER \n\n")
                    
                    self?.scanCardButton.isUserInteractionEnabled = true
                    
                    self?.placeCard.isHidden = true
                    self?.placeCardOutline.isHidden = true
                    self?.arrowDown.isHidden = true
                    self?.arrowLeft.isHidden = true
                    self?.placeCardHereLabel.isHidden = true
                    self?.placeCardOutline.layer.removeAllAnimations()
                    self?.placeCard.layer.removeAllAnimations()
                    
                    
                    self?.currentTask = nil
                }
                
                do {
                    // perform a biometric validation on the card. starts NFC scanning.
                    if let result = try await self?.sentrySDK.validateFingerprint() {
                        // update UI elements based on the validation result
                        if result == .matchFailed {
                            DispatchQueue.main.async {
                                self?.lockImage.isHidden = false
                                self?.unlockImage.isHidden = true
                                
                                let duration: CGFloat = 0.3
                                let repeatCount: Float = 4
                                let angle: Float = Float.pi / 27
                                
                                let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
                                rotationAnimation.duration = TimeInterval(duration/CGFloat(repeatCount))
                                rotationAnimation.repeatCount = repeatCount
                                rotationAnimation.autoreverses = true
                                rotationAnimation.fromValue = -angle
                                rotationAnimation.toValue = angle
                                rotationAnimation.isRemovedOnCompletion = true
                                
                                CATransaction.begin()
                                self?.lockImage.layer.add(rotationAnimation, forKey: "shakeAnimation")
                                CATransaction.commit()
                            }
                        }
                        
                        if result == .matchValid {
                            DispatchQueue.main.async {
                                self?.lockImage.isHidden = true
                                self?.unlockImage.isHidden = false
                            }
                        }
                        
                        if result == .notEnrolled {
                            let alert = UIAlertController(title: "fingerprintVerification.status.notEnrolled".localized,
                                                          message: "fingerprintVerification.status.notEnrolledInstructions".localized,
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
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
