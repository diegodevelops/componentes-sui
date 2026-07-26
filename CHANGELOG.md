# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.4] - 2026-07-26

### Fixed
- `WeeklyCalendarView`: setting `selectedDate` externally to a date within the loaded ~2-year batch, but on a different week than the one currently visible, previously didn't scroll to it — the view silently stayed on the old week, and the next scroll-offset update would revert `selectedDate` back to it. It now scrolls to the matching page.
- `Date.sameWeekAs(date:)` compared only the `weekOfYear` component, ignoring the year, so it aliased weeks ~52/53 apart from different years as "the same week." Since `WeeklyCalendarView` loads a batch spanning about two years, this could make it match the wrong page. Now uses `Calendar.isDate(_:equalTo:toGranularity:.weekOfYear)`, which accounts for the year.

## [1.4.3] - 2026-07-26

### Changed
- `WeeklyCalendarView`: the gap between `WeekSymbolView` and `WeekView` is now an explicit 8pt, independent of the header's other internal spacing. All other gaps (to `WeekTextView` or the bottom `Divider`) are unchanged.

## [1.4.2] - 2026-07-23

### Fixed
- `DayView`'s event indicator (both `.small` and `.big`, though far more noticeable in `.big`) could fail to show for days scrolled to in `WeeklyCalendarView`. `hasEvents` was `@State` set from a `.task`, which isn't reliably triggered for pages other than the one visible on first appear across the 105 preloaded weeks. It's now a plain computed property evaluated directly in `body`, so it's always correct regardless of scroll/appear timing.

## [1.4.1] - 2026-07-23

### Fixed
- `WeeklyCalendarView`: when `isDateHidden` is `true` and `eventIndicatorSize` is `.big`, the enlarged indicator becomes the last element before the bottom `Divider`. It now gets its own explicit 8pt gap instead of the smaller spacing meant to lead into `WeekTextView`.

## [1.4.0] - 2026-07-23

### Added
- Optional `isDateHidden` parameter on `WeeklyCalendarView` (default `false`). Set to `true` to hide the full date text (e.g. "Monday Jan 1, 2026") shown below the week row.

### Fixed
- Tightened the gap between the `.big` event indicator and the day circle. `bigIndicatorSpacing` was already 4, but the circle's own centering slack (up to ~3pt) added on top of it, making the true visual gap larger than intended. The circle is now pinned to the bottom of its fixed-height block in `.big` mode, so the spacing constant is the exact, full gap. `.small` mode is unaffected.

## [1.3.2] - 2026-07-22

### Changed
- `.big` event indicator scale bumped from 1.5x to 2x; 1.5x read as too small.

## [1.3.1] - 2026-07-22

### Fixed
- `.big` event indicator was scaled 3x; reduced to 1.5x, since the previous size was too large.
- `DayView`'s day circle would shift vertical position depending on whether a `.big` indicator was shown below it on that particular day, misaligning day numbers within the same week row. The circle now sits in a fixed-height block independent of the indicator, so its position no longer depends on whether that day has an event.

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
