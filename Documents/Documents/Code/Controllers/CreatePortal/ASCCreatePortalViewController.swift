//
//  ASCCreatePortalViewController.swift
//  Documents
//
//  Created by Alexander Yuzhin on 5/29/17.
//  Copyright © 2017 Ascensio System SIA. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import MBProgressHUD
import Alamofire
import SkyFloatingLabelTextField
import Firebase
import PhoneNumberKit

class ASCCreatePortalViewController: ASCBaseViewController {

    // MARK: - Properties
    var portal: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var isInfoPortal = false

    fileprivate let infoPortalSuffix = ".teamlab.info"
    fileprivate let phoneNumberKit = PhoneNumberKit()
    
    fileprivate lazy var phoneCodeLabel: UILabel = {
        $0.textStyle = .underlineField
        return $0
    }(UILabel())
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var portalField: ParkedTextField!
    @IBOutlet weak var firstNameField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordOneField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTwoField: SkyFloatingLabelTextField!
    @IBOutlet weak var countryButton: ASCButtonStyle!
    @IBOutlet weak var phoneNumberField: PhoneNumberTextField!
    @IBOutlet weak var footnoteLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: ASCButtonStyle!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure title

        titleLabel?.textStyle = .title1
        subtitleLabel?.textStyle = .subhead
        
        // Configure fields of form
        
        portalField?.parkedText = "." + domain(by: Locale.current.regionCode ?? "US")
        portalField?.selectedTitle = NSLocalizedString("Portal Address", comment: "")
        portalField?.title = NSLocalizedString("Portal Address", comment: "")
        
        for field in [portalField, firstNameField, lastNameField, emailField, passwordOneField, passwordTwoField] {
            field?.titleFont = ASCTextStyle.underlinePlaceholderField.font
            field?.lineHeight = UIDevice.screenPixel
            field?.selectedLineHeight = UIDevice.screenPixel * 2
            field?.titleFormatter = { $0.uppercased() }
            field?.placeholder = field?.placeholder?.uppercased()
            field?.placeholderFont = ASCTextStyle.underlinePlaceholderField.font
        }
        
        for field in [phoneNumberField] {
            field?.placeholder = field?.placeholder?.uppercased()
            field?.textStyle = .underlineField
            field?.placeholderTextStyle = .underlinePlaceholderField
            field?.delegate = self
            field?.underline(color: Asset.Colors.grayLight.color)
        }
        
        // Configure phone field
        
        phoneTitleLabel?.text = NSLocalizedString("Phone", comment: "").uppercased()
        phoneTitleLabel?.font = portalField?.titleFont
        phoneTitleLabel?.textColor = portalField?.titleColor
        
        countryButton?.styleType = .gray
        
        if let region = Locale.current.regionCode {
            countryButton?.setAttributedTitle(flagTitleButton(by: region), for: .normal)

            if let code = phoneNumberKit.countryCode(for: region) {
                phoneCodeLabel.text = "+\(code) "
                phoneNumberField?.leftView = phoneCodeLabel
                phoneNumberField?.leftViewMode = .always
                phoneNumberField?.placeholder = phonePlaceholder(for: region)
            }
        }
        
