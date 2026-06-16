import SwiftUI
import Combine

struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var buttonColor = Color.green
    @State private var buttonSize: CGFloat = 220
    @State private var gameOver = false
    @State private var tapScale: CGFloat = 1.0
    
    @AppStorage("tapHighScore") var highScore = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 25) {
            VStack(spacing: 5) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("Tap Frenzy")
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.orange)
                    Text("High Score: \(highScore)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 40) {
                VStack {
                    Text("Score")
                        .font(.caption)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Text("\(score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .contentTransition(.numericText(value: Double(score)))
                }
                
                VStack {
                    Text("Time Left")
                        .font(.caption)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Text("\(timeLeft)s")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(timeLeft <= 3 ? .red : .primary)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
            
            Spacer()
            
            // MARK: - Animated Target Button
            Button {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                    tapScale = 0.85
                    if buttonColor == .green { score += 1 } else { score -= 1 }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                        tapScale = 1.0
                        changeButton()
                    }
                }
            } label: {
                Text("TAP")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: max(buttonSize, 60), height: max(buttonSize, 60))
                    .background(buttonColor)
                    .clipShape(Circle())
                    .shadow(color: buttonColor.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .disabled(gameOver)
            .scaleEffect(tapScale)
            .animation(.snappy, value: buttonColor)
            .animation(.linear(duration: 1.0), value: buttonSize)
            
            Spacer()
            
            if gameOver {
                Button {
                    withAnimation(.spring()) { restartGame() }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 5)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .onReceive(timer) { _ in
            guard !gameOver else { return }
            
            if timeLeft > 0 {
                timeLeft -= 1
                buttonSize -= 12
                if timeLeft % 2 == 0 { changeButton() }
            } else {
                withAnimation(.bouncy) {
                    gameOver = true
                    if score > highScore { highScore = score }
                }
            }
        }
    }
    
    func changeButton() {
        buttonColor = Bool.random() ? .green : .gray
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
