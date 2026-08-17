//
//  WeeklyCalendarView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

public struct WeeklyCalendarView: View {

    // Observed from this view's own resolved size via .onGeometryChange
    // (see body), instead of being passed in — so callers don't need to
    // supply a width or wrap this view in their own GeometryReader.
    @State private var width: CGFloat = 0

    // Re-asserted via an explicit .frame(height:) in body. Without this,
    // a caller's own smaller .frame(height:).clipped() around this view
    // doesn't reliably clip: the internal horizontal ScrollView escapes an
    // externally-imposed constraint unless this view first reports a
    // plain, explicit height itself (verified empirically — a bare
    // ScrollView-containing view behaves the same way even outside this
    // package).
    @State private var contentHeight: CGFloat = 0

    var events: [Date]?

    @Binding var selectedDate: Date
    var isLoading: Bool

    // this flag was created because
    // for some reason the preview
    // canvas won't work unless
    // we force the first scroll
    // on .onAppear inside a
    // the main thread
    var isPreviewing: Bool

    let fontName: String
    let textColor: Color
    var eventIndicatorIcon: Image?
    var eventIndicatorSize: EventIndicatorSize
    var isDateHidden: Bool
    var todayColor: Color?

    @State private var scrollOffset = CGPoint()
    @State private var didScrollManually = true
    @State private(set) var datePages: [DatePage]
    @State private(set) var didTap: Bool

    // ADDED: Prevents scroll offset handler from firing during programmatic
    // scroll animations (e.g. after a batch reload scrolls back to center).
    @State private var isReloading = false

    private let helper = DatePageHelper()

    // ADDED: Number of weeks loaded in each direction from center (52 weeks ≈ 1 year)
    private let weeksPerDirection = 52

    // ADDED: Center page index within the year batch
    private var centerIndex: Int { weeksPerDirection }

    // ADDED: When scrolling within this many weeks of the edge, reload the batch
    private let edgeThreshold = 4

    public init(
        events: [Date]?,
        selectedDate: Binding<Date>,
        isLoading: Bool,
        isPreviewing: Bool = false,
        fontName: String,
        textColor: Color,
        eventIndicatorIcon: Image? = nil,
        eventIndicatorSize: EventIndicatorSize = .small,
        isDateHidden: Bool = false,
        todayColor: Color? = nil
    ) {
        self.events = events

        _selectedDate = selectedDate
        self.isLoading = isLoading
        self.isPreviewing = isPreviewing
        self.fontName = fontName
        self.textColor = textColor
        self.eventIndicatorIcon = eventIndicatorIcon
        self.eventIndicatorSize = eventIndicatorSize
        self.isDateHidden = isDateHidden
        self.todayColor = todayColor
        _didTap = State(initialValue: false)

        // MODIFIED: Initialize with a full year batch instead of 3 pages
        _datePages = State(
            initialValue: helper.newYearlyWeeklyDatePagesFrom(
                selectedDate.wrappedValue
            )
        )
    }

    public var body: some View {
        // .onGeometryChange (iOS 17+) observes this view's resolved size
        // without altering its layout behavior — unlike wrapping the body
        // in a GeometryReader, which forces it to greedily fill all
        // available height too and breaks inside vertically-scrolling
        // parents (which propose an effectively unbounded height, and a
        // GeometryReader given that resolves to close to zero).
        content(width: width)
            .onGeometryChange(for: CGSize.self) {
                geometry in

                geometry.size
            } action: {
                newSize in

                width = newSize.width
                contentHeight = newSize.height
            }
            // Re-assert the measured height explicitly. Without this, a
            // caller's own smaller .frame(height:).clipped() around this
            // view wouldn't reliably clip the internal horizontal
            // ScrollView (confirmed independently of this package: a bare
            // view containing a ScrollView escapes an externally-imposed
            // frame + clipped the same way). An explicit numeric height
            // behaves like any ordinary view's, so external clipping works.
            .frame(height: contentHeight > 0 ? contentHeight : nil)
    }

