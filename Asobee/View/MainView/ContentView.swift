import SwiftUI

struct ContentView: View {
    @State private var viewNumber = 2
    @EnvironmentObject var tabBarState: TabBarState
    
    var body: some View {
        ZStack(alignment: .bottom) {

            // メイン画面
            Group {
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
            if tabBarState.isVisible {
                HStack {
                    tabButton(icon: "airplane.up.forward", title: "プラン", index: 2)
                    tabButton(icon: "person.2", title: "フレンド", index: 3)
                    tabButton(icon: "person.fill", title: "プロフィール", index: 1)
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                .background(.ultraThinMaterial)
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
