//
//  FingerprintEnrollmentViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/2/24.
//

import UIKit
import Lottie

class FingerprintEnrollmentViewController: UIViewController {
    private let step1Title = "Place the card on a flat\nnon-metallic surface"
    private let step2Title = "Enroll Finger"
    
    private let step1Message = "Lay the phone over the top of the card so that just the fingerprint sensor is visible."
    private let step2Message = "Place and lift your finger at different angles on your card’s sensor until you reach 100%. "
    
    private var currentStep = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var placeCardImage: UIImageView!
    @IBOutlet weak var lottieAnimationViewContainer: UIView! {
        didSet {
            let animationView = LottieAnimationView(name: "fingerprint")

            animationView.translatesAutoresizingMaskIntoConstraints = false
            lottieAnimationViewContainer.addSubview(animationView)
            
            animationView.leadingAnchor.constraint(equalTo: lottieAnimationViewContainer.leadingAnchor).isActive = true
            animationView.trailingAnchor.constraint(equalTo: lottieAnimationViewContainer.trailingAnchor).isActive = true
            animationView.topAnchor.constraint(equalTo: lottieAnimationViewContainer.topAnchor).isActive = true
            animationView.bottomAnchor.constraint(equalTo: lottieAnimationViewContainer.bottomAnchor).isActive = true
        }
    }
    
    @IBAction func scanCardButtonTouched(_ sender: Any) {
        startBiometricEnrollment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Fingerprint Setup"
        reset()
    }
    
    
    private func reset() {
        currentStep = 0
        titleLabel.text = step1Title
        messageLabel.text = step1Message
        placeCardImage.isHidden = false
        lottieAnimationViewContainer.isHidden = true
    }
    
    
    
    func startBiometricEnrollment() {
    //    guard let steps = stepViewController?.progressSteps, !steps.isEmpty else { return }
      //  restartBiometric()
        
        func handleConnected(_ isConnected: Bool) {
            DispatchQueue.main.async { [weak self] in
                if isConnected {
                    self?.reset()
                } else {
                    self?.titleLabel.text = self?.step2Title
                    self?.messageLabel.text = self?.step2Message
                    self?.placeCardImage.isHidden = true
                    self?.lottieAnimationViewContainer.isHidden = false
                }
                
//                if isConnected {
//                    if self.currentViewControllerIndex == 0 {
//                        self.finished(enrollmentStep: 0)
//                    }
//                } else {
//                    CustomPopUpViewController.unableToConnectCard { [weak self] in
//                        self?.startBiometricEnrollment()
//                    }.applying {
//                        self.present($0, animated: true)
//                    }
//                }
            }
        }
        
//        func handleReadingError() {
//            DispatchQueue.main.async {
//                self.restartBiometric()
//                CustomPopUpViewController.unableToReadFingerprints { [weak self] in
//                    self?.startBiometricEnrollment()
//                } getHelp: { [weak self] in
//                    self?.router?.route(to: .biometricEnrollmentHelp)
//                }.applying {
//                    self.present($0, animated: true)
//                }
//            }
//        }
        
        Task { [weak self] in
            do {
                try await JavaCardManager.shared.enrollBiometric(connected: { connected in
                    handleConnected(connected)
                }, stepFinished: { [weak self] step in
                    DispatchQueue.main.async {
                        self?.finished(enrollmentStep: step == 100 ? -1 : Int(step))    // awful hack
                    }
                })
            } catch (let error) {
                if let errorMessage = ErrorHandler().getErrorMessage(error: error) {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }

//            } catch where (error as? WalletError) == .connectionNotEstablished { /// `handleConnected` deals with this error
//                print(error)
//            } catch {
//                handleReadingError()
//            }
       }
    }
    
    func finished(enrollmentStep: Int) {
//        if enrollmentStep == -1 {
//            showCompletion()
//        } else {
//            
//            stepViewController?.finished(enrollmentStep: enrollmentStep)
//            
//            if stepViewController?.validateToMoveForward() == true {
//                progressView.next()
//                
//                let afterIndex = currentViewControllerIndex + 1
//                
//                if indexIsValid(afterIndex) {
//                    currentViewControllerIndex = afterIndex
//                }
//                
//                
//                //            else {
//                //                showCompletion()
//                //            }
//            }
//        }
    }
}
