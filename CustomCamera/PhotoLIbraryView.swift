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
            
     
            Image(uiImage: selectedPhoto) // 選択された写真を表示
                .resizable()
                .scaledToFill()
                .padding(.top, 30)
               
            
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
                    deletePhoto(asset: asset!)
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

// もしかしたらこれは使えるかも
struct AssetImageView: View {
    let asset: PHAsset
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
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


// 写真を削除する関数
// 与えられたPHAssetをフォトライブラリから削除
func deletePhoto(asset: PHAsset) {
    // アプリのフォトライブラリにアクセス
    // メソッドは、フォトライブラリに対する変更
    // （この場合はアセットの削除）を行うために使用されます
    PHPhotoLibrary.shared().performChanges({
        // フォトライブラリから一つまたは複数のPHAssetオブジェクトを削除するためのリクエストを作成
        PHAssetChangeRequest.deleteAssets([asset] as NSArray)
    }) { success, error in
        // アセットの削除が成功した場合に実行
        if success {
            // 削除に成功した場合の処理
            print("写真が削除されました")
            DispatchQueue.main.async {
                // 必要に応じてUIを更新
            }
        } else {
            // 削除に失敗した場合のエラー処理
            print("写真の削除に失敗しました: \(String(describing: error))")
        }
    }
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
