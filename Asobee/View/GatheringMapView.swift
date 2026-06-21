import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MapKit

struct GatheringMapView: View {
    
    var plan: PlanItem
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = gatheringmapviewModel()
    
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
            .ignoresSafeArea()
            .onMapCameraChange { context in
                vm.centerCoordinate = context.region.center
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
                        if vm.searchnumber == 1{
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
                            .padding(.leading)
                    }
                    Spacer()
                    
                    Button {
                        
                        vm.isShowSearchSheet = true
                        
                    } label: {
                        
                        Image(systemName: "magnifyingglass")
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
            
            MapSheetView(
                mapnumber: $vm.mapnumber,
                mapStyle: $vm.MapStyle,
                cameraPosition: $vm.cameraPosition
            )
            .presentationDetents([.height(210)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $vm.isShowSearchSheet) {
            
            SearchSheetView(
                searchnumber: $vm.searchnumber
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
struct MapSheetView: View {
    @Binding var mapnumber: Int
    @Binding var mapStyle: MapStyle
    @Binding var cameraPosition: MapCameraPosition

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("地図スタイル")
                .font(.custom("KiwiMaru-Medium", size: 22))

            HStack(spacing: 16) {

                StyleCard(
                    title: "通常",
                    isSelected: mapnumber == 0
                ) {
                    mapnumber = 0
                    mapStyle = .standard
                }

                StyleCard(
                    title: "航空写真",
                    isSelected: mapnumber == 1
                ) {
                    mapnumber = 1
                    mapStyle = .hybrid
                }
            }
        }
        .padding()
        .background(
            Color(
                red: 248 / 255,
                green: 244 / 255,
                blue: 236 / 255
            )
        )
    }
}
struct SearchSheetView: View {
    @Binding var searchnumber: Int

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("検索モード")
                .font(.custom("KiwiMaru-Medium", size: 22))

            HStack(spacing: 16) {

                StyleCard(
                    title: "地名",
                    isSelected: searchnumber == 0
                ) {
                    searchnumber = 0
                }

                StyleCard(
                    title: "詳細",
                    isSelected: searchnumber == 1
                ) {
                    searchnumber = 1
                }
            }
        }
        .padding()
        .background(
            Color(
                red: 248 / 255,
                green: 244 / 255,
                blue: 236 / 255
            )
        )
    }
}
struct StyleCard: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            VStack(spacing: 10) {

                Image(
                    systemName: isSelected
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.system(size: 26))
                .foregroundStyle(
                    isSelected ? .blue : .gray
                )

                Text(title)
                    .font(
                        .custom(
                            "KiwiMaru-Regular",
                            size: 18
                        )
                    )
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected
                        ? Color.blue
                        : Color.clear,
                        lineWidth: 2
                    )
            }
            .shadow(
                color: .black.opacity(0.05),
                radius: 5
            )
        }
    }
}
#Preview {
    GatheringMapView(
        plan: PlanItem(
            id: "test-id",
            title: "Sample Plan",
            ownerId: "preview-user",
            inviteFriends: []
        )
    )
}
