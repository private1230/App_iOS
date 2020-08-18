//
//  ASCConnectStorageOAuth2Dropbox.swift
//  Documents
//
//  Created by Alexander Yuzhin on 5/16/17.
//  Copyright © 2017 Ascensio System SIA. All rights reserved.
//

import UIKit

class ASCConnectStorageOAuth2Dropbox: ASCConnectStorageOAuth2Delegate {

    // MARK: - Properties

    weak var viewController: ASCConnectStorageOAuth2ViewController? {
        didSet {
            viewController?.delegate = self
        }
    }

    var clientId: String?
    var redirectUrl: String?
    
    // MARK: - ASCConnectStorageOAuth2 Delegate
    
    func viewDidLoad(controller: ASCConnectStorageOAuth2ViewController) {
        let parameters: [String: String] = [
            "response_type": controller.responseType == .code ? "code" : "token",
            "client_id": clientId ?? "",
            "redirect_uri": redirectUrl ?? ""
        ]
        
        let authRequest = "https://www.dropbox.com/oauth2/authorize?\(parameters.stringAsHttpParameters())"
        let urlRequest = URLRequest(url: URL(string: authRequest)!)
        
        controller.load(request: urlRequest)
    }
    
    func shouldStartLoad(with request: String, in controller: ASCConnectStorageOAuth2ViewController) -> Bool {
        log.info("webview url = \(request)")
        
        if let errorCode = controller.getQueryStringParameter(url: request, param: "error") {
            log.error("code: \(errorCode)")
            
            if let topViewController = controller.navigationController?.topViewController {
                UIAlertController.showError(
                    in: topViewController,
                    message: String(format: NSLocalizedString("Please retry. \n\n If the problem persists contact us and mention this error code: Dropbox - %@", comment: ""), errorCode)
                )
                controller.navigationController?.popViewController(animated: true)
            }
            return false
        }
        
        if let redirectUrl = redirectUrl, request.contains(redirectUrl) {
            if controller.responseType == .code {
                if let code = controller.getQueryStringParameter(url: request, param: "code") {
                    controller.complation?([
                        "providerKey": ASCFolderProviderType.dropBox.rawValue,
                        "token": code
                    ])
                    return false
                }
            } else {
                var correctRequest = request
                
                if request.contains(redirectUrl + "#") {
                    correctRequest = request.replacingOccurrences(of: redirectUrl + "#", with: redirectUrl + "?")
                }
                
                if let token = controller.getQueryStringParameter(url: correctRequest, param: "access_token") {
                    controller.complation?([
                        "providerKey": ASCFolderProviderType.dropBox.rawValue,
                        "token": token
                    ])
                    return false
                }
            }
        }
        
        return true
    }
    
}
