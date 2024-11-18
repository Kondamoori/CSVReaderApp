//
//  AppConfiguration.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 15/11/2024.
//

import Foundation

/// Type to support app level configuration, which can be injected to each scene.
final class AppConfiguration: ObservableObject {
    
    // MARK: - Internal properties

    let csvFormat: CSVFormatProvider
    let inputFileName: String
    static let `default` = AppConfiguration(csvFormat: CSVFormats.semicolonDelimiter.format, inputFileName: "srini-example-csv-400K")

    
    /// Init
    /// - Parameters:
    ///   - csvFormat: csvFormat
    ///   - inputFileName: inputFileName
    init(csvFormat: CSVFormatProvider, inputFileName: String) {
        self.csvFormat = csvFormat
        self.inputFileName = inputFileName
    }
}
