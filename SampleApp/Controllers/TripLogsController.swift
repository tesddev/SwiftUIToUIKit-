/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 A view controller class to show the  list of a trips.
*/

import UIKit
import CoreData

class TripLogsController: UIViewController {

    private enum TripsSection {
        case main
    }

    // MARK: - CollectionView

    private var collectionView: UICollectionView!
    private var tripsDataSource: UICollectionViewDiffableDataSource<TripsSection, NSManagedObjectID>!

    // MARK: - Core Data

    private lazy var fetchedResultsController: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Trip.creationDate, ascending: false)]
        let viewContext = PersistenceController.shared.persistentContainer.viewContext
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    // MARK: - Life Cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSearchController()
        configureNavigationBar()
    }

    // MARK: - UI Configurations

    /// Configure navigation bar with title and a add button
    private func configureNavigationBar() {
        title = NSLocalizedString("Trips", comment: "Navigation bar title")
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBar = navigationController?.navigationBar
        navBar?.scrollEdgeAppearance = navBar?.standardAppearance

        let addTripAction = UIAction { [unowned self] _ in
            let context = PersistenceController.shared.makeChildViewContext()
            let trip = Trip.newTrip(with: context)
            let tripEditController = TripEditController(with: trip, context: context)
            let navController = UINavigationController(rootViewController: tripEditController)
            present(navController, animated: true)
        }
        let addbarButton = UIBarButtonItem(systemItem: .add, primaryAction: addTripAction)
        navigationItem.rightBarButtonItem = addbarButton
    }

    /// Add search bar to navigation bar
    /// Configure search result controller to display seach results
    private func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Title", comment: "Search bar placeholder text")
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

    /// fetchTrips based on the predicateß
    /// - Parameter filter: trip filter to apply
    private func fetchTrips(filter: TripFilters) {
        fetchedResultsController.fetchRequest.predicate = filter.predicate()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
}
// MARK: - NSFetchedResultsControllerDelegate

extension TripLogsController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let dataSource = collectionView?.dataSource as? UICollectionViewDiffableDataSource<TripsSection,
                NSManagedObjectID> else {
            assertionFailure("The data source has not implemented snapshot support while it should")
            return
        }
        dataSource.apply(
            snapshot as NSDiffableDataSourceSnapshot<TripsSection, NSManagedObjectID>,
            animatingDifferences: false
        )
    }
}
// MARK: - UICollectionView setup

extension TripLogsController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(220.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(220.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        configureCollectionViewDataSource()
    }

    private func configureCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <TripItemCollectionViewCell, NSManagedObjectID> { [self] cell, indexPath, _ in
            // Populate the cell with our item description.
            let trip = fetchedResultsController.object(at: indexPath)
            cell.titleLabel.text = trip.title
            cell.dateLabel.text = trip.formattedStartDate
            if let imageData = (trip.photosOrdered.first)?.thumbnailData {
                cell.imageView.image = UIImage(data: imageData)
            } else {
                cell.imageView.image = UIImage(systemName: noImageSymbol)
            }
        }
        tripsDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collection, index, id in
             collection.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: index,
                item: id
             )
        }
        /// Assign the data source to your collection view.
        collectionView.dataSource = tripsDataSource
        fetchTrips(filter: TripFilters.all)
    }
}
// MARK: - Search Delegates

extension TripLogsController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            guard let searchBarText = searchController.searchBar.text else { return }
            fetchTrips(filter: TripFilters.title(searchBarText))
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchTrips(filter: TripFilters.all)
    }
}
// MARK: - Collection view Delegate

extension TripLogsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trip = fetchedResultsController.object(at: indexPath)
        let detailViewController = TripDetailViewController(with: trip)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
