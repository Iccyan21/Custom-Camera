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
    
    @EnvironmentObject var photoManager: PhotoManager
    
    var asset: PHAsset?
    
    var fetchedPhotos: [PHAsset]
    
            
    var body: some View {
        VStack{
            // 最新の写真を表示する
            if let latestPhoto = photoManager.fetchedPhotos.first {
                AssetImageView(asset: latestPhoto)
            } else {
                Text("写真がありません")
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
                    if let assetToDelete = photoManager.fetchedPhotos.first {
                        deletePhoto(asset: assetToDelete)
                        photoManager.fetchLatestPhoto() // 削除後、最新の写真リストを再フェッチ
                    } else {
                        print("削除する写真が見つかりません")
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .imageScale(.large)
                        .padding()
                        .padding(.bottom,40)
                }

            }
        }
        .onAppear {
            photoManager.fetchLatestPhoto()
        }
    }
}



struct AssetImageView: View {
    let asset: PHAsset
    @State private var uiImage: UIImage?
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // 画像がまだロードされていない場合のプレースホルダー
                Rectangle()
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            print("AssetImageView onAppear")
            loadUIImage(asset: asset)
        }
    }
    
    func loadUIImage(asset: PHAsset) {
        print("ロードします")
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = false // 非同期に設定
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true // ネットワーク経由のロードを許可
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, info in
            DispatchQueue.main.async {
                if let error = info?[PHImageErrorKey] as? Error {
                    print("画像のロードに失敗: \(error)")
                    return
                }
                if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                    print("低品質の画像がロードされました。")
                    // 低品質の画像でも一時的に表示する場合はここでセット
                }
                if let image = image {
                    print("画像のロードに成功しました。サイズ: \(image.size)")
                    self.uiImage = image
                } else {
                    print("画像のロードに失敗しました。imageはnilです。")
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
        // ダミーのUIImageインスタンスを作成します。
        let dummyImage = UIImage(systemName: "photo") ?? UIImage()
        // 空のPHAsset配列を使用します。
        let dummyAssets = [PHAsset]()
        
        // PhotoManagerのインスタンスを作成します。
        let photoManager = PhotoManager()
        
        // PhotoLibraryViewにダミーデータを提供してプレビューします。
        PhotoLibraryView(selectedPhoto: dummyImage, fetchedPhotos: dummyAssets)
            .environmentObject(photoManager)
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
    
    @Published var fetchedPhotos: [PHAsset] = []
    
    func fetchFirstPhotos(limit: Int = 10) {
        print("フェッチします！")
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)] // 最初に撮った写真から
        fetchOptions.fetchLimit = limit // 最初の10枚を取得
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        DispatchQueue.main.async {
            self.fetchedPhotos = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
            print("取得した写真の数: \(self.fetchedPhotos.count)")
        }
    }
    func fetchLatestPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // 降順に並べ替え
        fetchOptions.fetchLimit = 1 // 最新の1枚のみを取得
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        DispatchQueue.main.async {
            self.fetchedPhotos = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
        }
    }
    
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
