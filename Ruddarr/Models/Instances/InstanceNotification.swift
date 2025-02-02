import Foundation

struct InstanceNotification: Identifiable, Codable {
    var id: Int?
    var name: String?
    var implementation: String = "Webhook"
    var configContract: String = "WebhookSettings"
    var fields: [InstanceNotificationField] = []

    // Radarr only
    var onMovieAdded: Bool? = false

    // Sonarr only
    var onSeriesAdd: Bool? = false

    // `Grab`: Release sent to download client
    var onGrab: Bool = false

    // `Download`: Completed downloading release
    var onDownload: Bool = false { didSet { onManualInteractionRequired = onHealthIssue } }
    private(set) var onManualInteractionRequired: Bool? = false // Sends test emails only

    // `Download`: Completed downloading upgrade (`isUpgrade`)
    var onUpgrade: Bool = false

    var onApplicationUpdate: Bool = false

    var onHealthIssue: Bool = false
    var onHealthRestored: Bool? = false
    var includeHealthWarnings: Bool = false

    var isEnabled: Bool {
        onGrab
        || onDownload
        || onUpgrade
        || onMovieAdded ?? false
        || onSeriesAdd ?? false
        || onHealthIssue
        || onHealthRestored ?? false
        || onApplicationUpdate
    }

    mutating func disable() {
        onGrab = false
        onDownload = false
        onUpgrade = false
        onMovieAdded = false // Radarr
        onSeriesAdd = false // Sonarr
        onHealthIssue = false
        onHealthRestored = false
        includeHealthWarnings = false
        onApplicationUpdate = false
        onManualInteractionRequired = false
    }

    mutating func enable() {
        onGrab = true
        onDownload = true
        onUpgrade = true
        onMovieAdded = true // Radarr
        onSeriesAdd = true // Sonarr
        onHealthIssue = false
        onHealthRestored = false
        includeHealthWarnings = false
        onApplicationUpdate = false
        onManualInteractionRequired = true
    }
}

struct InstanceNotificationField: Codable {
    let name: String
    var value: String = ""

    enum CodingKeys: String, CodingKey {
        case name
        case value
    }

    init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        if let string = try? container.decode(String.self, forKey: .value) {
            value = string
        }
    }
}
