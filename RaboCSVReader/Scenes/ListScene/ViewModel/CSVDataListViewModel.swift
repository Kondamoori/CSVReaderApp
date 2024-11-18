//
//  CSVDataListViewModel.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import Combine

typealias CSVRecordSelectionHandler = ((CSVRecord) -> Void)?

final class CSVDataListViewModel: ObservableObject {
    
    // MARK: - State
    
    enum State: Equatable {
        case loading, loaded, error(ParseError?), emptyFile
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let genericErrorMessage = "Something went wrong. Please check input file."
    }
    
    // MARK: - Internal properties
    
    let recordSelection: CSVRecordSelectionHandler
    @Published var state: State = .loading
    let csvData: CSVListData = CSVListData()
    
    // MARK: - Private properties
    
    private var anyCancellable = Set<AnyCancellable>()
    private let csvWorker: CSVWorker?
    
    // MARK: - Initialiser
    
    /// Initialiser
    /// - Parameters:
    ///   - formatProvider: csv formatProvider
    ///   - csvFileName: csvFileName
    ///   - recordSelection: recordSelection handler to move to details screen.
    init(formatProvider: CSVFormatProvider, csvFileName: String, recordSelection: CSVRecordSelectionHandler) {
        do {
            self.csvWorker = try CSVWorker(formatProvider: formatProvider, csvFileName: csvFileName)
        } catch {
            self.csvWorker = nil
            self.state = .error(nil)
        }
        self.recordSelection = recordSelection
        subscribeToPublishers()
    }
    
    // MARK: - Internal functions
    
    /// Function to trigger loading records.
    @MainActor
    func loadRecords() {
        Task {
            try csvWorker?.fetchRecords()
        }
    }
    
    /// Function to handle pagination
    /// - Parameter index: index of the row.
    @MainActor
    func checkAndLoadMoreContentIfNeeded(index: Int) {
        guard csvData.records.endIndex - 1 == index  else {
            return
        }
        loadRecords()
    }
    
    @MainActor
    func refreshData() {
        resetData()
        loadRecords()
    }
    
    // MARK: - Private function
    
    /// Subscribe to publishers.
    private func subscribeToPublishers() {
        csvWorker?.$state.receive(on: DispatchQueue.main).sink { _ in
        } receiveValue: { [weak self] state in
            guard let self else { return }
            switch state {
            case .loaded:
                self.csvData.records = self.csvWorker?.records ?? []
                self.state = .loaded
            case .emptyFile:
                self.state = .emptyFile
            case .error(let error):
                self.updateStateWithError(error: error)
            default: break
            }
        }.store(in: &anyCancellable)
    }
    
    /// To refresh data.
    private func resetData() {
        csvData.headers.removeAll()
        csvData.records.removeAll()
    }
    
    private func updateStateWithError(error: Error) {
        guard let parseError = error as? ParseError else  {
            state = .error(nil)
            return
        }
        state = .error(parseError)
    }
    
}
