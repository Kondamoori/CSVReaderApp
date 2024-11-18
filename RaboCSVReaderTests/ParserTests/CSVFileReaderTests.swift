//
//  FileReaderTests.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//


import XCTest
@testable import RaboCSVReader

import XCTest

final class FileReaderTests: XCTestCase {
        
    func testFileNotFoundError() {
        XCTAssertThrowsError(try FileReader("nonexistent")) { error in
            XCTAssertEqual(error as? FileReaderError, .fileNotFound)
        }
    }
    
    func testFailedToReadChunkError() throws {
        // Prepare a temporary test file with invalid UTF-8 encoded data
        
        let tempFileURL = createTempFile(withData: Data([0xFF, 0xFE, 0xFD]))
        
        defer { try? FileManager.default.removeItem(at: tempFileURL) }
        
        let reader = try FileReader(tempFileURL)
        
        XCTAssertThrowsError(try reader.readChunk()) { error in
            XCTAssertEqual(error as? FileReaderError, .dataToStringError)
        }
    }
    
    func testSuccessfulReadContinueTillEndOfFile() throws {
        // Prepare a temporary test file with sample CSV content
        let csvContent = "Name, Age\nJohn, 30\nJane, 25\n"
        let tempFileURL = createTempFile(withData: Data(csvContent.utf8))
        
        defer { try? FileManager.default.removeItem(at: tempFileURL) }
        
        let reader = try FileReader(tempFileURL)
        
        let chunk = try reader.readChunk()
        XCTAssertEqual(chunk, csvContent)
        
        
        XCTAssertThrowsError(try reader.readChunk()) { error in
            XCTAssertEqual(error as? FileReaderError, .endOfFile)
        }
    }
    
    func testErrorTests() {
        let values = ["File not found", "Failed to convert data to string", "Failed to read chunk", "End of file"]
        let errors = [FileReaderError.fileNotFound, FileReaderError.dataToStringError, FileReaderError.failedToReadChunk, FileReaderError.endOfFile]
        
        XCTAssertEqual(errors.map({ $0.rawValue }), values)
    }
    
    // Helper function to create a temporary file
    private func createTempFile(withData data: Data) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("csv")
        
        FileManager.default.createFile(atPath: tempFileURL.path, contents: data, attributes: nil)
        
        return tempFileURL
    }
}
