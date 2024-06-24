//
//  VersionInformationViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Created by John Ayres on 6/21/24.
//

import UIKit
import CoreNFC
import Lottie
import SentrySDK

/**
 Debugging screen that provides version information about the card and its installed applets.
 */
class VersionInformationViewController: UIViewController {
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode())
    
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

    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var verifyVersionLabel: UILabel!
    @IBOutlet weak var cvmVersionLabel: UILabel!
    @IBOutlet weak var enrollVersionLabel: UILabel!
    @IBOutlet weak var osVersionLabel: UILabel!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    
    @IBAction func scanCardButtonTouched(_ sender: Any) {
        scanCardButton.isUserInteractionEnabled = false
        scanCard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Version Information"
    }
    
    // scans the card and retrieves version information about the applets installed on the card
    private func scanCard() {
        Task { [weak self] in
            defer {
                self?.scanCardButton.isUserInteractionEnabled = true
            }
            
            do {
                var sdk = "Unavailable"
                let sdkVersion = SentrySDK.version
                sdk = "\(sdkVersion.majorVersion).\(sdkVersion.minorVersion).\(sdkVersion.hotfixVersion)"
                self?.sdkVersionLabel.text = "SDK Version: \(sdk)"
                
                // retrieve version information. starts NFC scanning.
                let version = try await self?.sentrySDK.getCardSoftwareVersions()
                if let version = version {
                    var os = "Unavailable"
                    if version.osVersion.majorVersion > 0 {
                        os = "\(version.osVersion.majorVersion).\(version.osVersion.minorVersion).\(version.osVersion.hotfixVersion)"
                    }
                    
                    var enroll = "Unavailable"
                    if version.enrollAppletVersion.majorVersion > 0 {
                        enroll = "\(version.enrollAppletVersion.majorVersion).\(version.enrollAppletVersion.minorVersion).\(version.enrollAppletVersion.hotfixVersion)"
                        
                        if let info = version.enrollAppletVersion.text {
                            enroll += " (\(info))"
                        }
                    }
                    
                    var cvm = "Unavailable"
                    if version.cvmAppletVersion.majorVersion > 0 {
                        cvm = "\(version.cvmAppletVersion.majorVersion).\(version.cvmAppletVersion.minorVersion).\(version.cvmAppletVersion.hotfixVersion)"
                        
                        if let info = version.cvmAppletVersion.text {
                            cvm += " (\(info))"
                        }
                    }
 
                    var verify = "Unavailable"
                    if version.verifyAppletVersion.majorVersion > 0 {
                        verify = "\(version.verifyAppletVersion.majorVersion).\(version.verifyAppletVersion.minorVersion).\(version.verifyAppletVersion.hotfixVersion)"
                        
                        if let info = version.verifyAppletVersion.text {
                            enroll += " (\(info))"
                        }
                    }
                    
                    self?.osVersionLabel.text = "OS Version: \(os)"
                    self?.enrollVersionLabel.text = "OS Version: \(enroll)"
                    self?.cvmVersionLabel.text = "CVM Version: \(cvm)"
                    self?.verifyVersionLabel.text = "Verify Version: \(verify)"
                }
            } catch (let error) {
                print("!!! Error reading version information: \(error)")
                
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
