/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 Trip editing view controller to enter trip details.
*/

import UIKit
import CoreData
import PhotosUI
import Foundation
import SwiftUI

class TripEditController: UIViewController {

    // MARK: - TableView datasource items

    private enum TripsSection: Int {
        case main
        case date
        case location
        case images
        case category
    }
    
    private enum TripItem: Hashable {
        case title
        case notes
        case startDate
        case endDate
        case location
        case addImage
        case displayImage(NSManagedObjectID)
        case category
    }

    // MARK: - TableView vars

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<TripsSection, TripItem>!

    // MARK: - Core Data vars

    let trip: Trip
    let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Photo> = {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trip == %@", trip)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Photo.addedDate, ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    // MARK: - Initializers

    init(with trip: Trip, context: NSManagedObjectContext) {
        self.trip = trip
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Life Cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }

    // MARK: - View configurations

    /// Configure navigation bar with cancel and save button
    private func configureNavigationBar() {
        title = NSLocalizedString("Edit Trip", comment: "Navigation Bar Item to edit a trip")
        let cancelAction = UIAction { [unowned self] _ in
            dismiss(animated: true)
            context.rollback()
        }
        let saveAction = UIAction { [unowned self] _ in
            PersistenceController.shared.saveContext(context: context)
            dismiss(animated: true)
        }

        let cancelBarButton = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)
        navigationItem.leftBarButtonItem = cancelBarButton

        let saveBarButton = UIBarButtonItem(systemItem: .save, primaryAction: saveAction)
        navigationItem.rightBarButtonItem = saveBarButton
    }
}

// MARK: - TableView setup

