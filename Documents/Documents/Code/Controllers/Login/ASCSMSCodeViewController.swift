//
//  ASCSMSCodeViewController.swift
//  Documents
//
//  Created by Alexander Yuzhin on 5/11/17.
//  Copyright © 2017 Ascensio System SIA. All rights reserved.
//

import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift

class ASCSMSCodeViewController: ASCBaseViewController {
    
    class override var storyboard: Storyboard { return Storyboard.login }

    // MARK: - Properties
    
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var sendSmsLabel: UILabel!

    private let codeLength: Int = 6
    var phoneNumber: String = "" {
        didSet {
            infoLabel?.text = String(format:NSLocalizedString("We have sent you an SMS with a code to the number %@", comment: ""), phoneNumber)
        }
    }
    var request: OnlyofficeAuthRequest?
    var completeon: ASCSignInComplateHandler?

    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        codeField?.delegate = self
        codeField?.underline(color: ASCConstants.Colors.lightGrey)
        codeField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        sendSmsLabel.isUserInteractionEnabled = true
        sendSmsLabel.addGestureRecognizer(tapGesture)
        
        if let phoneNoise = request?.phoneNoise {
            infoLabel?.text = String(format:NSLocalizedString("We have sent you an SMS with a code to the number %@", comment: ""), phoneNoise)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true

        codeField?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIDevice.phone ? .portrait : [.portrait, .landscape]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.phone ? .portrait : super.preferredInterfaceOrientationForPresentation
    }
    
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        sendSmsLabel.alpha = 0.5
        
        UIView.animate(withDuration: 0.6) {
            self.sendSmsLabel.alpha = 1
        }
        
        resendCode()
    }
    
    private func resendCode() {
        let hud = MBProgressHUD.showTopMost()
        
        guard let request = request else { return }
        
        OnlyofficeApiClient.request(OnlyofficeAPI.Endpoints.Auth.sendCode, request.toJSON()) { response, error in
            hud?.hide(animated: true)
            
            if let error = error {
                UIAlertController.showError(in: self, message: error.localized)
                log.error(error)
            }
        }
    }

    private func loginByCode(request: OnlyofficeAuthRequest, completion: ASCSignInComplateHandler?) {
        let hud = MBProgressHUD.showTopMost()
        hud?.label.text = NSLocalizedString("Logging in", comment: "Caption of the process")
        
        ASCSignInController.shared.login(by: request) { success in
            if success {
                hud?.setSuccessState()
                hud?.hide(animated: true, afterDelay: 2)
            } else {
                hud?.hide(animated: true)
            }
            completion?(success)
        }
    }

    private func login(with code: String) {
        guard let request = request else { return }
        request.code = code
        loginByCode(request: request, completion: completeon)
    }
}

// MARK: - UITextField Delegate

extension ASCSMSCodeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + string.count - range.length
        
        return newLength <= codeLength
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == codeField, let fieldText = textField.text {
            let code = fieldText.trimmed.substring(to: codeLength)
            
            if code.length == codeLength {
                login(with: code)
            }
        }
    }
}
