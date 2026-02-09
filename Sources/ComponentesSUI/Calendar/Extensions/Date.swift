//
//  Date.swift
//  ComponentesSUI
//
//  Created by Diego A. Perez Pares on 2/9/26.
//

import Foundation


extension Date {
    
    func timestamp() -> Int {
        return Int(self.timeIntervalSince1970*1000)
    }
    
    func month() -> Int {
        return Calendar.current
            .component(.month, from: self)
    }
    
    func year() -> Int {
        return Calendar.current
            .component(.year, from: self)
    }
    
    func isThisYear() -> Bool {
        let yearToday = Calendar
            .current
            .component(
                .year,
                from: Date()
            )
        return self.year() == yearToday
    }
    
    func isThisMonth() -> Bool {
        let thisMonth = Date().month()
        let thisYear = Date().year()
        return thisMonth == self.month()
            && thisYear == self.year()
    }
    
    func isThisWeek() -> Bool {
        let thisWeek = Date().currentWeekDates()
        return thisWeek.hasDateInSameDayAs(self)
    }
    
    func isNotTodayAndPast() -> Bool {
        return !self.isToday() && self < Date()
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    func sameMonthAs(date: Date) -> Bool {
        let cal = Calendar.current
        let m = cal.component(.month, from: self)
        let m2 = cal.component(.month, from: date)
        return m == m2
    }
    
    func sameDayAs(date: Date) -> Bool {
        return Calendar.current.isDate(
            self,
            inSameDayAs: date
        )
    }
    
    func sameWeekAs(date: Date) -> Bool {
        let cal = Calendar.current
        let w = cal.component(.weekOfYear, from: self)
        let w2 = cal.component(.weekOfYear, from: date)
        return w == w2
    }
    
    func yearsFromToday() -> Int {
        let cal = Calendar.current
        let year = cal.component(.year, from: self)
        let todayYear = cal.component(.year, from: Date())
        return year - todayYear
    }
    
    func monthsFromToday() -> Int {
        let cal = Calendar.current
        let month = cal.component(.month, from: self)
        let todayMonth = cal.component(.month, from: Date())
        return month - todayMonth
    }
    
    func weeksFromToday() -> Int {
        let cal = Calendar.current
        let week = cal.component(.weekOfYear, from: self)
        let todayWeek = cal.component(.weekOfYear, from: Date())
        return week - todayWeek
    }
    
    func getTimeString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func yesterday() -> Date {
        return Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: self
        ) ?? self
    }
    
    func tomorrow() -> Date {
        return Calendar.current.date(
            byAdding: .hour,
            value: 24,
            to: self
        ) ?? self
    }
    
    func sameDaysPlus(hours: Int) -> Date {
        return Calendar.current.date(
            byAdding: .hour,
            value: hours,
            to: self
        ) ?? self
    }
    
    func sameDayPreviousWeek() -> Date {
        return Calendar.current.date(
            byAdding: .weekOfYear,
            value: -1,
            to: self
        ) ?? self
    }
    
    func sameDayNextWeek() -> Date {
        let cal = Calendar.current
        return cal.date(
            byAdding: .weekOfYear,
            value: 1,
            to: self
        ) ?? self
    }
    
