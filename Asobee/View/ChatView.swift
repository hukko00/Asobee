import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    var plan: PlanItem
    @State private var listener: ListenerRegistration?
    @State var text: String = ""
    @EnvironmentObject var tabBarState: TabBarState
    @Environment(\.dismiss) var dismiss
    @State private var showScrollButton = false
    @State private var showPlusMenu = false
    @State private var navigationNumber = 0
    @State private var selectedMap: MapItem? = nil
    @State private var selectedQuestion: QuestionItem? = nil
    @StateObject var chatviewModel = chatviewmodel()
    
    var body: some View {
        ZStack {
            Color(colorcode(r: 247, g: 246, b: 242))
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    // タイトル（常に中央）
                    Text(plan.title)
                        .font(.custom("KiwiMaru-Medium", size: 18))
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.custom("KiwiMaru-Regular", size: 22))
                                .foregroundColor(colorcode(r: 255, g: 162, b: 97))
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                ScrollViewReader { proxy in
                    ZStack(alignment: .bottomTrailing) {
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                
                                let items = chatviewModel.makeTimelineItems(
                                    chats: chatviewModel.chats,
                                    maps: chatviewModel.maps,
                                    questions: chatviewModel.questions
                                )
                                
                                ForEach(items) { item in
                                    HStack {
                                        
                                        if item.senderId == Auth.auth().currentUser?.uid ?? "" {
                                            Spacer()
                                            messageView(item: item, isMe: true)
                                        } else {
                                            messageView(item: item, isMe: false)
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .id(item.id)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        
                        if showScrollButton {
                            Button {
                                let items = chatviewModel.makeTimelineItems(
                                    chats: chatviewModel.chats,
                                    maps: chatviewModel.maps,
                                    questions: chatviewModel.questions
                                )
                                
                                if let last = items.last {
                                    withAnimation {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                                
                                showScrollButton = false
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.gray.opacity(0.7))
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(radius: 4)
                                    )
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .onChange(of: chatviewModel.chats.count) {
                        showScrollButton = true
                    }
                }
                Spacer()
                
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showPlusMenu.toggle()
                        }
                    } label:{
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }

                    Button{
                        
                    } label:{
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }

                    TextField("メッセージを入力", text: $text)
                        .font(.custom("KiwiMaru-Regular", size: 18))
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)

                    Button{
                        if !text.isEmpty {
                            chatviewModel.createChat(chat: text, planId: plan.id)
                            text = ""
                        }
                    } label:{
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(colorcode(r: 255, g: 162, b: 97))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorcode(r: 234, g: 231, b: 220))
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
            if showPlusMenu {
                
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showPlusMenu = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    PlusButtonView { number in
                        showPlusMenu = false
                        navigationNumber = number
                    }
                    .padding(.bottom, 90)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showPlusMenu)
        .navigationDestination(isPresented: Binding(
            get: { navigationNumber != 0 },
            set: { _ in navigationNumber = 0 }
        )) {
            
            switch navigationNumber {
            case 1:
                QuestionnaireView(plan: plan)
                
            case 2:
                ItineraryView()
                
            case 3:
                MapView(plan: plan)
                
            case 4:
                RouteView()
                
            case 5:
                if let selectedMap {
                    ShowMapView(map: selectedMap)
                } else {
                    Text("データなし")
                }
            case 6:
                if let selectedMap {
                    ShowMapView(map: selectedMap)
                } else {
                    Text("データなし")
                }
            default:
                EmptyView()
            }
        }
        .onAppear {
            chatviewModel.start(planId: plan.id)
        }
        .onDisappear {
            chatviewModel.stop()
        }
        .navigationBarBackButtonHidden(true)
        .task {
            tabBarState.isVisible = false
            print("taskOK")
        }
        
        .onDisappear{
            tabBarState.isVisible = true
            print("DisappearOK")
        }
        .onChange(of: tabBarState.isVisible) {
            print("TabBar:", tabBarState.isVisible)
        }
    }
    func colorcode(r:Int,g:Int,b:Int)-> Color{
        return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
    @ViewBuilder
    func messageView(item: TimelineItem, isMe: Bool) -> some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
            
            if item.type == .chat {
                
                Text(item.chat ?? "")
                    .padding(12)
                    .font(.custom("KiwiMaru-Regular", size: 18))
                    .background(
                        isMe ?
                        colorcode(r: 255, g: 162, b: 97)
                        :
                            colorcode(r: 127, g: 183, b: 126)
                    )
                    .cornerRadius(14)
                
            } else if item.type == .map {
                
                Button {
                    selectedMap = MapItem(
                        id: item.id,
                        lat: item.lat ?? 0,
                        lng: item.lng ?? 0,
                        createdAt: item.createdAt,
                        senderId: item.senderId,
                        senderName: item.senderName
                    )
                    navigationNumber = 5
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.black)

                        Text("位置情報")
                            .font(.custom("text.document", size: 18))
                            .foregroundStyle(.black)
                    }
                    .padding(12)
                    .background(
                        isMe ?
                        colorcode(r: 255, g: 162, b: 97)
                        :
                        colorcode(r: 127, g: 183, b: 126)
                    )
                    .cornerRadius(14)
                }
            }else if item.type == .question {
                Button {
                    
                } label: {
                    VStack(spacing: 6) {
                        Text("アンケート")
                            .font(.custom("KiwiMaru-Regular", size: 30))
                            .foregroundStyle(.black)
                        Image(systemName: "text.document")
                            .font(.system(size: 26))
                            .foregroundStyle(.black)

                        Text(item.title ?? "")
                            .font(.custom("KiwiMaru-Regular", size: 18))
                            .foregroundStyle(.black)
                    }
                    .padding(12)
                    .background(
                        isMe ?
                        colorcode(r: 255, g: 162, b: 97)
                        :
                        colorcode(r: 127, g: 183, b: 126)
                    )
                    .cornerRadius(14)
                }
            }
            
            Text(item.senderName)
                .font(.custom("KiwiMaru-Regular", size: 11))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
    }
}
#Preview {
    ChatView(
        plan: PlanItem(
            id: "test",
            title: "テストプラン",
            ownerId: "user",
            inviteFriends: []
        )
    )
    .environmentObject(TabBarState())
}
