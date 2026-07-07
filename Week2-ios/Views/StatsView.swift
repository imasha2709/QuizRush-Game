import SwiftUI
import Charts

struct StatsView: View {

    @ObservedObject private var sessionManager = GameSessionManager.shared

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
        VStack(alignment: .leading) {
            Text("Score History")
                .font(.headline)

            Chart(sessionManager.sessions.reversed()) { session in
                LineMark(
                    x: .value("Date", session.date),
                    y: .value("Score", session.score)
                )

                PointMark(
                    x: .value("Date", session.date),
                    y: .value("Score", session.score)
                )
            }
            .frame(height: 250)
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

#Preview {
    StatsView()
}
