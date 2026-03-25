import Foundation

enum Category: String, Codable, CaseIterable, Hashable {
    case all
    case music
    case art
    case comedy
    case food
    case wellness
    case wine
    case social

    var displayName: String {
        switch self {
        case .all:
            String(localized: "All")
        case .music:
            String(localized: "Music")
        case .art:
            String(localized: "Art")
        case .comedy:
            String(localized: "Comedy")
        case .food:
            String(localized: "Food")
        case .wellness:
            String(localized: "Wellness")
        case .wine:
            String(localized: "Wine")
        case .social:
            String(localized: "Social")
        }
    }

    var icon: String {
        switch self {
        case .all:
            "square.grid.2x2"
        case .music:
            "music.note"
        case .art:
            "paintpalette"
        case .comedy:
            "theatermasks"
        case .food:
            "fork.knife"
        case .wellness:
            "figure.yoga"
        case .wine:
            "wineglass"
        case .social:
            "person.3"
        }
    }
}
