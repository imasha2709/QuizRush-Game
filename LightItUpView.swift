import SwiftUI

struct LightItUpView: View {
    
    @State private var cards: [Card] = []
    
    @State private var score = 0
    @State private var timeLeft = 60
    
    @State private var columns = 3
    
    @State private var gameOver = false
    
    @AppStorage("lightHighScore") var highScore = 0
    
    let gameTimer = Timer.publish(every: 1,
                                  on: .main,
                                  in: .common).autoconnect()
    
    let lightTimer = Timer.publish(every: 1,
                                   on: .main,
                                   in: .common).autoconnect()
    
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()),
                                     count: columns),
                      spacing: 15) {
                
                ForEach(cards.indices, id: \.self) { index in
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(cards[index].isLit ? Color.yellow : Color.gray)
                        .frame(height: 90)
                        .onTapGesture {
                            
                            if cards[index].isLit {
                                score += 1
                                cards[index].isLit = false
                            } else {
                                score -= 1
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
        .onReceive(gameTimer) { _ in
            
            if timeLeft > 0 {
                
                timeLeft -= 1
                updateLevel()
                
            } else {
                
                gameOver = true
                
                if score > highScore {
                    highScore = score
                }
            }
        }
        .onReceive(lightTimer) { _ in
            
            if !gameOver {
                lightRandomCard()
            }
        }
    }
    
    func startGame() {
        
        score = 0
        timeLeft = 60
        gameOver = false
        
        cards = Array(repeating: Card(), count: 3)
    }
    
    func lightRandomCard() {
        
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        let randomIndex = Int.random(in: 0..<cards.count)
        
        cards[randomIndex].isLit = true
    }
    
    func updateLevel() {
        
        if timeLeft > 45 {
            
            columns = 3
            cards = Array(repeating: Card(), count: 3)
            
        } else if timeLeft > 30 {
            
            columns = 4
            cards = Array(repeating: Card(), count: 4)
            
        } else if timeLeft > 15 {
            
            columns = 3
            cards = Array(repeating: Card(), count: 6)
            
        } else {
            
            columns = 3
            cards = Array(repeating: Card(), count: 9)
        }
    }
}

#Preview {
    LightItUpView()
}