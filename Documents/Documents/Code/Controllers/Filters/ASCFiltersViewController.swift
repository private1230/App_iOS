//
//  ASCFiltersViewController.swift
//  Documents
//
//  Created by Лолита Чернышева on 29.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class ASCFiltersViewController: UIViewController {
    // MARK: - Properties

    var data: [ASCDocumentsSectionModel] = [
        ASCDocumentsSectionModel(
            sectionName: NSLocalizedString("Type", comment: ""),
            filters: [
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Folders", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Documents", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Presentations", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Spreadsheets", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Images", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Media", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Archives", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("All files", comment: ""), isSelected: false),
            ]
        ),
        ASCDocumentsSectionModel(
            sectionName: NSLocalizedString("Author", comment: ""),
            filters: [
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Users", comment: ""), isSelected: false),
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Groups", comment: ""), isSelected: false),
            ]
        ),
        ASCDocumentsSectionModel(
            sectionName: NSLocalizedString("Search", comment: ""),
            filters: [
                ASCDocumentsFilterModel(filterName: NSLocalizedString("Exclude subfolders", comment: ""), isSelected: false),
            ]
        ),
    ]

    let cellLeftRightPadding: CGFloat = 32.0
    let resultCount = 100
    var collectionView: UICollectionView!
    private lazy var showResultsButton: ASCButtonStyle = {
        $0.styleType = .blank
        return $0
    }(ASCButtonStyle())

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.Colors.tableCategoryBackground.color
        setupNavigationBar()
        setupCollectionView()
        showResultButtonConstraints()

        showResultsButton.addTarget(self, action: #selector(onShowResultsButtonTapped), for: .touchUpInside)
    }
}

private extension ASCFiltersViewController {
    func showResultButtonConstraints() {
        showResultsButton.setTitle(String.localizedStringWithFormat(
            NSLocalizedString("Show %d results", comment: ""), resultCount
        ), for: .normal)

        view.addSubview(showResultsButton)
        showResultsButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            leftConstant: 16,
            bottomConstant: 10,
            rightConstant: 16,
            heightConstant: 52
        )
    }

    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = NSLocalizedString("Filters", comment: "")

        let rightBarButton = UIBarButtonItem(
            title: NSLocalizedString("Reset", comment: ""),
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(resetBarButtonItemTapped)
        )
        let leftBarButton = UIBarButtonItem(
            title: NSLocalizedString("Cancel", comment: ""),
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(cancelBarButtonItemTapped)
        )
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
    }

    func setupCollectionView() {
        let pillLayout = ASCPillLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: pillLayout)
        collectionView.backgroundColor = .clear
        guard let collectionView = collectionView else { return }
        collectionView.register(ASCFiltersCollectionViewCell.self,
                                forCellWithReuseIdentifier: ASCFiltersCollectionViewCell.identifier)
        collectionView.register(ASCFiltersCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ASCFiltersCollectionViewHeader.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        pillLayout.delegate = self
        collectionView.collectionViewLayout = pillLayout
        view.addSubview(collectionView)
        setupCollectionViewConstraints()
    }

    func setupCollectionViewConstraints() {
        collectionView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            leftConstant: 16,
            rightConstant: 16
        )
    }

    @objc func resetBarButtonItemTapped() {
        for (sectionIndex, section) in data.enumerated() {
            for (filterIndex, _) in section.filters.enumerated() {
                data[sectionIndex].filters[filterIndex].isSelected = false
            }
        }
        collectionView.reloadData()
        setupCollectionView()
    }

    @objc func cancelBarButtonItemTapped() {
        dismiss(animated: true)
    }

    @objc func onShowResultsButtonTapped() {
        print("call onShowResultsButtonTapped")
    }
}

extension ASCFiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        // TODO: Implement the logic for changing the appearance of the cell inside the class.
        // Use property like Selected.
        // Add dark mode support
        //
        if let cell = collectionView.cellForItem(at: indexPath) as? ASCFiltersCollectionViewCell {
            if (data[indexPath.section].filters[indexPath.row].isSelected) == false {
                data[indexPath.section].filters[indexPath.row].isSelected = true
                cell.labelText.textColor = Asset.Colors.viewBackground.color
                cell.backgroundColor = Asset.Colors.brend.color
            } else {
                if indexPath.section == 1 {
                    cell.labelText.textColor = Asset.Colors.brend.color
                } else {
                    cell.labelText.textColor = .black
                }
                cell.backgroundColor = Asset.Colors.viewBackground.color
                data[indexPath.section].filters[indexPath.row].isSelected = false
            }
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ASCFiltersCollectionViewCell.identifier, for: indexPath) as? ASCFiltersCollectionViewCell
        cell?.setLabel(data[indexPath.section].filters[indexPath.row].filterName)
        if indexPath.section == 1 {
            cell?.labelText.textColor = Asset.Colors.brend.color
        }
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ASCFiltersCollectionViewHeader.identifier, for: indexPath) as? ASCFiltersCollectionViewHeader
        header?.setupLabel("\(data[indexPath.section].sectionName)")
        header?.backgroundColor = Asset.Colors.tableCategoryBackground.color
        return header!
    }
}

extension ASCFiltersViewController: ASCPillLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForPillAtIndexPath indexPath: IndexPath) -> CGSize {
        let label = data[indexPath.section].filters[indexPath.row].filterName
        let referenceSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: ASCFiltersCollectionViewCell.pillHeight)
        let calculatedSize = (label as NSString).boundingRect(with: referenceSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)], context: nil)
        return CGSize(width: calculatedSize.width + cellLeftRightPadding, height: ASCFiltersCollectionViewCell.pillHeight)
    }

    func collectionView(_ collectionView: UICollectionView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22.0
    }

    func collectionView(_ collectionView: UICollectionView, insetsForItemsInSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16.0, left: 0, bottom: 16.0, right: 16.0)
    }

    func collectionView(_ collectionView: UICollectionView, itemSpacingInSection section: Int) -> CGFloat {
        return 16.0
    }
}
