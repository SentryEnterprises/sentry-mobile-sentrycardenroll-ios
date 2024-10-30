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
import AVFoundation

/**
 * Add the enrollment tutorial animation to the SentryCard Enroll app
 * Add the green card graphics to the SentryCard Enroll app
 Change enrollment in the SentryCard Enroll app to use the new static fingerprint graphics
 Two finger enrollment looks good and is ready to be ported to the SentryCard Enroll app
 * Add the card reset back to the SentryCard Enroll app, with verbiage that specifically says this is only for non-production cards, and include the card placement graphics
 * Change "leave finger..." to "place finger..." text for the final verification touch
 add the padlock stuff to the verify screen
 */




/**
 Fingerprint enrollment screen. Scans the card, and allows the user to record several fingerprint scans.
 */
class FingerprintEnrollmentViewController: UIViewController {
    // MARK: - Private Properties
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    
    private let animationView = LottieAnimationView(name: "CheckmarkAnimation")
    
    private var resetIsNeeded = false
    private var dingSound: AVAudioPlayer?
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var fingerprintImage: UIImageView!
    @IBOutlet weak var preparingLabel: UILabel!
    @IBOutlet weak var preparingOverlay: UIView!
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
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "fingerprintEnrollment.screen.navigationTitle".localized
        
        let soundFile = Bundle.main.url(forResource: "ding", withExtension: "wav")
        if let soundFile = soundFile {
            do {
                dingSound = try AVAudioPlayer(contentsOf: soundFile)
            } catch {
                print("Audio player creation error: \(error)")
            }
        } else {
            print("Unable to load sound file.")
        }
        
        placeCard.image = UIImage(named: "card")
        placeCard.layer.opacity = self.traitCollection.userInterfaceStyle == .dark ? 0.5 : 0.3
        
        sentrySDK.connectionDelegate = self
        sentrySDK.enrollmentDelegate = self
        
