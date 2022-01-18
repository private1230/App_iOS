//
//  ASCConnectStorageWebDavController.swift
//  Documents
//
//  Created by Alexander Yuzhin on 5/17/17.
//  Copyright © 2017 Ascensio System SIA. All rights reserved.
//

import UIKit

class ASCConnectStorageWebDavController: UITableViewController {
    static let identifier = String(describing: ASCConnectStorageWebDavController.self)

    // MARK: - Properties    
    
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serverCell: UITableViewCell!
    @IBOutlet weak var doneCell: UITableViewCell!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    
    var needServer: Bool = true {
        didSet {
            tableView?.reloadData()
        }
    }
    var provider: ASCFolderProviderType = .webDav
    var logo: UIImage?
    var complation: (([String: String]) -> ())?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneCell?.isUserInteractionEnabled = false
        doneLabel?.isEnabled = false
        
        for field in [serverField, loginField, passwordField] {
            field?.delegate = self
            field?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }

        if logo != nil {
            logoView.image = logo
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needServer {
            serverField?.becomeFirstResponder()
        } else {
            loginField?.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        var allowDone = true
        
        defer {
            doneCell?.isUserInteractionEnabled = allowDone
            doneLabel.isEnabled = allowDone
        }
        
        if let login = loginField?.text {
            allowDone = allowDone && !login.isEmpty
        }
        
        if let password = passwordField?.text {
            allowDone = allowDone && !password.isEmpty
        }
        
        if let server = serverField?.text, needServer {
            allowDone = allowDone && !server.isEmpty
        }
    }

    // MARK: - Private
    
    private func connect() {
        if let server = serverField?.text, needServer, server.isEmpty {
            serverField?.becomeFirstResponder()
            return
        }
        
        if let login = loginField?.text, login.isEmpty {
            loginField?.becomeFirstResponder()
            return
        }
        
        if let password = passwordField?.text, password.isEmpty {
            passwordField?.becomeFirstResponder()
            return
        }
        
        var params: [String: String] = [
            "providerKey": provider.rawValue,
            "login": loginField.text?.trimmed ?? "",
            "password": passwordField?.text ?? ""
        ]
        
        if needServer {
            var serverUrl = serverField?.text?.trimmed ?? ""
            
            if serverUrl.count > 0, !serverUrl.matches(pattern: "^https?://") {
                serverUrl = serverUrl.withPrefix("https://")
            }
            
            params["url"] = serverUrl
        }
        
        complation?(params)
    }
}
    
// MARK: - TableView Delegate
extension ASCConnectStorageWebDavController {
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        if section == 0, !needServer {
            return count - 1
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, !needServer {
            return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell == doneCell {
            connect()
        }
    }
}
    
 // MARK: - UITextField Delegate
 
extension ASCConnectStorageWebDavController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            if let primaryLanguage = textField.textInputMode?.primaryLanguage, primaryLanguage == "emoji" {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = tableView.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            connect()
            return true
        }
        
        return false
    }
}
