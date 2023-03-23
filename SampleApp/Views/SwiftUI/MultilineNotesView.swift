//
//  MultilineNotesView.swift
//  SampleApp
//
//  Created by Tes on 23/03/2023.
//

import SwiftUI

struct MultilineNotesView: View {
    @ObservedObject var trip: Trip
    
    var body: some View {
        TextField("Notes", text: $trip.notes, axis: .vertical)
            .lineLimit(1...10)
    }
}

struct MultilineNotesView_Previews: PreviewProvider {
    static var previews: some View {
        MultilineNotesView(trip: .preview)
    }
}