        titleLabel.text = "fingerprintEnrollment.screen.instructionsTitle".localized
        messageLabel.text = "fingerprintEnrollment.screen.instructions".localized
    //    hintLabel.text = "fingerprintEnrollment.hint.message".localized
        scanCardButton.setTitle("fingerprintEnrollment.screen.button".localized, for: .normal)
        placeCardHereLabel.text = "global.placeCardHere".localized
        sentrySDK.cardCommunicationErrorText = "nfcScanning.communicationError".localized
        sentrySDK.establishConnectionText = "nfcScanning.establishConnection".localized
        preparingLabel.text = "fingerprintEnrollment.preparing".localized
    }
    
    
    // MARK: - Private Methods
    
    // scans the card and performs fingerprint enrollment
    private func startBiometricEnrollment() {
        lottieAnimationViewContainer.isHidden = true
        preparingOverlay.isHidden = false
        
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
            
            let isReset = self?.resetIsNeeded ?? false
            self?.resetIsNeeded = false
            
            if isReset {
                self?.animationView.currentFrame = 0
            }

            do {
                // perform the fingerprint enrollment process. starts NFC scanning.
                try await self?.sentrySDK.enrollFingerprint(withReset: isReset)
           } catch SentrySDKError.enrollVerificationError {
                self?.showStep1()
                
                self?.resetIsNeeded = true
                
                let alert = UIAlertController(title: "fingerprintEnrollment.mismatch.title".localized, message: "fingerprintEnrollment.mismatch.message".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } catch {
                print("!!! Error during enrollment process: \(error)")
                
                self?.showStep1()

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
    
    // modifies UI elements based on the state of connection
    private func showStep1() {
        self.placeCardImage.isHidden = false
        self.fingerprintImage.isHidden = true
    }
    
    private func showStep2() {
        self.placeCardImage.isHidden = true
        self.fingerprintImage.isHidden = false
    }
    
    private func showFingerprint(forStep: Int) {
        var actualStep = forStep
        if forStep < 0 { actualStep = 0 }
        if forStep > 5 { actualStep = 5 }
        
        switch actualStep {
        case 0 : fingerprintImage.image = UIImage(named: "finger_center")
        case 1 : fingerprintImage.image = UIImage(named: "finger_left")
        case 2 : fingerprintImage.image = UIImage(named: "finger_bottom")
        case 3 : fingerprintImage.image = UIImage(named: "finger_right")
        case 4 : fingerprintImage.image = UIImage(named: "finger_top")
        case 5 : fingerprintImage.image = UIImage(named: "finger_center")
        default: fingerprintImage.image = UIImage(named: "finger_center")
        }
    }
}


extension FingerprintEnrollmentViewController: SentrySDKConnectionDelegate {
    func connected(session: NFCReaderSession, isConnected: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isConnected {
                print("*** Showing card connected ***")
                self?.showStep2()
                self?.placeCardOutline.isHidden = true
                self?.placeCardOutline.layer.removeAllAnimations()
                self?.arrowDown.isHidden = true
                self?.arrowLeft.isHidden = true
                self?.placeCardHereLabel.isHidden = true
                self?.placeCard.layer.opacity = 0.8
                self?.placeCard.image = UIImage(named: "card_highlight")
                self?.preparingOverlay.isHidden = true
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse]) {
                    self?.placeCard.layer.opacity = 0.5
                }
            } else {
                print("*** Showing card not connected ***")
                session.alertMessage = "Position the card under phone as shown above."
                
                self?.showStep1()
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


extension FingerprintEnrollmentViewController: SentrySDKEnrollmentDelegate {
    func enrollmentComplete(session: NFCReaderSession) {
        DispatchQueue.main.async { [weak self] in
            session.alertMessage = "fingerprintEnrollment.complete.message".localized
            
            self?.placeCardImage.isHidden = false
            self?.fingerprintImage.isHidden = true
            self?.lottieAnimationViewContainer.isHidden = true
            self?.titleLabel.text = "fingerprintEnrollment.screen.instructionsTitle".localized
            self?.messageLabel.text = "fingerprintEnrollment.screen.instructions".localized
            self?.scanCardButton.setTitle("fingerprintEnrollment.screen.button".localized, for: .normal)

            let alert = UIAlertController(title:"fingerprintEnrollment.finished.title".localized,
                                          message: "fingerprintEnrollment.finished.message".localized,
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "global.ok".localized, style: .default, handler: { _ in self?.navigationController?.popToRootViewController(animated: true) } )
            
            alert.addAction(action)
            self?.present(alert, animated: true, completion: nil)
        }
    }

    func fingerTransition(session: NFCReaderSession, nextFingerIndex: UInt8) {
        DispatchQueue.main.async { [weak self] in
            self?.placeCardImage.isHidden = true
            self?.fingerprintImage.isHidden = true
            self?.lottieAnimationViewContainer.isHidden = false
            self?.titleLabel.text = "fingerprintEnrollment.screen.instructionsTitleNext".localized
            self?.messageLabel.text = "fingerprintEnrollment.screen.instructionsNext".localized
            self?.scanCardButton.setTitle("Continue", for: .normal)
            
            self?.animationView.play()
        }
    }
    
    func enrollmentStatus(session: NFCReaderSession, currentFingerIndex: UInt8, currentStep: UInt8, totalSteps: UInt8) {
        DispatchQueue.main.async { [weak self] in
            if currentStep == 0 {
                session.alertMessage = String(format: "fingerprintEnrollment.ready.finger".localized, currentFingerIndex)
            } else {
                var stepsCompleted = Array(repeating: "✅", count: Int(currentStep))
                stepsCompleted.append(contentsOf: Array(repeating: "⬛️", count: Int(totalSteps - currentStep)))
                session.alertMessage = "fingerprintEnrollment.fingerNumber".localized + "\(currentFingerIndex): " + stepsCompleted.joined(separator: " ")
                
                self?.dingSound?.play()
                self?.showFingerprint(forStep: Int(currentStep))
                
                if currentStep == totalSteps {
                    session.alertMessage = "fingerprintEnrollment.finalVerify.message".localized
                }
            }
        }
    }
}
