//
//  WeekView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

enum CalendarType {
    case week, month
}

struct WeekView: View {
    
    var date: Date
    var monthDate: Date
    var events: [Date]?
    var calendarType: CalendarType
    @Binding var selectedDate: Date
    let fontName: String
    let textColor: Color
    var selectAction: ((_ date: Date) -> Void)?
        
    private(set) var week: Int // of month
    private var weekDates = [WeekDate]() // where count = 7
    
    init(
        date: Date,
        monthDate: Date,
        events: [Date]?,
        calendarType: CalendarType,
        selectedDate: Binding<Date>,
        fontName: String,
        textColor: Color,
        selectAction: ((_ date: Date) -> Void)? = nil
    ) {
        
        self.date = date
        self.monthDate = monthDate
        self.events = events
        self.calendarType = calendarType
        _selectedDate = selectedDate
        self.fontName = fontName
        self.textColor = textColor
        self.selectAction = selectAction
                
        let cal = Calendar.current
        self.week = cal.component(.weekOfMonth, from: date)
        
        let sevenDates = date.currentWeekDates()
        for d in sevenDates {
            weekDates.append(WeekDate(date: d))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(weekDates) {
                    weekDate in
                    
                    Spacer()
                    ZStack {
                        DayView(
                            date: weekDate.date,
                            monthDate: monthDate,
                            events: events,
                            calendarType: calendarType,
                            selectedDate: $selectedDate,
                            fontName: fontName,
                            textColor: textColor,
                            selectAction: selectAction
                        )
                    }
                    Spacer()
                }
            }
            .background(.clear)
            .frame(height: 50)
        }
    }
}

struct WeekView_Previews: PreviewProvider {
    
    @State static var selectedDate: Date = .now
    
    static var previews: some View {
        WeekView(
            date: Date(),
            monthDate: Date(),
            events: [Date()],
            calendarType: .week,
            selectedDate: $selectedDate,
            fontName: "Menlo",
            textColor: .primary,
            selectAction: nil
        )
    }
}
