//
//  SearchHistoryView.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 07.01.2025.
//

import Foundation
import UIKit
import SnapKit

final class SearchHistoryView: UIView {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .singleLine
        return tableView
    }()

    static let id = "cell"

    weak var searchHistoryViewController: SearchHistoryViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTableView(dataSource: UITableViewDataSource) {
        tableView.dataSource = dataSource
    }

    private func setupViews() {
        backgroundColor = .systemGray6
        addSubview(tableView)

        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SearchHistoryView.id)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchHistoryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedTerm =
                searchHistoryViewController?.searchHistoryTableViewDataSource.searchHistory[indexPath.row] else {
            return
        }
        performSearch(for: selectedTerm)
    }

    func performSearch(for term: String) {
        let searchViewController = SearchViewController()
        searchViewController.searchView.searchBar.isHidden = true
        searchViewController.searchAlbums(with: term)
        searchHistoryViewController?.navigationController?.pushViewController(searchViewController, animated: true)
    }
}
