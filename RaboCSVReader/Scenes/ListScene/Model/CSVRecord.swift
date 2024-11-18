//
//  CSVRecord.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation

struct CSVRecord: Identifiable, Equatable {
    let id = UUID()
    let data: [String: String]
}

class CSVListData {
    var headers: [String] = []
    var records: [CSVRecord] = []
}
