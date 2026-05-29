import SwiftUI

struct AnswerView: View {
    let question: QuestionItem
    @Environment(\.dismiss) var dismiss
    @State private var selectedChoice: String = ""
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
                    Text(question.title)
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
                        ForEach(question.choices, id: \.self) { choice in

                            Button {

                                selectedChoice = choice

                            } label: {

                                HStack {

                                    Text(choice)
                                        .font(.custom("KiwiMaru-Regular", size: 18))
                                        .foregroundStyle(.black)

                                    Spacer()

                                    if selectedChoice == choice {

                                        Image(systemName: "largecircle.fill.circle")
                                            .foregroundStyle(
                                                colorcode(
                                                    r: 255,
                                                    g: 162,
                                                    b: 97
                                                )
                                            )

                                    } else {

                                        Image(systemName: "circle")
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                Button {
                    if selectedChoice.isEmpty{
                        print(selectedChoice)
                    }
                } label: {
                    Text("回答を送信")
                        .font(.custom("KiwiMaru-Medium", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Color(
                                red: 255 / 255,
                                green: 162 / 255,
                                blue: 97 / 255
                            )
                        )
                        .cornerRadius(18)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    func colorcode(r:Int,g:Int,b:Int)-> Color{
        return Color(
            red: Double(r)/255,
            green: Double(g)/255,
            blue: Double(b)/255
        )
    }
}
//
//#Preview {
//    NavigationStack {
//        AnswerView(
//            question: QuestionItem(
//                id: "test-question",
//                title: "遊びアンケート",
//                choices: [
//                    "好きな食べ物は？",
//                    "集合時間は？",
//                    "行きたい場所は？"
//                ],
//                createdAt: Date(),
//                senderId: "user1",
//                senderName: "まさ"
//            )
//        )
//    }
//}
