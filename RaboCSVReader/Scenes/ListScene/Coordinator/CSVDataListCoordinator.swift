//
//  CSVDataListCoordinator.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import UIKit
import SwiftUI

/// CSVDataListCoordinator
final class CSVDataListCoordinator {
    
    // MARK: - Private properties
    
    private let navigationController: UINavigationController
    private var csvRecordsListViewController: UIViewController?
    private let csvFormatProvider: CSVFormatProvider
    private var detailsCoordinator: CSVDetailsCoordinator?
    private let csvFileName: String

    
    // MARK: - Initialisation
    
    init(navigationController: UINavigationController, csvFormateProvider: CSVFormatProvider, csvFileName: String) {
        self.navigationController = navigationController
        self.csvFormatProvider = csvFormateProvider
        self.csvFileName = csvFileName
    }
}

extension CSVDataListCoordinator: Coordinating {
    
    func start() -> UIViewController {
        let viewModel = CSVDataListViewModel(formatProvider: csvFormatProvider, csvFileName: csvFileName) { [weak self] record in
            self?.loadRecordDetails(record: record)
        }
        
        let listViewController = UIHostingController(rootView: CSVDataListView(viewModel: viewModel))
        csvRecordsListViewController = listViewController
        return csvRecordsListViewController!
    }
    
    func loadRecordDetails(record: CSVRecord) {
        let detailsCoordinator = CSVDetailsCoordinator(navigationController: navigationController, record: record)
        let detailsViewController = detailsCoordinator.start()
        self.detailsCoordinator = detailsCoordinator
        navigationController.pushViewController(detailsViewController, animated: true)
    }
}
