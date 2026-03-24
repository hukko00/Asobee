//
//  FriendView.swift
//  Asobea
//
//  Created by 鈴木勝博 on 2026/03/20.
//

import SwiftUI

struct FriendView: View {
    @State private var showRoot = false
    
    var body: some View {
        Button {
            showRoot = true
        } label: {
            Text("ログイン・新規登録")
                .font(Font.title2.bold())
                .foregroundStyle(Color.white)
                .padding()
                .background(.blue)
                .clipShape(Capsule())
        }
        .sheet(isPresented: $showRoot) {
            RootView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    FriendView()
}
