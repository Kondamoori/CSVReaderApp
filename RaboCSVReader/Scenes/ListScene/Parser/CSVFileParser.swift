//
//  CSVFileParser.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import Combine

/// A type which is used to parse CSV file give by file name.
final class CSVFileParser {
    
    // MARK: - Parsing Type,
    
    /// Intended to make use of this parser with input string.
    private enum ParsingType {
        case file, string
    }
    
    // MARK: - State
    
    enum State {
        case idle, parsing, finished
    }
    
    private enum Constants {
        static let thresholdCharacterLimit = 100
    }
    
    // MARK: - Private properties
    
    /// Limit used to prefetch chunk from file when limit is not reached but character count is reaching end. Example, you requested 100 rows but we still met only 40 rows and remaining text string is less than 100 char, it will fetch the chunk for our row parsing logic.
    private let thresholdCharacterLimit = Constants.thresholdCharacterLimit
    private var anyCancellable: Set<AnyCancellable> = []
    private var parsedFields = [String]()
    private var currentField = ""
    private var rowIndex = 0
    private var rowLimit: Int? = nil
    private var characterParser: CharacterParser
    private var operationQueue = OperationQueue()
    private var fileReader: FileReader?
    private var parseType: ParsingType = .string
    
    // MARK: - Internal properties
    
    var isParsingStarted: Bool { currentIndex != endIndex }
    private(set) var csvInput: String!
    private(set) var maxRowIndex: Int? = nil
    private(set) var totalParsedRows: Int = 0
    private(set) var currentIndex: String.Index = String.Index(utf16Offset: 0, in: "")
    private(set) var endIndex: String.Index = String.Index(utf16Offset: 0, in: "")

    
    // MARK: - Publishers
    
    /// Used to publish when each row completed parsing.
    let rowsPublisher: PassthroughSubject<[String], ParseError> = PassthroughSubject<[String], ParseError>()
    
    ///  Used to publish when parsing cycle state.
    let parsingPublisher: PassthroughSubject<State, Never> = PassthroughSubject<State, Never>()

    
    /// Initialiser.
    /// - Parameters:
    ///   - format: csv format.
    ///   - fileName: fileName which you want to parse.
    init(format: CSVFormatProvider, fileName: String) throws {
        characterParser = CharacterParser(formatProvider: format)
        fileReader = try FileReader(fileName)
        registerSubscriptions()
        operationQueue.maxConcurrentOperationCount = 1
        parsingPublisher.send(.idle)
    }
    
    // MARK: - Internal functions
    
    /// Method to trigger parsing from file.
    /// - Parameter rowLimit: number rows you want to parse.
    func startParse(rowLimit: Int? = nil) {
        do {
            self.rowLimit = rowLimit
            let csvInput = try fileReader?.readChunk()
            guard let csvInput else {
                rowsPublisher.send(completion: .failure(ParseError.error(message: "no input string")))
                return
            }
            parseType = .file
            parse(csvInput, rowLimit: rowLimit)
        }
        catch {
            rowsPublisher.send(completion: .failure(ParseError.error(message: "no input string")))
        }
    }
    
    /// Function which parse provided string.
    /// - Parameters:
    ///   - csvInput: csvInput string
    ///   - rowLimit: rows count that you want to fetch.
    func parse(_ csvInput: String, rowLimit: Int? = nil) {
        self.csvInput = csvInput
        self.rowLimit = rowLimit
        operationQueue.addOperation { [weak self] in
            guard let self else { return }
            reset()
            maxRowIndex = rowLimit.flatMap { $0 < 0 ? nil : self.totalParsedRows + $0 }
            currentIndex = csvInput.startIndex
            endIndex = csvInput.endIndex
            parseString()
        }
    }
    
