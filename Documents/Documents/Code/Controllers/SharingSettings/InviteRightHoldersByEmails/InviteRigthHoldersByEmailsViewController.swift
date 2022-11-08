//
//  InviteRigthHoldersByEmailsViewController.swift
//  Documents
//
//  Created by Pavel Chernyshev on 25/10/22.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import Combine
import Foundation
import UIKit
import WSTagsField

class InviteRigthHoldersByEmailsViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []

    let viewModel: InviteRigthHoldersByEmailsViewModel
    var isNextBarBtnEnabled: Bool {
        !tagsView.tags.isEmpty
    }

    @available(iOS 14.0, *)
    private var accessBarBtnMenu: UIMenu {
        let accessList = viewModel.accessProvides()
        let menuItems = accessList
            .map { access in
                UIAction(title: access.title(),
                         image: access.image(),
                         state: access == viewModel.currentAccess ? .on : .off,
                         handler: { [unowned self, access] action in viewModel.accessChangeHandler(access) })
            }
        return UIMenu(title: "", children: menuItems)
    }

    private lazy var keyboardToolbar: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.width, height: 44))
        bar.translatesAutoresizingMaskIntoConstraints = true
        bar.items = makeToolbarItems()
        bar.sizeToFit()
        return bar
    }()

    init(viewModel: InviteRigthHoldersByEmailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        viewModel.currentAccessPubliser
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateToolbars()
            }.store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tagsView: WSTagsField = {
        let tagsField = WSTagsField()
        tagsField.layer.cornerRadius = 10
        tagsField.backgroundColor = .systemBackground
        tagsField.textField.keyboardType = .emailAddress
        tagsField.textField.returnKeyType = .go
        tagsField.placeholder = NSLocalizedString("Enter email", comment: "placeholder")
        tagsField.cornerRadius = 6.0
        tagsField.spaceBetweenLines = 16
        tagsField.spaceBetweenTags = 6
        tagsField.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsField.placeholderAlwaysVisible = true
        tagsField.tintColor = Asset.Colors.brend.color
        tagsField.textColor = .link
        tagsField.selectedColor = Asset.Colors.brend.color
        tagsField.selectedTextColor = .white
        tagsField.enableScrolling = true
        tagsField.isScrollEnabled = true
        tagsField.showsVerticalScrollIndicator = true

        tagsField.onDidAddTag = { [weak self] field, tag in
            field.tagViews.forEach { $0.tintColor = Asset.Colors.systemFillQuarternary.color }
            self?.updateToolbars()
            field.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        }

        tagsField.onDidRemoveTag = { [weak self] field, tag in
            self?.updateToolbars()
            if field.tags.isEmpty {
                field.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            }
        }

        tagsField.onShouldAcceptTag = { field in
            field.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                .isValidOnlyofficeEmail ?? false
        }

        return tagsField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Invite people", comment: "")
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tagsView)
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            tagsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            tagsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tagsView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
        view.layoutSubviews()

        let touchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGuestureRecognize))
        tagsView.addGestureRecognizer(touchGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        configureToolBar()
        tagsView.textField.becomeFirstResponder()
    }

    @objc func tapGuestureRecognize() {
        tagsView.textField.becomeFirstResponder()
    }

    // MARK: - Toolbar

    func configureToolBar() {
        navigationController?.isToolbarHidden = false
        updateToolbars()
    }

    func updateToolbars() {
        if UIDevice.phone {
            keyboardToolbar.items = makeToolbarItems()
            tagsView.textField.inputAccessoryView = keyboardToolbar
        }
        toolbarItems = makeToolbarItems()
    }

    private func makeToolbarItems() -> [UIBarButtonItem] {
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let currentAccess = viewModel.currentAccess
        let accessBarBtnItem = makeAccessBarBtn(title: currentAccess.title(), image: currentAccess.image())
        return [accessBarBtnItem, spaceItem, makeNextBarBtn()]
    }

    private func makeAccessBarBtn(title: String, image: UIImage?) -> UIBarButtonItem {
        let barBtn = UIButton(type: .system)
        barBtn.setTitle(title, for: .normal)
        barBtn.setImage(image, for: .normal)
        barBtn.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
        barBtn.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -barBtn.contentEdgeInsets.right)
        barBtn.titleLabel?.font = .systemFont(ofSize: 17)
        barBtn.tintColor = Asset.Colors.brend.color
        let barBtnItem = UIBarButtonItem(customView: barBtn)
        barBtnItem.target = self
        if #available(iOS 14, *) {
            barBtn.showsMenuAsPrimaryAction = true
            barBtn.menu = accessBarBtnMenu
        } else {
            barBtn.addTarget(self, action: #selector(showAccessSheet), for: .touchUpInside)
        }

        return barBtnItem
    }

    private func makeNextBarBtn() -> UIBarButtonItem {
        let nextBtn = ASCButtonStyle()
        nextBtn.styleType = .capsule
        nextBtn.setTitleForAllStates(NSLocalizedString("Next", comment: "").uppercased())
        nextBtn.addTarget(self, action: #selector(onNextButtonTapped), for: .touchUpInside)
        nextBtn.isEnabled = isNextBarBtnEnabled
        nextBtn.enableMode = isNextBarBtnEnabled ? .enabled : .disabled

        let barItem = UIBarButtonItem(customView: nextBtn)
        barItem.isEnabled = isNextBarBtnEnabled
        return barItem
    }

    @objc func onNextButtonTapped() {
        viewModel.nextTapClosure(tagsView.tags.map { $0.text }, viewModel.currentAccess)
    }

    @objc func showAccessSheet() {
        let accessController = UIAlertController(
            title: NSLocalizedString("Selecting access rights", comment: ""),
            message: nil,
            preferredStyle: .actionSheet,
            tintColor: nil
        )
        let accessList = viewModel.accessProvides()
        accessList.forEach { access in
            accessController.addAction(UIAlertAction(
                title: access.title(),
                style: access == .deny ? .destructive : .default,
                handler: { [unowned self] _ in self.viewModel.accessChangeHandler(access) }
            ))
        }

        accessController.addAction(
            UIAlertAction(
                title: ASCLocalization.Common.cancel,
                style: .cancel,
                handler: nil
            )
        )

        present(accessController, animated: true, completion: nil)
    }
}
