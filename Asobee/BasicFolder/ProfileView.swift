import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack{
            NavigationLink{
                RootView()
            } label:{
                Text("ログイン・新規登録")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ProfileView()
}
