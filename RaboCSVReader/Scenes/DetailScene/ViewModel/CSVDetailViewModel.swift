//
//  CSVDetailViewModel.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//

import Foundation

final class CSVDetailViewModel: ObservableObject {
    
    // MARK: - Internal properties
    
    let csvRecord: CSVRecord
    
    // MARK: - Init
    
    init(csvRecord: CSVRecord) {
        self.csvRecord = csvRecord
    }
    
}
