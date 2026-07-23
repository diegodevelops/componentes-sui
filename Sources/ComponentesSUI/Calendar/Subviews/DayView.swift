//
//  DayView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

struct DayView: View {
    
    var date: Date
    var monthDate: Date
    var events: [Date]?
    var calendarType: CalendarType
    @Binding var selectedDate: Date
    let font: Font
    let textColor: Color
    var selectAction: ((_ date: Date) -> Void)?
    var eventIndicatorIcon: Image?

    @State var hasEvents: Bool
    @State var isInCurrentDateMonth: Bool

    private(set) var day: Int
    private let today = Date()

    private var hasSelectAction: Bool

    // Caps the day circle's diameter so it doesn't scale unbounded with
    // column width on wide layouts (landscape, iPad), where it would
    // otherwise overflow the fixed row height and overlap adjacent weeks.
    private let maxDiameter: CGFloat = 44

    init(
        date: Date,
        monthDate: Date,
        events: [Date]?,
        calendarType: CalendarType,
        selectedDate: Binding<Date>,
        fontName: String = "Helvetica",
        textColor: Color,
        selectAction: ((_ date: Date) -> Void)?,
        eventIndicatorIcon: Image? = nil
    ) {
        self.date = date
        self.monthDate = monthDate
        self.events = events
        self.calendarType = calendarType
        _selectedDate = selectedDate
        self.font = Font.custom(fontName, size: 14)
        self.textColor = textColor
        self.selectAction = selectAction
        self.eventIndicatorIcon = eventIndicatorIcon

        _hasEvents = State(
            initialValue: false
        )

        _isInCurrentDateMonth = State(
            initialValue: monthDate
                .sameMonthAs(date: date)
        )

        self.day = Calendar.current.component(.day, from: date)
        self.hasSelectAction = selectAction != nil
    }
    
    var body: some View {
        
        GeometryReader {
            geometry in

            let diameter = min(geometry.size.width, maxDiameter)

            VStack(spacing: 0) {

                Spacer()
                Button(action: {

                    selectedDate = date
                    selectAction?(date)
                }, label: {

                    Text("\(day)")
                        .font(font)
                        .foregroundColor(
                            date.sameDayAs(date: selectedDate)
                            ? (hasSelectAction ? textColor : Color.accentColor.contrastingTextColor)
                            : textColor
                        )

                })
                .frame(
                    width: diameter,
                    height: diameter
                )
                .background() {
                    date.sameDayAs(date: selectedDate)
                    ? Color.accentColor.opacity(
                        hasSelectAction
                        ? (date.sameDayAs(date: today) ? 0.3 : 0)
                        : 1
                      )
                    : Color.accentColor.opacity(
                        date.sameDayAs(date: today)
                        ? 0.3
                        : 0
                    )
                }
                .overlay() {
                    if hasEvents {
                        eventIndicator
                            .padding(.top, 24)
                    }
                }
                .cornerRadius(diameter/2)
                Spacer()
            }
            .frame(width: geometry.size.width)
            .background(.clear)
            .opacity(
                calendarType == .week
                ? 1
                : (isInCurrentDateMonth ? 1 : 0)
            )
            .task {

                if let events = events {
                    if events.hasDateInSameDayAs(date) {
                        hasEvents = true
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var eventIndicator: some View {
        if let eventIndicatorIcon {
            eventIndicatorIcon
                .resizable()
                .scaledToFit()
                .frame(width: 8, height: 8)
        } else {
            Circle()
                .foregroundColor(Color.accentColor)
                .frame(width: 4)
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(
            date: Date(),
            monthDate: Date(),
            events: [Date()],
            calendarType: .week,
            selectedDate: .constant(Date()),
            textColor: .primary,
            selectAction: nil
        )
    }
}
