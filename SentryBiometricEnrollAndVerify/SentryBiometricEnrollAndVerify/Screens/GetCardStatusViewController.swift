//
//  GetCardStatusViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import Lottie
import CoreNFC
import SentrySDK

/**
 The mobile application entry point. Allows the user to scan the card to determine its state.
 */
class GetCardStatusViewController: UIViewController {
    // MARK: - Private Properties
    
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var scanCardButton: UIButton!
    
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
    @IBAction func scanCardButtonTouched(_ sender: Any) {
        scanCardButton.isUserInteractionEnabled = false
        scanCard()
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Get Card Status"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(optionsTapped))
        versionLabel.text = "Sentry Enroll \(AppSettings.getSecureCommunicationSetting() ? "🔒 " : "")\(AppSettings.getVersionAndBuildNumber())"
    }
    
    
    // MARK: - Private Methods
    
    @objc private func optionsTapped(_ sender: Any) {
        if let vc = UIStoryboard(name: "Options", bundle: .main).instantiateViewController(withIdentifier: "Options") as? OptionsViewController {
            vc.loadViewIfNeeded()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // scans the card and navigates to different screens based on the card's status
    private func scanCard() {
        Task { [weak self] in
            defer {
                self?.scanCardButton.isUserInteractionEnabled = true
            }
            
            do {
                var title = ""
                var instructions = ""
                
                // retrieve the enrollment status from the card. starts NFC scanning.
                if let status = try await self?.sentrySDK.getEnrollmentStatus() {                  
                    // modifies various UI elements based on the card's status
                    if status.mode == .enrollment {
                        title = "Not Enrolled"
                        instructions = "This card is not enrolled. No fingerprints are recorded on this card. Click OK to continue."
                    } else {
                        title = "Enrolled"
                        instructions = "This card is enrolled. A fingerprint is recorded on this card. Click OK to continue."
                    }
                    
                    let alert = UIAlertController(title: title, message: instructions, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        if status.mode == .enrollment {
                            // if the card is in enrollment mode, navigate to the enrollment screen
                            if let vc = UIStoryboard(name: "FingerprintEnrollment", bundle: .main).instantiateViewController(withIdentifier: "FingerprintEnrollment") as? FingerprintEnrollmentViewController {
                                vc.loadViewIfNeeded()
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            // if the card is already enrolled, navigate to the verification screen
                            if let vc = UIStoryboard(name: "FingerprintVerification", bundle: .main).instantiateViewController(withIdentifier: "FingerprintVerification") as? FingerprintVerificationViewController {
                                vc.loadViewIfNeeded()
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    })
                    
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                }
            } catch (let error) {
                print("!!! Error getting enrollment status: \(error)")

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

