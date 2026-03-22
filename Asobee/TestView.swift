import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text("")
                    .padding(10)
                VStack{
                    Text("plantitle")
                        .font(.system(size: 14))
                        .bold()
                        .padding(10)
                    Text("friend")
                        .font(.system(size: CGFloat(StringSizeselect(number: 14))))
                }
                Spacer()
                Image(systemName:"photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipped()
                        .cornerRadius(12)
                        .padding(20)
            }
        }
    }
    
    func StringSizeselect(number: Int) -> Int{
        return 14 + number
    }
}

#Preview {
    TestView()
}
