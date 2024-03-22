import SwiftUI

struct CalendarView: View {
    @State var calendar = MediaCalendar()

    @State private var initialized: Bool = false
    @State private var scrollPosition: TimeInterval?

    @State private var onlyMonitored: Bool = false
    @State private var displayedMediaType: CalendarMediaType = .all

    @EnvironmentObject var settings: AppSettings

    private let firstWeekday = Calendar.current.firstWeekday

    private var gridLayout = [
        GridItem(.fixed(50), alignment: .center),
        GridItem(.flexible())
    ]

    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .leading) {
                    ForEach(calendar.dates, id: \.self) { timestamp in
                        let date = Date(timeIntervalSince1970: timestamp)
                        let weekday = Calendar.current.component(.weekday, from: date)

                        if firstWeekday == weekday {
                            CalendarWeekRange(date: date)
                        }

                        CalendarDate(date: date)
                            .offset(x: -5)

                        media(for: timestamp, date: date)
                    }
                }
                .scrollTargetLayout()

                if calendar.isLoadingFuture {
                    ProgressView().tint(.secondary).padding(.bottom)
                }
            }
            .viewPadding(.horizontal)
            .scrollIndicators(.never)
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                todayButton
                filtersMenu
            }
            .onAppear {
                calendar.instances = settings.instances
            }
            .onChange(of: scrollPosition) {
                calendar.maybeLoadMoreDates(scrollPosition)
            }
            .onChange(of: displayedMediaType) {
                scrollPosition = (scrollPosition ?? 0) - 86_400
            }
            .onChange(of: onlyMonitored) {
                scrollPosition = (scrollPosition ?? 0) - 86_400
            }
            .task {
                await calendar.initialize()
                guard !initialized else { return }
                initialized = (calendar.error == nil)
                scrollPosition = calendar.today()
            }
            .alert(
                isPresented: calendar.errorBinding,
                error: calendar.error
            ) { _ in } message: { error in
                Text(error.recoverySuggestionFallback)
            }
            .overlay {
                if notConnectedToInternet {
                    NoInternet()
                } else if initialLoading {
                    Loading()
                } else if initialLoadingFailed {
                    contentUnavailable
                }
            }
        }
        // swiftlint:enable closure_body_length
    }

    var notConnectedToInternet: Bool {
        if !calendar.dates.isEmpty { return false }
        if case .notConnectedToInternet = calendar.error { return true }
        return false
    }

    var initialLoading: Bool {
        if !calendar.dates.isEmpty { return false }
        return calendar.isLoading
    }

    var initialLoadingFailed: Bool {
        if !calendar.dates.isEmpty { return false }
        return calendar.error != nil
    }

    var displayMovies: Bool {
        [.all, .movies].contains(displayedMediaType)
    }

    var displaySeries: Bool {
        [.all, .series].contains(displayedMediaType)
    }

    func media(for timestamp: TimeInterval, date: Date) -> some View {
        VStack(spacing: 6) {
            if displayMovies, let movies = calendar.movies[timestamp] {
                ForEach(movies) { movie in
                    if !onlyMonitored || movie.monitored {
                        CalendarMovie(date: date, movie: movie)
                    }
                }
            }

            if displaySeries, let episodes = calendar.episodes[timestamp] {
                ForEach(episodes) { episode in
                    let series: String = calendar.series[episode.seriesId]?.title
                        ?? String(localized: "Unknown")

                    if !onlyMonitored || episode.monitored {
                        CalendarEpisode(episode: episode, seriesTitle: series)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    var todayButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Today") {
                withAnimation(.smooth()) {
                    scrollPosition = calendar.today()
                }
            }
        }
    }

    var contentUnavailable: some View {
        ContentUnavailableView {
            Label("Connection Failure", systemImage: "exclamationmark.triangle")
        } description: {
            Text(calendar.error?.recoverySuggestionFallback ?? "")
            Button("Retry") {
                Task { await calendar.initialize() }
            }
        }
    }

    var filtersMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu("Filters", systemImage: "line.3.horizontal.decrease") {
                Picker(selection: $displayedMediaType, label: Text("Media Type")) {
                    ForEach(CalendarMediaType.allCases, id: \.self) { type in
                        type.label
                    }
                }
                .pickerStyle(.inline)

                Toggle(isOn: $onlyMonitored) {
                    Label("Only Monitored", systemImage: "bookmark")
                        .symbolVariant(onlyMonitored ? .fill : .none)
                }
            }
        }
    }
}

#Preview {
    dependencies.router.selectedTab = .calendar

    return ContentView()
        .withAppState()
}

#Preview("Offline") {
    dependencies.api.movieCalendar = { _, _, _ in
        throw API.Error.notConnectedToInternet
    }

    dependencies.router.selectedTab = .calendar

    return ContentView()
        .withAppState()
}

#Preview("Failure") {
    dependencies.api.movieCalendar = { _, _, _ in
        throw API.Error.urlError(
            URLError(.badServerResponse)
        )
    }

    dependencies.router.selectedTab = .calendar

    return ContentView()
        .withAppState()
}
