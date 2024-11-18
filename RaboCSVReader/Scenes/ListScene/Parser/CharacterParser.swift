//
//  CharacterParser.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//

import Foundation
import Combine

/// Error type to handle character parse
enum ParseError: Error, Equatable {
    case error(message: String)
    
    var rawValue: String {
        switch self {
        case .error(message: let message): message
        }
    }
}

/// Character parser which will parse each character from the csv file string and send different notifications for each event.
struct CharacterParser {
    
    // MARK: - Constants
    
    private enum Constants {
        static let errorMessage = "Unable to parse field. Unexpected character:"
    }
    
    // MARK: - Private properties
    
    private var paringStart = true
    private var parsingField = false
    private var parsingQuotes = false
    private var parsingInnerQuotes = false
    private let formatProvider: CSVFormatProvider
    
    // MARK - Internal properties
    
    let finishRowPublisher: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    let finishFieldPublisher: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    let appendCharPublisher: PassthroughSubject<Character, ParseError> = PassthroughSubject<Character, ParseError>()

    // MARK: - Init
    
    /// Initialisation
    /// - Parameter formatProvider: instance of formatProvider
    init(formatProvider: CSVFormatProvider) {
        self.formatProvider = formatProvider
    }
    
    // MARK: - Internal functions
    
    /// Main parse function to iterate each character of the file.
    /// - Parameter char: char.
    mutating func parse(_ char: Character) {
        if paringStart {
            if char == formatProvider.quoteCharacter {
                paringStart = false
                parsingQuotes = true
            } else if char == formatProvider.delimiter {
                finishFieldPublisher.send()
            } else if char.isNewline {
                finishRowPublisher.send()
            } else if char.isWhitespace {
                // ignore whitespaces between fields
            } else {
                parsingField = true
                paringStart = false
                appendCharPublisher.send(char)
            }
        } else if parsingField {
            if parsingInnerQuotes {
                if char == formatProvider.escapeCharacter {
                    appendCharPublisher.send(char)
                    parsingInnerQuotes = false
                } else {
                    appendCharPublisher.send(completion: .failure(ParseError.error(message: "\(Constants.errorMessage) \(char)")))
                }
            } else {
                if char == formatProvider.quoteCharacter {
                    parsingInnerQuotes = true
                } else if char == formatProvider.delimiter {
                    paringStart = true
                    parsingField = false
                    parsingInnerQuotes = false
                    finishFieldPublisher.send()
                } else if char.isNewline {
                    paringStart = true
                    parsingField = false
                    parsingInnerQuotes = false
                    finishRowPublisher.send()
                } else {
                    appendCharPublisher.send(char)
                }
            }
        } else if parsingQuotes {
            if parsingInnerQuotes {
                if char == formatProvider.quoteCharacter {
                    appendCharPublisher.send(char)
                    parsingInnerQuotes = false
                } else if char == formatProvider.delimiter {
                    paringStart = true
                    parsingField = false
                    parsingInnerQuotes = false
                    finishFieldPublisher.send()
                } else if char.isNewline {
                    paringStart = true
                    parsingQuotes = false
                    parsingInnerQuotes = false
                    finishRowPublisher.send()
                } else if char.isWhitespace {
                    // ignore whitespaces between fields
                } else {
                    appendCharPublisher.send(completion: .failure(ParseError.error(message: "\(Constants.errorMessage) \(char)")))
                }
            } else {
                if char == formatProvider.quoteCharacter {
                    parsingInnerQuotes = true
                } else {
                    appendCharPublisher.send(char)
                }
            }
        } else {
            appendCharPublisher.send(completion: .failure(ParseError.error(message: "\(Constants.errorMessage) \(char)")))
        }
    }
    
    mutating func reset() {
        paringStart = true
        parsingField = false
        parsingQuotes = false
        parsingInnerQuotes = false
    }
}
