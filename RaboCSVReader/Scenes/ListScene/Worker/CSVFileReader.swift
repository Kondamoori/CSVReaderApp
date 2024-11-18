//
//  CSVFileReader.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 15/11/2024.
//

import Foundation
import Combine

/// Error to handle File reader failures
enum FileReaderError: Error {
    case fileNotFound
    case dataToStringError
    case failedToReadChunk
    case endOfFile
    
    /// Error description, should use localised string here.
    var rawValue: String {
        switch self {
        case .fileNotFound: return "File not found"
        case .dataToStringError: return "Failed to convert data to string"
        case .failedToReadChunk: return "Failed to read chunk"
        case .endOfFile: return "End of file"
        }
    }
}

/// A type to handle file reading by chunks form given file URL or fileName.
final class FileReader {
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultChunkSize: Int = 1024
    }
    
    // MARK: - Private properties
    
    private let fileHandle: FileHandle
    
    // MARK: - Init
    
    /// Initialiser
    /// - Parameter fileName: fileName which will be used to read form bundle.
    init(_ fileName: String) throws {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            throw FileReaderError.fileNotFound
        }
        do {
            fileHandle = try FileHandle(forReadingFrom: fileURL)
        } catch {
            throw FileReaderError.fileNotFound
        }
    }
    
    /// Initialiser
    /// - Parameter fileURL: instance of URL to load file.
    init(_ fileURL: URL) throws {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            throw FileReaderError.fileNotFound
        }
        
        do {
            self.fileHandle = try FileHandle(forReadingFrom: fileURL)
        } catch {
            throw FileReaderError.fileNotFound
        }
    }
    
    /// Function to read a chunk of Data every single time when you call this function.
    /// This is using FileHandle to load the file with give URL and traverse till end of the file.
    /// - Returns: return the data chunk as String with .utf8 format.
    func readChunk() throws -> String {
        guard let chunk = try fileHandle.read(upToCount: Constants.defaultChunkSize) else {
            throw FileReaderError.endOfFile
        }
        if let bufferString = String(data: chunk, encoding: .utf8) {
            return bufferString
        } else {
            throw FileReaderError.dataToStringError
        }
    }
    
    /// Cleaning the fileHandle.
    deinit {
        try? fileHandle.close()
    }
}
