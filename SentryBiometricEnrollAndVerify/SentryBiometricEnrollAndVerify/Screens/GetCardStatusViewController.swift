//
//  GetCardStatusViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import UIKit
import Lottie

class GetCardStatusViewController: UIViewController {
   // private let cardManager = CardManager()

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
    
    @IBAction func scanCardButtonTouched(_ sender: Any) {
        scanCard()
    }
    
    private func scanCard() {
        Task { [weak self] in
            do {
                var title = ""
                var instructions = ""
                
                print("(Scan Card)")
                //let status = try await self?.cardManager.getBiometricsStatus()
                //try await JavaCardManager.shared.firstTest()
                let status = try await JavaCardManager.shared.getEnrollmentStatus()
                print("(Scan Card - Have Status: \(status)")
                
                if status.mode == .enrollment {
                    title = "Card Is Not Enrolled"
                    instructions = "This card is not enrolled. No fingerprints are recorded on this card. We will now go through the enrollment process to record your fingerprint. Click OK to continue."
                } else {
                    title = "Card Is Enrolled"
                    instructions = "This card is enrolled. A fingerprint is recorded on this card, and we can now go through the verification process to see if the recorded fingerprint matches the finger on the card's sensor. Click OK to continue."
                }

                let alert = UIAlertController(title: title, message: instructions, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if status.mode == .enrollment {
                        if let vc = UIStoryboard(name: "FingerprintEnrollment", bundle: .main).instantiateViewController(withIdentifier: "FingerprintEnrollment") as? FingerprintEnrollmentViewController {
                            vc.loadViewIfNeeded()
                    //        vc.enrollmentStatus = status
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        
                    }
                })
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
           } catch (let error) {
                if let errorMessage = ErrorHandler().getErrorMessage(error: error) {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

