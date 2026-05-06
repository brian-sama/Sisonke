import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            moodKey: "breeze",
            companionText: "Take a slow, comforting breath. I am nearby.",
            gratitudeStars: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.zw.co.mmpzmne.sisonke")
        let moodKey = userDefaults?.string(forKey: "mood") ?? "breeze"
        let companionText = userDefaults?.string(forKey: "companion_text") ??
            "Take a slow, comforting breath. I am nearby."
        let gratitudeStars = max(userDefaults?.integer(forKey: "gratitude_stars") ?? 0, 0)

        let entry = SimpleEntry(
            date: Date(),
            moodKey: moodKey,
            companionText: companionText,
            gratitudeStars: gratitudeStars
        )
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let moodKey: String
    let companionText: String
    let gratitudeStars: Int
}

struct SisonkeWidgetEntryView: View {
    var entry: Provider.Entry

    var moodLabel: String {
        switch entry.moodKey {
        case "sunlight": return "Bright"
        case "breeze": return "Calm"
        case "rain": return "Gentle"
        case "cloud": return "Pause"
        case "storm": return "Breathe"
        default: return "Calm"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sisonke Friend")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.0, green: 0.65, blue: 0.65))
                Spacer()
                Text(moodLabel)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.18, green: 0.20, blue: 0.20))
            }

            Text(entry.companionText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.18, green: 0.20, blue: 0.20))
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack {
                Text("\(entry.gratitudeStars) gratitude stars")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.48, green: 0.38, blue: 1.0))
                Spacer()
                Text("Open")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.0, green: 0.65, blue: 0.65))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.0, green: 0.65, blue: 0.65).opacity(0.12))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(red: 0.97, green: 0.98, blue: 0.97))
    }
}

@main
struct SisonkeWidget: Widget {
    let kind: String = "SisonkeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SisonkeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sisonke Friend")
        .description("Keep a gentle companion prompt on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
