//
//  ViewController.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {
    lazy var searchView: SearchView = {
        let view = SearchView(frame: .zero)
        view.searchViewController = self
        return view
    }()

    let searchCollectionViewDataSource = SearchCollectionViewDataSource()

    override func loadView() {
        super.loadView()
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        searchView.configureCollectionView(dataSource: searchCollectionViewDataSource)
        searchView.configureSearchBar(delegate: self)
    }

    private func setupNavigationBar() {
        navigationItem.titleView = searchView.searchBar
    }

    func searchAlbums(with term: String) {
        self.searchCollectionViewDataSource.albums = CoreDataManager.shared.fetchAlbums(for: term)

        guard self.searchCollectionViewDataSource.albums.isEmpty else {
            DispatchQueue.main.async {
                self.searchView.collectionView.reloadData()
            }
            return
        }

        NetworkManager.shared.fetchAlbums(albumName: term) { [weak self] result, error in
            if let error {
                print("Error getting albums: \(error)")
                return
            }

            guard let result else {
                return
            }

            var albumsToSave: [(album: Album, imageData: Data)] = []
            let group = DispatchGroup()

            result.forEach { res in
                group.enter()
                NetworkManager.shared.fetchImage(from: res.artworkUrl100) { data, error in
                    if let error {
                        print("Failed to load image: \(error)")
                        return
                    }

                    guard let data else {
                        print("No data for image")
                        return
                    }

                    albumsToSave.append((album: res, imageData: data))
                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                CoreDataManager.shared.saveAlbums(albumsToSave, for: term)
                print("Successfully loaded \(albumsToSave.count) albums.")

                DispatchQueue.main.async {
                    self?.searchCollectionViewDataSource.albums = CoreDataManager.shared.fetchAlbums(for: term)
                    self?.searchView.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else {
            return
        }
        CoreDataManager.shared.saveSearchTerm(searchTerm)
        searchAlbums(with: searchTerm)
    }
}


