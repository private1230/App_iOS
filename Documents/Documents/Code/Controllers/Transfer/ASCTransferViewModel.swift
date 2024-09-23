//
//  ASCTransferViewModel.swift
//  Documents
//
//  Created by Pavel Chernyshev on 24.08.2024.
//  Copyright © 2024 Ascensio System SIA. All rights reserved.
//

import UIKit

struct ASCTransferViewModel {
    var title: String?
    var navPrompt: String
    var toolBarItems: [BarButtonItem]
    var tableData: TableData

    struct TableData {
        var cells: [Cell]

        static let empty = TableData(cells: [])
    }

    enum Cell {
        case folder(ASCTransferFolderModel)
        case file(ASCTransferFileModel)
    }

    struct BarButtonItem {
        var title: String
        var type: BarButtonItemType
        var isEnabled: Bool
        var onTapHandler: () -> Void
    }

    enum BarButtonItemType {
        case capsule
        case plain
    }
}

struct ASCTransferFolderModel {
    var provider: ASCFileProviderProtocol?
    var folder: ASCFolder
    var image: UIImage?
    var title: String
    var isInteractable: Bool

    var onTapAction: () -> Void
}

struct ASCTransferFileModel {
    var image: UIImage?
    var title: String

    var onTapAction: () -> Void
}
