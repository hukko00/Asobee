import SwiftUI

struct ContentView: View {
    @State private var Viewnumber = 1
    var body: some View {
        VStack{
            if Viewnumber == 1{
                RootView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if Viewnumber == 2{
                AddPlanView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
            HStack{
                Button{
                    Viewnumber = 2
                } label:{
                    VStack{
                        Image(systemName:"airplane.up.forward")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.black)
                        Text("プラン")
                            .foregroundStyle(Color.black)
                    }
                }
                Spacer()
                Button{
                    Viewnumber = 1
                } label:{
                    VStack{
                        Image(systemName:"person.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.black)
                        Text("プロフィール")
                            .foregroundStyle(Color.black)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
