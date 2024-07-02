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
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    
    private let step1Title = "Place the card on a flat\nnon-metallic surface"
    private let step2Title = "Enroll Finger"
    
    private let step1Message = "Lay the phone over the top of the card so that just the fingerprint sensor is visible."
    private let step2Message = "Place and lift your finger at different angles on your card’s sensor until you reach 100%. "
    
    private let animationView = LottieAnimationView(name: "fingerprint")
    
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
        scanCardButton.isUserInteractionEnabled = false
        startBiometricEnrollment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Fingerprint Enrollment"
    }
    
    // scans the card and performs fingerprint enrollment
    private func startBiometricEnrollment() {
        // modifies UI elements based on the state of connection
        func handleConnected(_ isConnected: Bool) {
            DispatchQueue.main.async { [weak self] in
                if isConnected {
                    self?.titleLabel.text = self?.step2Title
                    self?.messageLabel.text = self?.step2Message
                    self?.placeCardImage.isHidden = true
                    self?.lottieAnimationViewContainer.isHidden = false
                } else {
                    self?.titleLabel.text = self?.step1Title
                    self?.messageLabel.text = self?.step1Message
                    self?.placeCardImage.isHidden = false
                    self?.lottieAnimationViewContainer.isHidden = true
                }
            }
        }
        
        Task { [weak self] in
            defer {
                self?.scanCardButton.isUserInteractionEnabled = true
            }

            do {
                // perform the fingerprint enrollment process. starts NFC scanning.
                try await self?.sentrySDK.enrollFingerprint(connected: {connected in
                    handleConnected(connected)
                }, stepFinished: { [weak self] currentStep, maximumSteps in
                    DispatchQueue.main.async {
                        self?.finished(currentStep: currentStep, maximumSteps: maximumSteps)
                    }
                })
            } catch (let error) {
                print("!!! Error during enrollment process: \(error)")
                
                handleConnected(false)
                
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
    
    // if enrollment is finished, navigates the app back to the first screen, otherwise animates a UI element to indicate progress
    private func finished(currentStep: UInt8, maximumSteps: UInt8) {
        if currentStep == maximumSteps {
            let alert = UIAlertController(title: "Enrollment Finished",
                                          message: "Your fingerprint is now enrolled. Click OK to return to the previous screen and check enrollment status.",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            animationView.play(toProgress: Double(currentStep) / Double(maximumSteps))
        }
    }
}