    func sameDayPreviousMonth() -> Date {
        return Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: self
        ) ?? self
    }
    
    func sameDayNextMonth() -> Date {
        let cal = Calendar.current
        return cal.date(
            byAdding: .month,
            value: 1,
            to: self
        ) ?? self
    }
    
    func startOfDay() -> Date {
        let cal = Calendar.current
        var date = cal.date(
            bySetting: .hour,
            value: 0,
            of: self
        ) ?? self
        date = cal.date(
            bySetting: .minute,
            value: 0,
            of: date
        ) ?? date
        date = cal.date(
            bySetting: .second,
            value: 0,
            of: date
        ) ?? date
        return date
    }
    
    func startOfMonth() -> Date {
        let cal = Calendar.current
        var date = cal.date(
            from: cal.dateComponents(
                [.year, .month],
                from: self
            )
        ) ?? self
        date = cal.date(
            bySetting: .hour,
            value: 0,
            of: date
        ) ?? date
        date = cal.date(
            bySetting: .minute,
            value: 0,
            of: date
        ) ?? date
        date = cal.date(
            bySetting: .second,
            value: 0,
            of: date
        ) ?? date
        return date
    }
    
    func endOfMonth() -> Date {
        let cal = Calendar.current
        var date = cal.date(
            byAdding: DateComponents(
                month: 1,
                day: -1
            ),
            to: self.startOfMonth()
        ) ?? self
        
        date = cal.date(
            bySetting: .hour,
            value: 23,
            of: date
        ) ?? date
        date = cal.date(
            bySetting: .minute,
            value: 59,
            of: date
        ) ?? date
        date = cal.date(
            bySetting: .second,
            value: 59,
            of: date
        ) ?? date
        
        return date
    }
    
    func getPreviousOrNextDayDate(
        isNext: Bool
    ) -> Date {
        let cal = Calendar.current
        let add = isNext ? 1 : -1
        return cal.date(
            byAdding: .day,
            value: add,
            to: self
        ) ?? Date()
    }
    
    func getPreviousOrNextWeekDate(
        isNext: Bool
    ) -> Date {
        let cal = Calendar.current
        let add = isNext ? 7 : -7
        return cal.date(
            byAdding: .day,
            value: add,
            to: self
        ) ?? Date()
    }
    
    func getPreviousOrNextMonthDate(
        isNext: Bool
    ) -> Date {
        let cal = Calendar.current
        let add = isNext ? 1 : -1
        return cal.date(
            byAdding: .month,
            value: add,
            to: self
        ) ?? Date()
    }
    
    func firstDayOfMonth() -> Int {
        return Calendar.current.component(.day, from: self.startOfMonth())
    }
    
    func lastDayOfMonth() -> Int {
        return Calendar.current.component(.day, from: self.endOfMonth())
    }
    
    func currentMonthOneDayOfEachWeek() -> [Date] {
        let firstDayDate = startOfMonth()
        let lastDayDate = endOfMonth()
        var arr: [Date] = [ firstDayDate ]
        var temp = firstDayDate
        
        while true {
            
            temp = temp.getPreviousOrNextWeekDate(
                isNext: true
            )
            
            let isLastWeek = temp
                .currentWeekDates()
                .hasDateInSameDayAs(lastDayDate)
            
            arr.append(temp)
            
            if isLastWeek { break }
        }
        
        return arr
    }
    
    func currentMonthDates() -> [Date] {
        let cal = Calendar.current
        let start = startOfMonth()
        let eDay = lastDayOfMonth()
        var arr: [Date] = [ start ]
        for i in 1...(eDay-1) {
            let date = cal.date(
                byAdding: .day,
                value: i,
                to: start
            )
            arr.append(date!)
        }
        return arr
    }
    
    func currentWeekDates() -> [Date] {
        let cal = Calendar.current
        let weekDay = cal.component(.weekday, from: self)
        
        var dates = [Date]()
        for i in 1...7 {
            let add = i - weekDay
            let date = cal.date(byAdding: .day, value: add, to: self)
            dates.append(date ?? self)
        }
        
        return dates
    }
    
    func currentWeekHasDifferentMonth() -> Bool {
        let currentWeekDates = self.currentWeekDates()
        let firstWeekDate = currentWeekDates.first!
        let lastWeekDate = currentWeekDates.last!
        let currentMonth = self.month()
        let firstWeekDateMonth = firstWeekDate.month()
        let lastWeekDateMonth = lastWeekDate.month()
        return firstWeekDateMonth != currentMonth || lastWeekDateMonth != currentMonth
    }
    
    var dayOfYear: Int {
        return Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: self
        )!
    }
    
    func isYesterdayTodayOrTomorrow() -> Bool {
        return isYesterday() || isToday() || isTomorrow()
    }
}


