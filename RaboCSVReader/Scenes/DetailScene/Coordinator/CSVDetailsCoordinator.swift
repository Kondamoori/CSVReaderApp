//
//  CSVDetailsCoordinator.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//

import Foundation
import UIKit
import SwiftUI

final class CSVDetailsCoordinator {
    
    // MARK: - Private properties
    
    private let navigationController: UINavigationController
    private let record: CSVRecord
    private var detailsViewController: UIViewController?
    
    // MARK: - Init
    
    init(navigationController: UINavigationController,
         record: CSVRecord) {
        self.navigationController = navigationController
        self.record = record
    }
}

// Extension - Coordinating

extension CSVDetailsCoordinator: Coordinating {
    
    // MARK: - Start
    
    func start() -> UIViewController {
        let detailsView = CSVDetailsView(viewModel: CSVDetailViewModel(csvRecord: record))
        let detailsController = UIHostingController(rootView: detailsView)
        detailsViewController = detailsController
        return detailsController
    }
}
