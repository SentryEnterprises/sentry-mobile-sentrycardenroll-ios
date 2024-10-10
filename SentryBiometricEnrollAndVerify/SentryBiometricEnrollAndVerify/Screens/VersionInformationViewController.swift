//
//  VersionInformationViewController.swift
//  SentryBiometricEnrollAndVerify
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit
import CoreNFC
import Lottie
import SentrySDK

/**
 Debugging screen that provides version information about the card and its installed applets.
 */
class VersionInformationViewController: UIViewController {
    // MARK: - Private Properties
    private let sentrySDK = SentrySDK(enrollCode: AppSettings.getEnrollCode(), useSecureCommunication: AppSettings.getSecureCommunicationSetting())
    
    
    // MARK: - Outlets and Actions
    
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

    @IBOutlet weak var instructionsLabel: UILabel!
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
    
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "versionInformation.screen.navigationTitle".localized
        
        instructionsLabel.text = "versionInformation.screen.instructions".localized
        sdkVersionLabel.text = "versionInformation.screen.sdkVersion".localized
        osVersionLabel.text = "versionInformation.screen.osVersion".localized
        enrollVersionLabel.text = "versionInformation.screen.enrollVersion".localized
        cvmVersionLabel.text = "versionInformation.screen.cvmVersion".localized
        verifyVersionLabel.text = "versionInformation.screen.verifyVersion".localized
        scanCardButton.setTitle("versionInformation.screen.button".localized, for: .normal)
        
        let sdkVersion = SentrySDK.version
        let sdk = "\(sdkVersion.majorVersion).\(sdkVersion.minorVersion).\(sdkVersion.hotfixVersion)"
        sdkVersionLabel.text = "versionInformation.screen.sdkVersion".localized + "\(sdk)"
    }
    
    
    // MARK: - Private Methods
    
    // scans the card and retrieves version information about the applets installed on the card
    private func scanCard() {
        Task { [weak self] in
            defer {
                self?.scanCardButton.isUserInteractionEnabled = true
            }
            
            /**
             
             Whilte this was included only for debugging purposes, it may be prudent in a production application to provide a way to check the versions of
             applets that are installed on the SentryCard.
             
             */
            
            do {
                // retrieve version information. starts NFC scanning.
                let version = try await self?.sentrySDK.getCardSoftwareVersions()
                if let version = version {
                    var os = "global.unavailable".localized
                    if version.osVersion.majorVersion > 0 {
                        os = "\(version.osVersion.majorVersion).\(version.osVersion.minorVersion).\(version.osVersion.hotfixVersion)"
                        
                        if let info = version.osVersion.text {
                            os += " (\(info))"
                        }
                    }
                    
                    var enroll = "global.notInstalled".localized
                    if version.enrollAppletVersion.isInstalled {
                        enroll = "global.unavailable".localized
                        if version.enrollAppletVersion.majorVersion > 0 {
                            enroll = "\(version.enrollAppletVersion.majorVersion).\(version.enrollAppletVersion.minorVersion).\(version.enrollAppletVersion.hotfixVersion)"
                            
                            if let info = version.enrollAppletVersion.text {
                                enroll += " (\(info))"
                            }
                        }
                    }
                    
                    var cvm = "global.notInstalled".localized
                    if version.cvmAppletVersion.isInstalled {
                        cvm = "global.unavailable".localized
                        if version.cvmAppletVersion.majorVersion > 0 {
                            cvm = "\(version.cvmAppletVersion.majorVersion).\(version.cvmAppletVersion.minorVersion).\(version.cvmAppletVersion.hotfixVersion)"
                            
                            if let info = version.cvmAppletVersion.text {
                                cvm += " (\(info))"
                            }
                        }
                    }
 
                    var verify = "global.notInstalled".localized
                    if version.verifyAppletVersion.isInstalled {
                        verify = "global.unavailable".localized
                        if version.verifyAppletVersion.majorVersion > 0 {
                            verify = "\(version.verifyAppletVersion.majorVersion).\(version.verifyAppletVersion.minorVersion).\(version.verifyAppletVersion.hotfixVersion)"
                            
                            if let info = version.verifyAppletVersion.text {
                                enroll += " (\(info))"
                            }
                        }
                    }
                    
                    self?.osVersionLabel.text = "versionInformation.screen.osVersion".localized + "\(os)"
                    self?.enrollVersionLabel.text = "versionInformation.screen.enrollVersion".localized + "\(enroll)"
                    self?.cvmVersionLabel.text = "versionInformation.screen.cvmVersion".localized + "\(cvm)"
                    self?.verifyVersionLabel.text = "versionInformation.screen.verifyVersion".localized + "\(verify)"

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
                    let alert = UIAlertController(title: "global.error".localized, message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
