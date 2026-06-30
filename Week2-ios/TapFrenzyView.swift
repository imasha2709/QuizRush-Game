import SwiftUI
import Combine


struct TapEffect: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}


struct FloatingEffectView: View {
    let effect: TapEffect
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Text(effect.text)
            .font(.system(size: 28, weight: .black, design: .rounded))
            .foregroundColor(effect.color)
            .shadow(radius: 2)
            .offset(y: offset - 80)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    offset = -60
                    opacity = 0.0
                }
            }
    }
}


struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var buttonColor = Color.green
    @State private var buttonSize: CGFloat = 220
    @State private var gameOver = false
    @State private var tapScale: CGFloat = 1.0
    
    
    @State private var isBonusActive = false
    @State private var effects: [TapEffect] = []
    @State private var flashColor: Color = .clear
    
   
    @State private var showNamePrompt = false
    @State private var playerNameInput = ""
    
    
    @AppStorage("playerName") var savedPlayerName = ""
    @AppStorage("tapHighScore") var highScore = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
           
            flashColor
                .ignoresSafeArea()
                .opacity(0.15)
                .animation(.easeOut(duration: 0.2), value: flashColor)
            
            VStack(spacing: 25) {
                
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
                        Image(systemName: isBonusActive ? "sparkles" : "bolt.fill")
                            .foregroundColor(isBonusActive ? .init(red: 1, green: 0.85, blue: 0) : .yellow)
                            .scaleEffect(isBonusActive ? 1.3 : 1.0)
                            .animation(.bouncy, value: isBonusActive)
                        
                        Text(isBonusActive ? "BONUS FRENZY!" : "Tap Frenzy")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(isBonusActive ? .init(red: 0.8, green: 0.6, blue: 0) : .primary)
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
                
  
                ZStack {
                    ForEach(effects) { effect in
                        FloatingEffectView(effect: effect)
                    }
                    
                    Button {
                        handleTap()
                    } label: {
                        Text(isBonusActive ? "💥 BONUS" : "TAP")
                            .font(.system(size: isBonusActive ? 26 : 32, weight: .black, design: .rounded))
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
                }
                
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
        }
        .onReceive(timer) { _ in
            guard !gameOver else { return }
            
            if timeLeft > 0 {
                timeLeft -= 1
                buttonSize -= 12
                if timeLeft % 2 == 0 && !isBonusActive { changeButton() }
            } else {
                withAnimation(.bouncy) {
                    gameOver = true
                    isBonusActive = false
                    if score > highScore { highScore = score }
                    
                    // Triggers the prompt right when the game finishes
                    if LeaderboardManager.shared.isHighScore(score: score, game: "tap") {
                        playerNameInput = savedPlayerName.isEmpty ? "Player" : savedPlayerName
                        showNamePrompt = true
                    }
                }
            }
        }
    
        .alert("Submit to Leaderboard", isPresented: $showNamePrompt) {
            TextField("Your Name", text: $playerNameInput)
            
            Button("Submit Score") {
                let structuredName = playerNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalName = structuredName.isEmpty ? "Anonymous" : structuredName
                
                savedPlayerName = finalName
                LeaderboardManager.shared.addEntry(name: finalName, score: score, game: "tap")
            }
            
            Button("Skip", role: .cancel) {}
        } message: {
            Text("Nice round! Confirm your display name to record your \(score) pts on the Hall of Fame podium:")
        }
    }
    
    func handleTap() {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
            tapScale = 0.85
        }
        
        let text: String
        let color: Color
        
        if isBonusActive {
            score += 5
            text = "💥 BONUS! +5"
            color = .init(red: 1, green: 0.75, blue: 0)
            flashColor = .yellow
            isBonusActive = false
        } else if buttonColor == .green {
            score += 1
            text = "+1"
            color = .green
            flashColor = .green
        } else {
            score -= 1
            text = "-1"
            color = .red
            flashColor = .red
        }
        
        triggerFloatingEffect(text: text, color: color)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            flashColor = .clear
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                tapScale = 1.0
                
                if Double.random(in: 0...1) < 0.25 {
                    isBonusActive = true
                    buttonColor = Color(red: 1, green: 0.84, blue: 0)
                    buttonSize += 30
                } else {
                    changeButton()
                }
            }
        }
    }
    
    func triggerFloatingEffect(text: String, color: Color) {
        let newEffect = TapEffect(text: text, color: color)
        effects.append(newEffect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            effects.removeAll(where: { $0.id == newEffect.id })
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
        isBonusActive = false
        effects.removeAll()
    }
}

#Preview {
    TapFrenzyView()
}
