
import SwiftUI

struct PlusButtonView: View {

    var onSelect: (Int) -> Void
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 30) {
                Button {
                    onSelect(1)
                } label: {
                    ButtonBuilder(text: "アンケート", image: "questionmark.message")
                }

                Button {
                    onSelect(2)
                } label: {
                    ButtonBuilder(text: "日程調整", image: "calendar")
                }
            }

            HStack(spacing: 30) {
                Button {
                    onSelect(3)
                } label: {
                    ButtonBuilder(text: "マップ", image: "map")
                }

                Button {
                    onSelect(4)
                } label: {
                    ButtonBuilder(text: "しおり", image: "text.document")
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

