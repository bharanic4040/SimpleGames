import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 30) {
                
                Text("Games")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                
                NavigationLink {
                    ContentView() // Capture Tiles game screen
                } label: {
                    Text("Capture Tiles")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 60)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                }
            }
            .navigationBarHidden(true).padding(.top, 10)
        }
    }
}
#Preview {
    HomeView()
}
