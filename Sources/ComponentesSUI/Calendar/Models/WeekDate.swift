//
//  WeekDate.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import Foundation

struct WeekDate: Identifiable {
    
    private(set) var id: Int
    var date: Date
    
    init(date: Date) {
        self.date = date
        self.id = Int(date.timeIntervalSince1970)
    }
}
