import SwiftUI

struct ContentView: View {
    @State private var viewNumber = 2
    @EnvironmentObject var tabBarState: TabBarState
    
    var body: some View {
        VStack(spacing: 0) {
            
            // メイン画面
            ZStack {
                switch viewNumber {
                case 1:
                    NavigationStack { ProfileView() }
                case 2:
                    NavigationStack { PlanView() }
                case 3:
                    NavigationStack { FriendView() }
                default:
                    NavigationStack { PlanView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // タブバー
            if tabBarState.isVisible {
                HStack {
                    tabButton(icon: "airplane.up.forward", title: "プラン", index: 2)
                    tabButton(icon: "person.2", title: "フレンド", index: 3)
                    tabButton(icon: "person.fill", title: "プロフィール", index: 1)
                }
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .padding(.bottom, 8)
                .shadow(radius: 5)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    func tabButton(icon: String, title: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut) {
                viewNumber = index
            }
            print(ObjectIdentifier(tabBarState))
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 28)) // ← 少し大きく
                
                Text(title)
                    .font(.custom("KiwiMaru-Regular",size: 14))
            }
            .foregroundStyle(
                viewNumber == index
                ? Color(red: 121/255, green: 144/255, blue: 67/255)
                : Color.gray
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TabBarState())
}
