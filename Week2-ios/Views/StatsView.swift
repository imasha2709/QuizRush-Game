import SwiftUI
import Charts
import CoreLocation


enum ChartFilter: Hashable {
    case all
    case mode(GameMode)
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .mode(let mode): return mode.rawValue
        }
    }
}


struct StatsView: View {

    @ObservedObject private var sessionManager = GameSessionManager.shared
    
 
    @State private var selectedFilter: ChartFilter = .all

    var body: some View {
        NavigationStack {
            Group {
                if sessionManager.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Statistics",
                        systemImage: "chart.bar",
                        description: Text("Play your first game to begin collecting statistics.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            overviewCards
                            scoreChart
                            gameBreakdown
                            recentGames
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: shareSummary,
                        subject: Text("My Game Hub Stats 🏆"),
                        preview: SharePreview(
                            "Game Statistics Summary",
                            image: Image(systemName: "gamecontroller.fill")
                        )
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    
    private var totalGames: Int {
        sessionManager.sessions.count
    }

    private var totalScore: Int {
        sessionManager.sessions.reduce(0) { $0 + $1.score }
    }

    private var highestScore: Int {
        sessionManager.sessions.map(\.score).max() ?? 0
    }

    private var averageScore: Double {
        guard totalGames > 0 else { return 0 }
        return Double(totalScore) / Double(totalGames)
    }
    
    private var shareSummary: String {
        """
        🎮 My Game Statistics

        Total Games Played: \(totalGames)
        Highest High Score: \(highestScore)
        Average Score: \(String(format: "%.1f", averageScore))
        Total Points Earned: \(totalScore)

        Built using SwiftUI 🚀
        """
    }
    
   
    private var filteredSessions: [GameSession] {
        let chronologicalSessions = sessionManager.sessions.reversed()
        switch selectedFilter {
        case .all:
            return Array(chronologicalSessions)
        case .mode(let targetMode):
            return chronologicalSessions.filter { $0.game == targetMode }
        }
    }

  
    private var overviewCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {

            StatCard(
                title: "Games",
                value: "\(totalGames)",
                icon: "gamecontroller.fill",
                color: .blue
            )

            StatCard(
                title: "Highest",
                value: "\(highestScore)",
                icon: "trophy.fill",
                color: .yellow
            )

            StatCard(
                title: "Average",
                value: String(format: "%.1f", averageScore),
                icon: "chart.bar.fill",
                color: .green
            )

            StatCard(
                title: "Total Score",
                value: "\(totalScore)",
                icon: "star.fill",
                color: .orange
            )
        }
    }

    private var scoreChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History")
                .font(.headline)
            
            
            Picker("Game Selection", selection: $selectedFilter) {
                Text(ChartFilter.all.displayName).tag(ChartFilter.all)
                ForEach(GameMode.allCases) { mode in
                    Text(mode.rawValue).tag(ChartFilter.mode(mode))
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 5)

            if filteredSessions.isEmpty {
                VStack {
                    Text("No data for this game mode yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 250)
                .frame(maxWidth: .infinity)
            } else {
                Chart(filteredSessions) { session in
                    LineMark(
                        x: .value("Date", session.date),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(by: .value("Game", session.game.rawValue))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", session.date),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(by: .value("Game", session.game.rawValue))
                }
                .frame(height: 250)
                
                .chartForegroundStyleScale([
                    GameMode.tapFrenzy.rawValue: GameMode.tapFrenzy.swiftUIColor,
                    GameMode.lightItUp.rawValue: GameMode.lightItUp.swiftUIColor,
                    GameMode.quizRush.rawValue: GameMode.quizRush.swiftUIColor
                ])
                .chartLegend(selectedFilter == .all ? .visible : .hidden)
            }
        }
    }

    private var gameBreakdown: some View {
        VStack(alignment: .leading) {
            Text("Games Played")
                .font(.headline)

            ForEach(GameMode.allCases) { mode in
                let count = sessionManager.sessions.filter {
                    $0.game == mode
                }.count

                HStack {
                    Image(systemName: mode.icon)
                        .foregroundColor(mode.swiftUIColor)
                    Text(mode.rawValue)
                    Spacer()
                    Text("\(count)")
                        .bold()
                }
                .padding(.vertical, 5)
            }
        }
    }

    private var recentGames: some View {
        VStack(alignment: .leading) {
            Text("Recent Games")
                .font(.headline)

            ForEach(sessionManager.sessions.prefix(10)) { session in
                HStack {
                    Image(systemName: session.game.icon)
                        .foregroundColor(session.game.swiftUIColor)

                    VStack(alignment: .leading) {
                        Text(session.game.rawValue)
                        Text(session.date.formatted())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(session.score)")
                        .bold()
                }
                .padding(.vertical, 6)

                Divider()
            }
        }
    }
}


struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .bold()

            Text(title)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


extension GameMode {
   
    var swiftUIColor: Color {
        switch self.color {
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        default: return .primary
        }
    }
}


#Preview {
    
    let manager = GameSessionManager.shared
    if manager.sessions.isEmpty {
        manager.sessions = [
            GameSession(game: .tapFrenzy, score: 45, date: Date()),
            GameSession(game: .lightItUp, score: 110, date: Date().addingTimeInterval(-3600)),
            GameSession(game: .quizRush, score: 85, date: Date().addingTimeInterval(-7200)),
            GameSession(game: .tapFrenzy, score: 30, date: Date().addingTimeInterval(-86400)),
            GameSession(game: .lightItUp, score: 95, date: Date().addingTimeInterval(-172800))
        ]
    }
    
    return StatsView()
}
