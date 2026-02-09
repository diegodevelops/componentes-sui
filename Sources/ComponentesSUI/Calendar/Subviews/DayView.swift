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
    
    @State var hasEvents: Bool
    @State var isInCurrentDateMonth: Bool
    
    private(set) var day: Int
    private let today = Date()
    
    private var hasSelectAction: Bool
        
    init(
        date: Date,
        monthDate: Date,
        events: [Date]?,
        calendarType: CalendarType,
        selectedDate: Binding<Date>,
        fontName: String = "Helvetica",
        textColor: Color,
        selectAction: ((_ date: Date) -> Void)?
    ) {
        self.date = date
        self.monthDate = monthDate
        self.events = events
        self.calendarType = calendarType
        _selectedDate = selectedDate
        self.font = Font.custom(fontName, size: 14)
        self.textColor = textColor
        self.selectAction = selectAction
        
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
                    width: geometry.size.width,
                    height: geometry.size.width
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
                    Circle()
                        .foregroundColor(
                            hasEvents
                            ? Color.accentColor
                            : Color.clear
                        )
                        .padding(.top, 24)
                        .frame(width: 4)
                }
                .cornerRadius(geometry.size.width/2)
                Spacer()
            }
            .background(.clear)
            .frame(height: geometry.size.width)
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
