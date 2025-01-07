//
//  SearchTermModel.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import Foundation
import CoreData

@objc(SearchTermModel)
public class SearchTermModel: NSManagedObject {
    @NSManaged public var term: String?
}
