//
//  CharacterParserTests.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 17/11/2024.
//

import XCTest
import Combine
@testable import RaboCSVReader


final class CharacterParserTests: XCTestCase {
    
    private var parser: CharacterParser!
    private var formatProvider: CSVFormatProvider!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        formatProvider = CSVFormats.standard.format
        parser = CharacterParser(formatProvider: formatProvider)
        cancellables = []
    }
    
    override func tearDown() {
        parser = nil
        formatProvider = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testParsingValidCharacters() {
        let finishFieldExpectation = expectation(description: "Should finish field")
        let appendCharExpectation = expectation(description: "Should append character")
        
        parser.finishFieldPublisher
            .sink {
                finishFieldExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        parser.appendCharPublisher
            .sink(receiveCompletion: { _ in
                XCTFail("Unexpected completion")
            }, receiveValue: { char in
                XCTAssertEqual(char, "a")
                appendCharExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        parser.parse("a")
        parser.parse(",")
        
        wait(for: [finishFieldExpectation, appendCharExpectation], timeout: 1.0)
    }
    
    func testParseErrorForUnexpectedCharacterAfterQuotes() {
        // let say example ""AB -- here its missing one more escape character at beginning.
        let errorExpectation = expectation(description: "Should send error")
        
        parser.appendCharPublisher
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTAssertEqual(error, ParseError.error(message: "Unable to parse field. Unexpected character: 8"))
                    errorExpectation.fulfill()
                }
            }, receiveValue: { value in
            })
            .store(in: &cancellables)
        
        parser.parse("\"")
        parser.parse("\"")
        parser.parse("8")
        wait(for: [errorExpectation], timeout: 5.0)
    }
    
    func testParseErrorForUnexpectedCharacterWhileParserInField() {
        // let say example A"B -- here its missing escape character in the middle.
        let errorExpectation = expectation(description: "Should send error")
        
        parser.appendCharPublisher
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTAssertEqual(error, ParseError.error(message: "Unable to parse field. Unexpected character: 8"))
                    errorExpectation.fulfill()
                }
            }, receiveValue: { value in
            })
            .store(in: &cancellables)
        
        parser.parse("A")
        parser.parse("\"")
        parser.parse("8")
        wait(for: [errorExpectation], timeout: 5.0)
    }
    
    
    func testFinishRowPublisherAtNewLineChar() {
        let finishRowExpectation = expectation(description: "Should finish row")
        parser.finishRowPublisher
            .sink {
                finishRowExpectation.fulfill()
            }
            .store(in: &cancellables)
        parser.parse("\n")
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
}
