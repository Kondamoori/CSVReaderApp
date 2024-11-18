//
//  CSVFormat.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 15/11/2024.
//

import Foundation

/// Concrete type for CSVFormatProvider
struct CSVFormat: CSVFormatProvider {
    var delimiter: Character
    var lineFeed: Character
    var quoteCharacter: Character
    var escapeCharacter: Character
    var hasHeader: Bool = true
}

/// Enum to support known formats.
enum CSVFormats {
    case standard
    case semicolonDelimiter
    
    // MARK: - Internal properties
    
    var format: CSVFormatProvider {
        switch self {
        case .standard:
            return CSVFormat(delimiter: ",", lineFeed: "\n", quoteCharacter: "\"", escapeCharacter: "\"")
        case .semicolonDelimiter:
            return CSVFormat(delimiter: ";", lineFeed: "\n", quoteCharacter: "\"", escapeCharacter: "\"")
        }
    }
}
