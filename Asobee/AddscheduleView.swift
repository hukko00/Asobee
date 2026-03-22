import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddscheduleView: View {
    @Environment(\.modelContext) private var context
    @Binding var showAddSheet: Bool

    @State private var title = ""
    @State private var note = ""
    @State private var timedata = Date()
    @State private var imageData: Data?
    @State private var linkData: URL?

    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("タイトル")
                    .font(.title3)
                    .foregroundColor(.black)

                TextField("タイトル", text: $title)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("内容")
                    .font(.title3)
                    .foregroundColor(.black)

                TextEditor(text: $note)
                    .frame(height: 80)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("予定の内容を入力")
                                .foregroundStyle(.gray)
                                .padding(.top, 18)
                                .padding(.leading, 14)
                                .allowsHitTesting(false)
                        }
                    }
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
                    Text("日時")
                        .font(.headline)

                    DatePicker(
                        "",
                        selection: $timedata,
                        displayedComponents: [.date, .hourAndMinute]
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
                            .font(.system(size: 24))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        print("url ok")
                    } label: {
                        Image(systemName: "link")
                            .font(.system(size: 24))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
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
        let newPlan = schedule(
            title: title,
            note: note,
            timedata: timedata,
            imageData: imageData,
            linkData: linkData,
            dateCandidates: [],
            placeCandidates: []
        )

        context.insert(newPlan)

        do {
            try context.save()
            withAnimation(.easeInOut) {
                showAddSheet = false
            }
        } catch {
            print("保存エラー: \(error)")
        }
    }
}

#Preview {
    AddscheduleView(showAddSheet: .constant(true))
        .modelContainer(for: [schedule.self, DateCandidate.self, PlaceCandidate.self])
}
