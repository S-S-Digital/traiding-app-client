import WidgetKit
import SwiftUI
import Foundation

// MARK: - Models

struct WatchlistItem: Codable, Hashable {
    let symbol: String
    let price: Double
    let change24h: Double
}

struct RecentSignal: Codable, Hashable {
    let symbol: String
    let direction: String  // "BUY" | "SELL"
    let price: Double
    let ts: Double          // unix seconds
}

struct SignalEntry: TimelineEntry {
    let date: Date
    let symbol: String
    let direction: String
    let entry: Double    // entry price at signal creation
    let price: Double    // live current price
    let tp: Double
    let sl: Double
    let signalTs: Double
    let watchlist: [WatchlistItem]
    let recent: [RecentSignal]
    let isPremium: Bool
    let premiumUntilTs: Double
    let isPlaceholder: Bool

    /// Progress from entry price toward TP, 0…1.
    /// BUY:  0 at entry, 1 at (or past) tp
    /// SELL: 0 at entry, 1 at (or past) tp (price moving down)
    var tpProgress: Double {
        let isBuy = direction.uppercased() == "BUY" || direction.uppercased() == "LONG"
        let e = entry == 0 ? price : entry
        guard tp != 0 else { return 0 }
        if isBuy {
            guard tp > e else { return 0 }
            let progressed = price - e
            let total = tp - e
            return max(0, min(1, progressed / total))
        } else {
            guard e > tp else { return 0 }
            let progressed = e - price
            let total = e - tp
            return max(0, min(1, progressed / total))
        }
    }

    /// How far the price has drifted toward SL, 0…1. Used when the signal is
    /// in the red so the widget has something to visualise instead of a flat
    /// empty bar. Same symmetry as `tpProgress` — just in the opposite
    /// direction.
    var slProgress: Double {
        let isBuy = direction.uppercased() == "BUY" || direction.uppercased() == "LONG"
        let e = entry == 0 ? price : entry
        guard sl != 0 else { return 0 }
        if isBuy {
            guard e > sl else { return 0 }
            let regressed = e - price
            let total = e - sl
            return max(0, min(1, regressed / total))
        } else {
            guard sl > e else { return 0 }
            let regressed = price - e
            let total = sl - e
            return max(0, min(1, regressed / total))
        }
    }

    /// Signed P&L relative to the entry (positive = profit, negative = loss).
    /// Shown as "+0.87%" / "-0.44%" so the widget matches the app's chip.
    var pnlPct: Double {
        let e = entry == 0 ? price : entry
        guard e != 0 else { return 0 }
        let isBuy = direction.uppercased() == "BUY" || direction.uppercased() == "LONG"
        let raw = (price - e) / e * 100
        return isBuy ? raw : -raw
    }

    var isInLoss: Bool { pnlPct < 0 }

    var relativeAge: String {
        let seconds = max(0, Date().timeIntervalSince1970 - signalTs)
        if signalTs == 0 { return "" }
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(Int(seconds/60)) min ago" }
        if seconds < 86400 { return "\(Int(seconds/3600)) hr ago" }
        return "\(Int(seconds/86400)) d ago"
    }
}

// MARK: - Provider

struct SignalProvider: TimelineProvider {
    static let appGroupId = "group.com.aspiro.trade"

    static let placeholderEntry = SignalEntry(
        date: Date(),
        symbol: "BTCUSDT",
        direction: "BUY",
        entry: 94800,
        price: 95123.45,
        tp: 96500,
        sl: 94000,
        signalTs: Date().timeIntervalSince1970,
        watchlist: [
            WatchlistItem(symbol: "BTCUSDT", price: 95123, change24h: 1.2),
            WatchlistItem(symbol: "ETHUSDT", price: 3450,  change24h: 0.5),
            WatchlistItem(symbol: "SOLUSDT", price: 145.2, change24h: -0.8),
            WatchlistItem(symbol: "XAUUSD",  price: 2345,  change24h: 0.1),
        ],
        recent: [
            RecentSignal(symbol: "ETHUSDT", direction: "BUY",  price: 3450, ts: Date().timeIntervalSince1970 - 600),
            RecentSignal(symbol: "XRPUSDT", direction: "SELL", price: 0.58, ts: Date().timeIntervalSince1970 - 1800),
            RecentSignal(symbol: "SOLUSDT", direction: "BUY",  price: 145,  ts: Date().timeIntervalSince1970 - 3600),
        ],
        isPremium: true,
        premiumUntilTs: Date().timeIntervalSince1970 + 30 * 86400,
        isPlaceholder: true
    )

