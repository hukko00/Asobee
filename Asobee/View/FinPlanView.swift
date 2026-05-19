import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ScheduleItem: Identifiable {

    let id = UUID()

    var time: Date = Date()
    var place: String = ""
}
struct FinSchedule: Codable {

    var time: Date
    var place: String
}

struct FinPlanView: View {
    var plan:PlanItem
    @Environment(\.dismiss) var dismiss
    @State private var title = ""

    @State private var startselectedDate = Date()
    @State private var endselectedDate = Date()

    @State private var meetingPlace = ""

    @State private var schedules: [ScheduleItem] = [
        ScheduleItem()
    ]

    var body: some View {

        ZStack {

            Color(
                red: 248 / 255,
                green: 244 / 255,
                blue: 236 / 255
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                ZStack {

                    Text("しおり作成")
                        .font(
                            .custom(
                                "KiwiMaru-Medium",
                                size: 20
                            )
                        )

                    HStack {

                        Button {

                            dismiss()

                        } label: {

                            Image(systemName: "chevron.left")
                                .font(
                                    .custom(
                                        "KiwiMaru-Regular",
                                        size: 22
                                    )
                                )
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
                .onAppear {

                    fetchFinPlan()
                }

                ScrollView {

                    VStack(spacing: 24) {

                        headerView

                        scheduleSection

                        saveButton
                    }
                    .padding()
                    .font(
                        .custom(
                            "KiwiMaru-Regular",
                            size: 18
                        )
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Header
extension FinPlanView {

    var headerView: some View {

        VStack(alignment: .leading, spacing: 20) {

            TextField(
                "タイトル",
                text: $title
            )
            .font(
                .custom(
                    "KiwiMaru-Medium",
                    size: 34
                )
            )
            .textFieldStyle(.plain)
            .padding(.bottom, 6)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .offset(y: 10),
                alignment: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {

                Label(
                    "日にち",
                    systemImage: "calendar"
                )
                .font(
                    .custom(
                        "KiwiMaru-Medium",
                        size: 20
                    )
                )

                HStack {

                    DatePicker(
                        "",
                        selection: $startselectedDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()

                    Text("〜")

                    DatePicker(
                        "",
                        selection: $endselectedDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Label(
                        "集合場所",
                        systemImage: "mappin.and.ellipse"
                    )
                    .font(
                        .custom(
                            "KiwiMaru-Medium",
                            size: 20
                        )
                    )
                    .padding(.trailing, 16)
                    NavigationStack {

                        NavigationLink {
                            MapView(plan:plan)
                        } label: {

                            Image(systemName: "map")
                                .foregroundStyle(.black)
                        }
                    }
                    
                }

                TextField(
                    "例: 渋谷駅ハチ公前",
                    text: $meetingPlace
                )
                .font(
                    .custom(
                        "KiwiMaru-Regular",
                        size: 18
                    )
                )
                .textFieldStyle(.plain)
            }
        }
        .padding(24)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .shadow(
            color: .black.opacity(0.05),
            radius: 10,
            y: 4
        )
    }
}

// MARK: - Schedule

extension FinPlanView {

    var scheduleSection: some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack {

                Text("スケジュール")
                    .font(
                        .custom(
                            "KiwiMaru-Medium",
                            size: 26
                        )
                    )

                Spacer()

                Button {

                    schedules.append(
                        ScheduleItem()
                    )

                } label: {

                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            ForEach(schedules.indices, id: \.self) { index in

                HStack(alignment: .top, spacing: 16) {

                    VStack {

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 14)

                        Rectangle()
                            .fill(
                                Color.blue.opacity(0.3)
                            )
                            .frame(width: 2)
                    }
                    .frame(width: 20)

                    VStack(alignment: .leading, spacing: 14) {

                        HStack {

                            DatePicker(
                                "時間",
                                selection: $schedules[index].time,
                                displayedComponents: .hourAndMinute
                            )
                            .font(
                                .custom(
                                    "KiwiMaru-Regular",
                                    size: 18
                                )
                            )

                            Spacer()

                            Button {

                                if schedules.count > 1 {

                                    schedules.remove(
                                        at: index
                                    )
                                }

                            } label: {

                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.red)
                            }
                        }

                        TextField(
                            "どこへ行く？",
                            text: $schedules[index].place
                        )
                        .font(
                            .custom(
                                "KiwiMaru-Regular",
                                size: 18
                            )
                        )
                        .padding()
                        .background(

                            Color(
                                red: 245 / 255,
                                green: 245 / 255,
                                blue: 245 / 255
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14
                            )
                        )
                    }
                    .padding()
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 24
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Save Button

extension FinPlanView {

    var saveButton: some View {

        Button {
            createFinPlan(
                    title: title,startDate: startselectedDate,endDate: endselectedDate,meetingPlace: meetingPlace,schedules: schedules,planId: plan.id
                )
        } label: {

            HStack {

                Spacer()

                Text("しおりを保存")
                    .font(
                        .custom(
                            "KiwiMaru-Medium",
                            size: 20
                        )
                    )
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding()
            .background(

                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
        .padding(.top, 10)
    }
}

// MARK: - Firestore

extension FinPlanView {

    func createFinPlan(
        title: String,
        startDate: Date,
        endDate: Date,
        meetingPlace: String,
        schedules: [ScheduleItem],
        planId: String
    ) {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .getDocument { snapshot, _ in

                let name =
                snapshot?.data()?["userName"] as? String ?? "不明"

                let scheduleData = schedules.map {

                    [
                        "time": Timestamp(date: $0.time),
                        "place": $0.place
                    ]
                }

                // しおり保存
                db.collection("plans")
                    .document(planId)
                    .collection("finPlan")
                    .document("main")
                    .setData([

                        "title": title,

                        "startDate":
                            Timestamp(date: startDate),

                        "endDate":
                            Timestamp(date: endDate),

                        "meetingPlace":
                            meetingPlace,

                        "schedules":
                            scheduleData,

                        "updatedAt":
                            Timestamp(date: Date()),

                        "senderId":
                            uid,

                        "senderName":
                            name

                    ], merge: true)

                // チャット通知
                db.collection("plans")
                    .document(planId)
                    .collection("messages")
                    .addDocument(data: [

                        "createdAt":
                            Timestamp(date: Date()),

                        "chat":
                            "\(name)がしおりを変更しました！",

                        "senderId":
                            uid,

                        "senderName":
                            name
                    ])
            }
    }
    func fetchFinPlan() {

        let db = Firestore.firestore()

        db.collection("plans")
            .document(plan.id)
            .collection("finPlan")
            .document("main")
            .getDocument { snapshot, error in

                guard let data = snapshot?.data() else {
                    return
                }

                title = data["title"] as? String ?? ""

                meetingPlace =
                data["meetingPlace"] as? String ?? ""

                if let start =
                    data["startDate"] as? Timestamp {

                    startselectedDate = start.dateValue()
                }

                if let end =
                    data["endDate"] as? Timestamp {

                    endselectedDate = end.dateValue()
                }

                if let schedulesData =
                    data["schedules"] as? [[String: Any]] {

                    schedules = schedulesData.map {

                        ScheduleItem(
                            time:
                                ($0["time"] as? Timestamp)?
                                .dateValue()
                            ?? Date(),

                            place:
                                $0["place"] as? String
                            ?? ""
                        )
                    }
                }
            }
    }
}

#Preview {

    FinPlanView(
        plan: PlanItem(
            id: "preview-id",
            title: "テストプラン",
            ownerId: "user1",
            inviteFriends: [
                "user2",
                "user3"
            ]
        )
    )
}
