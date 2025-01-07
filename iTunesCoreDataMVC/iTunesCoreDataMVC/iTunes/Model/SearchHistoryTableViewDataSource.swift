//
//  SearchHistoryTableViewDataSource.swift
//  iTunesCoreDataMVC
//
//  Created by Ибрагим Габибли on 07.01.2025.
//

import Foundation
import UIKit

final class SearchHistoryTableViewDataSource: NSObject, UITableViewDataSource {
    var searchHistory = [String]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryView.id, for: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }
}