private extension TripEditController {
    func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = UIColor.secondarySystemBackground
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)
        registerCells()
        configureDataSource()
    }

    func registerCells() {
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.reuseIdentifier)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.reuseIdentifier)
        tableView.register(AddImageButtonCell.self, forCellReuseIdentifier: AddImageButtonCell.reuseIdentifier)
        tableView.register(ImageDisplayCell.self, forCellReuseIdentifier: ImageDisplayCell.reuseIdentifier)
        tableView.register(TripItemTableViewCell.self, forCellReuseIdentifier: ImageDisplayCell.defaultIdentifier)
    }

   func textCell(with text: String,
                 placeHolder: String?,
                 indexPath: IndexPath) -> TextFieldCell? {
        if let textCell: TextFieldCell = tableView.dequeueReusableCell(
            withIdentifier: TextFieldCell.reuseIdentifier,
            for: indexPath
        ) as? TextFieldCell {
            textCell.textField.placeholder = placeHolder
            textCell.textField.text = text
            return textCell
        }
        return nil
    }
    
    func notesCell(for trip: Trip, indexpath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripItemTableViewCell.defaultIdentifier, for: indexpath)
        cell.contentConfiguration = UIHostingConfiguration {
            MultilineNotesView(trip: trip)
        }
        return cell
    }

    func datePickercCell(with date: Date,
                         label: String,
                         indexPath: IndexPath, minimumDate: Date?, maximumDate: Date?) -> DatePickerCell? {
        if let datePickerCell: DatePickerCell = tableView.dequeueReusableCell(
            withIdentifier: DatePickerCell.reuseIdentifier,
            for: indexPath
        ) as? DatePickerCell {
            datePickerCell.datePicker.date = date
            datePickerCell.datePicker.maximumDate = maximumDate
            datePickerCell.datePicker.minimumDate = minimumDate
            datePickerCell.textLabel?.text = label
            datePickerCell.imageView?.image = UIImage(systemName: "calendar")
            return datePickerCell
        }
        return nil
    }

    func imageCell(with objectID: NSManagedObjectID, indexPath: IndexPath) -> ImageDisplayCell? {
        if let photo = context.object(with: objectID) as? Photo {
            let cellId = ImageDisplayCell.reuseIdentifier
            if let imageCell: ImageDisplayCell = tableView.dequeueReusableCell(
                withIdentifier: cellId,
                for: indexPath
            ) as? ImageDisplayCell {
                    if let imageData = photo.thumbnailData {
                        imageCell.imageView?.image = UIImage(data: imageData)
                    }
                    imageCell.onDelete { [unowned self]  in
                        delete(photo: photo)
                        fetchPhotos()
                    }
                    return imageCell
                }
        }
        return nil
    }

    func locationCell(with location: Location?, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationCell.reuseIdentifier,
            for: indexPath
        )
        cell.textLabel?.text = "Location"
        cell.imageView?.image = UIImage(systemName: "location.fill")
        cell.detailTextLabel?.text = location?.name ?? ""
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func addImageButtonCell(with indexPath: IndexPath) -> UITableViewCell? {
        if let buttonCell: AddImageButtonCell = tableView.dequeueReusableCell(
            withIdentifier: AddImageButtonCell.reuseIdentifier,
            for: indexPath
        ) as? AddImageButtonCell {
            buttonCell.button.setTitle("Add Image", for: .normal)
            buttonCell.onAction { [unowned self] in
                showImagePicker()
            }
            return buttonCell
        }
        return nil
    }
    
    func categoryCell(for trip: Trip, indexpath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripItemTableViewCell.defaultIdentifier, for: indexpath)
        cell.contentConfiguration = UIHostingConfiguration {
            CategoryPickerView(trip: trip)
        }
        return cell
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource
        <TripsSection, TripItem>(
            tableView: tableView
        ) { [unowned self] (_: _, index: IndexPath, item: TripItem) -> UITableViewCell? in
            switch item {
            case .title:
                let textCell = textCell(with: trip.title, placeHolder: nil, indexPath: index)
                textCell?.onTextChange { [unowned self] textField in
                    trip.title = textField.text ?? ""
                }
                return textCell
            case .notes:
                return notesCell(for: trip, indexpath: index)
            case .startDate:
                let datePickerCell = datePickercCell(
                    with: trip.startDate,
                    label: "Start Date",
                    indexPath: index,
                    minimumDate: nil,
                    maximumDate: trip.endDate
                )
                datePickerCell?.onDateChange { [unowned self] datePicker in
                    trip.startDate = datePicker.date
                    //Need to update the minumum date validation for the endDate picker
                    reconfigureItem(TripItem.endDate)
                }
                return datePickerCell
            case .endDate:
                let datePickerCell = datePickercCell(
                    with: trip.endDate,
                    label: "End Date",
                    indexPath: index,
                    minimumDate: trip.startDate,
                    maximumDate: nil
                )
                datePickerCell?.onDateChange { [unowned self] datePicker in
                    trip.endDate = datePicker.date
                    //Need to update the maximum date validation for the startDate picker
                    reconfigureItem(TripItem.startDate)
                }
                return datePickerCell
            case .location:
                return locationCell(with: trip.location, indexPath: index)
            case .addImage:
                return addImageButtonCell(with: index)
            case .displayImage(let photoID):
                return imageCell(with: photoID, indexPath: index)
            case .category:
                return categoryCell(for: trip, indexpath: index)
            }
        }
        tableView.dataSource = dataSource
        reloadStaticData()
        fetchPhotos()
    }

   func reloadStaticData() {
       var currentSnapshot = NSDiffableDataSourceSnapshot<TripsSection, TripItem>()
       currentSnapshot.appendSections([.main, .date, .location, .category, .images])
       currentSnapshot.appendItems([TripItem.title], toSection: .main)
       currentSnapshot.appendItems([TripItem.notes], toSection: .main)
       currentSnapshot.appendItems([TripItem.startDate], toSection: .date)
       currentSnapshot.appendItems([TripItem.endDate], toSection: .date)
       currentSnapshot.appendItems([TripItem.addImage], toSection: .images)
       currentSnapshot.appendItems([TripItem.location], toSection: .location)
       currentSnapshot.appendItems([TripItem.category], toSection: .category)
       dataSource.apply(currentSnapshot)
    }
    
    private func reconfigureItem(_ item: TripItem) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.reconfigureItems([item])
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
 }

