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
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var gettingStartedLabel: UILabel!
    @IBOutlet weak var placeCardHereLabel: UILabel!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var placeCardOutline: UIImageView!
    @IBOutlet weak var placeCard: UIImageView!
    @IBOutlet var instructionsContainer: UIView!
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
            
            self.scanCard()
        })
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "getCardStatus.screen.navigationTitle".localized
        
        #if INTERNAL_FEATURES
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(optionsTapped))
        #else
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"), style: .plain, target: self, action: #selector(infoTapped))
        #endif
        
        versionLabel.text = "SentryCard Enroll \(AppSettings.getSecureCommunicationSetting() ? "🔒 " : "")\(AppSettings.getVersionAndBuildNumber())"
        
        placeCard.layer.opacity = traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
        
        gettingStartedLabel.text = "getCardStatus.screen.gettingStarted".localized
        instructionsLabel.text = "getCardStatus.screen.instructions".localized
        scanCardButton.setTitle("getCardStatus.screen.button".localized, for: .normal)
        placeCardHereLabel.text = "global.placeCardHere".localized
        sentrySDK.cardCommunicationErrorText = "nfcScanning.communicationError".localized
        sentrySDK.establishConnectionText = "nfcScanning.establishConnection".localized
    }
    
    
    // MARK: - Private Methods
    
    // shows the Options screen
    @objc private func optionsTapped(_ sender: Any) {
        if let vc = UIStoryboard(name: "Options", bundle: .main).instantiateViewController(withIdentifier: "Options") as? OptionsViewController {
            vc.loadViewIfNeeded()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // shows the Version Info screen
    @objc private func infoTapped(_ sender: Any) {
        if let vc = UIStoryboard(name: "VersionInformation", bundle: .main).instantiateViewController(withIdentifier: "VersionInformation") as? VersionInformationViewController {
            vc.loadViewIfNeeded()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // scans the card and navigates to different screens based on the card's status
    private func scanCard() {
        Task { [weak self] in
            defer {
                self?.scanCardButton.isUserInteractionEnabled = true
                
                self?.placeCardOutline.layer.removeAllAnimations()
                self?.placeCard.layer.removeAllAnimations()
                self?.placeCard.layer.opacity = self?.traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                    self?.placeCard.layer.opacity = 0.0
                    self?.placeCardOutline.layer.opacity = 0.0
                    self?.arrowDown.layer.opacity = 0.0
                    self?.arrowLeft.layer.opacity = 0.0
                    self?.placeCardHereLabel.layer.opacity = 0.0
                }, completion: { _ in
                    self?.placeCard.isHidden = true
                    self?.placeCardOutline.isHidden = true
                    self?.arrowDown.isHidden = true
                    self?.arrowLeft.isHidden = true
                    self?.placeCardHereLabel.isHidden = true
                })
            }
            
            do {
                var title = ""
                var instructions = ""
                
                // retrieve the enrollment status from the card. starts NFC scanning.
                if let status = try await self?.sentrySDK.getEnrollmentStatus() {                  
                    // modifies various UI elements based on the card's status
                    if status.mode == .enrollment {
                        title = "getCardStatus.status.notEnrolled".localized
                        instructions = "getCardStatus.notEnrolled.instructions".localized
                    } else {
                        title = "getCardStatus.status.enrolled".localized
                        instructions = "getCardStatus.enrolled.instructions".localized
                    }
                    
                    let alert = UIAlertController(title: title, message: instructions, preferredStyle: .alert)
                    let action = UIAlertAction(title: "global.ok".localized, style: .default, handler: { _ in
                        if status.mode == .enrollment {
                            // if the card is in enrollment mode, navigate to the enrollment screen
                            if let vc = UIStoryboard(name: "FingerprintEnrollmentTutorial", bundle: .main).instantiateViewController(withIdentifier: "FingerprintEnrollmentTutorial") as? FingerprintEnrollmentTutorialViewController {
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
                    let alert = UIAlertController(title: "global.error".localized, message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

