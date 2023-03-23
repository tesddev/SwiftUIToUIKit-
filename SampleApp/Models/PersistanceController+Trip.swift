/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 An extension that wraps the related methods for managing trips.
*/

import Foundation

extension PersistenceController {
    func deleteTrip(trip: Trip) {
        let context = PersistenceController.shared.persistentContainer.viewContext
        context.delete(trip)
        PersistenceController.shared.saveContext(context: context)
    }
}
