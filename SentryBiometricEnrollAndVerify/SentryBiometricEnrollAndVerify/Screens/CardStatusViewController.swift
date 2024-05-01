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
                try await JavaCardManager.shared.firstTest()
                print("(Scan Card - Have Status)")
            } catch (let error) {
                print("ERROR: \(error)")
            }
        }
    }
}

