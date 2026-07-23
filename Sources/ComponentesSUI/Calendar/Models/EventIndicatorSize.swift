//
//  EventIndicatorSize.swift
//  ComponentesSUI
//

import Foundation

/// Controls how the event indicator is rendered by `WeeklyCalendarView` and `MonthlyCalendarView`.
public enum EventIndicatorSize {
    /// The indicator is sized to fit inside the day circle, right below the day number.
    case small
    /// The indicator is scaled up and placed below the day circle, since it no longer fits inside it.
    case big
}
