/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 An extension that wraps the related methods for managing trips.
*/

import Foundation
import CoreData
import UIKit

extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var title: String
    @NSManaged public var notes: String
    @NSManaged public var creationDate: Date
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var isFavorite: Bool
    @NSManaged public var categoryValue: String
    @NSManaged public var photos: NSSet?
    @NSManaged public var location: Location?

}

// MARK: Generated accessors for photos

extension Trip {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

extension Trip: Identifiable {

}

extension Trip {
    static func newTrip(with context: NSManagedObjectContext) -> Trip {
        let newTrip = Trip(context: context)
        newTrip.title = "New Trip"
        newTrip.creationDate = Date()
        newTrip.startDate = Date()
        newTrip.endDate = Date()
        return newTrip
    }

    var heroImage: UIImage? {
        if let imageData = (photosOrdered.first)?.thumbnailData {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
    var photosOrdered: [Photo] {
        let sortDesc = NSSortDescriptor(keyPath: \Photo.addedDate, ascending: true)
        guard let photosArray: [Photo] = photos?.sortedArray(using: [sortDesc]) as? [Photo] else {
            return []
        }
        return photosArray
    }

    var category: TripCategory {
        get {
             TripCategory(rawValue: categoryValue) ?? .solo
        }
        set {
            categoryValue = newValue.rawValue
        }
    }

    var formattedStartDate: String {
        startDate.formatted(.dateTime.month(.abbreviated).year())
    }
    var formattedEndDate: String {
        endDate.formatted(.dateTime.month(.abbreviated).year())
    }
}

extension Trip {
    static var preview: Trip {
        SampleData.generatePreviewTrip(context: PersistenceController.preview.persistentContainer.viewContext)
    }
}

extension Trip {
    static func recentTripsRequest() -> NSFetchRequest<Trip> {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = TripFilters.all.predicate()
        fetchRequest.fetchLimit = 4
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Trip.creationDate, ascending: false)]
        return fetchRequest
    }

    static func recentFavoriteTripsRequest() -> NSFetchRequest<Trip> {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = TripFilters.favorite.predicate()
        fetchRequest.fetchLimit = 4
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Trip.creationDate, ascending: false)]
        return fetchRequest
    }
}
