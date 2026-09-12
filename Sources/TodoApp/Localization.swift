import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    // SPM lowercases region-tagged .lproj folder names when bundling resources
    // (pt-BR.lproj -> pt-br.lproj), so the raw value must match that exactly.
    case en, ko, es, ptBR = "pt-br", fr, de
    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .en: return "en_US"
        case .ko: return "ko_KR"
        case .es: return "es_ES"
        case .ptBR: return "pt_BR"
        case .fr: return "fr_FR"
        case .de: return "de_DE"
        }
    }

    var displayName: String {
        switch self {
        case .en: return "English"
        case .ko: return "한국어"
        case .es: return "Español"
        case .ptBR: return "Português (Brasil)"
        case .fr: return "Français"
        case .de: return "Deutsch"
        }
    }
}

@MainActor
final class LocalizationManager: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "appLanguage") }
    }

    var locale: Locale { Locale(identifier: language.localeIdentifier) }

    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage")
        language = saved.flatMap(AppLanguage.init(rawValue:)) ?? .en
    }

    /// The specific per-language .lproj bundle — looked up fresh every call so a
    /// language switch takes effect immediately (String(localized:locale:) caches
    /// by bundle+key and can ignore a changed locale mid-session; NSLocalizedString
    /// against an explicit bundle does not have that pitfall).
    private var languageBundle: Bundle {
        guard let path = Bundle.module.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.module
        }
        return bundle
    }

    func t(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: languageBundle, comment: "")
        return args.isEmpty ? format : String(format: format, arguments: args)
    }
}
