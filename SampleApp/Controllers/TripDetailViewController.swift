/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 A view controller class to show the details of a trip.
 */

import UIKit
import CoreLocation
import MapKit
import CoreData

class TripDetailViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - CollectionView items

    private let trip: Trip

    private enum TripsDetailsSection: Hashable {
        case images
        case details
        case map
    }
    private enum TripDetailsItem: Hashable {
        case image(NSManagedObjectID)
        case detail
        case mapView
    }
    static let sectionFooterElementKind = "section-footer-element-kind"
    private var pageControl = UIPageControl()

    // MARK: - AsyncSequence
    private var didSaveTask: Task<Void, Never>?

    // MARK: - CollectionView vars
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource <TripsDetailsSection, TripDetailsItem>!

    // MARK: - Initializers

    init(with trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
        didSaveTask?.cancel()
    }
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        addObserverForTripUpdates()
        configureHierarchy()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        generateOptionsMenu()
    }

    // MARK: - Options Menu Setup

    private func generateOptionsMenu() {
        navigationItem.title = trip.title
        let favoriteAttributes = favoriteActionAttributes()
        let viewContext = PersistenceController.shared.persistentContainer.viewContext

        let favoriteAction = UIAction(
            title: favoriteAttributes.title,
            image: UIImage(systemName: favoriteAttributes.symbol)
        ) { [unowned self] _ in
            trip.isFavorite.toggle()
            PersistenceController.shared.saveContext(context: viewContext)
            generateOptionsMenu()
        }
        let editTrip = UIAction(
            title: NSLocalizedString("Edit", comment: "Button label to edit a trip"),
            image: UIImage(systemName: "square.and.pencil")
        ) { [unowned self] _ in
            let editController = TripEditController(with: trip, context: viewContext)
            let navigationController = UINavigationController(rootViewController: editController)
            present(navigationController, animated: true)
        }
        let deleteTrip = UIAction(
            title: NSLocalizedString("Delete", comment: "Button label to delete a trip"),
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [unowned self] _ in
            let alertTitle = NSLocalizedString("Are you sure you want to delete this trip?", comment: "")
            let alert = UIAlertController(title: nil, message: alertTitle, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Trip", comment: ""), style: .destructive, handler: { [unowned self] _ in
                PersistenceController.shared.deleteTrip(trip: trip)
                navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Cancel", comment: "Action to cancel the deletion of a trip"),
                    style: .default,
                    handler: { [unowned self] _ in
                        dismiss(animated: true)
                    }
                ))
            present(alert, animated: true)
        }

        let menu = UIMenu(options: .displayInline, children: [favoriteAction, editTrip, deleteTrip])
        let optionButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = optionButton
    }

    private func favoriteActionAttributes() -> (title: String, symbol: String) {
        var favoriteTitle = NSLocalizedString("Add to Favorites", comment: "Action label to add a trip as a favorite")
        var favoriteSymbol = "heart"
        if trip.isFavorite {
            favoriteTitle = NSLocalizedString("Remove from Favorites", comment: "Action label to remove a trip from favorites")
            favoriteSymbol = "heart.fill"
        }
        return (title: favoriteTitle, symbol: favoriteSymbol)
    }
}

// MARK: - CollectionView Setup