    @ViewBuilder
    private func content(width: CGFloat) -> some View {

        if isLoading {

            WeeklyCalendarLoadingView(
                width: width,
                events: events,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor,
                eventIndicatorIcon: eventIndicatorIcon,
                eventIndicatorSize: eventIndicatorSize,
                isDateHidden: isDateHidden,
                todayColor: todayColor
            )
        }
        else {

            VStack(spacing: 0) {

                ScrollViewReader {
                    proxy in

                    OffsetObservingScrollView(
                        axis: .horizontal,
                        showsIndicators: false,
                        enablePaging: true,
                        offset: $scrollOffset
                    ) {

                        // LazyHStack: datePages holds a full year batch (105
                        // weeks) for infinite-scroll room. A plain HStack
                        // would force SwiftUI to build and lay out all 735
                        // DayViews (105 weeks x 7 days) synchronously the
                        // moment this view appears, instead of just the
                        // page(s) actually on screen — the main-thread jank
                        // reported at first appearance. ScrollViewReader's
                        // scrollTo (used below to center on page load) works
                        // the same with a lazy stack, including scrolling to
                        // pages that haven't been built yet.
                        LazyHStack(spacing: 0) {
                            ForEach(datePages) {
                                datePage in

                                VStack(spacing: 0) {

                                    WeeklyCalendarHeaderView(
                                        width: width,
                                        date: datePage.date,
                                        events: events,
                                        selectedDate: $selectedDate,
                                        didTap: $didTap,
                                        fontName: fontName,
                                        textColor: textColor,
                                        eventIndicatorIcon: eventIndicatorIcon,
                                        eventIndicatorSize: eventIndicatorSize,
                                        isDateHidden: isDateHidden,
                                        todayColor: todayColor
                                    )
                                }
                                .frame(width: width)
                                .id(datePage.id)
                            }
                        }

                    }
                    .frame(width: width)
                    .onAppear() {

                        // MODIFIED: Scroll to center page of the year batch on appear
                        didScrollManually = true
                        scrollToCenter(proxy: proxy)
                    }
                    .onChange(of: selectedDate) {
                        _, newValue in

                        // MODIFIED: Only reload when the selected date falls outside the
                        // currently loaded year batch. Day taps within the loaded range
                        // update instantly without regenerating pages.
                        let firstDate = datePages.first?.date ?? newValue
                        let lastDate = datePages.last?.date ?? newValue
                        if newValue < firstDate || newValue > lastDate {
                            isReloading = true
                            datePages = helper.newYearlyWeeklyDatePagesFrom(newValue)
                        }
                        else {
                            // ADDED: newValue is within the loaded range, but the visible
                            // page might not be showing its week (e.g. selectedDate set
                            // externally by the parent). Scroll to the matching page so
                            // the view stays in sync — otherwise the next scroll-offset
                            // update would silently revert selectedDate back to whatever
                            // week is still on screen.
                            scrollToPage(matching: newValue, width: width, proxy: proxy)
                        }
                    }
                    .onChange(of: datePages) {
                        _, _ in

                        // MODIFIED: After reloading the year batch, scroll back to center page.
                        // isReloading stays true to suppress scroll offset handling during animation.
                        didScrollManually = true
                        scrollToCenter(proxy: proxy)
                        // ADDED: Allow scroll offset handler to resume after the scroll animation settles
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 0.3
                        ) {
                            isReloading = false
                        }
                    }
                    .onChange(of: scrollOffset) {
                        _, newValue in

                        // MODIFIED: Skip processing during programmatic scrolls or batch reloads
                        if didScrollManually {
                            didScrollManually = false
                            return
                        }
                        if isReloading { return }

                        guard width > 0 else { return }
                        let currentPageIndex = Int(round(newValue.x / width))
                        let totalPages = datePages.count
                        guard currentPageIndex >= 0,
                              currentPageIndex < totalPages else { return }

                        // ADDED: Update selectedDate to reflect the currently visible week
                        // as the user scrolls, so the highlight and date text stay in sync.
                        let currentPageDate = datePages[currentPageIndex].date
                        if !currentPageDate.sameWeekAs(date: selectedDate) {
                            selectedDate = currentPageDate
                        }

                        // MODIFIED: Detect if the user has scrolled near the edges
                        // of the year batch. If so, reload centered on the current
                        // visible week to give another year of scroll room.
                        let nearStart = currentPageIndex <= edgeThreshold
                        let nearEnd = currentPageIndex >= totalPages - 1 - edgeThreshold

                        if nearStart || nearEnd {
                            isReloading = true
                            datePages = helper.newYearlyWeeklyDatePagesFrom(currentPageDate)
                        }
                    }
                }
                .disabled(isLoading)

                Divider()
            }
        }
    }

    // ADDED: Helper to scroll to the center page of the year batch.
    // Handles the isPreviewing quirk (preview canvas needs DispatchQueue.main.async).
    private func scrollToCenter(proxy: ScrollViewProxy) {
        if isPreviewing {
            DispatchQueue.main.async {
                proxy.scrollTo(
                    datePages[centerIndex].id,
                    anchor: UnitPoint(x: 0, y: 0)
                )
            }
        }
        else {
            proxy.scrollTo(
                datePages[centerIndex].id,
                anchor: UnitPoint(x: 0, y: 0)
            )
        }
    }

    // ADDED: Scrolls to whichever loaded page shows the same week as `date`,
    // unless that page is already the one on screen. Used to resync the
    // scroll position when selectedDate changes to a date within the
    // loaded range but on a different week than the one currently visible.
    private func scrollToPage(matching date: Date, width: CGFloat, proxy: ScrollViewProxy) {
        guard let targetPage = datePages.first(where: { $0.date.sameWeekAs(date: date) }) else {
            return
        }

        let currentPageIndex = width > 0 ? Int(round(scrollOffset.x / width)) : centerIndex
        if datePages.indices.contains(currentPageIndex),
           datePages[currentPageIndex].id == targetPage.id {
            return
        }

        didScrollManually = true
        if isPreviewing {
            DispatchQueue.main.async {
                proxy.scrollTo(targetPage.id, anchor: UnitPoint(x: 0, y: 0))
            }
        }
        else {
            proxy.scrollTo(targetPage.id, anchor: UnitPoint(x: 0, y: 0))
        }
    }
}

