import SwiftUI

struct ContentView: View {
    @State private var viewnumber = 1
    @State private var colorAtHome: Color = .black
    @State private var colorAtPlan: Color = .black
    @State private var colorAtFriend: Color = .black
    @State private var colorAtSetting: Color = .black
    var body: some View {
        VStack(spacing: 0) {
            if viewnumber == 1{
                HomeView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else if viewnumber == 2{
                PlanView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else if viewnumber == 3{
                FriendView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else if viewnumber == 4{
                SettingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack {
                Button {
                    viewnumber = 1
                    colorAtHome = .blue
                    colorAtPlan = .black
                    colorAtFriend = .black
                    colorAtSetting = .black
                } label: {
                    VStack {
                        Image(systemName: "house")
                            .font(Font.system(size: 26, weight: .bold))
                            .foregroundStyle(colorAtHome)
                        Text("ホーム")
                            .font(Font.system(size: 13, weight: .bold))
                            .foregroundStyle(colorAtHome)
                    }
                }
                Spacer()
                Button {
                    viewnumber = 2
                    colorAtHome = .black
                    colorAtPlan = .blue
                    colorAtFriend = .black
                    colorAtSetting = .black
                } label: {
                    VStack {
                        Image(systemName: "airplane.up.forward")
                            .font(Font.system(size: 26, weight: .bold))
                            .foregroundStyle(colorAtPlan)
                        Text("プラン")
                            .font(Font.system(size: 13, weight: .bold))
                            .foregroundStyle(colorAtPlan)
                    }
                }
                Spacer()
                Button {
                    viewnumber = 3
                    colorAtHome = .black
                    colorAtPlan = .black
                    colorAtFriend = .blue
                    colorAtSetting = .black
                } label: {
                    VStack {
                        Image(systemName: "person.2")
                            .font(Font.system(size: 26, weight: .bold))
                            .foregroundStyle(colorAtFriend)
                        Text("フレンド")
                            .font(Font.system(size: 13, weight: .bold))
                            .foregroundStyle(colorAtFriend)
                    }
                }
                Spacer()
                Button {
                    viewnumber = 4
                    colorAtHome = .black
                    colorAtPlan = .black
                    colorAtFriend = .black
                    colorAtSetting = .blue
                } label: {
                    VStack {
                        Image(systemName: "gearshape")
                            .font(Font.system(size: 26, weight: .bold))
                            .foregroundStyle(colorAtSetting)
                        Text("設定")
                            .font(Font.system(size: 13, weight: .bold))
                            .foregroundStyle(colorAtSetting)
                    }
                }
            }
            .padding()
            .background(.white)
        }
    }
}
#Preview{
    ContentView()
}
