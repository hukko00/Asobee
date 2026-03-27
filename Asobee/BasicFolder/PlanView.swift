import SwiftUI

struct PlanView: View {
    var body: some View {
        NavigationStack{
            NavigationLink{
                AddPlanView()
            }label:{
                Image(systemName:"plus.circle")
                    .font(.largeTitle)
            }
        }
    }
}

#Preview {
    PlanView()
}
