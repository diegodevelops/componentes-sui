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
    var eventIndicatorSize: EventIndicatorSize

    @State var hasEvents: Bool
    @State var isInCurrentDateMonth: Bool

    private(set) var day: Int
    private let today = Date()

    private var hasSelectAction: Bool

    // Caps the day circle's diameter so it doesn't scale unbounded with
    // column width on wide layouts (landscape, iPad), where it would
    // otherwise overflow the fixed row height and overlap adjacent weeks.
    private let maxDiameter: CGFloat = 44

    // The height reserved for the day circle itself, regardless of
    // eventIndicatorSize. Keeping this fixed (matches WeekView's row
    // height in .small mode) means the circle/day number always lands
    // in the same spot, whether or not a .big indicator is added below it.
    private let baseRowHeight: CGFloat = 50

    // In .big mode the indicator no longer fits inside the circle, so it's
    // placed below it instead; this is the gap between the two. WeekView
    // reserves matching extra row height so it doesn't overlap the next week.
    private let bigIndicatorSpacing: CGFloat = 4
    private let indicatorScaleMultiplier: CGFloat = 2

    init(
        date: Date,
        monthDate: Date,
        events: [Date]?,
        calendarType: CalendarType,
        selectedDate: Binding<Date>,
        fontName: String = "Helvetica",
        textColor: Color,
        selectAction: ((_ date: Date) -> Void)?,
        eventIndicatorIcon: Image? = nil,
        eventIndicatorSize: EventIndicatorSize = .small
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
        self.eventIndicatorSize = eventIndicatorSize

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

                // Fixed-height block: the day circle is always centered
                // within the same baseRowHeight, so its position never
                // shifts based on whether a .big indicator is appended
                // below it for this particular day.
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
                        if hasEvents && eventIndicatorSize == .small {
                            eventIndicator
                                .padding(.top, 24)
                        }
                    }
                    .cornerRadius(diameter/2)

                    // In .small mode the circle stays centered in its block
                    // (trailing Spacer). In .big mode it's pinned to the
                    // block's bottom edge instead, so bigIndicatorSpacing is
                    // the exact gap to the indicator below — otherwise the
                    // centering slack above would add to it unpredictably.
                    if eventIndicatorSize == .small {
                        Spacer()
                    }
                }
                .frame(height: baseRowHeight)

                if hasEvents && eventIndicatorSize == .big {
                    eventIndicator
                        .padding(.top, bigIndicatorSpacing)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
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
        let scale: CGFloat = eventIndicatorSize == .big ? indicatorScaleMultiplier : 1

        if let eventIndicatorIcon {
            eventIndicatorIcon
                .resizable()
                .scaledToFit()
                .frame(width: 8 * scale, height: 8 * scale)
        } else {
            Circle()
                .foregroundColor(Color.accentColor)
                .frame(width: 4 * scale)
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
