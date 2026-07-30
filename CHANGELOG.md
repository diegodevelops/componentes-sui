# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.4] - 2026-07-29

### Fixed
- `WeeklyCalendarView` could render completely invisible when placed inside a vertically-scrolling `ScrollView`. The `GeometryReader` used internally since 2.0.2 to measure width adopts whatever height its parent proposes — and a `ScrollView` proposes an effectively unbounded height, which `GeometryReader` resolves to near-zero. Combined with 2.0.3's `.clipped()`, the view was clipped away to nothing. Replaced the `GeometryReader` wrap with `.onGeometryChange` (iOS 17+), which observes the resolved size without forcing greedy sizing, so the view now sizes to its natural content instead of collapsing.
- Re-introduced the 2.0.3 clipping fix on a sounder footing: the view now also re-asserts its own measured height via an explicit `.frame(height:)`. Without this, a caller's own smaller `.frame(height:).clipped()` didn't reliably clip — content containing a nested `ScrollView` (used internally for week paging) escapes an externally-imposed frame constraint unless the view first reports a plain, explicit height itself. Verified with an isolated SwiftUI test independent of this package.

## [2.0.3] - 2026-07-29

### Fixed
- `WeeklyCalendarView`: when given less height than its content needs, the excess spilled out past the bottom edge (since `GeometryReader`, used internally since 2.0.2, doesn't clip) and visually overlapped whatever the caller placed after it. Added `.clipped()` so undersized content is now cut off cleanly at the boundary instead of bleeding into sibling views.

## [2.0.2] - 2026-07-29

### Fixed
- `WeeklyCalendarView` still rendered nothing (the 2.0.1 fix wasn't enough): the width was measured via a `.background(GeometryReader{...})` + `@State`, but the real calendar content used that same state for internal `.frame(width:)` sizing needed for horizontal paging — the measurement depended on content's size, and content's size depended on the measurement, so it oscillated between `0` and the real width forever and never rendered past its placeholder. Removed the `@State`/`PreferenceKey` measuring apparatus entirely; `body` now wraps everything in a plain `GeometryReader` and passes its `geometry.size.width` straight through as a local value, never stored or fed back into anything.

### Changed
- As a result, `WeeklyCalendarView` now expands to fill all available height as well as width (since `GeometryReader` is greedy in both dimensions) — matching what the pre-2.0.0 API required of callers wrapping it in their own `GeometryReader`. Give it a bounded `.frame(height:)` if you don't want it to fill all available vertical space.

## [2.0.1] - 2026-07-26

### Fixed
- `WeeklyCalendarView` rendered nothing at all — the auto-width measurement introduced in 2.0.0 used `EmptyView()` as a placeholder while width was unresolved, but `EmptyView` has a zero ideal size, so `.frame(maxWidth: .infinity)` had nothing to expand and the background `GeometryReader` measured a width of zero forever, permanently stuck on the placeholder. Now uses `Color.clear.frame(height: 0)`, which reliably expands to fill the proposed width (while staying pinned to zero height) so the real width is measured correctly.

## [2.0.0] - 2026-07-26

### Changed
- **Breaking:** `WeeklyCalendarView` no longer takes a `width: CGFloat` parameter. It now measures its own width from its parent via an internal `GeometryReader`, so it can be dropped into a layout directly without the caller needing to wrap it in one. Update call sites by removing the `width:` argument (and the wrapping `GeometryReader`, if it was only there for this).

## [1.4.8] - 2026-07-26

### Fixed
- `DaySymbolView` centered its weekday-letter `Text` inside a fixed `.frame(height: 26)` via `Spacer`s, leaving dead space below the text (well beyond the text's actual ~12-14pt height) before `WeekView` even started, independent of `weekSymbolToWeekViewSpacing`. It now sizes to its actual content instead.

### Changed
- `WeeklyCalendarView`: reduced the explicit gap between `WeekSymbolView` and `WeekView` from 2pt to 0.

## [1.4.7] - 2026-07-26

### Fixed
- `DayView`'s day circle (in `.small` mode) was vertically centered within its fixed 50pt row, leaving unpredictable slack above it — worse the narrower the per-day column was relative to the 44pt circle cap — that no amount of external padding could remove. It's now top-aligned within the row instead, so explicit spacing above it (e.g. `WeeklyCalendarView`'s gap between `WeekSymbolView` and `WeekView`) is the full, exact visible gap. `.big` mode (bottom-pinned) is unaffected. Since `DayView`/`WeekView` are shared, this also affects day-circle positioning within `MonthlyCalendarView`'s week rows (now top-anchored per row instead of centered).

## [1.4.6] - 2026-07-26

### Changed
- `WeeklyCalendarView`: reduced the explicit gap between `WeekSymbolView` and `WeekView` further, from 4pt to 2pt.

## [1.4.5] - 2026-07-26

### Fixed
- `DaySymbolView` (the weekday-letter row used by both `WeeklyCalendarView` and `MonthlyCalendarView`) applied 16pt top/bottom padding around its `Text` while constrained to a fixed 26pt frame, causing the content to overflow well beyond its declared bounds since `VStack` doesn't clip. Removed the redundant padding — the text now centers cleanly within the 26pt row via the existing `Spacer`s.

### Changed
- `WeeklyCalendarView`: reduced the explicit gap between `WeekSymbolView` and `WeekView` from 8pt to 4pt.

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
