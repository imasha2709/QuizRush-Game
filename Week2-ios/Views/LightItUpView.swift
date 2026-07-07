import SwiftUI
import Combine

enum CardTheme: String, CaseIterable {
    case animals = "Animals"
    case foods = "Foods"
    case emotions = "Emotions"
    case mixed = "Mixed Blitz"
    
    var emojis: [String] {
        switch self {
        case .animals:
            return ["🦁", "🐯", "🐼", "🦊", "🐱", "🐶", "🐵", "🐻", "🐨"]
        case .foods:
            return ["🍕", "🍔", "🍟", "🍣", "🌮", "🍩", "🍓", "🥑", "🍦"]
        case .emotions:
            return ["😎", "🥳", "🤩", "😂", "🫠", "🤔", "🥸", "👽", "🤖"]
        case .mixed:
            return ["🦁", "🍕", "😎", "🦊", "🍩", "🥳", "🐼", "🌮", "🤖"]
        }
    }
}

struct LightItUpView: View {
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var columns = 3
    @State private var gameOver = false
    @State private var currentTheme: CardTheme = .animals
    
    @State private var showNamePrompt = false
    @State private var playerName = ""
    
    @AppStorage("playerName") var savedPlayerName = ""
    @AppStorage("lightHighScore") var highScore = 0
    
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 15) {
            
            VStack(spacing: 5) {
             
                if !savedPlayerName.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.blue)
                        Text(savedPlayerName)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .padding(.bottom, 5)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                    Text("Light It Up")
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                Text("Category: \(currentTheme.rawValue)")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 50) {
                Text("Score: \(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .contentTransition(.numericText(value: Double(score)))
                
                Text("Time: \(timeLeft)s")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(timeLeft <= 5 ? .red : .primary) 
            }
            .padding(.vertical, 10)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns), spacing: 12) {
                ForEach(cards.indices, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(cards[index].isLit ? Color.yellow : Color(.systemGray5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(cards[index].isLit ? Color.orange : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: cards[index].isLit ? .init(.displayP3, red: 1, green: 0.8, blue: 0, opacity: 0.4) : .clear, radius: 8)
                        
                        Text(cards[index].emoji)
                            .font(.system(size: 40))
                            .opacity(cards[index].isLit ? 1.0 : 0.3)
                            .scaleEffect(cards[index].isLit ? 1.1 : 0.9)
                            .animation(.snappy, value: cards[index].isLit)
                    }
                    .frame(height: 90)
                    .scaleEffect(cards[index].isLit ? 1.03 : 1.0)
                    .onTapGesture {
                        guard !gameOver else { return }
                        handleTap(at: index)
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: columns)
            .animation(.snappy, value: cards.map { $0.isLit })
            .padding()
            
            Spacer()
            
            if gameOver {
                Button {
                    withAnimation(.spring()) { startGame() }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Again")
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .onAppear {
            startGame()
        }
        .onReceive(gameTimer) { _ in
            guard !gameOver else { return }
            
            if timeLeft > 0 {
                timeLeft -= 1
                updateLevel()
                lightRandomCard()
            } else {
                withAnimation(.bouncy) {
                    gameOver = true
                    if score > highScore { highScore = score }
                    
                    GameSessionManager.shared.saveGame(
                        game: .lightItUp,
                        score: score
                    )
                    
                    if score > 0 {
                        playerName = savedPlayerName.isEmpty ? "Player" : savedPlayerName
                        showNamePrompt = true
                    }
                }
            }
        }
        .alert("Round Completed!", isPresented: $showNamePrompt) {
            TextField("Enter your name", text: $playerName)
            
            Button("Save") {
                let structuredName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalName = structuredName.isEmpty ? "Anonymous" : structuredName
                
                savedPlayerName = finalName
                LeaderboardManager.shared.addEntry(name: finalName, score: score, game: "light")
                playerName = ""
            }
            
            Button("Cancel", role: .cancel) {
                playerName = ""
            }
        } message: {
            Text("You secured \(score) points! Add your name to our infinite log:")
        }
    }
    
    func handleTap(at index: Int) {
        guard index < cards.count else { return }
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
            lightRandomCard()
        } else {
            score -= 1
        }
    }
    
    func startGame() {
        score = 0
        timeLeft = 30
        gameOver = false
        columns = 3
        currentTheme = .animals
        resetCards(count: 3)
    }
    
    func lightRandomCard() {
        guard !cards.isEmpty else { return }
        for i in cards.indices { cards[i].isLit = false }
        let randomIndex = Int.random(in: 0..<cards.count)
        cards[randomIndex].isLit = true
    }
    
    func updateLevel() {
        let targetCount: Int
        let targetColumns: Int
        let targetTheme: CardTheme
        
     
        if timeLeft > 22 {
            targetColumns = 3; targetCount = 3; targetTheme = .animals
        } else if timeLeft > 15 {
            targetColumns = 4; targetCount = 4; targetTheme = .foods
        } else if timeLeft > 7 {
            targetColumns = 3; targetCount = 6; targetTheme = .emotions
        } else {
            targetColumns = 3; targetCount = 9; targetTheme = .mixed
        }
        
        if cards.count != targetCount || currentTheme != targetTheme {
            currentTheme = targetTheme
            columns = targetColumns
            resetCards(count: targetCount)
        }
    }
    
    func resetCards(count: Int) {
        let pool = currentTheme.emojis.shuffled()
        
        cards = (0..<count).map { i in
            let emoji = pool.indices.contains(i) ? pool[i] : "✨"
            return Card(isLit: false, emoji: emoji)
        }
        lightRandomCard()
    }
}
