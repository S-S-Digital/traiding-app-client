import SwiftUI
import WidgetKit

// MARK: - Theme

private enum Theme {
    static let brand       = Color(red: 0.24, green: 0.62, blue: 0.39)
    static let buy         = Color(red: 0.27, green: 0.78, blue: 0.41)
    static let sell        = Color(red: 0.95, green: 0.34, blue: 0.34)
    static let cardBg      = Color(red: 0.09, green: 0.10, blue: 0.12)
    static let cardBgLite  = Color(red: 0.14, green: 0.15, blue: 0.17)
    static let stroke      = Color.white.opacity(0.08)
    static let textPrimary = Color.white
    static let textDim     = Color.white.opacity(0.55)
    static let textFaint   = Color.white.opacity(0.35)
}

// MARK: - Helpers

private func formatPrice(_ v: Double) -> String {
    if v >= 10_000 { return String(format: "%.0f", v) }
    if v >= 1      { return String(format: "%.2f", v) }
    return String(format: "%.4f", v)
}

private func formatCompact(_ v: Double) -> String {
    if v >= 1_000_000 { return String(format: "%.1fM", v/1_000_000) }
    if v >= 10_000    { return String(format: "%.1fK", v/1_000) }
    if v >= 1         { return String(format: "%.2f", v) }
    return String(format: "%.4f", v)
}

// MARK: - Main view

