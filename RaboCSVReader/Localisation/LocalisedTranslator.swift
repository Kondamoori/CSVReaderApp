//
//  LocalisedTranslator.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 18/11/2024.
//

import Foundation

/// Type which used access localised keys.
enum LocalisedTranslator {
    
    // Transaction scene
    enum ListScene {
        static let sceneTitle = NSLocalizedString("listSceneTitle", comment: "")
        static let genericErrorMessage = NSLocalizedString("genericErrorMessage", comment: "")
        static let emptyFile = NSLocalizedString("emptyFile", comment: "")
        static let emptyRecords = NSLocalizedString("recordsEmpty", comment: "")
        static let emptyRecordsInfoText = NSLocalizedString("emptyRecordsInfoText", comment: "")
    }
    
    // Alert
    struct AlertTranslation {
        static let error =  NSLocalizedString("error", comment: "")
        static let ok = NSLocalizedString("ok", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
    }
}
