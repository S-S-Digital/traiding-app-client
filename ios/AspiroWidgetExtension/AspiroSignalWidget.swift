import WidgetKit
import SwiftUI

struct SignalEntry: TimelineEntry {
    let date: Date
    let symbol: String
    let direction: String
    let price: Double
    let tp: Double
    let sl: Double
    let isPlaceholder: Bool
}

struct SignalProvider: TimelineProvider {
    let appGroupId = "group.com.aspiro.trade"

    func placeholder(in context: Context) -> SignalEntry {
        SignalEntry(date: Date(), symbol: "BTCUSDT", direction: "BUY", price: 95000, tp: 96500, sl: 94000, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SignalEntry) -> Void) {
        completion(readEntry() ?? placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SignalEntry>) -> Void) {
        let entry = readEntry() ?? placeholder(in: context)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func readEntry() -> SignalEntry? {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return nil }
        guard let symbol = defaults.string(forKey: "signal_symbol") else { return nil }
        return SignalEntry(
            date: Date(timeIntervalSince1970: defaults.double(forKey: "signal_ts")),
            symbol: symbol,
            direction: defaults.string(forKey: "signal_direction") ?? "BUY",
            price: defaults.double(forKey: "signal_price"),
            tp: defaults.double(forKey: "signal_tp"),
            sl: defaults.double(forKey: "signal_sl"),
            isPlaceholder: false
        )
    }
}

struct AspiroSignalWidget: Widget {
    let kind: String = "AspiroSignalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SignalProvider()) { entry in
            SignalWidgetView(entry: entry)
        }
        .configurationDisplayName("Aspiro Trade — Signal")
        .description("Last trading signal")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
