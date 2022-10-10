//
//  ASCShareSettingsRoomsAPIWorker.swift
//  Documents
//
//  Created by Павел Чернышев on 19.07.2021.
//  Copyright © 2021 Ascensio System SIA. All rights reserved.
//

import Foundation

class ASCShareSettingsRoomsAPIWorker: ASCShareSettingsAPIWorkerProtocol {
    let baseWorker: ASCShareSettingsAPIWorkerProtocol

    init(baseWorker: ASCShareSettingsAPIWorkerProtocol) {
        self.baseWorker = baseWorker
    }

    func makeApiRequest(entity: ASCEntity) -> Endpoint<OnlyofficeResponseArray<OnlyofficeShare>>? {
        guard let folder = entity as? ASCFolder, folder.roomType != nil else {
            return baseWorker.makeApiRequest(entity: entity)
        }

        return OnlyofficeAPI.Endpoints.Sharing.room(folder: folder)
    }

    func convertToParams(entities: [ASCEntity]) -> [String: [ASCEntityId]]? {
        nil
    }
}
