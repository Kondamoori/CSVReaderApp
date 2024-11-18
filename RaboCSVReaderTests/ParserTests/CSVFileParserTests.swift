//
//  CSVFileParserTests.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 17/11/2024.
//

import XCTest
import Combine
@testable import RaboCSVReader

final class CSVFileParserTests: XCTestCase {
    
    private var sut: CSVFileParser!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        sut = try CSVFileParser(format: CSVFormats.standard.format, fileName: "example-file-quotes")
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchingHeaderRows() {
        let row = ["Test Name", "Test value"]
        let finishRowExpectation = expectation(description: "Should finish row")
        
        sut.rowsPublisher.sink { _ in
            
        } receiveValue: { values in
            XCTAssertEqual(row, values)
            finishRowExpectation.fulfill()
        }.store(in: &cancellables)
        
        XCTAssertFalse(sut.isParsingStarted)
        sut.startParse(rowLimit: 1)
        
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
    
    func testFetchingWithQuotedText() {
        let row = [["Test Name", "Test value"], ["Hello Name", "\"Value\" result."]]
        
        var tempRows: [[String]] = []
        let finishRowExpectation = expectation(description: "Should finish row")
        
        sut.rowsPublisher.sink { _ in
            
        } receiveValue: { value in
            tempRows.append(value)
            if tempRows.count == 2 {
                XCTAssertEqual(tempRows, row)
                finishRowExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        XCTAssertFalse(sut.isParsingStarted)
        sut.startParse(rowLimit: 2)
        
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
    
    func testParserIsWorkingWithSemicolonDelimiterFormats() throws {
        sut = try CSVFileParser(format: CSVFormats.semicolonDelimiter.format, fileName: "srini-example-csv-400K")
        
        let finishRowExpectation = expectation(description: "test")
        var records: [[String]] = []
        sut.rowsPublisher.sink { completion in
        } receiveValue: { values in
            records.append(values)
            if records.count == 4 {
                finishRowExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        XCTAssertFalse(sut.isParsingStarted)
        
        // We are asking 10 rows, but it contains only 4 row.
        sut.startParse(rowLimit: 4)
        
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
    
    func testTotalNumerOfRowsWithSmallFile() throws {
        sut = try CSVFileParser(format: CSVFormats.standard.format, fileName: "example-file-quotes")
        let finishRowExpectation = expectation(description: "test")
        var records: [[String]] = []
        sut.rowsPublisher.sink { completion in
        } receiveValue: { values in
            records.append(values)
            if records.count == 4 {
                finishRowExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        XCTAssertFalse(sut.isParsingStarted)
        
        // We are asking 10 rows, but it contains only 4 row.
        sut.startParse(rowLimit: 10)
        
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
    
    /// Expectation here is to remove the parsed row from memory.
    func testInputStringCleanedOrNotOnceRowsArePublished() throws {
        sut = try CSVFileParser(format: CSVFormats.standard.format, fileName: "example-file-quotes")
        
        let stringBeforeClean = "Test Name, Test value\nHello Name,\"\"\"Value\"\" result.\"\nHello Name,\"\"\"Value\"\" result.\"\nHello Name,\"\"\"Value\"\" result.\"\nHello Name,\"\"\"Value\"\" result.\"\n"
        
        let stringAfterClean = "Hello Name,\"\"\"Value\"\" result.\"\nHello Name,\"\"\"Value\"\" result.\"\nHello Name,\"\"\"Value\"\" result.\"\nHello Name,\"\"\"Value\"\" result.\"\n"
        
        let finishRowExpectation = expectation(description: "test")
        sut.parsingPublisher.sink { completion in
        } receiveValue: { [weak self] state in
            switch state {
            case .parsing:
                XCTAssertEqual(self?.sut.csvInput, stringBeforeClean)
            case .finished:
                XCTAssertEqual(self?.sut.csvInput, stringAfterClean)
                finishRowExpectation.fulfill()
            default: break
            }
        }.store(in: &cancellables)
        
        XCTAssertFalse(sut.isParsingStarted)
        
        // We are asking 10 rows, but it contains only 4 row.
        sut.startParse(rowLimit: 1)
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
    
    func testLoadMoreFunctionCallWithOutParsingStart() {
        let finishRowExpectation = expectation(description: "test")
        
        sut.rowsPublisher.sink { completion in
            if case let .failure(error) = completion {
                XCTAssertEqual(error, ParseError.error(message: "no input string"))
                finishRowExpectation.fulfill()
            }
        } receiveValue: { values in
        }.store(in: &cancellables)
        
        XCTAssertFalse(sut.isParsingStarted)
        sut.loadMore(1)
        
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
    
    func testParsingWithWrongCombinationOfFormatAndFile() throws {
        sut = try CSVFileParser(format: CSVFormats.semicolonDelimiter.format, fileName: "example-file-quotes")
        let finishRowExpectation = expectation(description: "test")
        sut.rowsPublisher.sink { completion in
            if case let .failure(error) = completion {
                XCTAssertEqual(error, ParseError.error(message: "Unable to parse field. Unexpected character: V failed at row: 1, column: 0"))
                finishRowExpectation.fulfill()
            }
        } receiveValue: { _ in
        }.store(in: &cancellables)
        
        sut.startParse(rowLimit: 10)
        
        wait(for: [finishRowExpectation], timeout: 1.0)
    }
}
