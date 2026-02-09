//
//  WeeklyCalendarView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/14/23.
//

import SwiftUI

public struct WeeklyCalendarView: View {

    var width: CGFloat
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

    init(
        width: CGFloat,
        events: [Date]?,
        selectedDate: Binding<Date>,
        isLoading: Bool,
        isPreviewing: Bool = false,
        fontName: String,
        textColor: Color
    ) {
        self.width = width
        self.events = events

        _selectedDate = selectedDate
        self.isLoading = isLoading
        self.isPreviewing = isPreviewing
        self.fontName = fontName
        self.textColor = textColor
        _didTap = State(initialValue: false)

        // MODIFIED: Initialize with a full year batch instead of 3 pages
        _datePages = State(
            initialValue: helper.newYearlyWeeklyDatePagesFrom(
                selectedDate.wrappedValue
            )
        )
    }

    public var body: some View {

        if isLoading {

            WeeklyCalendarLoadingView(
                width: width,
                events: events,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor
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

                        HStack(spacing: 0) {
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
                                        textColor: textColor
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
}

private struct WeeklyCalendarHeaderView: View {

    var width: CGFloat
    var date: Date
    var events: [Date]?

    @Binding var selectedDate: Date
    @Binding var didTap: Bool

    let fontName: String
    let textColor: Color

    var body: some View {
        VStack(spacing: 2) {
            WeekSymbolView(
                date: date,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor
            )
            .padding(.top, 16)
            WeekView(
                date: date,
                monthDate: date,
                events: events,
                calendarType: .week,
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor
            )
            .padding(.bottom, 6)
            WeekTextView(
                selectedDate: $selectedDate,
                fontName: fontName,
                textColor: textColor
            )
            .padding(.bottom, 16)
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

    @State private(set) var didTap: Bool

    init(
        width: CGFloat,
        events: [Date]?,
        selectedDate: Binding<Date>,
        fontName: String,
        textColor: Color
    ) {
        self.width = width
        self.events = events
        self.fontName = fontName
        self.textColor = textColor
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
                textColor: textColor
            )

            Divider()
        }
    }
}

struct WeeklyCalendarView_Previews: PreviewProvider {
    static var previews: some View {

        GeometryReader {
            geometry in

            WithBinding(data: Date()) {
                selectedDate in

                WeeklyCalendarView(
                    width: geometry.size.width,
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
}