// MARK: - Involving localizaiton
extension Date {
    func getFriendlyDateTitle() -> String {
        
        if isYesterdayTodayOrTomorrow() {
            return getFriendlyDay()
        }
        
        let years = yearsFromToday()
        if years != 0 {
            return getFriendlyDateTitleForAmount(
                years,
                component: .years
            )
        }
        
        let months = monthsFromToday()
        if months != 0 {
            return getFriendlyDateTitleForAmount(
                months,
                component: .months
            )
        }
        
        let weeks = weeksFromToday()
        if weeks != 0 {
            return getFriendlyDateTitleForAmount(
                weeks,
                component: .weeks
            )
        }
        
        return LoStrings.thisWeek
    }
    
    func getLocalizedWeekDays() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // Use the user's locale
        formatter.calendar = Calendar.current
        return formatter.weekdaySymbols
    }
    
    private enum FriendlyDateComponent {
        case years, months, weeks
    }
    
    private func getFriendlyDateTitleForAmount(
        _ amount: Int,
        component: FriendlyDateComponent
    ) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let calendar = Calendar.current
        let now = Date()
        
        let targetDate: Date?
        
        switch component {
        case .years:
            targetDate = calendar.date(
                byAdding: .year,
                value: amount,
                to: now
            )
        case .months:
            targetDate = calendar.date(
                byAdding: .month,
                value: amount,
                to: now
            )
        case .weeks:
            targetDate = calendar.date(
                byAdding: .weekOfMonth,
                value: amount,
                to: now
            )
        }
        
        guard let date = targetDate else {
            return ""
        }
        
        let result = formatter.localizedString(
            for: date,
            relativeTo: now
        )
        
        // Capitalize first letter to match your original behavior
        return result.prefix(1).capitalized + result.dropFirst()
    }
    
    func getFriendlyDay() -> String {
        
        if self.isYesterday() ||
            self.isToday() ||
            self.isTomorrow() {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeStr = formatter.localizedString(
                for: self,
                relativeTo: Date()
            ) // ex. yesterday, today, tomorrow
            return relativeStr.capitalized
        }
        
        return getTimeString(format: "EEEE")
    }
    
    func getFriendlyDateWithoutTime() -> String {
        
        if self.isYesterday() ||
            self.isToday() ||
            self.isTomorrow() {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeStr = formatter.localizedString(
                for: self,
                relativeTo: Date()
            ) // ex. yesterday, today, tomorrow
            return relativeStr.capitalized
        }
        
        if self.isThisWeek() {
            return getTimeString(format: "EEEE")
        }
        
        return getTimeString(format: "MMM d, yyyy")
    }
    
    func getFriendlyDate() -> String {
        
        if self.isYesterday() ||
            self.isToday() ||
            self.isTomorrow() {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeStr = formatter.localizedString(
                for: self,
                relativeTo: Date()
            ) // ex. yesterday, today, tomorrow
            return "\(relativeStr.capitalized), \(getTimeString(format: "h:mm a"))"
        }
        
        if self.isThisWeek() {
            return getTimeString(format: "EEEE, h:mm a")
        }
        
        return getTimeString(format: "MMM dd, yyyy")
    }
    
    func getLongFriendlyDate() -> String {
        
        if self.isYesterday() ||
            self.isToday() ||
            self.isTomorrow() {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeStr = formatter.localizedString(
                for: self,
                relativeTo: Date()
            ) // ex. yesterday, today, tomorrow
            return "\(relativeStr.capitalized) @ \(getTimeString(format: "h:mm a"))"
        }
        
        if self.isThisWeek() {
            return getTimeString(format: "EEEE @ h:mm a")
        }
        
        return getTimeString(format: "MMM dd, yyyy @ h:mm a")
    }
}