    func placeholder(in context: Context) -> SignalEntry { Self.placeholderEntry }

    func getSnapshot(in context: Context, completion: @escaping (SignalEntry) -> Void) {
        completion(readEntry() ?? Self.placeholderEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SignalEntry>) -> Void) {
        // Try a fresh fetch from the backend so the widget stays current
        // without the user having to open the app. Falls back to whatever
        // Flutter last wrote into the shared UserDefaults if the network or
        // auth fails (e.g. logged-out state, offline, token expired).
        fetchSnapshot { fetched in
            let entry = fetched ?? self.readEntry() ?? Self.placeholderEntry
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    /// Calls `GET {apiUrl}/widget/snapshot` using the access token Flutter
    /// wrote into the App Group on the last successful auth. Silent on any
    /// failure — the caller will fall back to cached UserDefaults state.
    private func fetchSnapshot(_ completion: @escaping (SignalEntry?) -> Void) {
        guard let d = UserDefaults(suiteName: Self.appGroupId),
              let apiUrl = d.string(forKey: "api_url"),
              let token = d.string(forKey: "access_token"),
              !token.isEmpty,
              let url = URL(string: "\(apiUrl)/widget/snapshot") else {
            completion(nil); return
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 8
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: req) { data, resp, _ in
            guard let data = data,
                  let http = resp as? HTTPURLResponse,
                  http.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(nil); return
            }

            // Cache into UserDefaults so the widget has fresh data on its
            // next render, even if that render happens before the next
            // timeline refresh (e.g. Smart Stack tile flip).
            func num(_ v: Any?) -> Double {
                if let n = v as? NSNumber { return n.doubleValue }
                if let s = v as? String { return Double(s) ?? 0 }
                return 0
            }
            let sig = json["signal"] as? [String: Any]
            d.set(sig?["symbol"] as? String ?? "", forKey: "signal_symbol")
            d.set(sig?["direction"] as? String ?? "BUY", forKey: "signal_direction")
            d.set(num(sig?["entry"]), forKey: "signal_entry")
            d.set(num(sig?["price"]), forKey: "signal_price")
            d.set(num(sig?["tp"]), forKey: "signal_tp")
            d.set(num(sig?["sl"]), forKey: "signal_sl")
            d.set(num(sig?["ts"]), forKey: "signal_ts")
            if let watchlist = json["watchlist"],
               let wd = try? JSONSerialization.data(withJSONObject: watchlist),
               let ws = String(data: wd, encoding: .utf8) {
                d.set(ws, forKey: "watchlist_json")
            }
            if let recent = json["recent"],
               let rd = try? JSONSerialization.data(withJSONObject: recent),
               let rs = String(data: rd, encoding: .utf8) {
                d.set(rs, forKey: "recent_signals_json")
            }
            d.set(json["isPremium"] as? Bool ?? false, forKey: "user_is_premium")
            d.set(num(json["premiumUntil"]), forKey: "user_premium_until")

            completion(self.readEntry())
        }.resume()
    }

    private func readEntry() -> SignalEntry? {
        guard let d = UserDefaults(suiteName: Self.appGroupId) else { return nil }
        guard let symbol = d.string(forKey: "signal_symbol") else { return nil }
        return SignalEntry(
            date: Date(),
            symbol: symbol,
            direction: d.string(forKey: "signal_direction") ?? "BUY",
            entry: d.double(forKey: "signal_entry"),
            price: d.double(forKey: "signal_price"),
            tp: d.double(forKey: "signal_tp"),
            sl: d.double(forKey: "signal_sl"),
            signalTs: d.double(forKey: "signal_ts"),
            watchlist: decode([WatchlistItem].self, from: d.string(forKey: "watchlist_json")) ?? [],
            recent: decode([RecentSignal].self, from: d.string(forKey: "recent_signals_json")) ?? [],
            isPremium: d.bool(forKey: "user_is_premium"),
            premiumUntilTs: d.double(forKey: "user_premium_until"),
            isPlaceholder: false
        )
    }

    private func decode<T: Decodable>(_ type: T.Type, from json: String?) -> T? {
        guard let s = json, !s.isEmpty, let data = s.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Widget

struct AspiroSignalWidget: Widget {
    let kind: String = "AspiroSignalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SignalProvider()) { entry in
            SignalWidgetView(entry: entry)
        }
        .configurationDisplayName("Aspiro Trade — Signal")
        .description("Last trading signal, watchlist, recent history")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
