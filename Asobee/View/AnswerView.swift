import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct AnswerView: View {

    let question: QuestionItem
    let plan: PlanItem

    @Environment(\.dismiss) var dismiss

    @State private var selectedIndex: Int?
    @State private var hasAnswered = false
    @State private var showResult = false
    var body: some View {

        ZStack {

            Color(
                red: 247 / 255,
                green: 246 / 255,
                blue: 242 / 255
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
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
                
                if hasAnswered {
                    Button{
                        showResult = true
                    } label:{
                        Text("集計結果>")
                            .font(.custom("KiwiMaru-Medium", size: 20))
                            .foregroundColor(
                                Color(
                                    red: 255 / 255,
                                    green: 162 / 255,
                                    blue: 97 / 255
                                )
                            )
                    }
                    .navigationDestination(isPresented: $showResult) {
                        Answerresult(question: question)
                    }
                }

                ScrollView {

                    VStack(spacing: 16) {

                        ForEach(
                            Array(question.choices.enumerated()),
                            id: \.offset
                        ) { index, choice in

                            Button {

                                if !hasAnswered {
                                    selectedIndex = index
                                }

                            } label: {

                                HStack {

                                    Text(choice)
                                        .font(.custom("KiwiMaru-Regular", size: 18))
                                        .foregroundStyle(.black)

                                    Spacer()

                                    if selectedIndex == index {

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

                    guard let selectedIndex else {
                        return
                    }

                    answer(number: selectedIndex)

                } label: {

                    Text(
                        hasAnswered
                        ? "回答済み"
                        : "回答を送信"
                    )
                    .font(.custom("KiwiMaru-Medium", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        hasAnswered
                        ? Color.gray
                        : Color(
                            red: 255 / 255,
                            green: 162 / 255,
                            blue: 97 / 255
                        )
                    )
                    .cornerRadius(18)
                }
                .disabled(hasAnswered)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkAnswered()
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

    func checkAnswered() {

        guard let uid =
                Auth.auth().currentUser?.uid
        else {
            return
        }

        Firestore.firestore()
            .collection("plans")
            .document(plan.id)
            .collection("questions")
            .document(question.id)
            .getDocument { snapshot, error in

                guard let data = snapshot?.data()
                else {
                    return
                }

                let answeredUsers =
                    data["answeredUsers"]
                    as? [String] ?? []

                DispatchQueue.main.async {

                    hasAnswered =
                    answeredUsers.contains(uid)

                }
            }
    }

    func answer(number: Int) {

        guard let uid =
                Auth.auth().currentUser?.uid
        else {
            return
        }

        let ref = Firestore.firestore()
            .collection("plans")
            .document(plan.id)
            .collection("questions")
            .document(question.id)

        ref.getDocument { snapshot, error in

            guard let data = snapshot?.data()
            else {
                return
            }

            let answeredUsers =
                data["answeredUsers"]
                as? [String] ?? []

            if answeredUsers.contains(uid) {
                return
            }

            ref.updateData([
                "answerCounts.\(number)":
                    FieldValue.increment(Int64(1)),
                "answeredUsers":
                    FieldValue.arrayUnion([uid])
            ]) { error in

                if error == nil {

                    DispatchQueue.main.async {

                        hasAnswered = true

                        dismiss()
                    }
                }
            }
        }
    }
}
