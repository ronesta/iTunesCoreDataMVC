//
//  AlbumViewController.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import Foundation
import UIKit
import SnapKit

final class AlbumViewController: UIViewController {
    var album: AlbumModel?

    lazy var albumView = AlbumView(frame: .zero)

    override func loadView() {
        super.loadView()
        view = albumView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAlbum()
    }

    private func setupAlbum() {
        guard let album else {
            return
        }

        guard let imageData = CoreDataManager.shared.fetchImageData(forImageId: Int(album.artistId)),
              let image = UIImage(data: imageData) else {
            return
        }

        albumView.albumImageView.image = image
        albumView.albumNameLabel.text = album.collectionName
        albumView.artistNameLabel.text = album.artistName
        albumView.collectionPriceLabel.text = "\(album.collectionPrice) $"
    }
}

