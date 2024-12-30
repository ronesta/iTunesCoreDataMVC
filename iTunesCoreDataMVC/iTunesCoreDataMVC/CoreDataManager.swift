//
//  CoreDataManager.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iTunesModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    // swiftlint:disable:next function_parameter_count
    public func createOrUpdateAlbum(artistId: Int,
                                    artistName: String,
                                    collectionName: String,
                                    artworkUrl100: String,
                                    collectionPrice: Double,
                                    imageData: Data?,
                                    term: String) {
        let fetchRequest = NSFetchRequest<AlbumModel>(entityName: "AlbumModel")
        fetchRequest.predicate = NSPredicate(format: "artistId == %d", artistId)

        do {
            let albums = try context.fetch(fetchRequest)
            let album: AlbumModel
            if let existingAlbum = albums.first {
                album = existingAlbum
            } else {
                album = AlbumModel(context: context)
                album.artistId = Int64(artistId)
            }

            album.artistName = artistName
            album.collectionName = collectionName
            album.artworkUrl100 = artworkUrl100
            album.collectionPrice = collectionPrice
            album.imageData = imageData
            album.term = term

            saveContext()
        } catch {
            print("Error saving album: \(error)")
        }
    }

    func saveAlbums(_ albums: [(album: Album, imageData: Data?)], for searchTerm: String) {
        for (album, imageData) in albums {
            createOrUpdateAlbum(
                artistId: album.artistId,
                artistName: album.artistName,
                collectionName: album.collectionName,
                artworkUrl100: album.artworkUrl100,
                collectionPrice: album.collectionPrice,
                imageData: imageData,
                term: searchTerm)
        }
    }

    func saveSearchTerm(_ term: String) {
        let fetchRequest = NSFetchRequest<SearchTermModel>(entityName: "SearchTermModel")
        fetchRequest.predicate = NSPredicate(format: "term == %@", term)

        do {
            if try context.fetch(fetchRequest).isEmpty {
                let searchTerm = SearchTermModel(context: context)
                searchTerm.term = term
                saveContext()
            }
        } catch {
            print("Failed to save search term: \(error)")
        }
    }

    func fetchAlbums(for searchTerm: String) -> [AlbumModel] {
        let fetchRequest = NSFetchRequest<AlbumModel>(entityName: "AlbumModel")
        fetchRequest.predicate = NSPredicate(format: "term == %@", searchTerm)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "collectionName", ascending: true)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch albums: \(error)")
        }
        return []
    }

    func fetchImageData(forImageId id: Int) -> Data? {
        let fetchRequest = NSFetchRequest<AlbumModel>(entityName: "AlbumModel")
        fetchRequest.predicate = NSPredicate(format: "artistId == %d", id)

        do {
            if let albums = try context.fetch(fetchRequest).first {
                return albums.imageData
            }
        } catch {
            print("Error fetching image data for character with id \(id): \(error)")
        }

        return nil
    }

    func getSearchHistory() -> [String] {
        let fetchRequest = NSFetchRequest<SearchTermModel>(entityName: "SearchTermModel")

        do {
            let results = try context.fetch(fetchRequest)
            return results.map { $0.term ?? "" }
        } catch {
            print("Failed to fetch search history: \(error)")
            return []
        }
    }
}
