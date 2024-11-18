//
//  WorkerTests.swift
//  RaboCSVReaderTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 18/11/2024.
//

import XCTest
import Combine
@testable import RaboCSVReader

final class WorkerTests: XCTestCase {
    
    private var sut: CSVWorker!
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
    func testSuccessCaseWithFetchRecords() throws {
        sut = try CSVWorker(formatProvider: CSVFormats.semicolonDelimiter.format, csvFileName: "srini-example-csv-400K")

        let expectation = expectation(description: "test")
        sut.$state.sink { _ in
        } receiveValue: { [weak self] state in
            if state == .loaded && self?.sut.records.count == 9 {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        try sut.fetchRecords()
    
        wait(for: [expectation], timeout: 10.0)
    }
    
    @MainActor
    func testErrorFlowWithWrongConfiguration() throws {
        sut = try CSVWorker(formatProvider: CSVFormats.semicolonDelimiter.format, csvFileName: "example-file-quotes")

        let expectation = expectation(description: "test")
        sut.$state.sink { competion in
        } receiveValue: { value in
            guard case.error(let error) = value else {
                return
            }
            XCTAssertNotNil(error.rawValue)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        try sut.fetchRecords()
    
        wait(for: [expectation], timeout: 10.0)
    }
}
