# ComponentesSUI

A Swift Package containing reusable SwiftUI views for iOS 17+.

## Installation

Add this package to your Xcode project via Swift Package Manager:

```
https://github.com/diegodevelops/ComponentesSUI.git
```

## Available Views

### WithBinding

A wrapper view that creates internal `@State` and exposes it as a `Binding` to its content. Useful for SwiftUI previews or when you need self-contained state without an external source.

**Usage:**

```swift
WithBinding(data: "Initial value") { textBinding in
    TextField("Enter text", text: textBinding)
}
```

---

### OffsetObservingScrollView

A `ScrollView` that tracks its content offset and reports it through a `Binding<CGPoint>`. Ideal for scroll-driven animations, parallax effects, or custom scroll indicators.

**Parameters:**
- `axis`: Scroll direction (`.vertical` or `.horizontal`)
- `showsIndicators`: Whether to show scroll indicators
- `enablePaging`: Enable paging behavior
- `offset`: Binding to receive the current scroll offset

**Usage:**

```swift
@State private var scrollOffset: CGPoint = .zero

OffsetObservingScrollView(
    axis: .vertical,
    showsIndicators: true,
    enablePaging: false,
    offset: $scrollOffset
) {
    // Your scrollable content
}
```

---

### WeeklyCalendarView

A horizontally pageable weekly calendar that displays one week at a time with infinite scrolling. It highlights the selected date, marks event dates, and automatically loads more weeks as the user scrolls near the edges. It measures its own width from its parent — no need to pass a `width` or wrap it in your own `GeometryReader` — and sizes itself to its natural content height, so it works correctly both in a plain layout and inside a `ScrollView`. If you constrain it to less height than its content needs (e.g. `.frame(height:)`), add `.clipped()` so the excess is cut off cleanly instead of overlapping whatever comes after it.

**Parameters:**
- `events`: Optional array of `Date` values to mark on the calendar
- `selectedDate`: Binding to the currently selected date
- `isLoading`: Shows a loading state when `true`
- `isPreviewing`: Set to `true` when used inside SwiftUI previews
- `fontName`: The custom font name to use
- `textColor`: The text color for the calendar
- `eventIndicatorIcon`: Optional custom `Image` shown in place of the default dot to mark event dates
- `eventIndicatorSize`: `.small` (default) keeps the indicator inside the day circle; `.big` scales it up and places it below the circle instead
- `isDateHidden`: Set to `true` to hide the full date text below the week row (defaults to `false`, showing it)
- `todayColor`: Optional `Color` for the background of today's date circle (defaults to `nil`, falling back to `Color.accentColor`). Only affects today's circle — the selected-date circle and event indicator stay `accentColor`.

**Usage:**

```swift
@State private var selectedDate = Date()

WeeklyCalendarView(
    events: [Date()],
    selectedDate: $selectedDate,
    isLoading: false,
    fontName: "Helvetica",
    textColor: .primary,
    eventIndicatorIcon: Image(systemName: "star.fill"),
    eventIndicatorSize: .big,
    isDateHidden: false,
    todayColor: .orange
)
```

---

### MonthlyCalendarView

A horizontally pageable monthly calendar that displays a full month grid with infinite scrolling. It shows the month and year header, weekday symbols, week rows, event markers, and a "back to this month" button when navigating away from the current month.

**Parameters:**
- `width`: The width of the calendar view (typically from `GeometryReader`)
- `events`: Optional array of `Date` values to mark on the calendar
- `selectedDate`: Binding to the currently selected date
- `isLoading`: Dims the calendar content when `true`
- `selectAction`: Optional closure called when a date is selected
- `isPreviewing`: Set to `true` when used inside SwiftUI previews
- `fontName`: The custom font name to use (defaults to `"Helvetica"`)
- `textColor`: The text color for the calendar
- `eventIndicatorIcon`: Optional custom `Image` shown in place of the default dot to mark event dates
- `eventIndicatorSize`: `.small` (default) keeps the indicator inside the day circle; `.big` scales it up and places it below the circle instead

**Usage:**

```swift
@State private var selectedDate = Date()

MonthlyCalendarView(
    width: 400,
    events: [Date()],
    selectedDate: $selectedDate,
    isLoading: false,
    selectAction: { date in
        print("Selected: \(date)")
    },
    fontName: "Helvetica",
    textColor: .primary,
    eventIndicatorIcon: Image(systemName: "star.fill"),
    eventIndicatorSize: .big
)
```

## Requirements

- iOS 17.0+
- Swift 6.2+

## License

MIT License
