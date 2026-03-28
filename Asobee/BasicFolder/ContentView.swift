import SwiftUI

struct ContentView: View {
    @State private var Viewnumber = 2
    
    var body: some View {
        VStack(spacing: 0) {
            
            // メイン画面
            Group {
                if Viewnumber == 1 {
                    ProfileView()
                } else if Viewnumber == 2 {
                    PlanView()
                } else if Viewnumber == 3 {
                    FriendView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // タブバー
            HStack {
                tabButton(icon: "airplane.up.forward", title: "プラン", index: 2)
                tabButton(icon: "person.fill", title: "プロフィール", index: 1)
                tabButton(icon: "person.2", title: "フレンド", index: 3)
            }
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .padding(.bottom, 8)
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
                    .font(.system(size: 35))
                Text(title)
                    .font(.system(size:15))
            }
            .foregroundStyle(Viewnumber == index ? Color.blue : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
