//import SwiftUI
//import MapKit
//
//struct ShowMapView: View {
//    var map: MapDataItem
//    @State private var cameraPosition: MapCameraPosition
//    init(map: MapDataItem) {
//        self.map = map
//        _cameraPosition = State(initialValue: .region(
//            MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: map.lat, longitude: map.lng),
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//        ))
//    }
//    var body: some View {
//        let coordinate = CLLocationCoordinate2D(latitude: map.lat, longitude: map.lng)
//        Map(position: $cameraPosition) {
//            Marker("選択地点", coordinate: coordinate)
//        }
//        .ignoresSafeArea()
//    }
//}
//#Preview {
//    ShowMapView(
//        map: MapDataItem(
//            id: "test",
//            lat: 35.681236,
//            lng: 139.767125,
//            title: "東京駅",
//            createdAt: Date(),
//            senderId: "user",
//            senderName: "まさ"
//        )
//    )
//}
