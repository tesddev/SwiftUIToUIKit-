/*
See LICENSE folder for this sample’s licensing information.

Abstract:
 Sample trips data generator
*/

import UIKit
import CoreData

struct SampleData {
    static func generatePreviewTrip(context: NSManagedObjectContext) -> Trip {
        if let trip = try? context.fetch(Trip.fetchRequest()).first {
            return trip
        } else {
            let newTrip = Trip(context: context)
            newTrip.title = "Preview Trip"
            newTrip.notes = "Preview notes"
            newTrip.startDate = Date()
            newTrip.endDate = Date()
            newTrip.creationDate = Date()
            newTrip.isFavorite = true
            newTrip.categoryValue = "Solo"
            let photo = Photo(context: context)
            let image = UIImage(named: "Kakadu_1")
            photo.data = image?.pngData()
            photo.addedDate = Date()
            let thumbnailData = image?.preparingThumbnail(
                of: CGSize(width: 640, height: 480)
            )?.jpegData(compressionQuality: 1)
            photo.thumbnailData = thumbnailData
            newTrip.addToPhotos(photo)
            return newTrip
        }
    }

    /// load sample trips details json
    static func load<T: Decodable>(_ filename: String) -> T {
        let file = Bundle.main.url(forResource: filename, withExtension: nil)!
        let data = try! Data(contentsOf: file)
        return try! JSONDecoder().decode(T.self, from: data)
    }

    /// generating sample trips if we dont have any in the database
    /// Sample data is reading from the file SampleTripsData.json
    static func generateSampleDataIfNeeded(context: NSManagedObjectContext, maxTrips: Int = 5) {
        context.perform {
            guard let number = try? context.count(for: Trip.fetchRequest()), number == 0 else {
                return
            }
            let sampleData: [Dictionary<String, String>] = load("SampleTripsData.json")
            var tripsCount = 0
            for trip in sampleData {
                 let newTrip = Trip(context: context)
                 newTrip.title = trip["title"] ?? ""
                 newTrip.notes = trip["notes"] ?? ""
                 newTrip.startDate = Date()
                 newTrip.endDate = Date()
                 newTrip.creationDate = Date()
                 newTrip.isFavorite = true
                 newTrip.categoryValue = trip["categoryValue"] ?? "Solo"
                 let imageIdentifier = trip["image_identifier"] ?? ""
                 var index = 1
                 while let image = UIImage(named: imageIdentifier + "_\(index)") {
                    let photo = Photo(context: context)
                    photo.data = image.pngData()
                    photo.addedDate = Date()
                    guard let thumbnailData = image.preparingThumbnail(
                        of: CGSize(width: 640, height: 480)
                    )?.jpegData(compressionQuality: 1) else {
                        print("\(#function): Failed to create a thumbnail for the picked image.")
                        return
                    }
                    photo.thumbnailData = thumbnailData
                    newTrip.addToPhotos(photo)
                    index += 1
                }
                tripsCount += 1
                if tripsCount == maxTrips {
                    break
                }
            }
            do {
                try context.save()
            } catch {
                print("Failed to saving test data: \(error)")
            }
        }
    }
}
