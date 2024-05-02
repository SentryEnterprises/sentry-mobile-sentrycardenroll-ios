//
//  CardStatusViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 4/29/24.
//

import UIKit

class CardStatusViewController: UIViewController {
   // private let cardManager = CardManager()

    @IBAction func scanCardButtonTouched(_ sender: Any) {
        scanCard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    func scanCard() {
        Task { [weak self] in
            do {
                print("(Scan Card)")
                //let status = try await self?.cardManager.getBiometricsStatus()
                //try await JavaCardManager.shared.firstTest()
                let status = try await JavaCardManager.shared.getEnrollmentStatus()
                print("(Scan Card - Have Status: \(status)")
                
                if status.mode == .enrollment {
                    
                } else {
                    
                }
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

