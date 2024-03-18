//
//  ContentView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/01/24.
//

import SwiftUI
import AVFoundation
import PhotosUI
import Photos

struct ContentView: View {
    // プロパティが変更されるとビューを自動的に更新
    @ObservedObject private var cameraviewmodel = CameraViewModel()
    
    @State private var showingPhotoLibrary = false
    // スクロールで必要
    // ズームレベルを管理する変数
    @State private var scale: CGFloat = 1.0 // 画像のスケール
    // スライダーの現在値を保持する状態変数
    @State private var sliderValue: Double = 1.0 // スライダーの値
    
    @StateObject private var sharedPhotoData = SharedPhotoData()
    
    var body: some View {
        NavigationView{
            VStack {
                // カメラのビュー
                // trueの場合CameraPreviewビューを表示
                cameraviewmodel.cameraView
                
                Spacer()
                
                VStack{
                    
                    // スクロールボタン
                    HStack{
                        Button(action: {
                            // アクション内でsliderValueを0.1減少させただし、最小値は1.0
                            sliderValue = max(1.0, sliderValue - 0.1)
                            // カメラのズームレベルを更新
                            cameraviewmodel.setZoomLevel(CGFloat(sliderValue))
                        }) {
                            Image(systemName: "minus")
                        }
                        // CameraViewのSliderの見直し
                        // 値の範囲は1からcameraManager.maxZoomFactor()までで
                        // ステップは0.1です。スライダーの値が変更されるたびに
                        // cameraManager.setZoomLevelを呼び出してズームレベルを更新します
                        
                        Slider(value: $sliderValue, in: 1...cameraviewmodel.maxZoomFactor(), step: 0.1) {
                            _ in cameraviewmodel.setZoomLevel(CGFloat(sliderValue))
                        }
                        
                        // ただし、最大値はcameraManager.maxZoomFactor())
                        // cameraManager.setZoomLevelメソッドを
                        // 呼び出してカメラのズームレベルを更新します
                        Button(action: {
                            // 最大ズームファクターをCameraManagerから取得するように変更
                            let maxZoomFactor = cameraviewmodel.maxZoomFactor()
                            sliderValue = min(maxZoomFactor, sliderValue + 0.1)
                            cameraviewmodel.setZoomLevel(CGFloat(sliderValue))
                        }) {
                            Image(systemName: "plus")
                        }
                        
                    }
                    HStack{
                        Spacer()
                        
                        // lastPhotoがある場合にはその画像を表示し、ない場合はデフォルトのアイコンを表示
                        if let image = cameraviewmodel.lastSavedPhoto {
                            NavigationLink(destination: PhotoLibraryView(selectedPhoto: image, fetchedPhotos: cameraviewmodel.fetchedPhotos)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75, height: 75)
                            }
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
                            cameraviewmodel.takePhoto()
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
                            cameraviewmodel.switchCamera()
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
                }
                .frame(height: 160)
                .background(Color.black)
            }
            // 真っ先に実行される
            .onAppear {
                cameraviewmodel.setup()
                cameraviewmodel.loadLastPhoto()
            }
            // 画面から消える直前に実行される
            // 不要にカメラが動作し続けることを防ぐため
            .onDisappear {
                cameraviewmodel.stopSession()
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
class CameraViewModel: NSObject,ObservableObject, AVCapturePhotoCaptureDelegate {
    // private(set)で保護されているので
    // セッションのインスタンスはこのクラス内でのみ変更
    @Published private(set) var isCameraReady = false
    @Published private(set) var session = AVCaptureSession()
    
    @Published private var photoModel = PhotoModel()
    @Published var lastSavedPhoto: UIImage? 
    
    override init() {
        super.init()
        self.lastSavedPhoto = photoModel.lastSavedPhoto
        
    }
    
    // 写真を撮影するための出力
    private let photoOutput = AVCapturePhotoOutput()
    
    // カメラデバイスへの参照を保持する
    private var cameraDevice: AVCaptureDevice?
    //
    var audioPlayer: AVAudioPlayer?
    
    // 無音の音
    var soundPlayer = SoundPlayer()
    
    @Published var fetchedPhotos: [PHAsset] = []
    
    
    
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
        self.cameraDevice = camera
        
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
    
    // ズームレベル
    func setZoomLevel(_ zoomFactor: CGFloat) {
        // カメラにデバイスがない場合は中止
        guard let device = cameraDevice else {
            print("Cansel")
            return
        }
        do {
            // カメラの設定変更のためのロック
            try device.lockForConfiguration()
            // デバイスがサポートする最大ズームファクターと5.0のうち、小さい方をmaxZoomFactorとして計算
            let maxZoomFactor = min(device.activeFormat.videoMaxZoomFactor, 5.0)
            // 指定されたzoomFactorが1.0以上かつデバイスがサポートする最大ズームファクター以下になるように調整し、newZoomFactorに設定します
            let newZoomFactor = min(max(zoomFactor, 1.0), maxZoomFactor)
            
            device.videoZoomFactor = newZoomFactor
            // カメラデバイスの設定変更後にロックを解除
            device.unlockForConfiguration()
        } catch {
            print("ズームレベルの設定中にエラーが発生しました: \(error)")
        }
    }
    
    // CameraManagerのmaxZoomFactorメソッドの見直し
    // 最大ズームファクターを取得するために使用
    func maxZoomFactor() -> CGFloat {
        // cameraDeviceが存在するかどうかをチェック
        guard let camera = cameraDevice else {
            return 5.0 // カメラデバイスが利用不可能な場合のデフォルト値
        }
        // デバイスがサポートする最大ズームファクターと5.0のうち、小さい方を返す
        return min(camera.activeFormat.videoMaxZoomFactor, 5.0)
    }
    
    // 写真を撮影する
    // 写真を無音で実装
    func takePhoto() {
        // 撮影する写真に関する特定の設定（例えばフラッシュの使用、HDRの有効化など）を指定
        let settings = AVCapturePhotoSettings()
        // 設定したsettingsを使用して写真を撮影
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        
    }
    
    // 写真が撮影され、処理が完了すると呼び出されます
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto,error: Error?) {
        // 撮影された写真から画像データを取り出します
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        // UIImage(data: imageData)を使用して取得した画像データからUIImageオブジェクトを作成します
        if let image = UIImage(data: imageData) {
            photoModel.saveImageToPhotoLibrary(image: image)
        } else {
            print("失敗しました")
        }
    }
    func loadLastPhoto() {
        photoModel.loadLastSavedPhoto { [weak self] image in
            DispatchQueue.main.async {
                self?.lastSavedPhoto = image
            }
        }
    }
    // カメラの設定の準備
    var cameraView: AnyView {
        if isCameraReady {
            return AnyView(CameraPreview(session: session).edgesIgnoringSafeArea(.all))
        } else {
            return AnyView(Color.black.ignoresSafeArea(.all))
        }
    }
}

// 写真のデータ
class PhotoModel{
    // 最後の写真を表示するための値
    var lastPhoto: UIImage?
    // 今まで撮った写真をまとめて表示させるため
    var photos: [UIImage] = []
    // 最新の撮影写真のPHAsset
    var lastAsset: PHAsset?
    // ラストイメージ
    var lastSavedPhoto: UIImage?
    
    var fetchedPhotos: [PHAsset] = []
    
    // 写真をフォトライブラリに保存した後に呼び出されるコールバックメソッド
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 保存に失敗した場合の処理
            print("Error saving photo: \(error.localizedDescription)")
        } else {
            // 保存に成功した場合の処理
            print("Successfully saved photo to library")
            // 必要に応じて、ここでViewModelの更新メソッドを呼び出す
        }
    }
    
    func saveImageToPhotoLibrary(image: UIImage?) {
        guard let image = image else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    // 画像の保存に成功したら、最新の写真をロード
                    self?.loadLastSavedPhoto { newImage in
                        // ここでロードされた画像を使って具体的な処理を行う
                        // 例: UIの更新や、画像を使用した後続の処理
                        DispatchQueue.main.async {
                            if let loadedImage = newImage {
                                print("ロードされる前の lastSavedPhoto: \(String(describing: self?.lastSavedPhoto))")
                                print("ロードされた画像: \(loadedImage), サイズ: \(loadedImage.size)")
                                self?.lastSavedPhoto = loadedImage
                                print("ロードされた後の lastSavedPhoto: \(String(describing: self?.lastSavedPhoto))")
                            }

                        }
                    }
                } else {
                    // エラーハンドリングをここに記述
                    print("Error saving photo to library: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }


    

    func loadLastSavedPhoto(completion: @escaping (UIImage?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let lastAsset = fetchResult.firstObject else {
            completion(nil) // 画像が見つからない場合は nil を返します。
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true // iCloudから画像をダウンロードすることを許可します。
        
        let manager = PHImageManager.default()
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        manager.requestImage(for: lastAsset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
            DispatchQueue.main.async {
                if let isDegraded = info?[PHImageResultIsDegradedKey as NSString] as? Bool, isDegraded {
                    // Degraded imageは無視します。
                    return
                }
                
                if let error = info?[PHImageErrorKey as NSString] as? Error {
                    print("Error loading image: \(error)")
                    completion(nil) // エラーが発生した場合は nil を返します。
                    return
                }
                print("こんにちわ")
                completion(image) // 成功した場合は画像をコールバック経由で返します。
            }
        }
    }
}

class SharedPhotoData: ObservableObject {
    @Published var lastAsset: PHAsset?
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