private struct WeeklyCalendarHeaderView: View {

    var width: CGFloat
    var date: Date
    var events: [Date]?

    @Binding var selectedDate: Date
    @Binding var didTap: Bool

    let fontName: String
    let textColor: Color
    var eventIndicatorIcon: Image?
    var eventIndicatorSize: EventIndicatorSize
    var isDateHidden: Bool
    var todayColor: Color?

    // Landscape on iPhone reports a compact vertical size class; shrink
    // the header paddings then so the week row has more room to breathe.
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isCompactHeight: Bool { verticalSizeClass == .compact }

    // When the date text is hidden, the .big indicator becomes the last
    // thing before the bottom Divider, so it gets its own explicit gap
    // instead of the smaller spacing meant to lead into WeekTextView.
    private let bigIndicatorDividerSpacing: CGFloat = 8

    // Explicit gap between WeekSymbolView and WeekView, independent of
    // the VStack's own spacing (which now only separates WeekView from
    // whatever follows it).
    private let weekSymbolToWeekViewSpacing: CGFloat = 0

    private var weekViewBottomPadding: CGFloat {
        if eventIndicatorSize == .big && isDateHidden {
            return bigIndicatorDividerSpacing
        }
        let base: CGFloat = isCompactHeight ? 2 : 6
        // Restores the gap the VStack's own spacing used to provide here
        // before it was zeroed out, only when WeekTextView follows.
        return isDateHidden ? base : base + 2
    }

    var body: some View {
        VStack(spacing: 0) {
            WeekSymbolView(
                date: date,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor
            )
            .padding(.top, isCompactHeight ? 4 : 16)
            .padding(.bottom, weekSymbolToWeekViewSpacing)
            WeekView(
                date: date,
                monthDate: date,
                events: events,
                calendarType: .week,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor,
                eventIndicatorIcon: eventIndicatorIcon,
                eventIndicatorSize: eventIndicatorSize,
                todayColor: todayColor
            )
            .padding(.bottom, weekViewBottomPadding)
            if !isDateHidden {
                WeekTextView(
                    selectedDate: $selectedDate,
                    fontName: fontName,
                    textColor: textColor
                )
                .padding(.bottom, isCompactHeight ? 4 : 16)
            }
        }
        .frame(width: width)
    }
}

private struct WeeklyCalendarLoadingView: View {

    var width: CGFloat
    var events: [Date]?

    @Binding var selectedDate: Date

    let fontName: String
    let textColor: Color
    var eventIndicatorIcon: Image?
    var eventIndicatorSize: EventIndicatorSize
    var isDateHidden: Bool
    var todayColor: Color?

    @State private(set) var didTap: Bool

    init(
        width: CGFloat,
        events: [Date]?,
        selectedDate: Binding<Date>,
        fontName: String,
        textColor: Color,
        eventIndicatorIcon: Image? = nil,
        eventIndicatorSize: EventIndicatorSize = .small,
        isDateHidden: Bool = false,
        todayColor: Color? = nil
    ) {
        self.width = width
        self.events = events
        self.fontName = fontName
        self.textColor = textColor
        self.eventIndicatorIcon = eventIndicatorIcon
        self.eventIndicatorSize = eventIndicatorSize
        self.isDateHidden = isDateHidden
        self.todayColor = todayColor
        _selectedDate = selectedDate
        _didTap = State(initialValue: false)
    }

    var body: some View {

        VStack(spacing: 0) {

            // header
            WeeklyCalendarHeaderView(
                width: width,
                date: $selectedDate.wrappedValue,
                events: events,
                selectedDate: $selectedDate,
                didTap: $didTap,
                fontName: fontName,
                textColor: textColor,
                eventIndicatorIcon: eventIndicatorIcon,
                eventIndicatorSize: eventIndicatorSize,
                isDateHidden: isDateHidden,
                todayColor: todayColor
            )

            Divider()
        }
    }
}

struct WeeklyCalendarView_Previews: PreviewProvider {
    static var previews: some View {

        WithBinding(data: Date()) {
            selectedDate in

            WeeklyCalendarView(
                events: [ Date() ],
                selectedDate: selectedDate,
                isLoading: false,
                isPreviewing: true,
                fontName: "Menlo",
                textColor: .primary
            )
        }
    }
}
