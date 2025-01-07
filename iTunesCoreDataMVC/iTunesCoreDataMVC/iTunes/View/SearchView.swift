//
//  SearchView.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 07.01.2025.
//

import Foundation
import UIKit
import SnapKit

final class SearchView: UIView {
    weak var searchViewController: SearchViewController?

    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Albums"
        searchBar.sizeToFit()
        return searchBar
    }()

    let collectionView: UICollectionView = {
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCollectionView(dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = dataSource
    }

    func configureSearchBar(delegate: UISearchBarDelegate) {
        searchBar.delegate = delegate
    }

    private func setupViews() {
        backgroundColor = .systemGray6
        addSubview(searchBar)
        addSubview(collectionView)

        collectionView.delegate = self

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SearchView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let albumViewController = AlbumViewController()
        let album = searchViewController?.searchCollectionViewDataSource.albums[indexPath.item]
        albumViewController.album = album
        searchViewController?.navigationController?.pushViewController(albumViewController, animated: true)
    }
}
