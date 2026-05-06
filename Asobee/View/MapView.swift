import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MapKit

struct MapView: View {
    var plan: PlanItem
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = mapviewModel()
    var body: some View {
        ZStack {
            Map(position: $vm.cameraPosition)
                .mapStyle(vm.MapStyle)
                .onMapCameraChange(frequency: .onEnd) { context in
                    self.vm.centerCoordinate = context.region.center
                }
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)

                    TextField("場所を検索", text: $vm.searchText)
                        .textFieldStyle(.plain)
                        .font(.custom("KiwiMaru-Regular", size: 24))

                    if !vm.searchText.isEmpty {
                        Button {
                            vm.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                                .font(.system(size: 24))
                        }
                    }

                    Button {
                        vm.searchPlaces()
                        vm.searchText = ""
                    } label: {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.08), radius: 8)
                .padding(.horizontal)

                Spacer()
            }

            Image(systemName: "mappin")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .offset(y: -20)

            VStack {
                Spacer()
                
                HStack {
                    Button {
                        vm.createMapData(latitude: vm.centerCoordinate.latitude, longitude: vm.centerCoordinate.longitude, id: plan.id)
                        dismiss()
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
                        vm.isShowChangeSheet = true
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
        .sheet(isPresented: $vm.isShowChangeSheet){
            SheetView(
                mapnumber: $vm.mapnumber,
                mapStyle: $vm.MapStyle,
                cameraPosition: $vm.cameraPosition
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
