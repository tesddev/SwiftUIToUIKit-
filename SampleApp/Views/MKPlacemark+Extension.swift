/*
See LICENSE folder for this sample’s licensing information.

Abstract:
MKPlacement extension to get the formatted address.
*/

import MapKit
import Contacts

extension MKPlacemark {

    var formattedAddress: String? {
        guard let postalAddress else { return nil }
        return CNPostalAddressFormatter
            .string(from: postalAddress, style: .mailingAddress)
            .replacingOccurrences(of: "\n", with: " ")
    }
}
