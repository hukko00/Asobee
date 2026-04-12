
import SwiftUI

struct PlusButtonView: View {
    @State var navigationnumber:Int = 0
    var body: some View {
        VStack(spacing :30){
            HStack(spacing: 30){
                Button{
                    navigationnumber = 1
                } label:{
                    ButtonBuilder(text: "アンケート", image: "text.document")
                }
                Button{
                    navigationnumber = 2
                } label:{
                    ButtonBuilder(text: "日程調整", image: "calendar")
                }
            }
            HStack(spacing: 30){
                Button{
                    navigationnumber = 3
                } label:{
                    ButtonBuilder(text: "マップ", image: "map")
                }
                Button{
                    navigationnumber = 4
                } label:{
                    ButtonBuilder(text: "乗り換え", image: "tram")
                }
            }
        }
    }
    func ButtonBuilder(text:String,image:String) -> some View {
        
        VStack{
            Image(systemName:image)
                .font(.custom("KiwiMaru-Regular", size: 50))
                .foregroundStyle(Color(.black))
            if text.count < 6{
                Text(text)
                    .font(.custom("KiwiMaru-Regular", size: 15))
                    .foregroundStyle(Color(.black))
            } else {
                Text(text)
                    .font(.custom("KiwiMaru-Regular", size: 75/CGFloat(text.count)))
                    .foregroundStyle(Color(.black))
            }
        }
    }
}

#Preview {
    PlusButtonView()
}
