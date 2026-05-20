import Foundation
import MapKit
import Firebase
import FirebaseFirestore
import SwiftUI
internal import Combine
import FirebaseAuth
struct LocalSearchResponse: Codable {
    let Feature: [Feature]?
}

struct Feature: Codable {
    let Name: String
    let Geometry: Geometry
    let Property: PropertyData?
}

struct Geometry: Codable {
    let Coordinates: String
}

struct PropertyData: Codable {
    let Image1: String?
}
class mapviewModel:ObservableObject{
    @Published var showFinPlanView: Bool = false
    @Published var selectedLatitude = 0.0
    @Published var selectedLongitude = 0.0
    @Published var mapItems: [MapItem] = []
    @Published var MapStyle: MapStyle = .standard
    @Published var isShowChangeSheet = false
    @Published var mapnumber: Int = 0
    @Published var searchText: String = ""
    @Published var searchResults: [Feature] = []

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35, longitude: 135),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    @Published var centerCoordinate: CLLocationCoordinate2D =
        CLLocationCoordinate2D(latitude: 35.170915, longitude: 136.881537)

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
    func fetchLocalSearch(
        query: String,
        latitude: Double,
        longitude: Double,
//        gc: String = "0115001"
    ) async {
        
        print("==== API START ====")
        print("query:", query)
        print("lat:", latitude, "lon:", longitude)

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "LOCALMAP_API_KEY") as? String,
              !apiKey.isEmpty else {
            print("APIキー取得失敗")
            return
        }

        var components = URLComponents(string: "https://map.yahooapis.jp/search/local/V1/localSearch")
        components?.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "query", value: query),
//            URLQueryItem(name: "gc", value: gc),
            URLQueryItem(name: "output", value: "json")
        ]
        

        guard let url = components?.url else {
            print("URL作成失敗")
            return
        }

        print("URL:", url.absoluteString)

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // ステータス確認
            if let http = response as? HTTPURLResponse {
                print("status:", http.statusCode)
            }

            // 生JSON確認（これ超重要）
            if let jsonString = String(data: data, encoding: .utf8) {
                print("==== RAW JSON ====")
                print(jsonString)
            }
            
            // デコード
            let decoded = try JSONDecoder().decode(LocalSearchResponse.self, from: data)

            let features = decoded.Feature ?? []
            print("取得件数:", features.count)

            let items = features.compactMap { f -> MapItem? in
                let parts = f.Geometry.Coordinates.split(separator: ",")

                guard parts.count == 2,
                      let lon = Double(parts[0]),
                      let lat = Double(parts[1]) else {
                    print("座標変換失敗:", f.Geometry.Coordinates)
                    return nil
                }

                print("→", f.Name, lat, lon)

                return MapItem(
                    id: UUID().uuidString,
                    lat: lat,
                    lng: lon,
                    createdAt: Date(),
                    senderId: "api",
                    senderName: f.Name
                )
            }
            if let imageURL = decoded.Feature?.first?.Property?.Image1 {
                print(imageURL)
            } else {
                print("画像なし")
            }

            await MainActor.run {
                self.mapItems = items
                self.searchResults = decoded.Feature ?? []
            }

            print("API END")

        } catch {
            print("エラー:", error)
        }
    }
}

