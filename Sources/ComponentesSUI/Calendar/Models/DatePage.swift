//
//  DatePage.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import Foundation

struct DatePage: Identifiable, Equatable {
    
    var id: String
    var date: Date
    private(set) var index: Int
    
    init(date: Date, index: Int) {
        self.id = "\(Int(date.timeIntervalSince1970))_\(index)"
        self.date = date
        self.index = index
    }
}

struct DatePageHelper {
    
    func newDailyDatePagesFrom(
        _ newCurrentDate: Date
    ) -> [DatePage] {
        
        let page1 = DatePage(
            date: newCurrentDate.yesterday(),
            index: 0
        )
        let page2 = DatePage(
            date: newCurrentDate,
            index: 1
        )
        let page3 = DatePage(
            date: newCurrentDate.tomorrow(),
            index: 2
        )
        return [
            page1,
            page2,
            page3
        ]
    }
    
    func newWeeklyDatePagesFrom(
        _ newCurrentDate: Date
    ) -> [DatePage] {
        
        let page1 = DatePage(
            date: newCurrentDate.sameDayPreviousWeek(),
            index: 0
        )
        let page2 = DatePage(
            date: newCurrentDate,
            index: 1
        )
        let page3 = DatePage(
            date: newCurrentDate.sameDayNextWeek(),
            index: 2
        )
        return [
            page1,
            page2,
            page3
        ]
    }
    
    // ADDED: Generates a year's worth of weekly pages (52 weeks in each direction)
    // centered on the given date, for the year-batch infinite scroll approach.
    func newYearlyWeeklyDatePagesFrom(
        _ newCurrentDate: Date
    ) -> [DatePage] {
        let cal = Calendar.current
        let weeksPerDirection = 52
        var pages = [DatePage]()

        for i in -weeksPerDirection...weeksPerDirection {
            let weekDate = cal.date(
                byAdding: .weekOfYear,
                value: i,
                to: newCurrentDate
            ) ?? newCurrentDate
            pages.append(DatePage(
                date: weekDate,
                index: i + weeksPerDirection
            ))
        }

        return pages
    }

    func newMonthlyDatePagesFrom(
        _ newCurrentDate: Date
    ) -> [DatePage] {
        
        let page1 = DatePage(
            date: newCurrentDate.sameDayPreviousMonth(),
            index: 0
        )
        let page2 = DatePage(
            date: newCurrentDate,
            index: 1
        )
        let page3 = DatePage(
            date: newCurrentDate.sameDayNextMonth(),
            index: 2
        )
        return [
            page1,
            page2,
            page3
        ]
    }
}