struct SignalWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SignalEntry

    private var isBuy: Bool { entry.direction.uppercased() == "BUY" }
    private var arrow: String { isBuy ? "▲" : "▼" }
    /// Badge color keeps the direction identity (green BUY / red SELL).
    private var accent: Color { isBuy ? Theme.buy : Theme.sell }
    /// Progress color tracks P&L state, not direction: red while the signal
    /// is in the red (so it visually matches the app's -0.44% chip).
    private var pnlColor: Color { entry.isInLoss ? Theme.sell : Theme.buy }
    /// Progress bar fill — shifts to the SL side when in loss.
    private var barProgress: Double {
        entry.isInLoss ? entry.slProgress : entry.tpProgress
    }
    private var pnlLabel: String {
        let sign = entry.pnlPct >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, entry.pnlPct)
    }
    private var targetLabel: String {
        entry.isInLoss ? "→ SL" : "→ TP"
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularAccessory.containerBackground(for: .widget) { Color.clear }
        case .accessoryRectangular:
            rectangularAccessory.containerBackground(for: .widget) { Color.clear }
        case .accessoryInline:
            Text("\(arrow) \(entry.direction.uppercased()) \(entry.symbol) \(formatPrice(entry.price))")
        case .systemSmall:
            smallView.containerBackground(for: .widget) { Theme.cardBg }
        case .systemMedium:
            mediumView.containerBackground(for: .widget) { Theme.cardBg }
        case .systemLarge:
            largeView.containerBackground(for: .widget) { Theme.cardBg }
        default:
            smallView.containerBackground(for: .widget) { Theme.cardBg }
        }
    }

    // MARK: systemSmall (2x2)

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(spacing: 4) {
                directionBadge
                Spacer(minLength: 0)
                if entry.isPremium {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Theme.brand)
                }
            }
            // Symbol + price
            Text(entry.symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1).minimumScaleFactor(0.75)
            Text(formatPrice(entry.price))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1).minimumScaleFactor(0.6)

            // TP progress
            progressBar
                .frame(height: 4)

            HStack(spacing: 6) {
                tpSlPill(label: "TP", value: entry.tp, color: Theme.buy)
                tpSlPill(label: "SL", value: entry.sl, color: Theme.sell)
            }
            Spacer(minLength: 0)
            Text(entry.relativeAge)
                .font(.system(size: 9))
                .foregroundColor(Theme.textFaint)
        }
        .padding(10)
    }

    // MARK: systemMedium (4x2)

    private var mediumView: some View {
        HStack(alignment: .top, spacing: 10) {
            // left column — current signal
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    directionBadge
                    Spacer(minLength: 0)
                    if entry.isPremium {
                        Text("PRO")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(Theme.brand)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Theme.brand.opacity(0.15))
                            .cornerRadius(3)
                    }
                }
                Text(entry.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(formatPrice(entry.price))
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1).minimumScaleFactor(0.6)
                progressBar.frame(height: 4)
                HStack(spacing: 6) {
                    tpSlPill(label: "TP", value: entry.tp, color: Theme.buy)
                    tpSlPill(label: "SL", value: entry.sl, color: Theme.sell)
                }
                Spacer(minLength: 0)
                Text(entry.relativeAge)
                    .font(.system(size: 9))
                    .foregroundColor(Theme.textFaint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // right column — recent signals (3 rows)
            VStack(alignment: .leading, spacing: 6) {
                Text("RECENT")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Theme.textFaint)
                ForEach(Array(entry.recent.prefix(3).enumerated()), id: \.offset) { _, s in
                    recentSignalRow(s)
                }
                if entry.recent.isEmpty {
                    Text("—")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textFaint)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
        }
        .padding(12)
    }

    // MARK: systemLarge (4x4) — dashboard

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header — latest signal
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    directionBadge
                    Text(entry.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text(entry.relativeAge)
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textFaint)
                    if entry.isPremium {
                        Text("PRO")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(Theme.brand)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Theme.brand.opacity(0.15))
                            .cornerRadius(3)
                    }
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(formatPrice(entry.price))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text("\(pnlLabel) \(targetLabel)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(pnlColor)
                }
                progressBar.frame(height: 4)
                HStack(spacing: 6) {
                    tpSlPill(label: "TP", value: entry.tp, color: Theme.buy)
                    tpSlPill(label: "SL", value: entry.sl, color: Theme.sell)
                    Spacer()
                }
            }
            .padding(10)
            .background(Theme.cardBgLite)
            .cornerRadius(10)

            // Watchlist
            if !entry.watchlist.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("WATCHLIST")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(Theme.textFaint)
                    ForEach(Array(entry.watchlist.prefix(4).enumerated()), id: \.offset) { _, item in
                        watchlistRow(item)
                    }
                }
            }

            // Recent signals
            if !entry.recent.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECENT SIGNALS")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(Theme.textFaint)
                    ForEach(Array(entry.recent.prefix(3).enumerated()), id: \.offset) { _, s in
                        recentSignalRow(s)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }

    // MARK: - Shared parts

    private var directionBadge: some View {
        HStack(spacing: 3) {
            Text(arrow).font(.system(size: 12, weight: .black))
            Text(entry.direction.uppercased()).font(.system(size: 10, weight: .black))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 5).padding(.vertical, 2)
        .background(accent)
        .cornerRadius(4)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [pnlColor.opacity(0.6), pnlColor],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: max(2, geo.size.width * barProgress))
            }
        }
    }

    private func tpSlPill(label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .heavy))
                .foregroundColor(color)
            Text(formatCompact(value))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Theme.textDim)
        }
        .padding(.horizontal, 5).padding(.vertical, 2)
        .background(color.opacity(0.12))
        .cornerRadius(4)
    }

    private func recentSignalRow(_ s: RecentSignal) -> some View {
        let isBuy = s.direction.uppercased() == "BUY"
        let color: Color = isBuy ? Theme.buy : Theme.sell
        let age: String = {
            let sec = max(0, Date().timeIntervalSince1970 - s.ts)
            if sec < 60 { return "now" }
            if sec < 3600 { return "\(Int(sec/60))m" }
            if sec < 86400 { return "\(Int(sec/3600))h" }
            return "\(Int(sec/86400))d"
        }()
        return HStack(spacing: 6) {
            Text(isBuy ? "▲" : "▼")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
            Text(s.symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 2)
            Text(formatPrice(s.price))
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Theme.textDim)
            Text(age)
                .font(.system(size: 9))
                .foregroundColor(Theme.textFaint)
        }
    }

    private func watchlistRow(_ item: WatchlistItem) -> some View {
        let isUp = item.change24h >= 0
        let changeColor: Color = isUp ? Theme.buy : Theme.sell
        return HStack(spacing: 6) {
            Text(item.symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .frame(width: 70, alignment: .leading)
            Spacer(minLength: 2)
            Text(formatPrice(item.price))
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            Text(String(format: "%@%.2f%%", isUp ? "+" : "", item.change24h))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(changeColor)
                .frame(width: 60, alignment: .trailing)
        }
    }

    // MARK: - Lock screen accessories

    /// Circular — ring shows progress to TP, center shows direction arrow +
    /// ticker (3 letters). Uses monochrome — iOS tints it on lock screen.
    private var circularAccessory: some View {
        ZStack {
            AccessoryWidgetBackground()
            // Progress ring around the circumference (entry → TP).
            Circle()
                .trim(from: 0, to: max(0.02, barProgress))
                .stroke(
                    .white,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(2)
            VStack(spacing: -1) {
                Text(arrow)
                    .font(.system(size: 18, weight: .black))
                Text(String(entry.symbol.prefix(3)))
                    .font(.system(size: 8.5, weight: .heavy))
                    .kerning(0.4)
                    .minimumScaleFactor(0.5)
            }
        }
        .widgetAccentable()
    }

    /// Rectangular — header row (direction + symbol + age), big price, and
    /// a mini progress bar from entry to TP with TP/SL labels beneath.
    private var rectangularAccessory: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Header
            HStack(spacing: 3) {
                Text(arrow)
                    .font(.system(size: 11, weight: .black))
                Text("\(entry.direction.uppercased()) \(entry.symbol)")
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 2)
                if !entry.relativeAge.isEmpty {
                    Text(entry.relativeAge)
                        .font(.system(size: 9))
                        .opacity(0.65)
                }
            }
            // Big price
            Text(formatPrice(entry.price))
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .widgetAccentable()
            // Mini progress bar — entry -> TP
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(height: 3)
                    Capsule()
                        .fill(.white)
                        .frame(
                            width: max(2, geo.size.width * entry.tpProgress),
                            height: 3
                        )
                        .widgetAccentable()
                }
            }
            .frame(height: 3)
            // TP / SL compact labels
            HStack(spacing: 6) {
                Text("TP \(formatCompact(entry.tp))")
                    .font(.system(size: 9, weight: .semibold))
                Text("SL \(formatCompact(entry.sl))")
                    .font(.system(size: 9, weight: .semibold))
                    .opacity(0.7)
                Spacer(minLength: 0)
                Text(pnlLabel)
                    .font(.system(size: 9, weight: .heavy))
                    .widgetAccentable()
            }
        }
    }
}
