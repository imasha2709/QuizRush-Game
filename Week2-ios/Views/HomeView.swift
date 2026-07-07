import SwiftUI

struct HomeView: View {
    @State private var animateIn = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 30) {
                      
                        HStack(spacing: 12) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.largeTitle)
                                .foregroundColor(.purple)
                            
                            Text("Mini Games")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .offset(y: animateIn ? 0 : -20)
                        .opacity(animateIn ? 1 : 0)
                        
                       
                        NavigationLink(destination: TapFrenzyView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.title2)
                                Text("Tap Frenzy")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(width: 260, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                        
                       
                        NavigationLink(destination: LightItUpView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title2)
                                Text("Light It Up")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(width: 260, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                        
                       
                        NavigationLink(destination: QuizRushView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "timer")
                                    .font(.title2)
                                Text("Quiz Rush")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(width: 260, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                        
                      
                        NavigationLink(destination: LeaderboardView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "trophy.fill")
                                    .font(.title3)
                                Text("View Hall of Fame")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.purple)
                            .padding()
                            .frame(width: 260)
                            .background(Capsule().stroke(Color.purple, lineWidth: 2))
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
            
                .containerRelativeFrame(.vertical, alignment: .center)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                    animateIn = true
                }
            }
        }
    }
}
