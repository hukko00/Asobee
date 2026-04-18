import SwiftUI

struct ContentView: View {
    @State private var Viewnumber = 2
    @StateObject private var keyboard = KeyboardObserver()
    @EnvironmentObject var tabBarState: TabBarState
    
    var body: some View {
        VStack(spacing: 0) {
            
            // メイン画面
            NavigationStack {
                Group {
                    if Viewnumber == 1 {
                        ProfileView()
                    } else if Viewnumber == 2 {
                        PlanView()
                    } else if Viewnumber == 3 {
                        FriendView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // タブバー
            if tabBarState.isVisible && Viewnumber == 2 {
                HStack {
                    tabButton(icon: "airplane.up.forward", title: "プラン", index: 2)
                    tabButton(icon: "person.fill", title: "プロフィール", index: 1)
                    tabButton(icon: "person.2", title: "フレンド", index: 3)
                }
                .padding(.vertical, 10)
                .background(Color(.white))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color.white)
    }
    
    // タブボタン共通化
    func tabButton(icon: String, title: String, index: Int) -> some View {
        Button {
            Viewnumber = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.custom("KiwiMaru-Regular", size: 35))
                Text(title)
                    .font(.custom("KiwiMaru-Regular", size: 15))
            }
            .foregroundStyle(Viewnumber == index ? Color(red: 121/255, green: 144/255, blue: 67/255) : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TabBarState())
}
