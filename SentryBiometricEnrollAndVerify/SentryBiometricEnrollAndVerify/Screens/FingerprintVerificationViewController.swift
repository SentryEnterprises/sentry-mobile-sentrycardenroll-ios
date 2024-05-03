//
//  FingerprintVerificationViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 5/2/24.
//

import UIKit
import Lottie

class FingerprintVerificationViewController: UIViewController {
    
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
    
    @IBAction func verifyButtonTouched(_ sender: Any) {
        verifyFingerprint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Fingerprint Validation"
    }
    
    private func verifyFingerprint() {
        Task { [weak self] in
            do {
                var title = ""
                var instructions = ""
                
                print("(Scan Card)")
                let isValid = try await JavaCardManager.shared.validateBiometrics()
                print("(Scan Card - Have Validation: \(isValid)")
                
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
                if let errorMessage = ErrorHandler().getErrorMessage(error: error) {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
