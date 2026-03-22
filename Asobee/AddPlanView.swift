import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddPlanView: View {
    @Environment(\.modelContext) private var context
    @Binding var showAddplanSheet: Bool

    @State private var plantitle = ""
    @State private var planimageData = Data()
    @State private var plancolor = 1
    @State private var planDate = Date()
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    private var canSave: Bool {
        !plantitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("タイトル")
                    .font(.title3)
                    .foregroundColor(.black)

                TextField("タイトル", text: $plantitle)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("日にち")
                        .font(.headline)

                    DatePicker(
                        "",
                        selection: $planDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundStyle(.black)
                            .frame(width: 52, height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        print("friendOK")
                    } label: {
                        Image(systemName: "person.2")
                            .font(.system(size: 37))
                            .foregroundStyle(.black)
                            .frame(width: 52, height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                addPlan()
//                let repository = FirebasePlanRepository()
//
//                repository.addPlan(title: title, note: note) { error in
//                    if let error {
//                        print("保存失敗: \(error.localizedDescription)")
//                    } else {
//                        print("保存成功")
//                    }
//                }
            } label: {
                Text("保存")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canSave ? Color.blue : Color.gray.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!canSave)
        }
        .padding(20)
        .background(Color(red: 255/255, green: 255/255, blue: 249/255))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                guard let newItem else { return }

                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }

    func addPlan() {
        let newPlan = Plan(
            plantitle: plantitle,
            planimageData: planimageData,
            planColor: plancolor,
            planDate: planDate
        )
        
        context.insert(newPlan)
        
        do {
            try context.save()
            withAnimation(.easeInOut) {
                showAddplanSheet = false
            }
        } catch {
            print("保存エラー: \(error)")
        }
    }

}

#Preview {
    AddPlanView(showAddplanSheet: .constant(true))
        .modelContainer(for: [schedule.self, DateCandidate.self, PlaceCandidate.self])
}
