//
//  FingerprintEnrollmentTutorialViewController.swift
//  SentryCardEnroll
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import Lottie

class FingerprintEnrollmentTutorialViewController: UIViewController {
    private let animationView = LottieAnimationView(name: "Final_SentryCard")
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var lottieAnimationContainer: UIView! {
        didSet {
            animationView.translatesAutoresizingMaskIntoConstraints = false
            animationView.loopMode = .loop
            
            lottieAnimationContainer.addSubview(animationView)
            
            animationView.leadingAnchor.constraint(equalTo: lottieAnimationContainer.leadingAnchor).isActive = true
            animationView.trailingAnchor.constraint(equalTo: lottieAnimationContainer.trailingAnchor).isActive = true
            animationView.topAnchor.constraint(equalTo: lottieAnimationContainer.topAnchor).isActive = true
            animationView.bottomAnchor.constraint(equalTo: lottieAnimationContainer.bottomAnchor).isActive = true
            
            animationView.play()
        }
    }

    @IBAction func continueButtonTouched(_ sender: Any) {
        if let vc = UIStoryboard(name: "FingerprintEnrollment", bundle: .main).instantiateViewController(withIdentifier: "FingerprintEnrollment") as? FingerprintEnrollmentViewController {
            vc.loadViewIfNeeded()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "fingerprintEnrollmentTutorial.screen.navigationTitle".localized
        continueButton.setTitle("fingerprintEnrollmentTutorial.screen.button".localized, for: .normal)
    }
}