    /// Function to load more records. Pleas remember that if you call this with out 'startParse', it wont work, since the csvInput string is empty.
    /// - Parameter noOfRows: noOfRows you want to fetch.
    func loadMore(_ noOfRows: Int) {
        operationQueue.addOperation { [weak self] in
            guard let self else { return }
            guard let csvInput, !csvInput.isEmpty, currentIndex < endIndex else {
                rowsPublisher.send(completion: .failure(ParseError.error(message: "no input string")))
                return
            }
            maxRowIndex = noOfRows + self.totalParsedRows
            parseString()
        }
    }
    
    // MARK: - Private functions
    
    /// Core function of parsing.
    /// ```
    /// Loop through each character of the csvString and until it reaches the limited row count. For each character run it will doe blow things.
    /// 1. Parse each character.
    /// 2. Append fields once field is accumulated and publish with rowPublisher.
    /// 3. checkAndUpdateEndIndex() this function will try to fetch chunk when the csvString is approaching to close index. This value can be changed with `thresholdCharacterLimit`.
    /// 4. Once row limit reached, it will send notification with parsing publisher and set it status back to idle.
    /// 5. Remove the used and parsed string from csvString to save memory.
    /// ```
    private func parseString() {
        /// Update listeners about parsing
        parsingPublisher.send(.parsing)
        
        /// Loop to each character with Character parser.
        while currentIndex < endIndex,
              !limitReached(rowIndex) {
            let char = csvInput[currentIndex]
            characterParser.parse(char)
            currentIndex = csvInput.index(after: currentIndex)
            if parseType == .file {
                checkAndUpdateEndIndex()
            }
        }
        
        /// Check limit here
        if !limitReached(rowIndex) {
            if !currentField.isEmpty {
                parsedFields.append(currentField)
            }
            if !parsedFields.isEmpty {
                rowsPublisher.send(parsedFields)
                totalParsedRows += 1
            }
        } else {
            /// Cleanup and post notification once limit reached.
            csvInput.removeSubrange(csvInput.startIndex...csvInput.index(before: currentIndex))
            currentIndex = csvInput.startIndex
            endIndex = csvInput.endIndex
            parsingPublisher.send(.finished)
            parsingPublisher.send(.idle)
        }
    }
    
    /// Check and load next chunk for csvInput string based on remaining characters length.
    private func checkAndUpdateEndIndex() {
        guard var currentInput = csvInput,
              csvInput.distance(from: currentIndex, to: endIndex) < thresholdCharacterLimit else { return }
        guard let nextInput = try? fileReader?.readChunk() else { return }
        currentInput.append(nextInput)
        endIndex = currentInput.endIndex
        csvInput = currentInput
    }
    
    /// Function to register subscribers.
    private func registerSubscriptions() {
        characterParser.finishFieldPublisher.sink { [weak self] in
            guard let self else { return }
            parsedFields.append(currentField)
            currentField = ""
        }.store(in: &anyCancellable)
        
        characterParser.appendCharPublisher.sink { [weak self] error in
            guard let self else { return }
            var errorMessage: String = ""
            if case Subscribers.Completion.failure(let characterError) = error {
                errorMessage += characterError.rawValue
            }
            errorMessage.append(" failed at row: \(rowIndex), column: \(parsedFields.count)")
            rowsPublisher.send(completion: .failure(ParseError.error(message: errorMessage)))
        } receiveValue: { [weak self] in
            guard let self else { return }
            currentField.append($0)
        }.store(in: &anyCancellable)
        
        characterParser.finishRowPublisher.sink{ [weak self] in
            guard let self else { return }
            parsedFields.append(String(currentField))
            totalParsedRows += 1
            rowsPublisher.send(parsedFields)
            rowIndex += 1
            parsedFields.removeAll()
            currentField = ""
        }.store(in: &anyCancellable)
    }
    
    /// Function to check limit reached or not.
    /// - Parameter rowNumber: rowNumber
    /// - Returns: true if limit reached.
    private func limitReached(_ rowNumber: Int) -> Bool {
        guard let maxRowIndex else { return false }
        return rowNumber >= maxRowIndex
    }
    
    /// Reset state.
    private func reset() {
        parsedFields.removeAll()
        currentField = ""
        rowIndex = 0
    }
}
