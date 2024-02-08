//
//  CameraMyMake.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/06.
//

import SwiftUI
import AVFoundation

struct CameraMyMake: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CameraMyMake()
}
// カメラセッション管理
class CameraManager_MyMake: NSObject,ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published private(set) var isCameraReady = false
    @Published private(set) var session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    // カメラの設定を行う
    func setup(){
        DispatchQueue(label: "camera.setUp").async {
            self.configureCaptureSession()
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isCameraReady = true
            }
        }
    }
    private func configureCaptureSession() {
        // デバイス設定
        guard let camera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video,position: .back) else {
            fatalError("カメラが見つかりません")
        }
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput){
                session.addInput(cameraInput)
            }
            if session.canAddOutput(photoOutput){
                session.addOutput(photoOutput)
            }
        } catch {
            fatalError("セッション中にエラーが発生しました:\(error)")
        }
    }
    // セッションを開始
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    // セッション停止
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    // 写真を撮影する
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        // 画像データを使用して何かをする
        // 例えば、UIImageに変換して共有する
        let image = UIImage(data: imageData)
        // imageを使用してUIを更新するためには、
        // @Publishedプロパティに保存するか、
        // 適切な方法でコールバックを提供する
    }
}


struct CameraPreview_MyMake: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
