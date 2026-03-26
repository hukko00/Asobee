import SwiftUI

struct ContentView: View {
    @State private var Viewnumber = 1
    var body: some View {
        VStack{
            if Viewnumber == 1{
                RootView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
            HStack{
                Button{
                    Viewnumber = 1
                } label:{
                    VStack{
                        Image(systemName:"plus")
                            .font(.system(size: 30))
                        Text("ログイン")
                            .font(.largeTitle)
                    }
                    .background(.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
