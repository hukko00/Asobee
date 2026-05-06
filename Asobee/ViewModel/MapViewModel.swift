import Foundation
import MapKit
import Firebase
import FirebaseFirestore
import SwiftUI
internal import Combine
import FirebaseAuth
class mapviewModel:ObservableObject{
    @Published var MapStyle: MapStyle = .standard
    @Published var isShowChangeSheet = false
    @Published var mapnumber: Int = 0
    @Published var searchText: String = ""

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35, longitude: 135),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    @Published var centerCoordinate: CLLocationCoordinate2D = .init()

    func searchPlaces() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let item = response?.mapItems.first else { return }
            
            let coordinate = item.location.coordinate
            
            withAnimation {
                self.cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.01,
                            longitudeDelta: 0.01
                        )
                    )
                )
            }
        }
    }
    func createMapData(latitude:Double,longitude:Double,id:String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            
            let name = snapshot?.data()?["userName"] as? String ?? "不明"
            
            db.collection("plans")
                .document(id)
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
    func fetchlocalsearch(){
        guard let url = URL(string: "https://map.yahooapis.jp/search/local/V1/localSearch") else {
            print("URLが不正です")
            return
        }
    }
}
