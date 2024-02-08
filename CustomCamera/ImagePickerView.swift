//
//  ImagePickerView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/01/31.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    // UIImagePickerPicker(写真撮影)が表示されているかを確認
    @Binding var isShowSheet: Bool
    // 撮影した写真を格納する変数
    @Binding var caputureImage: UIImage?
    
    // Coordinatorでコントローラーのdelegateを管理
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        // ImagePickerView型を定義を用意
        let parent: ImagePickerView
        
        // イニシャライザ
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        // 撮影が終わった時に呼ばれるdelegateメゾット
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            // 撮影した写真をcaptureImageに保存
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.caputureImage = originalImage
            }
            // sheetを閉じる
            parent.isShowSheet.toggle()
        }
        // キャンセルボタンが選択された時に呼ばれるdelegateメゾット、必ず必要
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // sheetを閉じる
            parent.isShowSheet.toggle()
        }
    }
    // Coordinatorを作成、SwiftUIによって自動的に呼び出し
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    // Viewを生成する時に実行
    func makeUIViewController(context: Context) -> UIImagePickerController {
        // UIImagePickerControllerのインスタンスを作成
        let myImagePickerController = UIImagePickerController()
        // sourceTypeにcameraを設定
        myImagePickerController.sourceType = .camera
        // delegate設定
        myImagePickerController.delegate = context.coordinator
        // UIImagePickerControllerを返す
        return myImagePickerController
    }
    // Viewが更新されたときに実行
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
}


