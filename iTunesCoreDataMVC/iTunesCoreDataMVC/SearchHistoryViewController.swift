//
//  SearchHistoryViewController.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import UIKit

final class SearchHistoryViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .singleLine
        return tableView
    }()

    private let id = "cell"
    var searchHistory = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSearchHistory()
    }

    private func setupNavigationBar() {
        title = "History"
    }

    private func setupViews() {
        view.addSubview(tableView)
        view.backgroundColor = .systemGray6

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: id)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateSearchHistory() {
        searchHistory = CoreDataManager.shared.getSearchHistory()
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension SearchHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTerm = searchHistory[indexPath.row]
        performSearch(for: selectedTerm)
    }

    func performSearch(for term: String) {
        let searchViewController = SearchViewController()
        searchViewController.searchBar.isHidden = true
        searchViewController.searchAlbums(with: term)
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}