// MARK: - NSFetchedResultsControllerDelegate

extension TripEditController: NSFetchedResultsControllerDelegate {
    private func fetchPhotos() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    private func delete(photo: Photo) {
        trip.removeFromPhotos(photo)
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let dataSource = tableView?.dataSource as? UITableViewDiffableDataSource<TripsSection, TripItem> else {
            assertionFailure("The data source has not implemented snapshot support while it should")
            return
        }
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        var currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<TripsSection, TripItem>
        var imageSectionIdentifiers = currentSnapshot.itemIdentifiers(inSection: .images)
        let updatedItemIdentifiers = snapshot.itemIdentifiers
        let newItems: [TripItem] = updatedItemIdentifiers.compactMap { itemIdentifier in
            let item = TripItem.displayImage(itemIdentifier)
            return item
        }
        imageSectionIdentifiers.removeFirst()
        currentSnapshot.deleteItems(imageSectionIdentifiers)

        currentSnapshot.appendItems(newItems, toSection: .images)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension TripEditController: PHPickerViewControllerDelegate {
    @objc func showImagePicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        let newFilter = PHPickerFilter.any(of: [.images])
        // Set the filter type according to the user’s selection.
        configuration.filter = newFilter
        // Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
        configuration.preferredAssetRepresentationMode = .current
        // Set the selection behavior to respect the user’s selection order.
        configuration.selection = .ordered
        // Set the selection limit to enable multiselection.
        configuration.selectionLimit = 0
        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers()
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func selectedAssetIdentifiers() -> [String] {
        var photoIdentifiers = [String]()
        for photo in trip.photosOrdered {
            if let assetIdentifier = photo.assetIdentifier {
                photoIdentifiers.append(assetIdentifier)
            }
        }
        return photoIdentifiers
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                guard let image = object as? UIImage, let identifier = result.assetIdentifier else {
                    print("Failed to load UIImage from the picker reuslt.")
                    return
                }
                Task { @MainActor [weak self] in
                    self?.saveImage(image, assetIdentifier: identifier)
                }
            }
        }
        dismiss(animated: true)
    }

    private func saveImage(_ image: UIImage, assetIdentifier: String) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("\(#function): Failed to retrieve JPG data and URL of the picked image.")
            return
        }
        guard let thumbnailData = image.preparingThumbnail(
            of: CGSize(width: 640, height: 480)
        )?.jpegData(compressionQuality: 1) else {
            print("\(#function): Failed to create a thumbnail for the picked image.")
            return
        }
        let photo = Photo(context: context)
        photo.data = imageData
        photo.thumbnailData = thumbnailData
        photo.assetIdentifier = assetIdentifier
        photo.addedDate = Date()
        trip.addToPhotos(photo)
    }
}

// MARK: - UITableViewDelegate

extension TripEditController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
        if indexPath.section == TripsSection.location.rawValue && indexPath.row == 0 {
            let searchViewController = TripLocationSearchController()
            if let location = trip.location {
                let searchResultItem = SearchResultItem(
                    name: location.name,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    formattedAddress: location.formattedAddress
                )
                searchViewController.currentItem = searchResultItem
            }
            searchViewController.onLocationSelectionChange { [weak self] selectedItem in
                if let item = selectedItem, let context = self?.context {
                    let location = Location(context: context)
                    location.name = item.name
                    location.latitude = item.latitude
                    location.longitude = item.longitude
                    location.formattedAddress = item.formattedAddress
                    self?.trip.location = location
                } else {
                    if let currentLocation = self?.trip.location {
                        self?.context.delete(currentLocation)
                        self?.trip.location = nil
                    }
                }
                if var currentSnapshot = self?.dataSource.snapshot() {
                    currentSnapshot.reconfigureItems([TripItem.location])
                    self?.dataSource.apply(currentSnapshot, animatingDifferences: false)
                }
            }
            navigationController?.pushViewController(searchViewController, animated: true)
        }
    }
}
