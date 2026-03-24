import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddPlanView: View {
    @Environment(\.modelContext) private var context
    @Binding var showAddplanSheet: Bool

    @State private var plantitle = ""
    @State private var planimageData: Data? = nil
    @State private var plancolor = 1
    @State private var planDate = Date()
    @State private var selectedItem: PhotosPickerItem? = nil
    
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

            if let data = planimageData,
               let uiImage = UIImage(data: data) {
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
                
                // 日付
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
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        
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
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                // Optionally validate it's an image by attempting to init UIImage
                                if UIImage(data: data) != nil {
                                    await MainActor.run {
                                        self.planimageData = data
                                    }
                                }
                            }
                        }
                    }

                    // フレンドボタン（仮）
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

            // 保存ボタン
            Button {
                addPlan()
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
    }

    func addPlan() {
        let newPlan = Plan(
            plantitle: plantitle,
            planimageData: planimageData ?? Data(),
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
        .modelContainer(for: [Schedule.self, DateCandidate.self, PlaceCandidate.self])
}

