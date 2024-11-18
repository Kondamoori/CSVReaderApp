//
//  CSVWorker.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 15/11/2024.
//

import Foundation
import Combine

/// A worker object which is mainly intended to deal with CSV parsing and communicate updates to the parties which are interested with csv file parsing.
final class CSVWorker: ObservableObject {
    
    // MARK: - State

    enum State: Equatable {
        case loading, loaded, error(ParseError), emptyFile
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let fetchCount = 10
    }
    
    // MARK: - Private properties
    
    private let formatProvider: CSVFormatProvider
    private var headers: [String] = []
    private var currentParsingRows: [[String]] = []
    private var cancellable = Set<AnyCancellable>()
    private let hasHeaders: Bool
    
    // MARK: - Published Internal properties
    
    @Published var records: [CSVRecord] = []
    @Published var state: State = .loading
    let csvParser: CSVFileParser

    
    // MARK: - Initialiser
    
    /// Function to initialise CSVWorker object.
    /// - Parameters:
    ///   - formatProvider: instance of CSVFormateProviderType.
    ///   - csvFileName: csvFileName
    ///   - hasHeaders: flag to indicate whether the first row should be considered as header row or not.
    init(formatProvider: CSVFormatProvider, csvFileName: String, hasHeaders: Bool = true) throws {
        self.formatProvider = formatProvider
        self.csvParser = try CSVFileParser(format: formatProvider, fileName: csvFileName)
        self.hasHeaders = hasHeaders
        bindPublishers()
    }
    
    // MARK: - Internal functions
    
    /// Function to fetch records from CSV parser.
    func fetchRecords() throws {
        state = .loading
        if csvParser.isParsingStarted {
            csvParser.loadMore(Constants.fetchCount)
        } else {
            csvParser.startParse(rowLimit: Constants.fetchCount)
        }
    }
    
    // MARK: - Private functions
    
    /// Binding parsing publisher to receive events from parser.
    private func bindPublishers() {
        csvParser.parsingPublisher.sink { [weak self] state in
            guard let self else { return }
            if state == .finished {
                /// Check headers is mentioned in format config, and consider the first row as header.
                if hasHeaders, headers.isEmpty {
                    let headers = currentParsingRows.removeFirst()
                    self.headers.append(contentsOf: headers)
                }
                
                records.append(contentsOf: currentParsingRows.map { CSVWorker.makeCSVRecords(headers: self.headers, fields: $0) })
                currentParsingRows.removeAll()
                Task {
                    await MainActor.run { [weak self] in
                        self?.state = .loaded
                    }
                }
            }
        }.store(in: &cancellable)
        
        /// Listen here for each row published. keep them in temp array.
        csvParser.rowsPublisher.sink { [weak self] error in
            if case Subscribers.Completion.failure(let characterError) = error {
                self?.state = .error(characterError)
            }
        } receiveValue: { [weak self] row in
            guard let self else { return }
            currentParsingRows.append(row)
        }.store(in: &cancellable)
    }
}

// MARK: - CSVWorker Extension

extension CSVWorker {
    
    /// Function to convert row strings to real row object with header key value pair.
    /// - Parameters:
    ///   - headers: headers array.
    ///   - fields: row fields array.
    /// - Returns: instance of CSVRecord.
    static func makeCSVRecords(headers: [String], fields: [String]) -> CSVRecord {
        var object = [String: String]()
        for (index, headerFieldName) in headers.enumerated() {
            object[headerFieldName] = index < fields.count ? fields[index] : ""
        }
        return CSVRecord(data: object)
    }
}
