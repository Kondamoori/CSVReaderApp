//
//  CSVDataListView.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import SwiftUI

/// View To show user list
struct CSVDataListView: View {
    
    // MARK: Constants
    
    private enum Constants {
        static let backgroundColor = Color(hex: 0xF3F6F9)
    }
    
    // MARK: - Internal properties
    
    @ObservedObject var viewModel: CSVDataListViewModel
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var listContent: AnyView = AnyView(EmptyView())
    
    var body: some View {
        listContent
            .background(Constants.backgroundColor)
            .onChange(of: viewModel.state) { oldState, newState in
                handleStateChange(newState)
            }
            .onReceive(viewModel.$state) { value in
                handleStateChange(value)
            }.task {
                viewModel.loadRecords()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(LocalisedTranslator.AlertTranslation.ok))
                )
            }
            .navigationTitle(LocalisedTranslator.ListScene.sceneTitle)
    }
    
    /// Organise state changes
    private func handleStateChange(_ state: CSVDataListViewModel.State) {
        switch state {
        case .loading:
            listContent = AnyView(
                ForEach((0..<10).map { String($0) }, id: \.self) { _ in
                    CSVDataCell(record: CSVRecord(data: ["Loading...": ""]), rowNumber: 1).shimmer()
                }
            )
            showAlert = false
        case .loaded:
            listContent = AnyView(
                List {
                    ForEach(viewModel.csvData.records.indices, id: \.self) { index in
                        CSVDataCell(record: viewModel.csvData.records[index], rowNumber: index + 1)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            checkIfShouldLoadMoreContent(geometry: geometry, index: index)
                                        }
                                }
                            )
                            .onTapGesture {
                                viewModel.recordSelection?(viewModel.csvData.records[index])
                            }
                    }
                })
            showAlert = false
        case .emptyFile:
            showAlertForState(title: LocalisedTranslator.ListScene.emptyFile, message: LocalisedTranslator.ListScene.emptyRecords)
            listContent = AnyView(InformationView(message: LocalisedTranslator.ListScene.emptyRecordsInfoText))
            showAlert = true
        case .error(let error):
            showAlertForState(title: LocalisedTranslator.AlertTranslation.error, message: error?.rawValue ?? LocalisedTranslator.ListScene.genericErrorMessage)
            showAlert = true
            listContent = AnyView(InformationView(message: error?.rawValue))
        }
    }
    
    private func showAlertForState(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func checkIfShouldLoadMoreContent(geometry: GeometryProxy, index: Int) {
        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        
        // Trigger loading when the view is within 200 points from the bottom of the screen
        if frame.maxY > screenHeight - 200 {
            viewModel.checkAndLoadMoreContentIfNeeded(index: index)
        }
    }
}
