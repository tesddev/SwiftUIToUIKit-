//
//  CategoryPickerView.swift
//  SampleApp
//
//  Created by Tes on 23/03/2023.
//

import SwiftUI

struct CategoryPickerView: View {
    @ObservedObject var trip: Trip
    var body: some View {
        LabeledContent {
            Picker("Category", selection: $trip.category) {
                ForEach(TripCategory.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .offset(x: 10)
        } label: {
            Label("Category", systemImage: "folder.fill")
        }
    }
}

struct CategoryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPickerView(trip: .preview)
    }
}
