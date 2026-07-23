# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-07-22

### Added
- Optional `eventIndicatorSize` parameter (`EventIndicatorSize`: `.small` or `.big`) on `WeeklyCalendarView` and `MonthlyCalendarView`. `.small` (default) keeps the existing behavior, indicator fitting inside the day circle. `.big` scales the indicator 3x and places it below the circle instead, since it no longer fits inside; `WeekView` reserves matching extra row height so it doesn't overlap the week below.

## [1.2.1] - 2026-07-22

### Fixed
- `DayView`'s day-circle diameter was capped at 44pt instead of scaling unbounded with column width. On wide layouts (landscape, iPad) it previously grew past the fixed row height and visually overlapped adjacent weeks.

### Changed
- `WeeklyCalendarView` and `MonthlyCalendarView` header paddings now shrink when the vertical size class is compact (iPhone landscape), leaving more room for the week/month grid.

## [1.2.0] - 2026-07-22

### Added
- Optional `eventIndicatorIcon` parameter on `WeeklyCalendarView` and `MonthlyCalendarView` to show a custom `Image` in place of the default dot for dates with events. Threaded through `WeekView` down to `DayView`, which renders the indicator. Defaults to `nil` (existing dot behavior), so it's fully backward compatible.

## [1.1.1] - 2026-02-10

### Fixed
- `MonthlyCalendarView` and `WeeklyCalendarView` initializers, along with `OffsetObservingScrollView` and `WithBinding`, were missing `public` access, making them unusable from outside the package.

## [1.1.0] - 2026-02-09

### Added
- `WeeklyCalendarView`: a horizontally pageable weekly calendar with infinite scrolling, selected-date highlighting, and event markers.
- `MonthlyCalendarView`: a horizontally pageable monthly calendar grid with infinite scrolling, weekday symbols, event markers, and a "back to this month" button.

### Changed
- Reorganized `OffsetObservingScrollView` and `WithBinding` into a `General/` folder.
