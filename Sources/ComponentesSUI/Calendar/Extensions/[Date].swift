//
//  [Date].swift
//  ComponentesSUI
//
//  Created by Diego A. Perez Pares on 2/9/26.
//

import Foundation


extension Array where Element==Date {
    func getDatesInSameWeekAs(_ date: Date) -> [Date] {
        let cal =  Calendar.current
        let year = cal.component(.year, from: date)
        let weekOfYear = cal.component(.weekOfYear, from: date)
        var comp = DateComponents()
        comp.year = year
        comp.weekOfYear = weekOfYear
        return self.filter({ cal.date($0, matchesComponents: comp )})
    }
    
    func hasDateInSameDayAs(_ date: Date) -> Bool {
        for d in self {
            if d.sameDayAs(date: date) {
                return true
            }
        }
        return false
    }
}
