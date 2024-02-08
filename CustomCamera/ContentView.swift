//
//  ContentView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/01/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    // プロパティが変更されるとビューを自動的に更新
    @ObservedObject private var cameraManager = CameraManager()
    
    @State private var showingPhotoLibrary = false
    var body: some View {
        NavigationView{
            VStack {
                // カメラのビュー
                // trueの場合CameraPreviewビューを表示
                if cameraManager.isCameraReady {
                    CameraPreview(session: cameraManager.session)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("カメラを設定中...")
                }
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    // lastPhotoがある場合にはその画像を表示し、ない場合はデフォルトのアイコンを表示
                    if let lastPhoto = cameraManager.lastPhoto {
                        Image(uiImage: lastPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 70) // 画像のサイズを小さく調整
                            .padding(4) // 余白を少なくする
                            .background(Color.black)
                    } else {
                        Image(systemName: "photo.artframe")
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.takePhoto()
                    }, label: {
                        ZStack{
                            Circle()
                                .fill(Color.white)
                                .frame(width: 65,height: 65)
                            // 周りを囲おうデザイン
                            Circle()
                                .stroke(Color.white,lineWidth: 2)
                                .frame(width: 75,height: 75)
                        }
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.switchCamera()
                    },label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    })
                    
                    Spacer()
                    
                }
                .frame(height: 120)
                .background(Color.black)
                
            }
            // 真っ先に実行される
            .onAppear {
                cameraManager.setup()
            }
            // 画面から消える直前に実行される
            // 不要にカメラが動作し続けることを防ぐため
            .onDisappear {
                cameraManager.stopSession()
            }
            // 戻る時にカメラのセッティングでUIの遅延が起きるから注意
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

// カメラセッション管理
class CameraManager: NSObject,ObservableObject, AVCapturePhotoCaptureDelegate {
    // private(set)で保護されているので
    // セッションのインスタンスはこのクラス内でのみ変更
    @Published private(set) var isCameraReady = false
    @Published private(set) var session = AVCaptureSession()
    // 写真を撮影するための出力
    private let photoOutput = AVCapturePhotoOutput()
    // 最後の写真を表示するための値
    @Published var lastPhoto: UIImage?
    // 今まで撮った写真をまとめて表示させるため
    @Published var photos: [UIImage] = []
    
    // カメラの設定を行う
    func setup(){
        // 非同期でカメラを設定
        DispatchQueue(label: "camera.setUp").async {
            // カメラ設定
            self.configureCaptureSession()
            // セッション開始
            self.session.startRunning()
            // メインに戻って処理
            DispatchQueue.main.async {
                // trueになるとUIはカメラが撮影準備が整ったことを検出し
                // ユーザーに対して撮影可能な状態であることを反映
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
            // カメラをデバイスをAVCaptureDeviceInputオブジェクトを作成
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput){
                session.addInput(cameraInput)
            }
            // 写真を出力するプロセス
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
    // カメラの内側、外側交換
    func switchCamera(){
        // セッションの設定を開始
        session.beginConfiguration()
        // 現在のカメラを入力を習得し、削除
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else {return}
        session.removeInput(currentInput)
        
        // 新しいカメラデバイスを設定
        let newCameraPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newCameraPosition) else {
            print("新しいデバイスカメラが見つかりません")
            return
        }
        // 新しい入力をセッションに追加
        do {
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            if session.canAddInput(newInput){
                session.addInput(newInput)
            } else {
                print("新しいセッションを追加しません")
            }
        } catch {
            print("新しい入力の設定に失敗しました:\(error)")
            session.commitConfiguration()
            return
        }
        // 新しい設定をコミット
        session.commitConfiguration()
    }
    
    // 写真を撮影する
    func takePhoto() {
        // 撮影する写真に関する特定の設定（例えばフラッシュの使用、HDRの有効化など）を指定
        let settings = AVCapturePhotoSettings()
        // 設定したsettingsを使用して写真を撮影
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    // 写真が撮影され、処理が完了すると呼び出されます
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        // 撮影された写真から画像データを取り出します
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        // UIImage(data: imageData)を使用して取得した画像データからUIImageオブジェクトを作成します
        if let image = UIImage(data: imageData) {
            // 最後の写真に代入
            self.lastPhoto = image
            // 撮影した写真をフォトライブラリに保存します
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            // 撮影した写真配列に追加
            DispatchQueue.main.async {
                self.photos.append(image)
            }
        }
        
    }
    // 写真の保存完了時に呼ばれるメソッド
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 保存に失敗した場合の処理
            print("Error saving photo: \(error.localizedDescription)")
        } else {
            // 保存に成功した場合の処理
            print("Successfully saved photo to library")
        }
    }
}

// SwiftUIでカメラプレビューを表示するため
struct CameraPreview: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // カメラセッションからの映像を表示するプレビューレイヤーを作成し
        // これをビューコントローラーのビューのレイヤーに追加しています
        // このプレビューレイヤーは、カメラからのリアルタイムの映像フィードを表示
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        // プレビューレイヤーを画面全体に広げます
        previewLayer.frame = UIScreen.main.bounds
        // プレビューがアスペクト比を保持しつつビューの全域を埋めるように内容をリサイズ
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
