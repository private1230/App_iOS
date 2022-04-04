//
//  ASCFiltersCollectionViewCell.swift
//  Documents
//
//  Created by Лолита Чернышева on 30.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class ASCFiltersCollectionViewCell: UICollectionViewCell {
    static let identifier = "ASCFiltersCollectionViewCell"
    static let pillHeight: CGFloat = 32.0
    var labelText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLabel(_ text: String?) {
        labelText.text = text
    }
}

private extension ASCFiltersCollectionViewCell {
    func setupView() {
        backgroundColor = Asset.Colors.viewBackground.color
        layer.cornerRadius = ASCFiltersCollectionViewCell.pillHeight / 2
        labelText.frame = bounds
        labelText.textAlignment = .center
        addSubview(labelText)
    }
}
