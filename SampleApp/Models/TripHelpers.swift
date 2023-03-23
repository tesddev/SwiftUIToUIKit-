/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 Trip helpers holds enumerations and constants specific to trips.
*/

import Foundation

let noImageSymbol = "square.dashed"

enum TripCategory: String, CaseIterable, Identifiable {
    case adventure = "Adventure"
    case business = "Business"
    case leisure = "Leisure"
    case solo = "Solo"

    var id: Self { self }
    var symbolName: String {
        switch self {
        case .adventure: return "figure.skiing.downhill"
        case .business: return "bag.fill"
        case .leisure: return "beach.umbrella.fill"
        case .solo: return "figure.walk.diamond.fill"

        }
    }
    var localizedTitle: String {
        switch self {
        case .adventure: return NSLocalizedString("Adventure", comment: "Trip category for adventure")
        case .business: return NSLocalizedString("Business", comment: "Trip category for business")
        case .leisure: return NSLocalizedString("Leisure", comment: "Trip category for leisure")
        case .solo: return NSLocalizedString("Solo", comment: "Trip category for solo adventures")
        }
    }
}

enum TripFilters: Hashable {
    case all
    case favorite
    case category(TripCategory)
    case title(String)

    func predicate() -> NSPredicate? {
        switch self {
        case .all:
            return nil
        case .favorite:
            return NSPredicate(format: "%K == %d", #keyPath(Trip.isFavorite), true)
        case .category(let category):
            return NSPredicate(format: "%K == %@", #keyPath(Trip.categoryValue), category.rawValue)
        case .title(let searchText):
            return NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Trip.title), searchText)
        }
    }
}
