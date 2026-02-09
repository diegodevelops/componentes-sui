//
//  DaySymbolView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

struct DaySymbolView: View {
    var date: Date
    @Binding var selectedDate: Date
    private let font: Font
    private let textColor: Color
    
    private(set) var weekDay: Int
    private(set) var weekDaySymbol: String
    private let width: CGFloat = 44
    
    init(
        date: Date,
        selectedDate: Binding<Date>,
        fontName: String = "Helvetica",
        textColor: Color
    ) {
        self.date = date
        _selectedDate = selectedDate
        
        let cal = Calendar.current
        let symbols = cal.veryShortWeekdaySymbols
        let wd =  Calendar.current.component(.weekday, from: date)
        
        self.weekDaySymbol = symbols[wd - 1]
        self.weekDay = wd
        self.font = Font.custom(fontName, size: 10)
        self.textColor = textColor
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            Text(weekDaySymbol)
                .font(font)
                .padding(.bottom, 16)
                .padding(.top, 16)
                .foregroundColor(textColor)
                .opacity(0.8)
            Spacer()
        }
        .background(.clear)
        .frame(height: 26)
    }
}

struct DaySymbolView_Previews: PreviewProvider {
    static var previews: some View {
        DaySymbolView(
            date: Date(),
            selectedDate: .constant(Date()),
            fontName: "Menlo",
            textColor: Color.primary
        )
    }
}
