//
//  MonthlyCalendarView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

public struct MonthlyCalendarView: View {
    
    var width: CGFloat
    var events: [Date]?
    
    @Binding var selectedDate: Date
    var isLoading: Bool
    var selectAction: ((_ date: Date) -> Void)?
    
    // this flag was created because
    // for some reason the preview
    // canvas won't work unless
    // we force the first scroll
    // on .onAppear inside a
    // the main thread
    var isPreviewing: Bool
    
    let fontName: String
    let textColor: Color
    
    @State private var scrollOffset = CGPoint()
    @State private var didScrollManually = true
    @State private(set) var datePages: [DatePage]
    
    @State var opacity: Double = 1
        
    private let helper = DatePageHelper()
    
    init(
        width: CGFloat,
        events: [Date]?,
        selectedDate: Binding<Date>,
        isLoading: Bool,
        selectAction: ((_ date: Date) -> Void)? = nil,
        isPreviewing: Bool = false,
        fontName: String = "Helvetica",
        textColor: Color
    ) {
        self.width = width
        self.events = events
        _selectedDate = selectedDate
        self.isLoading = isLoading
        self.selectAction = selectAction
        self.isPreviewing = isPreviewing
        self.fontName = fontName
        self.textColor = textColor
        _datePages = State(
            initialValue: helper.newMonthlyDatePagesFrom(
                selectedDate.wrappedValue
            )
        )
    }
    
    public var body: some View {
        
        
        ScrollViewReader {
            proxy in
            
            OffsetObservingScrollView(
                axis: .horizontal,
                showsIndicators: false,
                enablePaging: true,
                offset: $scrollOffset
            ) {
                
                
                HStack(spacing: 0) {
                    ForEach(datePages) {
                        datePage in
                        
                        VStack(spacing: 0) {
                            
                            // header
                            MonthlyCalendarHeaderView(
                                width: width,
                                date: datePage.date,
                                selectedDate: $selectedDate,
                                fontName: fontName,
                                textColor: textColor
                            )
                            
                            Divider()
                            
                            // content
                            MonthlyCalendarContentView(
                                width: width,
                                date: datePage.date,
                                events: events,
                                selectedDate: $selectedDate,
                                fontName: fontName,
                                textColor: textColor,
                                selectAction: selectAction
                            )
                            .opacity(isLoading ? opacity : 1)
                            .padding(.top, 20)
                            .onAppear {
                                opacity = 0.5
                            }
                            .disabled(isLoading)
                        }
                        .frame(width: width)
                        .id(datePage.id)
                    }
                }
            }
            .frame(width: width)
            .onAppear() {
                
                didScrollManually = true
                if isPreviewing {
                    DispatchQueue.main.async {
                        proxy.scrollTo(
                            datePages[1].id,
                            anchor: UnitPoint(x: 0, y: 0)
                        )
                    }
                }
                else {
                    proxy.scrollTo(
                        datePages[1].id,
                        anchor: UnitPoint(x: 0, y: 0)
                    )
                }
            }
            .onChange(of: selectedDate) {
                _, newValue in
                 
                datePages = helper.newMonthlyDatePagesFrom(newValue)
            }
            .onChange(of: datePages) {
                _, _ in
                
                didScrollManually = true
                proxy.scrollTo(
                    datePages[1].id,
                    anchor: UnitPoint(x: 0, y: 0)
                )
            }
            .onChange(of: scrollOffset) {
                _, newValue in
                
                
                let prevPageX: CGFloat = 0
                let nextPageX = 2*width
                let x = newValue.x
                         
                if didScrollManually {
                    didScrollManually = false
                    return
                }
                                
                if x==prevPageX {
                    selectedDate = selectedDate.getPreviousOrNextMonthDate(
                        isNext: false
                    )
                }
                else if x==nextPageX {
                    selectedDate = selectedDate.getPreviousOrNextMonthDate(
                        isNext: true
                    )
                }
            }
        }
    }
}

struct MonthlyCalendarHeaderView: View {
    var width: CGFloat
    var date: Date
    @Binding var selectedDate: Date
    var events: [Date]?
    
    let fontName: String
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 2) {
            
            // month year
            Text(
                date.getTimeString(
                    format: "LLLL yyyy"
                )
            )
            .font(Font.custom(
                fontName,
                size: 15)
            )
            .foregroundStyle(textColor)
            .padding(.top, 16)
            
            // weekday symbols
            WeekSymbolView(
                date: date,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor
            )
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .frame(width: width)
    }
}

private struct MonthlyWeekRow: Identifiable, Equatable {
    
    var id: Int
    var date: Date
    
    init(date: Date) {
        self.id = Int(date.timeIntervalSince1970)
        self.date = date
    }
}

private struct MonthlyCalendarContentView: View {
    
    var width: CGFloat
    var date: Date
    var events: [Date]?
    @Binding var selectedDate: Date
    let fontName: String
    let textColor: Color
    var selectAction: ((_ date: Date) -> Void)?
    
    private(set) var weekRows: [MonthlyWeekRow]
    
    init(
        width: CGFloat,
        date: Date,
        events: [Date]?,
        selectedDate: Binding<Date>,
        fontName: String,
        textColor: Color,
        selectAction: ((_ date: Date) -> Void)?
    ) {
        self.width = width
        self.date = date
        self.events = events
        _selectedDate = selectedDate
        self.fontName = fontName
        self.textColor = textColor
        self.selectAction = selectAction
        
        let weekDates = date.currentMonthOneDayOfEachWeek()
        
        self.weekRows = []
        for d in weekDates {
            weekRows.append(
                MonthlyWeekRow(date: d)
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            ForEach(
                weekRows
            ) {
                weekRow in
                
                WeekView(
                    date: weekRow.date,
                    monthDate: date,
                    events: events,
                    calendarType: .month,
                    selectedDate: $selectedDate,
                    fontName: fontName,
                    textColor: textColor,
                    selectAction: selectAction
                )
            }
            
            if !selectedDate.isThisMonth() {
                ThisMonthButtonView(
                    selectedDate: $selectedDate,
                    fontName: fontName
                )
            }
            
            Spacer()
        }
        .padding(0)
        .background(.clear)
        .frame(width: width)
    }
}

private struct ThisMonthButtonView: View {
    
    @Binding var selectedDate: Date
    let fontName: String
    
    private let today = Date()
    
    var body: some View {
        Button(action: {
            selectedDate = today
        }) {
            
            HStack {
                Spacer()
                Text(LoStrings.backToThisMonthsSchedule)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColor)
                    .underline()
                    .font(Font.custom(
                        fontName,
                        size: 14)
                    )
                Spacer()
            }
        }
        .padding(20)
        .listRowBackground(Color.clear)
    }
}

struct MonthlyCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        
        WithBinding(data: Date()) {
            selectedDate in
            MonthlyCalendarView(
                width: 440,
                events: [ Date() ],
                selectedDate: selectedDate,
                isLoading: true ,
                selectAction: nil,
                isPreviewing: true,
                fontName: "Menlo",
                textColor: .primary
            )
        }
    }
}
