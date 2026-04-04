import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MapKit

struct MapView: View {
    var plan: PlanItem
    @State var MapStyle: MapStyle = .standard
    @State private var isShowChangeSheet = false
    @State var mapnumber: Int = 0

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35, longitude: 135),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    @State private var centerCoordinate: CLLocationCoordinate2D = .init()

    var body: some View {
        ZStack {

            Map(position: $cameraPosition)
                .mapStyle(MapStyle)
                .onMapCameraChange(frequency: .onEnd) { context in
                    centerCoordinate = context.region.center
                }

            Image(systemName: "mappin")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .offset(y: -20)

            VStack {
                Spacer()
                
                HStack {
                    Button {
                        createMapData(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    } label: {
                        Text("ここにする")
                            .font(Font.custom("KiwiMaru-Light",size:30))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        isShowChangeSheet = true
                    } label: {
                        Image(systemName: "map")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $isShowChangeSheet){
            SheetView(
                mapnumber: $mapnumber,
                mapStyle: $MapStyle,
                cameraPosition: $cameraPosition
            )
        }
    }
    func createMapData(latitude:Double,longitude:Double) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            
            let name = snapshot?.data()?["userName"] as? String ?? "不明"
            
            db.collection("plans")
                .document(plan.id)
                .collection("maps")
                .addDocument(data: [
                    "latitude":latitude,
                    "longitude":longitude,
                    "createdAt": Timestamp(date: Date()),
                    "senderId": uid,
                    "senderName": name
                ])
        }
    }
}

struct SheetView: View {
    @Binding var mapnumber: Int
    @Binding var mapStyle: MapStyle
    @Binding var cameraPosition: MapCameraPosition

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing:5){
                Button{
                    mapStyle = .standard
                } label:{
                    Map(position: $cameraPosition)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                        .mapStyle(.standard)
                        .allowsHitTesting(false)
                }
                Text("通常")
                    .font(.custom("KiwiMaru-Light", size: 20))
                    .foregroundStyle(Color.black)
            }

            Button{
                mapStyle = .hybrid
            } label:{
                VStack{
                    Map(position: $cameraPosition)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                        .mapStyle(.hybrid)
                        .allowsHitTesting(false)
                    Text("航空写真")
                        .font(.custom("KiwiMaru-Light", size: 20))
                        .foregroundStyle(Color.black)
                }
            }
        }
        .padding()
    }
}
#Preview {
    MapView(
        plan: PlanItem(
            id: "test-id",
            title: "Sample Plan",
            ownerId: "preview-user",
            inviteFriends: []
        )
    )
}
