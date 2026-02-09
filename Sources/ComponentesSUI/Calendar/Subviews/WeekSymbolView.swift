//
//  WeekSymbolView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

struct WeekSymbolView: View {
    var date: Date
    @Binding var selectedDate: Date
        
    private(set) var week: Int // of month
    private var weekDates = [WeekDate]() // where count = 7
    private let fontName: String
    private let textColor: Color
    
    init(
        date: Date,
        selectedDate: Binding<Date>,
        fontName: String = "Helvetica",
        textColor: Color
    ) {
        self.date = date
        
        _selectedDate = selectedDate
        self.fontName = fontName
        self.textColor = textColor
                
        let cal = Calendar.current
        self.week = cal.component(.weekOfMonth, from: date)
        
        let sevenDates = date.currentWeekDates()
        for d in sevenDates {
            weekDates.append(WeekDate(date: d))
        }
    }
    
    var body: some View {
        HStack {
            ForEach(weekDates) {
                weekDate in
                Spacer()
                ZStack {
                    DaySymbolView(
                        date: weekDate.date,
                        selectedDate: $selectedDate,
                        fontName: fontName,
                        textColor: textColor
                    )
                }
                Spacer()
            }
        }
        .background(.clear)
    }
}

struct WeekSymbolView_Previews: PreviewProvider {
    static var previews: some View {
        WeekSymbolView(
            date: Date(),
            selectedDate: .constant(Date()),
            fontName: "Menlo",
            textColor: Color.primary
        )
    }
}
