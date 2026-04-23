import SwiftUI
import MapKit

struct ShowMapView: View {
    var map: MapItem
    @State private var isShowChangeSheet: Bool = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapnumber = 0
    @State private var mapStyle: MapStyle = .standard

    var body: some View {
        ZStack{
            Map(position: $cameraPosition) {
                Marker(
                    map.senderName,
                    coordinate: CLLocationCoordinate2D(latitude: map.lat, longitude: map.lng)
                )
                .tint(.red)
            }
            .mapStyle(mapStyle)
            .onAppear {
                let region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: map.lat, longitude: map.lng),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                cameraPosition = .region(region)
            }
            .ignoresSafeArea()
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button {
                        isShowChangeSheet = true
                    } label: {
                        Image(systemName: "map")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowChangeSheet){
            SheetView(
                mapnumber: $mapnumber,
                mapStyle: $mapStyle,
                cameraPosition: $cameraPosition
            )
        }
    }
}

#Preview {
    ShowMapView(
        map: MapItem(
            id: "preview-id",
            lat: 35.681236,
            lng: 139.767125,
            createdAt: Date(),
            senderId: "user1",
            senderName: "masa"
        )
    )
}
