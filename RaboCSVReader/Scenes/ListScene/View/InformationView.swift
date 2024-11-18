//
//  InformationView.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 16/11/2024.
//

import Foundation
import SwiftUI

/// View to display information to user, used for error state and empty states.
struct InformationView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let imageName = "csv"
        static let defaultMessage = "No Data Available"
    }
    
    // MARK: - Internal properties
    
    let message: String?
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 16) {
                Image(Constants.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 20)
                Text(message ?? Constants.defaultMessage)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.secondary)
                    .padding()
            }
            Spacer()
        }
        .padding(.leading, 50)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(message: "No records found, please check your input file")
    }
}
#endif
