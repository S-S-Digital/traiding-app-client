import SwiftUI
import WidgetKit

struct SignalWidgetView: View {
    let entry: SignalEntry

    var body: some View {
        let isBuy = entry.direction.uppercased() == "BUY"
        let accent: Color = isBuy ? Color(red: 0.27, green: 0.78, blue: 0.41) : Color(red: 0.95, green: 0.34, blue: 0.34)
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(isBuy ? "▲" : "▼").font(.system(size: 18, weight: .bold)).foregroundColor(accent)
                Text(entry.direction.uppercased()).font(.system(size: 14, weight: .bold)).foregroundColor(accent)
                Spacer()
                if entry.isPlaceholder {
                    Text("—").font(.caption2).foregroundColor(.secondary)
                }
            }
            Text(entry.symbol).font(.system(size: 17, weight: .semibold)).foregroundColor(.primary)
            Text(String(format: "%.2f", entry.price)).font(.system(size: 14, weight: .medium)).foregroundColor(.primary)
            HStack(spacing: 8) {
                Text("TP \(String(format: "%.2f", entry.tp))").font(.system(size: 10)).foregroundColor(.secondary)
                Text("SL \(String(format: "%.2f", entry.sl))").font(.system(size: 10)).foregroundColor(.secondary)
            }
        }
        .padding(10)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}
