import os
import SwiftUI
import Foundation

@Observable
class SonarrInstance {
    private var instance: Instance

    var isVoid = true

    var series: SeriesModel
    var lookup: SeriesLookup
    var releases: SeriesReleases
    var episodes: SeriesEpisodes
    var files: SeriesFiles

    init(_ instance: Instance = .sonarrVoid) {
        if instance.type != .sonarr {
            fatalError("\(instance.type.rawValue) given to SonarrInstance")
        }

        self.isVoid = instance == .sonarrVoid

        self.instance = instance
        self.series = SeriesModel(instance)
        self.lookup = SeriesLookup(instance)
        self.releases = SeriesReleases(instance)
        self.episodes = SeriesEpisodes(instance)
        self.files = SeriesFiles(instance)
    }

    func switchTo(_ target: Instance) {
        isVoid = target == .sonarrVoid

        self.instance = target
        self.series = SeriesModel(target)
        self.lookup = SeriesLookup(target)
        self.releases = SeriesReleases(target)
        self.episodes = SeriesEpisodes(instance)
        self.files = SeriesFiles(instance)
    }

    var id: UUID {
        instance.id
    }

    var isLarge: Bool {
        instance.mode == .large
    }

    var rootFolders: [InstanceRootFolders] {
        instance.rootFolders
    }

    var qualityProfiles: [InstanceQualityProfile] {
        instance.qualityProfiles
    }
    
    var tags: [InstanceTag] {
        instance.tags
    }

    func fetchMetadata() async -> Instance? {
        if isVoid {
            return nil
        }

        do {
            instance.rootFolders = try await dependencies.api.rootFolders(instance)
            instance.qualityProfiles = try await dependencies.api.qualityProfiles(instance)
            instance.tags = try await dependencies.api.tags(instance)
        } catch {
            return nil
        }

        return instance
    }
}
