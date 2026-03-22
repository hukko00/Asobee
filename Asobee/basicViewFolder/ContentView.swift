import SwiftUI

struct ContentView: View {
    @State private var viewnumber = 1
    var body: some View {
        VStack(spacing: 0) {
            if viewnumber == 1{
                PlanView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else if viewnumber == 2{
                
            }else if viewnumber == 3{
                
            }else{
                
            }
            
            HStack {
                Button {
                    print("home")
                    viewnumber = 1
                } label: {
                    VStack {
                        Image(systemName: "house")
                            .font(Font.system(size: 35, weight: .bold))
                            .foregroundStyle(Color(.black))
                        Text("ホーム")
                            .font(Font.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(.black))
                    }
                }
                Spacer()
                Button {
                    print("search")
                    viewnumber = 2
                } label: {
                    VStack {
                        Image(systemName: "airplane.up.forward")
                            .font(Font.system(size: 40, weight: .bold))
                            .foregroundStyle(Color(.black))
                        Text("プラン")
                            .font(Font.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(.black))
                    }
                }
                Spacer()
                Button {
                    print("setting")
                    viewnumber = 3
                } label: {
                    VStack {
                        Image(systemName: "person.2")
                            .font(Font.system(size: 35, weight: .bold))
                            .foregroundStyle(Color(.black))
                        Text("フレンド")
                            .font(Font.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(.black))
                    }
                }
                Spacer()
                Button {
                    print("setting")
                    viewnumber = 4
                } label: {
                    VStack {
                        Image(systemName: "gearshape")
                            .font(Font.system(size: 40, weight: .bold))
                            .foregroundStyle(Color(.black))
                        Text("設定")
                            .font(Font.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(.black))
                    }
                }
            }
            .padding()
            .background(Color.white)
        }
    }
}
#Preview{
    ContentView()
}
