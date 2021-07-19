//
//  ASCSharingOptionsInteractor.swift
//  Documents
//
//  Created by Pavel Chernyshev on 28.06.2021.
//  Copyright (c) 2021 Ascensio System SIA. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

protocol ASCSharingOptionsBusinessLogic {
    func makeRequest(request: ASCSharingOptions.Model.Request.RequestType)
}

protocol ASCSharingOptionsDataStore {
    var entity: ASCEntity? { get }
    var entityOwner: ASCUser? { get }
    var currentUser: ASCUser? { get }
    var sharedInfoItems: [ASCShareInfo] { get }
}

class ASCSharingOptionsInteractor: ASCSharingOptionsBusinessLogic, ASCSharingOptionsDataStore {
    // MARK: - Workers
    let entityLinkMaker: ASCEntityLinkMakerProtocol
    
    // MARK: - ASCSharingOptionsDataStore properties
    var entity: ASCEntity?
    var entityOwner: ASCUser?
    var currentUser: ASCUser?
    var sharedInfoItems: [ASCShareInfo] = []
    
    // MARK: - ASCSharingOptionsBusinessLogic
    var presenter: ASCSharingOptionsPresentationLogic?
    let apiWorker: ASCShareSettingsAPIWorkerProtocol
    
    init(entityLinkMaker: ASCEntityLinkMakerProtocol, entity: ASCEntity, apiWorker: ASCShareSettingsAPIWorkerProtocol) {
        self.entityLinkMaker = entityLinkMaker
        self.entity = entity
        self.apiWorker = apiWorker
    }
    
    func makeRequest(request: ASCSharingOptions.Model.Request.RequestType) {
        switch request {
        case .loadRightHolders(loadRightHoldersRequest: let loadRightHoldersRequest):
            loadCurrentUser()
            loadRightHolders(loadRightHoldersRequest: loadRightHoldersRequest)
        case .changeRightHolderAccess(changeRightHolderAccessRequest: let changeRightHolderAccessRequest):
            changeRightHolderAccess(changeRightHolderAccessRequest: changeRightHolderAccessRequest)
        case .clearData:
            currentUser = nil
            sharedInfoItems = []
        }
    }
    
    private func loadCurrentUser() {
        currentUser = ASCFileManager.onlyofficeProvider?.user
    }
    
    private func loadRightHolders(loadRightHoldersRequest: ASCSharingOptions.Model.Request.LoadRightHoldersRequest) {

        guard let entity = loadRightHoldersRequest.entity
        else {
            presenter?.presentData(response: .presentRightHolders(
                                    .init(sharedInfoItems: [], currentUser: currentUser, internalLink: nil, externalLink: nil)))
            return
        }
        
        let internalLink = entityLinkMaker.make(entity: entity)
        
        guard let apiRequest = apiWorker.makeApiRequest(entity: entity)
        else {
            presenter?.presentData(response: .presentRightHolders(
                                    .init(sharedInfoItems: [], currentUser: currentUser, internalLink: internalLink, externalLink: nil)))
            return
        }

        ASCOnlyOfficeApi.get(apiRequest) { (results, error, response) in
            var exteralLink: ASCSharingOprionsExternalLink?
            if let results = results as? [[String: Any]] {
                self.sharedInfoItems = []
                for item in results {
                    var sharedItem = ASCShareInfo()
                    
                    sharedItem.access = ASCShareAccess(item["access"] as? Int ?? 0)
                    sharedItem.locked = item["isLocked"] as? Bool ?? false
                    sharedItem.owner = item["isOwner"] as? Bool ?? false

                    if let sharedTo = item["sharedTo"] as? [String: Any] {
                        
                        /// External link
                        let shareLink = sharedTo["shareLink"] as? String
                        let shareId = sharedTo["id"] as? String
                        if shareLink != nil && shareId != nil {
                            exteralLink = .init(id: shareId!, link: shareLink!, isLocked: sharedItem.locked, access: sharedItem.access)
                            continue
                        }
                        
                        if let _ = sharedTo["userName"] {
                            sharedItem.user = ASCUser(JSON: sharedTo)
                            if sharedItem.owner {
                                self.entityOwner = sharedItem.user
                            }
                        } else if let _ = sharedTo["name"] {
                            sharedItem.group = ASCGroup(JSON: sharedTo)
                        }
                        self.sharedInfoItems.append(sharedItem)
                    }
                }
            }
            
            self.presenter?.presentData(response: .presentRightHolders(.init(sharedInfoItems: self.sharedInfoItems,
                                                                             currentUser: self.currentUser,
                                                                             internalLink: internalLink,
                                                                             externalLink: exteralLink)))
        }
    }
    
    private func changeRightHolderAccess(changeRightHolderAccessRequest: ASCSharingOptions.Model.Request.ChangeRightHolderAccessRequest) {
        
        let entity = changeRightHolderAccessRequest.entity
        var rightHolder = changeRightHolderAccessRequest.rightHolder
        let access = changeRightHolderAccessRequest.access
        
        guard let request = apiWorker.makeApiRequest(entity: entity) else { return }
        
        let baseParams: Parameters = ["notify": "false"]
        
        let sharesParams = apiWorker.convertToParams(items: [(rightHolder.id, access)])
        
        ASCOnlyOfficeApi.put(request, parameters: baseParams + sharesParams) { [weak self] (results, error, response) in
            if let _ = results as? [[String: Any]] {
                rightHolder.access = access
                self?.presenter?.presentData(response: .presentChangeRightHolderAccess(.init(rightHolder: rightHolder, error: nil)))
            } else if let response = response {
                let errorMessage = ASCOnlyOfficeApi.errorMessage(by: response)
                self?.presenter?.presentData(response: .presentChangeRightHolderAccess(.init(rightHolder: rightHolder, error: errorMessage)))
            }
        }
    }
}
