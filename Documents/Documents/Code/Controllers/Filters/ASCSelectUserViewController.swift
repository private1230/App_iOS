//
//  ASCSelectUserViewController.swift
//  Documents
//
//  Created by Лолита Чернышева on 15.04.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class ASCSelectUserViewController: UIViewController {
    private enum Constants {
        static let cellHeight: CGFloat = 60
        static let leftRightInserts: CGFloat = 16
        static let cornerRadius: CGFloat = 10
    }

    // MARK: - properties

    private var dataArray = [ASCUserTableViewDataModelItem]()
    private var tableView = UITableView()
    weak var delegate: ASCFiltersViewControllerDelegate?

    // MARK: - search

    let searchController = UISearchController(searchResultsController: nil)
    private var filteredUsers = [ASCUserTableViewDataModelItem]()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.Colors.tableCategoryBackground.color
        searchController.searchBar.delegate = self
        setupNavigationBar()
        usersListRequest()
        setupTableView()
        configureSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }

    private func configureSearchController() {
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = NSLocalizedString("Select user", comment: "")
        navigationItem.hidesSearchBarWhenScrolling = false

        let rightBarButton = UIBarButtonItem(
            title: NSLocalizedString("Cancel", comment: ""),
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(cancelBarButtonItemTapped)
        )
        navigationItem.rightBarButtonItem = rightBarButton
    }

    private func setupTableView() {
        tableView.register(ASCSharingRightHolderTableViewCell.self, forCellReuseIdentifier: ASCSharingRightHolderTableViewCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = Asset.Colors.viewBackground.color
        tableView.layer.cornerRadius = Constants.cornerRadius

        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor,
                         leftConstant: Constants.leftRightInserts,
                         rightConstant: Constants.leftRightInserts)
    }

    @objc private func cancelBarButtonItemTapped() {
        dismiss(animated: true)
    }

    private func usersListRequest() {
        OnlyofficeApiClient.request(OnlyofficeAPI.Endpoints.People.all) { [weak self] response, error in
            if let error = error {
                log.error(error)
            } else if let users = response?.result {
                for user in users {
                    let firstName = user.firstName ?? ""
                    let lastName = user.lastName ?? ""
                    let fullName = "\(lastName) \(firstName)".trimmed

                    let userName = fullName
                    let department = user.department
                    let avatarUrl = user.avatar
                    let id = user.userId

                    self?.dataArray.append(ASCUserTableViewDataModelItem(id: id, avatarImageUrl: avatarUrl, userName: userName, userPosition: department))
                }

                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension ASCSelectUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredUsers.count
        }
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ASCSharingRightHolderTableViewCell.reuseId, for: indexPath) as? ASCSharingRightHolderTableViewCell else { return UITableViewCell() }

        let dataModel = getDataModel(indexPath: indexPath)

        cell.viewModel = .init(id: dataModel.id ?? "",
                               avatarUrl: dataModel.avatarImageUrl,
                               name: dataModel.userName ?? "",
                               department: dataModel.userPosition)
        return cell
    }

    func getDataModel(indexPath: IndexPath) -> ASCUserTableViewDataModelItem {
        if isFiltering {
            return filteredUsers[indexPath.row]
        } else {
            return dataArray[indexPath.row]
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        let dataModel = getDataModel(indexPath: indexPath)
        if let filterText = dataModel.userName {
            delegate?.updateData(filterText: filterText)
        }
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: - UISearchBarDelegate

extension ASCSelectUserViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchedText)
    }

    private func filterContentForSearchText(_ searchText: String) {
        filteredUsers = dataArray.filter { (user: ASCUserTableViewDataModelItem) -> Bool in
            (user.userName?.lowercased().contains(searchText.lowercased())) ?? false
        }

        tableView.reloadData()
    }
}
