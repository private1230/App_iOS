//
//  ASCPasswordRecoveryViewController.swift
//  Documents
//
//  Created by Иван Гришечко on 26.04.2021.
//  Copyright © 2021 Ascensio System SIA. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MBProgressHUD
import Alamofire
import IQKeyboardManagerSwift

class ASCPasswordRecoveryViewController: ASCBaseViewController {
    
    class override var storyboard: Storyboard { return Storyboard.login }
    
    // MARK: - Outlets
    
    @IBOutlet weak var recoveryTitle: UILabel!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sendButton: ASCButtonStyle!
    
    // MARK: - Properties
    
    private let portal: String? = nil
    private var responseText: String? = nil
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAddHideKeyboardHandler = true
        
        sendButton?.styleType = .default
        sendButton?.tag = ASCBaseViewController.actionTag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 124.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField?.becomeFirstResponder()
    }
    
    private func valid(email: String) -> Bool {
        if email.length < 1 {
            emailTextField?.errorMessage = NSLocalizedString("Email is empty", comment: "")
            emailTextField?.shake()
            return false
        }

        if !email.isValidOnlyofficeEmail {
            emailTextField?.errorMessage = NSLocalizedString("Email is not valid", comment: "")
            emailTextField?.shake()
            return false
        }

        return true
    }
    
    private func presentEmailSentVC(responseText: String) {
        guard let email = emailTextField?.text?.trimmed else { return }
        navigator.navigate(to: .recoveryPasswordConfirmed(email: email))
    }
    
    // MARK: - Actions
    
    @IBAction func onSendButton(_ sender: Any) {
        let email = emailTextField?.text?.trimmed ?? ""
        
        guard valid(email: email) else {
            return
        }
        
        guard let portal = OnlyofficeApiClient.shared.baseURL?.absoluteString.trimmed else {
            emailTextField?.errorMessage = NSLocalizedString("The portal is not available", comment: "")
            emailTextField?.shake()
            return
        }
        
        let parameters: Parameters = [
            "email": email,
            "portal": portal
        ]
        
        let hud = MBProgressHUD.showTopMost()
        hud?.label.text = NSLocalizedString("Sending", comment: "Caption of the process")
        
        ASCPasswordRecoveryController.shared.forgotPassword(portalUrl: portal, options: parameters) { [weak self] result in
            switch result {
            case .success(let response):
                hud?.setSuccessState()
                hud?.hide(animated: true, afterDelay: 2)
                
                self?.presentEmailSentVC(responseText: response.response)
            case .failure(let error):
                log.error(error)
                hud?.hide(animated: true)
                
                if let controller = self {
                    UIAlertController.showError(
                        in: controller,
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
}