        // Configure terms and footnote label
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTerms))
        termsLabel?.textStyle = .subheadLight
        termsLabel?.attributedText = NSAttributedString(string: NSLocalizedString("By creating the portal you agree with our Terms of service", comment: ""))
            .applying(attributes: [.foregroundColor: Asset.Colors.brend.color], toRangesMatching: NSLocalizedString("Terms of service", comment: ""))
        termsLabel?.isUserInteractionEnabled = true
        termsLabel?.addGestureRecognizer(tapGesture)
        
        footnoteLabel?.textStyle = .subheadLight

        // Configure action button
        
        actionButton?.styleType = .default
        
        // Configure constarin
        
        if UIDevice.pad {
            topConstraint?.constant = 100
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses = [UIStackView.self, UIView.self]

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIDevice.phone ? .portrait : [.portrait, .landscape]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.phone ? .portrait : super.preferredInterfaceOrientationForPresentation
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func tapTerms(_ recognizer: UITapGestureRecognizer) {
        guard let text = termsLabel?.attributedText?.string else {
            return
        }
        
        if  let range = text.range(of: NSLocalizedString("Terms of service", comment: "Part of phrases - By creating the portal you agree with our Terms of service")),
            recognizer.didTapAttributedTextInLabel(label: termsLabel, inRange: NSRange(range, in: text)),
            let url = URL(string: ASCConstants.Urls.legalTerms),
            UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    // MARK: - Private

    private func flag(by countryCode: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        return countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()
    }
    
    private func phonePlaceholder(for region: String) -> String? {
        return ""
        return phoneNumberKit
            .getFormattedExampleNumber(forCountry: region, ofType: .mobile, withFormat: .international, withPrefix: false)?
            .replacingOccurrences(of: "\\d", with: "0", options: .regularExpression)
    }
    
    private func flagTitleButton(by countryCode: String) -> NSAttributedString {
        var defaultColor: UIColor = .black
        
        if #available(iOS 13.0, *) {
            defaultColor = .label
        }
        
        return NSAttributedString(string: flag(by: countryCode))
            .applying(attributes: [.font: UIFont.systemFont(ofSize: 20)])
            +
            NSAttributedString(string: "  ▼")
            .applying(attributes: [
                .font: UIFont.systemFont(ofSize: 8),
                .baselineOffset: 4
            ])
            .colored(with: defaultColor)
    }
    
    private func valid(portal: String) -> Bool {
        if portal.length < 1 {
            portalField?.errorMessage = NSLocalizedString("Account name is empty", comment: "")
            portalField?.shake()
            return false
        }
        
        // The account name must be between 6 and 50 characters long.
        if !(6...50 ~= portal.count) {
            portalField?.errorMessage = NSLocalizedString("Account name is not valid", comment: "")
            portalField?.shake()
            showError(NSLocalizedString("The account name must be between 6 and 50 characters long", comment: ""))
            return false
        }
        
        return true
    }
    
    private func valid(email: String) -> Bool {
        if email.length < 1 {
            emailField?.errorMessage = NSLocalizedString("Email is empty", comment: "")
            emailField?.shake()
            return false
        }

        if !email.isValidEmail {
            emailField?.errorMessage = NSLocalizedString("Email is not valid", comment: "")
            emailField?.shake()
            return false
        }
        
        return true
    }
    
    private func valid(name: String) -> Bool {
        if name.length < 1 || !name.matches(pattern: "^[\\p{L}\\p{M}' \\.\\-]+$") {
            return false
        }
        
        return true
    }
    
    private func valid(password: String) -> Bool {
        if password.length < 1 {
            return false
        }
        
        return true
    }
    
    private func showNextStep() {
        IQKeyboardManager.shared.resignFirstResponder()

        let isInfoPortal = portalField?.typedText.trimmed.contains(infoPortalSuffix) ?? false

        // Validate form
        
        guard
            let portal = portalField?
                .typedText
                .trimmed
                .replacingOccurrences(of: infoPortalSuffix, with: ""),
            valid(portal: portal)
        else {
            return
        }
        
        guard let firstName = firstNameField?.text?.trimmed, firstName.length > 0 else {
            firstNameField?.errorMessage = NSLocalizedString("Name is empty", comment: "")
            firstNameField?.shake()
            return
        }
        
        guard valid(name: firstName) else {
            firstNameField?.errorMessage = NSLocalizedString("First name is incorrect", comment: "")
            firstNameField?.shake()
            return
        }
        
        guard let lastName = lastNameField?.text?.trimmed, lastName.length > 0 else {
            lastNameField?.errorMessage = NSLocalizedString("Last name is empty", comment: "")
            lastNameField?.shake()
            return
        }
        
        guard valid(name: lastName) else {
            lastNameField?.errorMessage = NSLocalizedString("Last name is incorrect", comment: "")
            lastNameField?.shake()
            return
        }
        
        guard let email = emailField?.text?.trimmed, valid(email: email) else {
            emailField?.shake()
            return
        }
        
        
        // Validate phone number
        
        var isValidNumber = false
        var phoneNumber: PhoneNumber!

        if  let phoneCodeText = phoneCodeLabel.text?.trimmed,
            let phonenumberText = phoneNumberField.text?.trimmed,
            let stringCode = phoneCodeLabel.text?.trimmed.replacingOccurrences(of: "+", with: ""),
            let intCode = UInt64(stringCode),
            let regionCode = phoneNumberKit.mainCountry(forCode: intCode)
        {
            do {
                phoneNumber = try phoneNumberKit.parse("\(phoneCodeText)\(phonenumberText)", withRegion: regionCode)
                isValidNumber = true
            } catch let error {
                log.error(error)
                isValidNumber = false
            }
        }
        
        guard isValidNumber else {
            phoneTitleLabel?.text = NSLocalizedString("Phone is incorrect", comment: "").uppercased()
            phoneTitleLabel?.textColor = portalField?.errorLabel.textColor
            phoneTitleLabel?.shake()
            countryButton?.shake()
            phoneNumberField?.shake()
            return
        }
            
        let phoneNumberE164 = phoneNumberKit.format(phoneNumber, toType: .e164)
        
        
        // Validate portal name
        
        let hud = MBProgressHUD.showTopMost()
        hud?.label.text = NSLocalizedString("Validation", comment: "Caption of the process")
        
        let baseApi = String(format: ASCConstants.Urls.apiSystemUrl, domain(by: isInfoPortal ? "DEBUG" : Locale.current.regionCode ?? "US"))
        let requestUrl = baseApi + "/" + ASCConstants.Urls.apiValidatePortalName
        let params: Parameters = [
            "portalName": portal
        ]
        
        AF.request(requestUrl, method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                DispatchQueue.main.async(execute: {
                    hud?.hide(animated: true)
                    
                    switch response.result {
                    case .success(let responseJson):
                        if
                            let responseJson = responseJson as? [String: Any],
                            let message = responseJson["message"] as? String
                        {
                            let status = ASCCreatePortalStatus(message)

                            switch status {
                            case .successReadyToRegister:
                                if let portalViewController = self.storyboard?.instantiateViewController(withIdentifier: "createPortalStepTwoController") as? ASCCreatePortalViewController {
                                    IQKeyboardManager.shared.enable = false

                                    portalViewController.portal = portal
                                    portalViewController.firstName = firstName
                                    portalViewController.lastName = lastName
                                    portalViewController.email = email
                                    portalViewController.phone = phoneNumberE164
                                    portalViewController.isInfoPortal = isInfoPortal

                                    self.navigationController?.pushViewController(portalViewController, animated: true)
                                }

                            default:
                                self.showError(NSLocalizedString("Failed to check the name of the portal", comment: ""))
                            }
                        }
                    case .failure(let error):
                        log.error(error)

                        if
                            let data = response.data,
                            let responseString = String(data: data, encoding: .utf8),
                            let responseJson = responseString.toDictionary()
                        {
                            if let errorType = responseJson["error"] as? String {
                                let status = ASCCreatePortalStatus(errorType)

                                switch status {
                                case .failureTooShortError,
                                     .failurePortalNameExist,
                                     .failurePortalNameIncorrect:
                                    self.showError(status.description)
                                default:
                                    if let errorMessage = responseJson["message"] as? String {
                                        self.showError(errorMessage)
                                    } else {
                                        self.showError(NSLocalizedString("Failed to check the name of the portal", comment: ""))
                                    }
                                }
                            } else {
                                self.showError(error.localizedDescription)
                            }
                        } else {
                            self.showError(error.localizedDescription)
                        }
                    }
                })
        }
    }
    
    private func createPortal() {
        IQKeyboardManager.shared.resignFirstResponder()
        
        guard let passwordOne = passwordOneField?.text?.trimmed, valid(password: passwordOne) else {
            passwordOneField?.errorMessage = NSLocalizedString("Password is empty", comment: "")
            passwordOneField?.shake()
            return
        }
        
        guard let passwordTwo = passwordTwoField?.text?.trimmed, valid(password: passwordTwo) else {
            passwordTwoField?.errorMessage = NSLocalizedString("Password is empty", comment: "")
            passwordTwoField?.shake()
            return
        }
        
        if passwordOne != passwordTwo {
            passwordTwoField?.errorMessage = NSLocalizedString("Passwords do not match", comment: "")
            passwordTwoField?.shake()
            return
        }
        
        guard
            let firstName = firstName ,
            let lastName = lastName,
            let email = email,
            let language = Locale.preferredLanguages.first,
            let portalName = portal,
            let phone = phone
        else {
            return
        }
        
        let hud = MBProgressHUD.showTopMost()
        hud?.label.text = NSLocalizedString("Registration", comment: "")
        
        let baseApi = String(format: ASCConstants.Urls.apiSystemUrl, domain(by: isInfoPortal ? "DEBUG" : Locale.current.regionCode ?? "US"))
        let requestUrl = baseApi + "/" + ASCConstants.Urls.apiRegistrationPortal
        let params: Parameters = [
            "firstName"      : firstName,
            "lastName"       : lastName,
            "email"          : email,
            "phone"          : phone,
            "portalName"     : portalName,
            "partnerId"      : "",
            "industry"       : 0,
            "timeZoneName"   : TimeZone.current.identifier,
            "language"       : language,
            "password"       : passwordOne,
            "appKey"         : ASCConstants.Keys.portalRegistration
        ]
        
        AF.request(requestUrl, method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                DispatchQueue.main.async(execute: {
                    hud?.hide(animated: true)
                    
                    switch response.result {
                    case .success(let responseJson):
                        if let responseJson = responseJson as? [String: Any] {
                            if let tenant = responseJson["tenant"] as? [String: Any], let domain = tenant["domain"] as? String {
                                ASCAnalytics.logEvent(ASCConstants.Analytics.Event.createPortal, parameters: [
                                    ASCAnalytics.Event.Key.portal: domain,
                                    "email": email
                                    ]
                                )
                                self.login(address: domain)
                            } else {
                                self.showError(NSLocalizedString("Unable to get information about the portal", comment: ""))
                            }
                        }
                    case .failure(let error):
                        log.error(error)

                        if
                            let data = response.data,
                            let responseString = String(data: data, encoding: .utf8),
                            let responseJson = responseString.toDictionary()
                        {
                            if let errorType = responseJson["error"] as? String {
                                let status = ASCCreatePortalStatus(errorType)

                                switch status {
                                case .failurePassPolicyError,
                                     .failureTooShortError:
                                    self.showError(status.description)
                                default:
                                    if let errorMessages = responseJson["message"] as? [String] {
                                        var messages: [String] = []
                                        
                                        for errorMessage in errorMessages {
                                            let errorMessageType = ASCCreatePortalStatus(errorMessage)
                                            
                                            if errorMessageType != .unknown {
                                                messages.append(errorMessageType.description)
                                            } else {
                                                messages.append(errorMessage)
                                            }
                                        }
                                        
                                        if messages.count > 0 {
                                            self.showError(messages.joined(separator: " "))
                                        } else {
                                            self.showError(NSLocalizedString("Failed to check the name of the portal", comment: ""))
                                        }
                                    } else {
                                        self.showError(NSLocalizedString("Failed to check the name of the portal", comment: ""))
                                    }
                                }
                            } else {
                                self.showError(error.localizedDescription)
                            }
                        } else {
                            self.showError(error.localizedDescription)
                        }
                    }
                })
        }
    }

    private func login(address: String) {
        guard let login = email else {
            return
        }

        guard let password = passwordOneField?.text?.trimmed else {
            return
        }

        let api = OnlyofficeApiClient.shared
        let baseUrl = "https://" + address

        api.baseURL = URL(string: baseUrl)

        let hud = MBProgressHUD.showTopMost()
        hud?.label.text = NSLocalizedString("Logging in", comment: "Caption of the process")

        let authRequest = OnlyofficeAuthRequest()
        authRequest.provider = .email
        authRequest.portal = baseUrl
        authRequest.userName = login
        authRequest.password = password
        
        ASCSignInController.shared.login(by: authRequest, in: navigationController) { [weak self] success in
            if success {
                hud?.setSuccessState()
                hud?.hide(animated: true, afterDelay: 2)

                NotificationCenter.default.post(name: ASCConstants.Notifications.loginOnlyofficeCompleted, object: nil)

                self?.dismiss(animated: true, completion: nil)
            } else {
                hud?.hide(animated: true)
            }
        }
    }
    
    private func showError(_ message: String) {
        UIAlertController.showError(in: self, message: message)
    }
    
    private func presentCountryCodes() {
        if let countryCodeVC = navigator.navigate(to: .countryPhoneCodes) as? ASCCountryCodeViewController {
            countryCodeVC.selectCountry = { [weak self] country, code, region in
                guard let self = self else { return }
                self.countryButton?.setAttributedTitle(self.flagTitleButton(by: region), for: .normal)
                self.phoneCodeLabel.text = "+\(code) "
                self.phoneNumberField?.leftView = nil
                self.phoneNumberField?.leftView = self.phoneCodeLabel
                self.phoneNumberField?.placeholder = self.phonePlaceholder(for: region)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onFinalStep(_ sender: UIButton) {
        showNextStep()
    }
    
    @IBAction func onCreate(_ sender: UIButton) {
        createPortal()
    }
    
    @IBAction func onCountryButton(_ sender: UIButton) {
        presentCountryCodes()
    }
}
    
// MARK: - Text Field Delegate
extension ASCCreatePortalViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneNumberField {
            textField.underline(color: Asset.Colors.brend.color, weight: UIDevice.screenPixel * 2)
            phoneTitleLabel?.textColor = portalField?.tintColor
            phoneTitleLabel?.text = NSLocalizedString("Phone", comment: "").uppercased()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneNumberField {
            textField.underline(color: Asset.Colors.grayLight.color)
            phoneTitleLabel?.textColor = portalField?.titleColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let isRegistryForm = restorationIdentifier == StoryboardScene.CreatePortal.createPortalStepOneController.identifier
        let orderViews: [UIView?] = isRegistryForm
            ? [portalField, firstNameField, lastNameField, emailField, phoneNumberField]
            : [passwordOneField, passwordTwoField]
        
        if let fieldIndex = orderViews.firstIndex(where: { $0 == textField }),
           let nextField = orderViews[safe: fieldIndex + 1] {
            nextField?.becomeFirstResponder()
        } else {
            if isRegistryForm {
                showNextStep()
            } else {
                createPortal()
            }
            return true
        }

        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
            floatingLabelTextField.errorMessage = ""
        }
        
        if textField == phoneNumberField {
            phoneTitleLabel?.textColor = portalField?.tintColor
        }
        
        return true
    }
}

extension ASCCreatePortalViewController {
    func domain(by regin: String) -> String {
        let domainRegion: [String: String] = ASCConstants.Urls.domainRegions
        return domainRegion[regin] ?? ASCConstants.Urls.defaultDomainRegions
    }
}
