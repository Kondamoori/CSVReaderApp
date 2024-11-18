//
//  CSVFormateProvider.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation

/// Protocol to define the csv format.
protocol CSVFormatProvider {
    var delimiter: Character { get }
    var lineFeed: Character { get }
    var quoteCharacter: Character { get }
    var escapeCharacter: Character { get }
    var hasHeader: Bool { get }
}
