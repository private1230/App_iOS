//
//  ASCSharingOptionsRightHolderTableViewCell.swift
//  Documents
//
//  Created by Pavel Chernyshev on 10.06.2021.
//  Copyright © 2021 Ascensio System SIA. All rights reserved.
//

import UIKit

class ASCSharingRightHolderTableViewCell: UITableViewCell, ASCReusedIdentifierProtocol, ASCViewModelSetter {
    static var reuseId: String = "SharingRightHolderCell"
    
    var viewModel: ASCSharingRightHolderViewModel? {
        didSet {
            configureContent()
        }
    }
    
    var avatarSideSize: CGFloat = 40
    var titleStackHeigh: CGFloat = 40
    var hSpacing: CGFloat = 16
    var defaultLineLeftSpacing: CGFloat = 60
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: avatarSideSize, height: avatarSideSize))
        imageView.layer.cornerRadius = imageView.height / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = label.font.withSize(15)
        return label
    }()
    
    private lazy var subtitle: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = label.font.withSize(13)
        return label
    }()
    
    private lazy var accessLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()
    
    func configureContent() {
        guard let viewModel = viewModel else {
            return
        }
        
        separatorInset.left = defaultLineLeftSpacing
        selectionStyle = .none
        
        avatar.image = viewModel.avatar
        title.text = viewModel.name
        if let rightHolderType = viewModel.rightHolderType {
            subtitle.text = rightHolderType.rawValue
        }
        
        let access = viewModel.access
        if access != nil {
            accessLabel.text = access?.documetAccess.title()
        }
        
        if viewModel.access?.accessEditable ?? false {
            self.accessoryType = .disclosureIndicator
        }

        avatar.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        accessLabel.translatesAutoresizingMaskIntoConstraints = false
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(avatar)
        contentView.addSubview(accessLabel)
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(vStack)
        
        vStack.addArrangedSubview(title)
        vStack.addArrangedSubview(subtitle)

        NSLayoutConstraint.activate([
            accessLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: viewModel.access?.accessEditable ?? false ? -10 : -18),
            accessLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            avatar.heightAnchor.constraint(equalToConstant: avatar.height),
            avatar.widthAnchor.constraint(equalToConstant: avatar.width),
            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hSpacing),
            avatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            vStack.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: hSpacing),
            vStack.trailingAnchor.constraint(equalTo: accessLabel.leadingAnchor, constant: -hSpacing),
            vStack.heightAnchor.constraint(equalToConstant: titleStackHeigh),
            vStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
}
