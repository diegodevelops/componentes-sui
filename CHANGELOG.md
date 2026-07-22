# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
