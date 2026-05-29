import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MapKit

struct GatheringMapView: View {
    
    var plan: PlanItem
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = mapviewModel()
    
    var body: some View {
        
        ZStack {
            
            Color(
                red: 248 / 255,
                green: 244 / 255,
                blue: 236 / 255
            )
            .ignoresSafeArea()
            
            Map(position: $vm.cameraPosition) {
                
                ForEach(vm.mapItems) { item in
                    
                    Marker(
                        item.senderName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: item.lat,
                            longitude: item.lng
                        )
                    )
                }
            }
            .mapStyle(vm.MapStyle)
            .clipShape(
                RoundedRectangle(cornerRadius: 28)
            )
            .padding(.horizontal)
            .padding(.top, 90)
            .padding(.bottom, 100)
            
            VStack(spacing: 0) {
                
                // MARK: Header
                
                ZStack {
                    
                    Text("集合場所を探す")
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
                
                // MARK: Search
                
                HStack(spacing: 10) {
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    
                    TextField(
                        "場所を検索",
                        text: $vm.searchText
                    )
                    .font(
                        .custom(
                            "KiwiMaru-Regular",
                            size: 18
                        )
                    )
                    
                    if !vm.searchText.isEmpty {
                        
                        Button {
                            
                            vm.searchText = ""
                            
                        } label: {
                            
                            Image(
                                systemName:
                                    "xmark.circle.fill"
                            )
                            .foregroundStyle(.gray)
                        }
                    }
                    
                    Button {
                        
                        let lat =
                        vm.centerCoordinate.latitude
                        
                        let lon =
                        vm.centerCoordinate.longitude
                        
                        Task {
                            await vm.fetchLocalSearch(
                                query: vm.searchText,
                                latitude: lat,
                                longitude: lon
                            )
                        }
                        
                    } label: {
                        
                        Image(
                            systemName:
                                "arrow.forward.circle.fill"
                        )
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 10,
                    y: 4
                )
                .padding()
                
                Spacer()
            }
            
            // MARK: Center Pin
            
            Image(systemName: "mappin")
                .font(.system(size: 40))
                .foregroundStyle(.red)
                .offset(y: -20)
            
            // MARK: Bottom Button
            
            VStack {
                
                Spacer()
                
                HStack {
                    Button {

                        if let region = vm.cameraPosition.region {

                            let lat = region.center.latitude
                            let lon = region.center.longitude

                            vm.selectedLatitude = lat
                            vm.selectedLongitude = lon

                            vm.showFinPlanView = true
                        }

                    } label: {

                        Text("決定")
                            .font(.custom("KiwiMaru-Medium", size: 25))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 60)
                            .padding(5)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.leading, 55)
                    }
                    Spacer()
                    
                    Button {
                        
                        vm.isShowChangeSheet = true
                        
                    } label: {
                        
                        Image(systemName: "map")
                            .font(.system(size: 24))
                            .foregroundStyle(.black)
                            .padding(18)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 8,
                                y: 4
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $vm.isShowChangeSheet) {
            
            SheetView(
                mapnumber: $vm.mapnumber,
                mapStyle: $vm.MapStyle,
                cameraPosition: $vm.cameraPosition
            )
            .presentationDetents([.height(210)])
            .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: $vm.showFinPlanView) {
            FinPlanView(
                latitude: vm.selectedLatitude,
                longitude: vm.selectedLongitude,
                plan:plan
            )
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
        .background(Color(
            red: 248 / 255,
            green: 244 / 255,
            blue: 236 / 255
        ))
    }
    
}
//#Preview {
//    GatheringMapView(
//        plan: PlanItem(
//            id: "test-id",
//            title: "Sample Plan",
//            ownerId: "preview-user",
//            inviteFriends: []
//        )
//    )
//}
