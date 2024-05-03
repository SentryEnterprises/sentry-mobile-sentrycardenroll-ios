//
//  FingerprintVerificationViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/2/24.
//

import UIKit
import Lottie
import CoreNFC

/**
 Fingerprint verification screen. Scans the card, and performs a biometric validation of the finger on the fingerprint sensor against the fingerprints recorded on the card.
 */
class FingerprintVerificationViewController: UIViewController {
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
        verifyFingerprint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Fingerprint Validation"
    }
    
    // scans the card and performs a biometric validation
    private func verifyFingerprint() {
        Task { [weak self] in
            do {
                var title = ""
                var instructions = ""
                
                // perform a biometric validation on the card. starts NFC scanning.
                let isValid = try await JavaCardManager.shared.validateBiometrics()
                
                // update UI elements based on the validation result
                if isValid {
                    title = "Fingerprint Matched"
                    instructions = "The scanned fingerprint matches the fingerprint recorded during enrollment."
                } else {
                    title = "Fingerprint Does Not Match"
                    instructions = "The scanned fingerprint does not match the fingerprint recorded during enrollment."
                }
                
                let alert = UIAlertController(title: title, message: instructions, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } catch (let error) {
                // if the user cancelled or the session timed out, don't display this as an error
                let errorCode = (error as NSError).code
                if errorCode != NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue && errorCode != NFCReaderError.readerSessionInvalidationErrorSessionTimeout.rawValue {
                    let errorMessage = ErrorHandler().getErrorMessage(error: error)
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
