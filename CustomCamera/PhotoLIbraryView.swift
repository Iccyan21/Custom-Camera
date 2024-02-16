//
//  PhotoLIbraryView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/08.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryView: View {
    @State var selectedPhoto: UIImage
    
    @State private var showShareSheet = false
    
    @State var selectedAsset: PHAsset?
        
    @EnvironmentObject var photoManager: PhotoManager
    
    var asset: PHAsset?
            
    var body: some View {
        VStack{
            HStack{
                Spacer()
                
                Text("全ての写真")
                    .padding()
                
            }
            if let asset = asset {
                AssetImageView(asset: asset)
                // AssetImageViewはPHAssetから画像を読み込み、表示するビュー
            } else {
                Text("No Photo Available")
            }
                        
            HStack{
                
                
                Button(action: {
                    self.showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                        .padding()
                        .padding(.bottom,40)
                }
                .sheet(isPresented: $showShareSheet, content: {
                    ActivityViewController(activityItems: [self.selectedPhoto])
                })
                
                Spacer()
                
                // 写真を削除する機能
                Button(action: {
                        print("Hello")
                      }) {
                    Image(systemName: "trash.fill")
                        .imageScale(.large)
                        .padding()
                        .padding(.bottom,40)
                }
            }
        }
    }
}


struct AssetImageView: View {
    let asset: PHAsset
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Loading...")
            }
        }
        .onAppear(perform: loadAssetImage)
    }
    
    private func loadAssetImage() {
        print("Hello")
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: options) { image, info in
            // エラーがあればログに出力
            if let error = info?[PHImageErrorKey] as? NSError {
                print("画像の読み込みエラー: \(error)")
            }
            
            DispatchQueue.main.async {
                self.uiImage = image
                if image != nil {
                    print("画像が正しく読み込まれました")
                } else {
                    print("画像がnilです")
                }
            }
        }
    }
}


func deletePhoto(asset: PHAsset) {
    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.deleteAssets([asset] as NSArray)
    }, completionHandler: { success, error in
        if success {
            // 削除成功
            DispatchQueue.main.async {
                // UIの更新やユーザーへの通知など
            }
        } else {
            // 削除失敗またはエラー発生
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
        }
    })
}


struct PhotoLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        let photoManager = PhotoManager() // PhotoManagerのインスタンスを作成
        let systemImage = UIImage(systemName: "photo")!
        PhotoLibraryView(selectedPhoto: systemImage).environmentObject(photoManager) 
        // EnvironmentObjectとして注入

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
    func deletePhoto(_ photo: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([photo] as NSArray)
        }) { success, error in
            if success {
                // 削除成功
                DispatchQueue.main.async {
                    // UIの更新処理
                }
            } else {
                // 削除失敗
                print("削除に失敗しました: \(error?.localizedDescription ?? "")")
            }
        }
    }
}


class PhotoLibraryViewModel: ObservableObject {
    @Published var lastAsset: PHAsset?
    
    func updateLastAsset(with asset: PHAsset) {
        self.lastAsset = asset
    }
}
