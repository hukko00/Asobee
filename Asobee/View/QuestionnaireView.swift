import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct Questions {
    var title: String
    var choicec: [String]
}

struct QuestionnaireView: View {

    var plan: PlanItem

    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Int?

    @State private var selected: String? = nil
    @State private var choices: [String] = ["", ""]
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var ignorename = false

    let templates = [
        "お昼ごはんどうする？",
        "何時集合にする？",
        "どこ行きたい？",
        "写真スポット決めよう！"
    ]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        choices.filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }.count >= 2
    }

    var body: some View {

        ZStack(alignment: .bottom) {

            colorcode(r: 248, g: 244, b: 236)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                topBar

                ScrollView {

                    VStack(spacing: 24) {

                        titleSection
                        choicesSection

                        Rectangle()
                            .fill(.clear)
                            .frame(height: 120)
                    }
                    .padding()
                }
            }

            createButton
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - TopBar

extension QuestionnaireView {

    var topBar: some View {

        ZStack {

            Text("アンケート作成")
                .font(.custom("KiwiMaru-Medium", size: 20))
            VStack{
                HStack {
                    
                    Button {
                        dismiss()
                        
                    } label: {
                        
                        Image(systemName: "chevron.left")
                            .font(.custom("KiwiMaru-Regular", size: 22))
                            .foregroundColor(
                                colorcode(r: 255, g: 162, b: 97)
                            )
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// MARK: - Title

extension QuestionnaireView {

    var titleSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("タイトル")
                .font(.custom("KiwiMaru-Medium", size: 22))

            TextField("アンケートタイトル", text: $title)
                .font(.custom("KiwiMaru-Regular", size: 18))
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            HStack{
                Text("期日")
                    .font(.custom("KiwiMaru-Medium", size: 22))
                DatePicker("Start Date",selection: $date,displayedComponents: [.date])
                .labelsHidden()
                .padding(.horizontal,10)
                Text("匿名回答")
                .font(.custom("KiwiMaru-Medium", size: 22))
                Button{
                    ignorename.toggle()
                    print(ignorename ? "true":"false")
                } label:{
                    ZStack{
                        Image(systemName:ignorename ? "square":"square")
                            .font(.custom("KiwiMaru-Medium", size: 22))
                            .foregroundStyle(.black)
                        if ignorename {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.black)
                            }
                    }
                }
                .animation(nil, value: ignorename)
            }
        }
    }
}

// MARK: - Choices

extension QuestionnaireView {

    var choicesSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack {

                Text("選択肢")
                    .font(.custom("KiwiMaru-Medium", size: 22))

                Spacer()

                Button {

                    withAnimation {
                        choices.append("")
                        focusedField = choices.count - 1
                    }

                } label: {

                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            ForEach(choices.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 10) {
                    Text("選択肢 \(index + 1)")
                        .font(.custom("KiwiMaru-Regular", size: 14))
                        .foregroundStyle(.gray)
                    HStack {
                        TextField("入力してください", text: $choices[index])
                            .font(.custom("KiwiMaru-Regular", size: 18))
                            .focused($focusedField, equals: index)
                        Button {
                            if choices.count > 2 {
                                choices.remove(at: index)
                            }
                        } label: {
                            Image(systemName: choices.count > 2 ? "minus.circle.fill":"")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

// MARK: - CreateButton

extension QuestionnaireView {
    var createButton: some View {
        VStack {
            Divider()
            Button {
                createQuestion(
                    title: title,
                    choices: choices,
                    ignorename: ignorename,
                    finishdate: date
                )
                dismiss()
            } label: {
                Text("作成する")
                    .font(.custom("KiwiMaru-Medium", size: 20))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(!isValid)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Firestore

extension QuestionnaireView {

    func createQuestion(title: String, choices: [String],ignorename:Bool,finishdate:Date) {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .getDocument { snapshot, _ in

                let name = snapshot?.data()?["userName"] as? String ?? "不明"

                db.collection("plans")
                    .document(plan.id)
                    .collection("questions")
                    .addDocument(data: [
                        "title": title,
                        "choices": choices.filter { !$0.isEmpty },
                        "createdAt": Timestamp(date: Date()),
                        "senderId": uid,
                        "senderName": name,
                        "ignorename":ignorename,
                        "finishdate":finishdate
                    ])
            }
    }
}

// MARK: - Color

extension QuestionnaireView {

    func colorcode(r: Int, g: Int, b: Int) -> Color {

        Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
// MARK: - Preview
//#Preview {
//
//    NavigationStack {
//
//        QuestionnaireView(
//            plan: PlanItem(
//                id: "preview-id",
//                title: "テストプラン",
//                ownerId: "user1",
//                inviteFriends: ["user2", "user3"]
//            )
//        )
//    }
//}
