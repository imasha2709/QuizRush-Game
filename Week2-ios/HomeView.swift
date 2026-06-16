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
                        .font(.title2)
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
