import SwiftUI

struct LeaderboardView: View {
    @StateObject private var manager = LeaderboardManager.shared
    @State private var selectedGame = "tap"
    
    var currentEntries: [LeaderboardEntry] {
        switch selectedGame {
        case "tap": return manager.tapFrenzyScores
        case "light": return manager.lightItUpScores
        default: return manager.quizRushScores
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Game Picker Header
            Picker("Game Mode", selection: $selectedGame) {
                Text("Tap Frenzy").tag("tap")
                Text("Light It Up").tag("light")
                Text("Quiz Rush").tag("quiz")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if currentEntries.isEmpty {
                Spacer()
                ContentUnavailableView("No Records Yet",
                                       systemImage: "trophy.slash",
                                       description: Text("Play a round to claim the crown!"))
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - THE TOP 3 PODIUM CELEBRATION
                        HStack(alignment: .bottom, spacing: 15) {
                            // 2nd Place
                            if currentEntries.count > 1 {
                                podiumCard(entry: currentEntries[1], rank: 2, trophy: "🥈", height: 130, color: .gray)
                            }
                            
                            // 1st Place (Center / Tallest)
                            if currentEntries.count > 0 {
                                podiumCard(entry: currentEntries[0], rank: 1, trophy: "🥇", height: 160, color: .yellow)
                            }
                            
                            // 3rd Place
                            if currentEntries.count > 2 {
                                podiumCard(entry: currentEntries[2], rank: 3, trophy: "🥉", height: 110, color: .orange)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // MARK: - ALL REMAINING SCORES LIST
                        VStack(spacing: 10) {
                            // Grabs everything else from rank 4 onwards
                            ForEach(Array(currentEntries.enumerated()), id: \.element.id) { index, entry in
                                if index >= 3 {
                                    HStack(spacing: 15) {
                                        Text("#\(index + 1)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                            .frame(width: 40, alignment: .leading)
                                        
                                        VStack(alignment: .leading) {
                                            Text(entry.name)
                                                .font(.headline)
                                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(entry.score) pts")
                                            .font(.body)
                                            .fontWeight(.bold)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("🏆 Hall of Fame")
        .onAppear { manager.loadAllScores() }
    }
    
    // Custom View builder helper component for the top 3 podium layout slots
    @ViewBuilder
    func podiumCard(entry: LeaderboardEntry, rank: Int, trophy: String, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(trophy)
                .font(.system(size: rank == 1 ? 44 : 34))
                .shadow(radius: 4)
            
            VStack(spacing: 2) {
                Text(entry.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(entry.score) pts")
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            // The literal podium block base
            Text("RANK \(rank)")
                .font(.caption)
                .fontWeight(.black)
                .foregroundColor(.white)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: rank == 1 ? 3 : 1)
                )
        )
        .shadow(color: color.opacity(rank == 1 ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
    }
}
