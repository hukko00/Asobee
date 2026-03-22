//
//  FriendView.swift
//  Asobea
//
//  Created by 鈴木勝博 on 2026/03/20.
//

import SwiftUI

struct FriendView: View {
    var body: some View {
        Text("friendView")
        Button{
            let repository = FirebasePlanRepository()

            repository.fetchPlans { plans, error in
                if let error {
                    print("取得失敗: \(error.localizedDescription)")
                } else if let plans {
                    print("取得成功: \(plans.count)件")
                    for plan in plans {
                        print("title: \(plan.title), note: \(plan.note)")
                    }
                }
            }
        } label:{
            Text("aaaaaaa")
                .font(.largeTitle)
        }
    }
}

#Preview {
    FriendView()
}
