//
//  CSVDataListViewModelTests.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 18/11/2024.
//

import XCTest
import Combine
@testable import RaboCSVReader


final class CSVDataListViewModelTests: XCTestCase {
    
    private var sut: CSVDataListViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    @MainActor
    func testHappyFlowWithLoadingRecords() {
        sut = CSVDataListViewModel(formatProvider: CSVFormats.semicolonDelimiter.format, csvFileName: "srini-example-csv-400K", recordSelection: { _ in })

        let expectation = expectation(description: "test")
        expectation.expectedFulfillmentCount = 1
        sut.$state.sink { competion in
        } receiveValue: { [weak self] state in
            if state == .loaded {
                XCTAssertTrue(self?.sut.csvData.records.count == 9)
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        sut.loadRecords()
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    @MainActor
    func testViewModelStateChangesInErrorFlowWithWrongConfiguration() {
        sut = CSVDataListViewModel(formatProvider: CSVFormats.semicolonDelimiter.format, csvFileName: "example-file-quotes", recordSelection: { _ in })

        let expectation = expectation(description: "test")
        sut.$state.sink { competion in
        } receiveValue: { value in
            guard case.error(let error) = value else {
                return
            }
            XCTAssertNotNil(error?.rawValue)
            XCTAssertEqual(error?.rawValue, "Unable to parse field. Unexpected character: V failed at row: 1, column: 0")

            expectation.fulfill()
        }.store(in: &cancellables)
        
        sut.loadRecords()
    
        wait(for: [expectation], timeout: 10.0)
    }
}