private extension TripDetailViewController {
    func createLayout() -> UICollectionViewLayout {
        let provider = { [unowned self] (index: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            if index == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                section.visibleItemsInvalidationHandler = { [unowned self] _, offset, _ -> Void in
                    let page = round(offset.x / collectionView.bounds.width)
                    pageControl.currentPage = Int(page)
                }

                if let photosCount = trip.photos?.count, photosCount > 1 {
                    let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .estimated(22)
                        ),
                        elementKind: TripDetailViewController.sectionFooterElementKind,
                        alignment: .bottom
                    )
                    section.boundarySupplementaryItems = [sectionFooter]
                }
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(280)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(280)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        let layout = UICollectionViewCompositionalLayout(sectionProvider: provider, configuration: config)
        return layout
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configurePageControl(with superview: UIView) {
        guard let photosCount = trip.photos?.count else {
            return
        }
        pageControl.numberOfPages = photosCount
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(moveToPage), for: .valueChanged)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(pageControl)
        pageControl.pageIndicatorTintColor = .secondaryLabel
        pageControl.currentPageIndicatorTintColor = .orange
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    func configureDataSource() {
        let imageCell = UICollectionView.CellRegistration
        <TripImageDetailCell, Photo> { cell, _, item in
            if let imageData = item.thumbnailData {
                cell.imageView.image = UIImage(data: imageData)
            } else {
                cell.imageView.image = UIImage(systemName: noImageSymbol)
            }
        }
        let mapCell = UICollectionView.CellRegistration
        <TripLocationCell, Location> { cell, _, item in
            cell.mapView.centerCoordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = item.latitude
            annotation.coordinate.longitude = item.longitude
            annotation.title = item.name
            cell.mapView.addAnnotation(annotation)
        }
        let tripInfoCell = UICollectionView.CellRegistration
        <TripInformationCell, Trip> { cell, _, trip in
            cell.categoryImageView.image = UIImage(systemName: trip.category.symbolName)
            cell.titleLabel.text = trip.title
            cell.dateLabel.text = (trip.startDate ..< trip.endDate).formatted(date: .abbreviated, time: .omitted)
            cell.notesLabel.text = trip.notes
        }
        dataSource = UICollectionViewDiffableDataSource <TripsDetailsSection, TripDetailsItem>(
            collectionView: collectionView
        ) { [unowned self] (view: UICollectionView, index: IndexPath, item: TripDetailsItem) -> UICollectionViewCell? in
            // Return the cell.
            switch item {
            case .image(let photoID):
                guard let photo = PersistenceController.shared.persistentContainer.viewContext.object(with: photoID) as? Photo else {
                    return nil
                }
                return view.dequeueConfiguredReusableCell(using: imageCell, for: index, item: photo)
            case .detail:
                return view.dequeueConfiguredReusableCell(using: tripInfoCell, for: index, item: trip)
            case .mapView:
                return view.dequeueConfiguredReusableCell(using: mapCell, for: index, item: trip.location)
            }
        }
        let kind = TripDetailViewController.sectionFooterElementKind
        let footerRegistration = UICollectionView.SupplementaryRegistration
        <UICollectionReusableView>(elementKind: kind) { [unowned self] supplementaryView, _, _ in
            configurePageControl(with: supplementaryView)
        }
        dataSource.supplementaryViewProvider = { [unowned self] _, _, index in
             collectionView.dequeueConfiguredReusableSupplementary(
                using: footerRegistration,
                for: index
             )
        }
        refreshSnapshot()
    }

    func refreshSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot <TripsDetailsSection, TripDetailsItem>()
        snapshot.appendSections([.images, .details, .map])
        for photo in trip.photosOrdered {
            snapshot.appendItems([TripDetailsItem.image(photo.objectID)], toSection: .images)
        }
        snapshot.appendItems([TripDetailsItem.detail], toSection: .details)
        if trip.location != nil {
            snapshot.appendItems([TripDetailsItem.mapView], toSection: .map)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    @objc func moveToPage(pageControl: UIPageControl) {
        let scrollIndex = IndexPath(item: pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: scrollIndex, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - Core Data Notifications

private extension TripDetailViewController {
    func addObserverForTripUpdates() {
        didSaveTask = Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(named: NSManagedObjectContext.didSaveObjectsNotification) {
                if let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updates.isEmpty {
                    for update in updates {
                        if let currentTrip = self?.trip {
                            if update as? Trip == currentTrip {
                                self?.refreshSnapshot()
                            }
                        }
                    }
                }
            }
        }
    }
}
