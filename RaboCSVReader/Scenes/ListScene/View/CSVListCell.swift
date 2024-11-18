//
//  CSVListCell.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//

import Foundation
import SwiftUI

struct CSVDataCell: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let recordNumber = "Record #"
    }
    
    // MARK: - Internal properties
   
    let record: CSVRecord
    let rowNumber: Int

    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                VStack(alignment: .leading) {
                    ForEach(record.data.prefix(2).sorted(by: <), id: \.key) { (key, value) in
                        Text("\(key) : \(value)")
                    }
                }
                Spacer()
            }
            .padding()
            Text("\(Constants.recordNumber)\(rowNumber)")
                .font(.caption)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(4)
                .padding([.top, .trailing], 8)
        }
    }
}
