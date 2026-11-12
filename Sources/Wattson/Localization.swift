import Foundation

/// Localization is deliberately confined to presentation. Reader values, device
/// identities, JSON output and all hardware calculations retain their original data.
enum L10n {
    private static let bundle: Bundle = {
        let resources = Bundle.main.resourceURL?.appendingPathComponent("Wattson_Wattson.bundle")
        let base = resources.flatMap { Bundle(url: $0) } ?? Bundle.module
        if let language = ProcessInfo.processInfo.environment["WATTSON_LANGUAGE"],
           ["en", "zh-Hans"].contains(language),
           let path = base.path(forResource: language, ofType: "lproj"),
           let selected = Bundle(path: path) { return selected }
        return base
    }()
    private static let english: [String: String] = {
        guard let url = (Bundle.main.resourceURL.flatMap { Bundle(url: $0.appendingPathComponent("Wattson_Wattson.bundle")) } ?? Bundle.module).url(forResource: "Localizable", withExtension: "strings", subdirectory: "en.lproj"),
              let data = try? Data(contentsOf: url),
              let table = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else { return [:] }
        return table
    }()
    private static let patterns: [(String, NSRegularExpression)] = english.keys
        .filter { $0.contains("%@") }
        .sorted { $0.count > $1.count }
        .compactMap { key in
            let pattern = "^" + key.components(separatedBy: "%@")
                .map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "(.+?)") + "$"
            return (try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]))
                .map { (key, $0) }
        }

    static func text(_ value: String) -> String {
        render(value, depth: 0)
    }
    private static func render(_ value: String, depth: Int) -> String {
        guard depth < 8, !value.isEmpty else { return value }
        if english[value] != nil {
            return bundle.localizedString(forKey: value, value: value, table: nil)
        }
        // Uppercase section headings are derived from display labels.
        if let key = english.keys.first(where: { !$0.contains("%@") && $0.lowercased() == value.lowercased() }) {
            let translated = bundle.localizedString(forKey: key, value: key, table: nil)
            return translated == key ? value : translated
        }
        for (key, regex) in patterns {
            let range = NSRange(value.startIndex..., in: value)
            guard let match = regex.firstMatch(in: value, range: range) else { continue }
            let translated = bundle.localizedString(forKey: key, value: key, table: nil)
            guard translated != key else { return value }
            let arguments: [CVarArg] = (1..<match.numberOfRanges).map { index in
                let part = Range(match.range(at: index), in: value).map { String(value[$0]) } ?? ""
                // Only this template embeds another presentation sentence. Other
                // arguments can contain manufacturer names, serials or user text.
                return (key == "This Mac: %@" ? render(part, depth: depth + 1) : part) as NSString
            }
            return String(format: translated, arguments: arguments)
        }
        for separator in ["\n", " · ", " — "] where value.contains(separator) {
            return value.components(separatedBy: separator).map { render($0, depth: depth + 1) }.joined(separator: separator)
        }
        return value
    }
}
