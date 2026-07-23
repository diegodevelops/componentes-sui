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
    var eventIndicatorIcon: Image?
    var eventIndicatorSize: EventIndicatorSize

    private(set) var week: Int // of month
    private var weekDates = [WeekDate]() // where count = 7

    // Mirrors DayView's indicator sizing so the row reserves enough extra
    // height for the enlarged, below-circle indicator in .big mode.
    private let baseRowHeight: CGFloat = 50
    private let bigIndicatorSpacing: CGFloat = 4
    private let indicatorScaleMultiplier: CGFloat = 3

    private var rowHeight: CGFloat {
        guard eventIndicatorSize == .big else { return baseRowHeight }
        let baseIndicatorSize: CGFloat = eventIndicatorIcon != nil ? 8 : 4
        return baseRowHeight + bigIndicatorSpacing + baseIndicatorSize * indicatorScaleMultiplier
    }

    init(
        date: Date,
        monthDate: Date,
        events: [Date]?,
        calendarType: CalendarType,
        selectedDate: Binding<Date>,
        fontName: String,
        textColor: Color,
        selectAction: ((_ date: Date) -> Void)? = nil,
        eventIndicatorIcon: Image? = nil,
        eventIndicatorSize: EventIndicatorSize = .small
    ) {

        self.date = date
        self.monthDate = monthDate
        self.events = events
        self.calendarType = calendarType
        _selectedDate = selectedDate
        self.fontName = fontName
        self.textColor = textColor
        self.selectAction = selectAction
        self.eventIndicatorIcon = eventIndicatorIcon
        self.eventIndicatorSize = eventIndicatorSize

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
                            selectAction: selectAction,
                            eventIndicatorIcon: eventIndicatorIcon,
                            eventIndicatorSize: eventIndicatorSize
                        )
                    }
                    Spacer()
                }
            }
            .background(.clear)
            .frame(height: rowHeight)
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
