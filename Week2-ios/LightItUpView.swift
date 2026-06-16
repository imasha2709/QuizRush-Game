import SwiftUI
import Combine // 1. CRITICAL: This is required to make .autoconnect() compile without errors!

struct LightItUpView: View {
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var columns = 3
    @State private var gameOver = false
    
    @AppStorage("lightHighScore") var highScore = 0
    
    // 2. FIX: Move .autoconnect() up here. Now that 'import Combine' is at the top, this works perfectly!
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text("Light It Up")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Score: \(score)")
                .font(.title2)
            
            Text("Time: \(timeLeft)")
                .font(.title3)
            
            Text("High Score: \(highScore)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 15) {
                ForEach(cards.indices, id: \.self) { index in
                    if index < cards.count {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(cards[index].isLit ? Color.yellow : Color.gray)
                            .frame(height: 90)
                            .onTapGesture {
                                guard !gameOver else { return }
                                
                                if cards[index].isLit {
                                    score += 1
                                    cards[index].isLit = false
                                    lightRandomCard()
                                } else {
                                    score -= 1
                                }
                            }
                    }
                }
            }
            .padding()
            
            if gameOver {
                Button("Play Again") {
                    startGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            startGame()
        }
        // 3. FIX: Simplified to direct listening. No inline chaining required.
        .onReceive(gameTimer) { _ in
            guard !gameOver else { return }
            
            if timeLeft > 0 {
                timeLeft -= 1
                updateLevel()
                lightRandomCard()
            } else {
                gameOver = true
                if score > highScore {
                    highScore = score
                }
            }
        }
    }
    
    func startGame() {
        score = 0
        timeLeft = 60
        gameOver = false
        columns = 3
        resetCards(count: 3)
    }
    
    func lightRandomCard() {
        guard !cards.isEmpty else { return }
        
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        let randomIndex = Int.random(in: 0..<cards.count)
        cards[randomIndex].isLit = true
    }
    
    func updateLevel() {
        let targetCount: Int
        let targetColumns: Int
        
        if timeLeft > 45 {
            targetColumns = 3
            targetCount = 3
        } else if timeLeft > 30 {
            targetColumns = 4
            targetCount = 4
        } else if timeLeft > 15 {
            targetColumns = 3
            targetCount = 6
        } else {
            targetColumns = 3
            targetCount = 9
        }
        
        if cards.count != targetCount {
            columns = targetColumns
            resetCards(count: targetCount)
        }
    }
    
    func resetCards(count: Int) {
        cards = (0..<count).map { _ in Card() }
    }
}

#Preview {
    LightItUpView()
}
