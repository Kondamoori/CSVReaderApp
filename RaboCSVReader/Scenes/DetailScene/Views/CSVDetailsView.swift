//
//  CSVDetailsView.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//

import Foundation
import SwiftUI


struct CSVDetailsView: View {
    
    // MARK: - Internal properties
    
    @ObservedObject var viewModel: CSVDetailViewModel
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(Array(viewModel.csvRecord.data.keys), id: \.self) { key in
                    HStack {
                        Text(key)
                            .fontWeight(.bold)
                        Text(viewModel.csvRecord.data[key] ?? "")
                    }
                }
            }
        }
        .padding()
    }
}
