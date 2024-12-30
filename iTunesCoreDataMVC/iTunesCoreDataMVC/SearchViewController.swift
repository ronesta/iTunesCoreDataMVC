//
//  ViewController.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Albums"
        searchBar.sizeToFit()
        return searchBar
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 15, height: 130)
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.register(
            AlbumCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumCollectionViewCell.id
        )

        return collectionView
    }()

    var albums = [AlbumModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .systemGray6
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        navigationItem.titleView = searchBar

        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
    }

    func searchAlbums(with term: String) {
        self.albums = CoreDataManager.shared.fetchAlbums(for: term)

        guard self.albums.isEmpty else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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

            result.forEach { res in
                guard let url = URL(string: res.artworkUrl100) else {
                    print("Invalid URL for album image")
                    return
                }

                do {
                    let imageData = try Data(contentsOf: url)
                    albumsToSave.append((album: res, imageData: imageData))
                } catch {
                    print("Failed to load image data: \(error)")
                }
            }

            CoreDataManager.shared.saveAlbums(albumsToSave, for: term)
            print("Successfully loaded \(albumsToSave.count) albums.")

            DispatchQueue.main.async {
                self?.albums = CoreDataManager.shared.fetchAlbums(for: term)
                self?.collectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albums.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumCollectionViewCell.id,
            for: indexPath)
                as? AlbumCollectionViewCell else {
            return UICollectionViewCell()
        }

        let album = albums[indexPath.item]

        guard let imageData = CoreDataManager.shared.fetchImageData(forImageId: Int(album.artistId)),
              let image = UIImage(data: imageData) else {
            return cell
        }

        cell.configure(with: album, image: image)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let albumViewController = AlbumViewController()
        let album = albums[indexPath.item]
        albumViewController.album = album
        navigationController?.pushViewController(albumViewController, animated: true)
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


