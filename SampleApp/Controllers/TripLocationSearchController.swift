/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Search locations using MapKit Seach APIs
*/

import UIKit
import MapKit

struct SearchResultItem: Hashable {
    var name: String
    var latitude: Double
    var longitude: Double
    var formattedAddress: String
}

class TripLocationSearchController: UITableViewController {

    var locationSelectionHandler: (SearchResultItem?) -> Void = { _ in }
    var currentItem: SearchResultItem?

    private var searchController = UISearchController(searchResultsController: nil)
    private var dataSource: UITableViewDiffableDataSource<Int, SearchResultItem>! = nil
    private var search: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            search?.cancel()
        }
    }

    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.reuseIdentifier)
        tableView.delegate = self
        configureDataSource()
        configureSearchController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationSelectionHandler(currentItem)
    }

    // MARK: - Search SetUp

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = NSLocalizedString("Seach Location", comment: "Search placeholder")
        searchController.hidesNavigationBarDuringPresentation = false
        navigationController?.navigationBar.isHidden = false
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        /*
         Search is presenting a view controller, and needs a controller in the presented view controller hierarchy
         to define the presentation context.
         */
        definesPresentationContext = true
    }

    // MARK: - TableView SetUp

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource
        <Int, SearchResultItem>(tableView: tableView) { [unowned self] tableView, indexPath, item -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LocationCell.reuseIdentifier,
                for: indexPath
            )
            cell.textLabel?.text = item.name
            let address = item.formattedAddress
            cell.detailTextLabel?.text = address
            if item == currentItem {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        tableView.dataSource = dataSource
        if let item = currentItem {
            var currentSnapshot = NSDiffableDataSourceSnapshot<Int, SearchResultItem>()
            currentSnapshot.appendSections([0])
            currentSnapshot.appendItems([item], toSection: 0)
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }
    }
}

// MARK: - Search

extension TripLocationSearchController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        // Only display results that are in travel-related categories.
        self.search = MKLocalSearch(request: request)
        self.search?.start { [weak self] response, _ in
            guard let response else {
                return
            }
            var currentSnapshot = NSDiffableDataSourceSnapshot<Int, SearchResultItem>()
            currentSnapshot.appendSections([0])
            var items: [SearchResultItem] = []
            response.mapItems.forEach { mapItem in
                if let coordinate = mapItem.placemark.location {
                    let searchResultItem = SearchResultItem(
                        name: mapItem.name ?? "",
                        latitude: coordinate.coordinate.latitude,
                        longitude: coordinate.coordinate.longitude,
                        formattedAddress: mapItem.placemark.formattedAddress ?? ""
                    )
                    items.append(searchResultItem)
                }
            }
            currentSnapshot.appendItems(items, toSection: 0)
            self?.dataSource.apply(currentSnapshot, animatingDifferences: false)
        }
    }

    func onLocationSelectionChange(handler: @escaping ((SearchResultItem?) -> Void)) {
        locationSelectionHandler = handler
    }
}

// MARK: - UITableViewDelegate

extension TripLocationSearchController {

    override func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
        if let searchResultItem = dataSource.itemIdentifier(for: indexPath) {
            if self.currentItem == searchResultItem {
                self.currentItem = nil
            } else {
                self.currentItem = searchResultItem
            }
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.reconfigureItems([searchResultItem])
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }
    }
}
