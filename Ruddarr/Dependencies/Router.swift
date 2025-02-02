import SwiftUI
import Combine
import AppIntents

@Observable
final class Router {
    static let shared = Router()

    var selectedTab: Tab = .movies

    var switchToRadarrInstance: Instance.ID?
    var switchToSonarrInstance: Instance.ID?

    var moviesPath: NavigationPath = .init()
    var seriesPath: NavigationPath = .init()
    var calendarPath: NavigationPath = .init()
    var settingsPath: NavigationPath = .init()

    let moviesScroll = PassthroughSubject<Void, Never>()
    let seriesScroll = PassthroughSubject<Void, Never>()
    let calendarScroll = PassthroughSubject<Void, Never>()

    func reset() {
        moviesPath = .init()
        seriesPath = .init()
        calendarPath = .init()
    }
}

enum Tab: String, Hashable, CaseIterable, Identifiable {
    var id: Self { self }

    case movies
    case series
    case calendar
    case activity
    case settings

    enum Openable: String {
        case movies
        case series
        case calendar
        case activity
    }

    var text: LocalizedStringKey {
        switch self {
        case .movies: "Movies"
        case .series: "Series"
        case .calendar: "Calendar"
        case .activity: "Activity"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .movies: "film"
        case .series: "tv"
        case .calendar: "calendar"
        case .activity: "waveform.path.ecg"
        case .settings: "gear"
        }
    }

    @ViewBuilder
    var label: some View {
        Label(text, systemImage: icon)
    }

    @ViewBuilder
    var row: some View {
        Label {
            Text(text)
                .tint(.primary)
                .font(.headline)
                .fontWeight(.regular)
        } icon: {
            Image(systemName: icon)
                .imageScale(.large)
        }
    }

    @ViewBuilder
    var stack: some View {
        VStack(spacing: 0) {
            Spacer()
            switch self {
            case .movies:
                Image(systemName: icon).font(.system(size: 23))
                    .frame(height: 15)

                Text(text).font(.system(size: 10, weight: .semibold))
                    .frame(height: 15).padding(.top, 8)
            case .series:
                Image(systemName: icon).font(.system(size: 23))
                    .frame(height: 15)

                Text(text).font(.system(size: 10, weight: .semibold))
                    .frame(height: 15).padding(.top, 8)
            case .calendar:
                Image(systemName: icon).font(.system(size: 23))
                    .frame(height: 15)

                Text(text).font(.system(size: 10, weight: .semibold))
                    .frame(height: 15).padding(.top, 8)
            case .activity:
                Image(systemName: icon).font(.system(size: 23))
                    .frame(height: 15)

                Text(text).font(.system(size: 10, weight: .semibold))
                    .frame(height: 15).padding(.top, 8)
            case .settings:
                Image(systemName: icon).font(.system(size: 23))
                    .frame(height: 15)

                Text(text).font(.system(size: 10, weight: .semibold))
                    .frame(height: 15).padding(.top, 8)

            }
        }
        .frame(height: 50)
    }
}

extension Tab.Openable: AppEnum {
    var tab: Tab {
        switch self {
        case .movies: .movies
        case .series: .series
        case .calendar: .calendar
        case .activity: .activity
        }
    }

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tab")

    static var caseDisplayRepresentations: [Tab.Openable: DisplayRepresentation] {[
        .movies: DisplayRepresentation(
            title: "Movies",
            subtitle: nil,
            image: DisplayRepresentation.Image(systemName: "film")
        ),
        .series: DisplayRepresentation(
            title: "Series",
            subtitle: nil,
            image: DisplayRepresentation.Image(systemName: "tv")
        ),
        .calendar: DisplayRepresentation(
            title: "Calendar",
            subtitle: nil,
            image: DisplayRepresentation.Image(systemName: "calendar")
        ),
        .activity: DisplayRepresentation(
            title: "Activity",
            subtitle: nil,
            image: DisplayRepresentation.Image(systemName: "waveform.path.ecg")
        ),
    ]}
}
