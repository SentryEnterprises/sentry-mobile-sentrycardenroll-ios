//
//  FingerprintEnrollmentViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import Lottie
import CoreNFC
import SentrySDK

/**
 Fingerprint enrollment screen. Scans the card, and allows the user to record several fingerprint scans.
 */
class FingerprintEnrollmentViewController: UIViewController {
    // MARK: - Private Properties
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    private let animationView = LottieAnimationView(name: "finger_position")
    private var resetIsNeeded = false
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var instructionContainer: UIStackView!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var placeCardHereLabel: UILabel!
    @IBOutlet weak var placeCardOutline: UIImageView!
    @IBOutlet weak var placeCard: UIImageView!
    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var placeCardImage: UIImageView!
    
    // sets up the Lottie animation (does not affect actual functionality)
    @IBOutlet weak var lottieAnimationViewContainer: UIView! {
        didSet {
            animationView.translatesAutoresizingMaskIntoConstraints = false
            lottieAnimationViewContainer.addSubview(animationView)
            
            animationView.leadingAnchor.constraint(equalTo: lottieAnimationViewContainer.leadingAnchor).isActive = true
            animationView.trailingAnchor.constraint(equalTo: lottieAnimationViewContainer.trailingAnchor).isActive = true
            animationView.topAnchor.constraint(equalTo: lottieAnimationViewContainer.topAnchor).isActive = true
            animationView.bottomAnchor.constraint(equalTo: lottieAnimationViewContainer.bottomAnchor).isActive = true
        }
    }
    
    // starts the scanning functionality
    @IBAction func scanCardButtonTouched(_ sender: Any) {
        scanCardButton.isUserInteractionEnabled = false     // guards against double-tap
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.instructionContainer.transform = CGAffineTransform(translationX: 0, y: 80)
        }, completion: { _ in
            self.placeCard.layer.opacity = 0.0
            self.placeCard.isHidden = false
            self.placeCardOutline.layer.opacity = 0.0
            self.placeCardOutline.isHidden = false
            self.arrowDown.layer.opacity = 0.0
            self.arrowDown.isHidden = false
            self.arrowLeft.layer.opacity = 0.0
            self.arrowLeft.isHidden = false
            self.placeCardHereLabel.layer.opacity = 0.0
            self.placeCardHereLabel.isHidden = false
            
            self.placeCard.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: -self.placeCard.bounds.height)
            
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
                
                self.startBiometricEnrollment()
            })
        })
   }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "fingerprintEnrollment.screen.navigationTitle".localized
        
        placeCard.layer.opacity = self.traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
        
        titleLabel.text = "fingerprintEnrollment.step1.title".localized
        messageLabel.text = "fingerprintEnrollment.step2.message".localized
        scanCardButton.setTitle("fingerprintEnrollment.screen.button".localized, for: .normal)
        sentrySDK.cardCommunicationErrorText = "nfcScanning.communicationError".localized
        sentrySDK.establishConnectionText = "nfcScanning.establishConnection".localized
    }
    
    
    // MARK: - Private Methods
    
    // scans the card and performs fingerprint enrollment
    private func startBiometricEnrollment() {
        // modifies UI elements based on the state of connection
        func showStep1() {
            self.titleLabel.text = "fingerprintEnrollment.step1.title".localized
            self.messageLabel.text = "fingerprintEnrollment.step1.message".localized
            self.placeCardImage.isHidden = false
            self.lottieAnimationViewContainer.isHidden = true
        }
        
        func showStep2() {
            self.titleLabel.text = "fingerprintEnrollment.step2.title".localized
            self.messageLabel.text = "fingerprintEnrollment.step2.message".localized
            self.placeCardImage.isHidden = true
            self.lottieAnimationViewContainer.isHidden = false
        }

        // modifies UI elements based on the state of connection
        func handleConnected(_ isConnected: Bool) {
            DispatchQueue.main.async { [weak self] in
                if isConnected {
                    print("*** Showing card connected ***")
                    showStep2()
                    
                    self?.placeCardOutline.isHidden = true
                    self?.placeCardOutline.layer.removeAllAnimations()
                    self?.arrowDown.isHidden = true
                    self?.arrowLeft.isHidden = true
                    self?.placeCardHereLabel.isHidden = true
                    self?.placeCard.layer.opacity = 0.8

                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                        self?.placeCard.layer.opacity = 0.5
                    }
                } else {
                    print("*** Showing card not connected ***")
                    showStep1()
                    
                    self?.placeCard.layer.removeAllAnimations()
                    self?.placeCard.layer.opacity = self?.traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
                    self?.placeCardOutline.isHidden = false
                    self?.arrowDown.isHidden = false
                    self?.arrowLeft.isHidden = false
                    self?.placeCardHereLabel.isHidden = false
                    self?.placeCardOutline.layer.opacity = 1.0

                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                        self?.placeCardOutline.layer.opacity = 0.1
                    }
                }
            }
        }
        
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

                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                    self?.instructionContainer.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
            
            let isReset = self?.resetIsNeeded ?? false
            self?.resetIsNeeded = false
            
            if isReset {
                self?.animationView.currentFrame = 0
            }

            do {
                // perform the fingerprint enrollment process. starts NFC scanning.
                try await self?.sentrySDK.enrollFingerprint(connected: { nfcSession, connected in
                    if connected {
                        nfcSession.alertMessage = "fingerprintEnrollment.connected.message".localized
                    } else {
                        nfcSession.alertMessage = "fingerprintEnrollment.notConnected.message".localized
                    }
                    handleConnected(connected)
                }, stepFinished: { [weak self] nfcSession, currentStep, maximumSteps in
                    DispatchQueue.main.async {
                        self?.stepFinished(nfcSession: nfcSession, currentStep: currentStep, maximumSteps: maximumSteps)
                    }
                }, enrollmentComplete: { [weak self] nfcSession in
                    DispatchQueue.main.async {
                        self?.enrollmentCompleted(nfcSession: nfcSession)
                    }
                }, withReset: isReset)
            } catch SentrySDKError.enrollVerificationError {
                showStep1()
                
                self?.resetIsNeeded = true
                
                let alert = UIAlertController(title: "fingerprintEnrollment.mismatch.title".localized, message: "fingerprintEnrollment.mismatch.message".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } catch {
                print("!!! Error during enrollment process: \(error)")
                
                showStep1()

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
    
    // if enrollment is finished, navigates the app back to the first screen, otherwise animates a UI element to indicate progress
    private func stepFinished(nfcSession: NFCReaderSession, currentStep: UInt8, maximumSteps: UInt8) {
        if currentStep < maximumSteps {
            let fromProgress = Double(currentStep - 1) / Double(maximumSteps - 1)
            let toProgress = Double(currentStep) / Double(maximumSteps - 1)
            animationView.play(fromProgress: fromProgress, toProgress: toProgress)
            
            var stepsCompleted = Array(repeating: "✅", count: Int(currentStep))
            stepsCompleted.append(contentsOf: Array(repeating: "⬛️", count: Int(maximumSteps - currentStep)))
            nfcSession.alertMessage = stepsCompleted.joined(separator: " ")
        } else {
            nfcSession.alertMessage = "fingerprintEnrollment.finalVerify.message".localized
        }
    }
    
    // indicates enrollment is completed and navigates the user to the next screen
    private func enrollmentCompleted(nfcSession: NFCReaderSession) {
        nfcSession.alertMessage = "fingerprintEnrollment.complete.message".localized
        
        let alert = UIAlertController(title: "fingerprintEnrollment.finished.title".localized,
                                      message: "fingerprintEnrollment.finished.message".localized,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "global.ok".localized, style: .default, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
