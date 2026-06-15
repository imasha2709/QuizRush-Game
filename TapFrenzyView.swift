import SwiftUI

struct TapFrenzyView: View {
    
    @State private var score = 0
    @State private var timeLeft = 10
    
    @State private var buttonColor = Color.green
    @State private var buttonSize: CGFloat = 220
    
    @State private var gameOver = false
    
    @AppStorage("tapHighScore") var highScore = 0
    
    let timer = Timer.publish(every: 1,
                              on: .main,
                              in: .common).autoconnect()
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Tap Frenzy")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Score: \(score)")
                .font(.title)
            
            Text("Time: \(timeLeft)")
                .font(.title2)
            
            Text("High Score: \(highScore)")
            
            Spacer()
            
            Button {
                
                if buttonColor == .green {
                    score += 1
                } else {
                    score -= 1
                }
                
                changeButton()
                
            } label: {
                
                Text("TAP")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: buttonSize,
                           height: buttonSize)
                    .background(buttonColor)
                    .clipShape(Circle())
            }
            .disabled(gameOver)
            
            Spacer()
            
            if gameOver {
                
                Button("Play Again") {
                    restartGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            
            if timeLeft > 0 {
                
                timeLeft -= 1
                
                buttonSize -= 10
                
                if timeLeft % 2 == 0 {
                    changeButton()
                }
                
            } else {
                
                gameOver = true
                
                if score > highScore {
                    highScore = score
                }
            }
        }
    }
    
    func changeButton() {
        
        if Bool.random() {
            buttonColor = .green
        } else {
            buttonColor = .gray
        }
    }
    
    func restartGame() {
        
        score = 0
        timeLeft = 10
        buttonSize = 220
        gameOver = false
    }
}

#Preview {
    TapFrenzyView()
}