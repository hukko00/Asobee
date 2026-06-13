import Firebase
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Friend3: Identifiable {
    let id: String
    let name: String
}

struct SelectFriendsView: View {

    @State private var friends: [Friend3] = []
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFriends: [String]

    var body: some View {

        ZStack {

            Color(
                red: 247 / 255,
                green: 246 / 255,
                blue: 242 / 255
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ヘッダー
                ZStack {

                    Text("フレンドを選択")
                        .font(.custom("KiwiMaru-Medium", size: 20))

                    HStack {

                        Button {
                            dismiss()
                        } label: {

                            Image(systemName: "chevron.left")
                                .font(.system(size: 22))
                                .foregroundColor(
                                    Color(
                                        red: 255 / 255,
                                        green: 162 / 255,
                                        blue: 97 / 255
                                    )
                                )
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                if friends.isEmpty {

                    VStack(spacing: 12) {

                        Spacer()

                        Image(systemName: "person.2")
                            .font(.system(size: 44))
                            .foregroundStyle(.gray)

                        Text("フレンドがいません")
                            .font(.custom("KiwiMaru-Regular", size: 18))

                        Text("まずはフレンドを追加しましょう")
                            .font(.custom("KiwiMaru-Regular", size: 13))
                            .foregroundStyle(.gray)

                        Spacer()
                    }

                } else {

                    ScrollView {

                        VStack(spacing: 14) {

                            ForEach(friends) { friend in

                                HStack {

                                    Circle()
                                        .fill(
                                            colorcode(
                                                r: 255,
                                                g: 162,
                                                b: 97
                                            )
                                        )
                                        .frame(width: 45, height: 45)
                                        .overlay {

                                            Text(
                                                String(
                                                    friend.name.prefix(1)
                                                )
                                            )
                                            .font(
                                                .custom(
                                                    "KiwiMaru-Regular",
                                                    size: 18
                                                )
                                            )
                                            .foregroundStyle(.white)
                                        }

                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {

                                        Text(friend.name)
                                            .font(
                                                .custom(
                                                    "KiwiMaru-Regular",
                                                    size: 18
                                                )
                                            )

                                        if selectedFriends.contains(friend.id) {

                                            Text("追加済み")
                                                .font(
                                                    .custom(
                                                        "KiwiMaru-Regular",
                                                        size: 12
                                                    )
                                                )
                                                .foregroundStyle(.green)
                                        }
                                    }

                                    Spacer()

                                    Button {

                                        if selectedFriends.contains(friend.id) {

                                            selectedFriends.removeAll {
                                                $0 == friend.id
                                            }

                                        } else {

                                            selectedFriends.append(friend.id)
                                        }

                                    } label: {

                                        Image(
                                            systemName:
                                                selectedFriends.contains(friend.id)
                                            ? "checkmark.circle.fill"
                                            : "plus.circle"
                                        )
                                        .font(.system(size: 28))
                                        .foregroundStyle(
                                            selectedFriends.contains(friend.id)
                                            ? .green
                                            : .gray
                                        )
                                    }
                                }
                                .padding(16)
                                .background(.white)
                                .cornerRadius(18)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectedFriends = []
        }
        .onAppear {
            fetchFriends { result in
                friends = result
            }
        }
    }

    func fetchFriends(
        completion: @escaping ([Friend3]) -> Void
    ) {

        guard let myUid =
                Auth.auth().currentUser?.uid
        else {

            completion([])
            return
        }

        let db = Firestore.firestore()

        db.collection("users")
            .document(myUid)
            .getDocument { snapshot, error in

                let myFollowing =
                    snapshot?.data()?["following"]
                    as? [String] ?? []

                var friends: [Friend3] = []

                let group = DispatchGroup()

                for uid in myFollowing {

                    group.enter()

                    db.collection("users")
                        .document(uid)
                        .getDocument { doc, error in

                            let data = doc?.data()

                            let otherFollowing =
                                data?["following"]
                                as? [String] ?? []

                            let name =
                                data?["userName"]
                                as? String ?? "名前なし"

                            if otherFollowing.contains(myUid) {

                                friends.append(
                                    Friend3(
                                        id: uid,
                                        name: name
                                    )
                                )
                            }

                            group.leave()
                        }
                }

                group.notify(queue: .main) {

                    completion(friends)
                }
            }
    }

    func colorcode(
        r: Int,
        g: Int,
        b: Int
    ) -> Color {

        Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
#Preview {
    FriendListView()
}
