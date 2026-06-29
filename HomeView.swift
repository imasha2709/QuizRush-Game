import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 30) {
                
                Text("Mini Games")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                NavigationLink(destination: TapFrenzyView()) {
                    
                    Text("Tap Frenzy")
  import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                Text("Tap & Light Games")
                    .font(.largeTitle.bold())
                    .padding(.top, 50)
                
                NavigationLink {
                    TapFrenzyView()
                } label: {
                    GameButton(title: "Tap Frenzy", color: .blue)
                }
                
                NavigationLink {
                    LightItUpView()
                } label: {
                    GameButton(title: "Light It Up", color: .orange)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct GameButton: View {
    var title: String
    var color: Color
    
    var body: some View {
        Text(title)
            .font(.title2.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.gradient)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .scaleEffect(1.0)
            .onTapGesture {
                withAnimation(.spring()) {}
            }
    }
}                      .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                
                NavigationLink(destination: LightItUpView()) {
                    
                    Text("Light It Up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(Color.orange)
                        .cornerRadius(15)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}