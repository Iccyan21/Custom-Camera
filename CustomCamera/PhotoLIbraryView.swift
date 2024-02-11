//
//  PhotoLIbraryView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/08.
//

import SwiftUI

struct PhotoLibraryView: View {
    @State var selectedPhoto: UIImage
    @State private var showShareSheet = false
    
    @EnvironmentObject var photoManager: PhotoManager
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                
                
                
                Text("全ての写真")
                    .padding()
                
                
            }
            Image(uiImage: selectedPhoto) // 選択された写真を表示
                .resizable()
                .scaledToFill()
            
            HStack{
                
                
                Button(action: {
                    self.showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                        .padding()
                }
                .sheet(isPresented: $showShareSheet, content: {
                    ActivityViewController(activityItems: [self.selectedPhoto])
                })
                
                Spacer()
                
                // 写真を削除する機能
                Button(action: {
                    photoManager.deletePhoto(selectedPhoto)
                    // 必要に応じてUIを更新する処理をここに追加
                }) {
                    Image(systemName: "trash.fill")
                        .imageScale(.large)
                        .padding()
                }
            }
        }
    }
}


struct PhotoLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        let photoManager = PhotoManager() // PhotoManagerのインスタンスを作成
        let systemImage = UIImage(systemName: "photo")!
        PhotoLibraryView(selectedPhoto: systemImage).environmentObject(photoManager) // EnvironmentObjectとして注入
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}


class PhotoManager: ObservableObject {
    @Published var photos: [UIImage] = []
    // 写真を削除するメゾット
    func deletePhoto(_ photo: UIImage) {
        if let index = photos.firstIndex(of: photo) {
            DispatchQueue.main.async {
                self.photos.remove(at: index)
            }
        }
    }
}



