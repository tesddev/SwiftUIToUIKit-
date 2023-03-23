//
//  MultilineNotesView.swift
//  SampleApp
//
//  Created by GIGL iOS on 23/03/2023.
//

import SwiftUI

struct MultilineNotesView: View {
    @State var notes = ""
    
    var body: some View {
        TextField("Notes", text: $notes, axis: .vertical)
            .lineLimit(1...10)
    }
}

struct MultilineNotesView_Previews: PreviewProvider {
    static var previews: some View {
        MultilineNotesView()
    }
}
