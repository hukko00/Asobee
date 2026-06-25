import SwiftUI

struct ContentView: View {
    @State private var viewNumber = 2
    @EnvironmentObject var tabBarState: TabBarState
    @State private var showMenu = false
    
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
            
            // 右上メニューボタン
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "list.dash")
                            .foregroundStyle(.black)
                            .font(.system(size: 30))
                    }
                    .padding(20)
                }
                
                Spacer()
            }
            
            // 背景暗転
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu = false
                        }
                    }
            }
            if tabBarState.isVisible {
                HStack {
                    tabButton(
                        icon: "airplane.up.forward",
                        title: "プラン",
                        index: 2,
                        imagetype: 1
                    )
                    
                    tabButton(
                        icon: "person.2",
                        title: "フレンド",
                        index: 3,
                        imagetype: 1
                    )
                    
                    tabButton(
                        icon: "person.fill",
                        title: "プロフィール",
                        index: 1,
                        imagetype: 1
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                .background(.ultraThinMaterial)
            }
            // サイドメニュー
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("メニュー")
                        .font(.custom("KiwiMaru-Regular", size: 37))
                    
                    HStack {
                        sideButton(
                            icon: "airplane.up.forward",
                            title: "予定を立てる",
                            index: 2,
                            imagetype: 1
                        )
                        Spacer()
                    }
                    
                    HStack {
                        sideButton(
                            icon: "person.2",
                            title: "記録する",
                            index: 3,
                            imagetype: 1
                        )
                        Spacer()
                    }
                    
                    HStack {
                        sideButton(
                            icon: "person.fill",
                            title: "振り返る",
                            index: 1,
                            imagetype: 1
                        )
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 280)
                .background(.white)
            }
            .offset(x: showMenu ? 0 : 300)
            .animation(.easeInOut(duration: 0.3), value: showMenu)
            
        }
        .ignoresSafeArea(.keyboard)
    }
    func sideButton(
        icon: String,
        title: String,
        index: Int,
        imagetype: Int
    ) -> some View {
        
        Button {
            withAnimation(.easeInOut) {
                viewNumber = index
                showMenu = false
            }
        } label: {
            
            HStack(spacing: 6) {
                
                if imagetype == 1 {
                    Image(systemName: icon)
                        .font(.system(size: 35))
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                
                Text(title)
                    .font(.custom("KiwiMaru-Regular", size: 21))
            }
            .foregroundStyle(
                viewNumber == index
                ? Color(red: 121/255, green: 144/255, blue: 67/255)
                : .gray
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
    func tabButton(
        icon: String,
        title: String,
        index: Int,
        imagetype: Int
    ) -> some View {
        
        Button {
            withAnimation(.easeInOut) {
                viewNumber = index
                showMenu = false
            }
        } label: {
            
            VStack(spacing: 6) {
                
                if imagetype == 1 {
                    Image(systemName: icon)
                        .font(.system(size: 35))
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                
                Text(title)
                    .font(.custom("KiwiMaru-Regular", size: 15))
            }
            .foregroundStyle(
                viewNumber == index
                ? Color(red: 121/255, green: 144/255, blue: 67/255)
                : .gray
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
