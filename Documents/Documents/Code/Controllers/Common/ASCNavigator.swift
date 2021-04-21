//
//  ASCNavigator.swift
//  Documents-develop
//
//  Created by Alexander Yuzhin on 21.04.2021.
//  Copyright © 2021 Ascensio System SIA. All rights reserved.
//

import UIKit

enum Destination {
    
    // MARK: - Documents
    
    case sort(types: [ASCSortViewController.ASCSortTypes], ascending: Bool, complation: ASCSortViewController.ASCSortComplation?)
    
    // MARK: - Login
    
    case onlyofficeConnectPortal
    case onlyofficeSignIn(portal: String?)
    
}

class ASCNavigator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?

    // MARK: - Initialize
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public
    
    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)
        
        switch destination {
        case .sort(let types, let ascending, let complation):
            if let sortViewController = viewController as? ASCSortViewController {
                sortViewController.types = types
                sortViewController.ascending = ascending
                sortViewController.onDone = complation
                let navigationVC = UINavigationController(rootASCViewController: sortViewController)
                navigationController?.present(navigationVC, animated: true, completion: nil)
            }
        case .onlyofficeConnectPortal:
            navigationController?.viewControllers = [viewController]
        default:
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Private
    
    fileprivate func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        case .sort:
            return ASCSortViewController.instance()
        case .onlyofficeConnectPortal:
            return ASCConnectPortalViewController.instance()
        case .onlyofficeSignIn(let portal):
            let signinViewController = ASCSignInViewController.instance()
            signinViewController.portal = portal
            return signinViewController
        }
    }
    
}
