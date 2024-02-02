import SwiftUI

struct MovieReleasesView: View {
    @Binding var movie: Movie

    @State private var fetched = false

    @Environment(RadarrInstance.self) private var instance

    // TODO: sort by ...
    //    Menu("Sorting", systemImage: "line.3.horizontal.decrease") {

    var body: some View {
        Group {
            List {
                ForEach(instance.releases.items) { release in
                    MovieReleaseRow(release: release)
                }
            }
            .listStyle(.inset)
        }
        .navigationTitle("Releases")
        .navigationBarTitleDisplayMode(.large)
        .task {
            guard !fetched else { return }

            await instance.releases.search(movie)

            fetched = true
        }
        .overlay {
            if instance.releases.isSearching {
                ProgressView {
                    VStack {
                        Text("Loading")
                        Text("(This may take a moment)").font(.callout)
                    }
                }.tint(.secondary)
            }
        }
    }
}

struct MovieReleaseRow: View {
    var release: MovieRelease

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Title
                Text(release.title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                // TODO: Tap to expand!
                // TODO: freeleech
                // TODO: weight

                HStack(spacing: 6) {
                    Text(release.quality.quality.name)
                    Text("•")
                    Text(release.sizeLabel)
                    Text("•")
                    Text(release.ageLabel)
                }
                .font(.subheadline)
                .lineLimit(1)

                HStack(spacing: 6) {
                    Text(release.typeLabel)
                        .foregroundStyle(peerColor)
                    Text("•")
                    Text(release.indexerLabel)
                }
                .font(.subheadline)
                .lineLimit(1)

                // Expanding: Language(s), [Link]
            }
            .padding(.trailing, 10)

            Spacer()

            Group {
                if release.rejected {
                    Image(systemName: "exclamationmark")
                        .symbolVariant(.circle.fill)
                        .imageScale(.large)
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "arrow.down")
                        .symbolVariant(.circle.fill)
                        .imageScale(.large)
                }
            }

        }
    }

    var peerColor: any ShapeStyle {
        return switch release.seeders {
        case 50...: .green
        case 10..<50: .blue
        case 1..<10: .orange
        default: .red
        }
    }
}

#Preview {
    let movies: [Movie] = PreviewData.load(name: "movies")
    let movie = movies[66]

    dependencies.router.selectedTab = .movies
    dependencies.router.moviesPath.append(MoviesView.Path.movie(movie.id))
    dependencies.router.moviesPath.append(MoviesView.Path.releases(movie.id))

    return ContentView()
        .withSettings()
        .withRadarrInstance(movies: movies)
}
