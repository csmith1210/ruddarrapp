import os
import SwiftUI
import Foundation

@Observable
class RadarrInstance {
    private var instance: Instance

    var isVoid = true

    var movies: Movies
    var lookup: MovieLookup
    var releases: MovieReleases
    var metadata: MovieMetadata

    init(_ instance: Instance = .radarrVoid) {
        if instance.type != .radarr {
            fatalError("\(instance.type.rawValue) given to RadarrInstance")
        }

        self.isVoid = instance == .radarrVoid

        self.instance = instance
        self.movies = Movies(instance)
        self.lookup = MovieLookup(instance)
        self.releases = MovieReleases(instance)
        self.metadata = MovieMetadata(instance)
    }

    func switchTo(_ target: Instance) {
        isVoid = target == .radarrVoid

        self.instance = target
        self.movies = Movies(target)
        self.lookup = MovieLookup(target)
        self.releases = MovieReleases(target)
        self.metadata = MovieMetadata(target)
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
