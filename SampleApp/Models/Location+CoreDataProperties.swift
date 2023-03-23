/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An extension that wraps the related methods for managing locations.
*/

import Foundation
import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String
    @NSManaged public var formattedAddress: String
    @NSManaged public var trip: Trip?

}

extension Location: Identifiable {

}
