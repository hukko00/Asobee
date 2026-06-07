import SwiftUI

struct Answerresult: View {

    let question: QuestionItem

    @Environment(\.dismiss) var dismiss

    var totalVotes: Int {
        question.answerCounts.values.reduce(0, +)
    }

    var body: some View {

        ZStack {

            Color(
                red: 247 / 255,
                green: 246 / 255,
                blue: 242 / 255
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                // 上バー
                ZStack {

                    Text("回答結果")
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

                ScrollView {

                    VStack(spacing: 16) {

                        VStack(alignment: .leading, spacing: 10) {

                            Text(question.title)
                                .font(.custom("KiwiMaru-Medium", size: 22))

                            Text("回答数 \(totalVotes)人")
                                .font(.custom("KiwiMaru-Regular", size: 14))
                                .foregroundStyle(.gray)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.white)
                        .cornerRadius(20)

                        ForEach(
                            Array(question.choices.enumerated()),
                            id: \.offset
                        ) { index, choice in

                            let count =
                                question.answerCounts["\(index)"] ?? 0

                            let percent =
                                totalVotes == 0
                                ? 0
                                : Int(
                                    Double(count)
                                    / Double(totalVotes)
                                    * 100
                                )

                            VStack(alignment: .leading, spacing: 10) {

                                HStack {

                                    Text(choice)
                                        .font(
                                            .custom(
                                                "KiwiMaru-Regular",
                                                size: 18
                                            )
                                        )

                                    Spacer()

                                    Text("\(count)票")
                                        .font(
                                            .custom(
                                                "KiwiMaru-Regular",
                                                size: 20
                                            )
                                        )
                                        .foregroundStyle(.gray)
                                }

                                GeometryReader { geo in

                                    ZStack(alignment: .leading) {

                                        RoundedRectangle(
                                            cornerRadius: 8
                                        )
                                        .fill(
                                            Color.gray.opacity(0.15)
                                        )

                                        RoundedRectangle(
                                            cornerRadius: 8
                                        )
                                        .fill(
                                            Color(
                                                red: 255 / 255,
                                                green: 162 / 255,
                                                blue: 97 / 255
                                            )
                                        )
                                        .frame(
                                            width:
                                                geo.size.width
                                                * CGFloat(percent)
                                                / 100
                                        )
                                    }
                                }
                                .frame(height: 12)

                                Text("\(percent)%")
                                    .font(
                                        .custom(
                                            "KiwiMaru-Regular",
                                            size: 13
                                        )
                                    )
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        Answerresult(
            question: QuestionItem(
                id: "test",
                title: "遊ぶ場所は？",
                choices: [
                    "カラオケ",
                    "映画",
                    "ボウリング",
                    "その他"
                ],
                answerCounts: [
                    "0": 6,
                    "1": 3,
                    "2": 2,
                    "3": 1
                ],
                answeredUsers: [],
                createdAt: Date(),
                senderId: "user1",
                senderName: "まさ"
            )
        )
    }
}
