//
//  ASCSharingSettingsVerifyRightHoldersInteractor.swift
//  Documents
//
//  Created by Pavel Chernyshev on 14.07.2021.
//  Copyright (c) 2021 Ascensio System SIA. All rights reserved.
//

import UIKit

protocol ASCSharingSettingsVerifyRightHoldersBusinessLogic {
    func makeRequest(requestType: ASCSharingSettingsVerifyRightHolders.Model.Request.RequestType)
}

protocol ASCSharingSettingsVerifyRightHoldersDataStore {
    var entity: ASCEntity? { get set }
    
    var sharedInfoItems: [ASCShareInfo] { get set }
    var itemsForSharingAdd: [ASCShareInfo] { get set }
    var itemsForSharingRemove: [ASCShareInfo] { get set }
}

class ASCSharingSettingsVerifyRightHoldersInteractor: ASCSharingSettingsVerifyRightHoldersBusinessLogic, ASCSharingSettingsVerifyRightHoldersDataStore {
    var entity: ASCEntity? {
        didSet {
            guard let entity = entity else { return }
            accessProvider = ASCSharingSettingsAccessProviderFactory().get(entity: entity, isAccessExternal: false)
        }
    }
    
    var sharedInfoItems: [ASCShareInfo] = []
    var itemsForSharingAdd: [ASCShareInfo] = []
    var itemsForSharingRemove: [ASCShareInfo] = []
    var accessProvider: ASCSharingSettingsAccessProvider = ASCSharingSettingsAccessDefaultProvider()
    
    
    var presenter: ASCSharingSettingsVerifyRightHoldersPresentationLogic?
    var service: ASCSharingSettingsVerifyRightHoldersService?
    
    func makeRequest(requestType: ASCSharingSettingsVerifyRightHolders.Model.Request.RequestType) {
        switch requestType {
            
        case .loadShareItems:
            let removingGroupsIds = itemsForSharingRemove.map({ $0.group?.id }).compactMap({ $0 })
            let removingUserIds = itemsForSharingRemove.map({ $0.user?.userId }).compactMap({ $0 })
            
            let sharedItemWithoutRemoveItems = sharedInfoItems.filter({
                if let userId = $0.user?.userId {
                    return !removingUserIds.contains(userId)
                } else if let groupId = $0.group?.id {
                    return !removingGroupsIds.contains(groupId)
                }
                return true
            })
            let items = sharedItemWithoutRemoveItems + itemsForSharingAdd
            presenter?.presentData(responseType: .presentShareItems(.init(items: items)))
        case .loadAccessProvider:
            return
        case .applyShareSettings:
            return
        }
    }
}
