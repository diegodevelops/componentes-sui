//
//  WeekTextView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

struct WeekTextView: View {
    
    @Binding var selectedDate: Date
    let fontName: String
    let textColor: Color
    private let height: CGFloat = 15
    
    var body: some View {
        
        // title
        let str = selectedDate.getTimeString(
            format: "EEEE MMM d, yyyy"
        )
        
        Text(str)
            .font(Font.custom(
                fontName,
                size: height)
            )
            .multilineTextAlignment(.center)
            .background(.clear)
            .foregroundColor(textColor)
            .frame(height: height)
    }
}

struct WeekTextView_Previews: PreviewProvider {
    static var previews: some View {
        WeekTextView(
            selectedDate: .constant(Date()),
            fontName: "Menlo",
            textColor: Color.primary
        )
    }
}
