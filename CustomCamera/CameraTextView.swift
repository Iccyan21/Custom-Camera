//
//  CameraTextView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/03.
//

import SwiftUI
import AVFoundation

struct CameraTextView: View {
    var body: some View {
        // カメラのViewを呼び出す
        CameraView()
    }
}

#Preview {
    CameraTextView()
}

struct CameraView: View {
    @ObservedObject var camera = CameraModel()
    var body: some View {
        ZStack{
            // カメラのViewを表示
            CameraPreview_Sub(camera: camera)
                .ignoresSafeArea()
            
            VStack{
                if camera.isTaken {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            camera.reTake()
                        },label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding()
                    }
                }
                // 上に空白のスペース
                Spacer()
                
                HStack {
                    // もし写真のボタンが押されたら
                    // 保存ボタンが表示される
                    if camera.isTaken {
                        Button(action: {
                            if !camera.isSaved{camera.savePic()}
                        }, label: {
                            
                            Text(camera.isSaved ? "保存しました":"保存")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical,10)
                                .padding(.horizontal,20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading)
                        
                        Spacer()
                        
                    } else {
                        Button(action: camera.takePic, label: {
                            // 撮影ボタンのデザイン
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
                    }
                }
                .frame(height: 75)
            }
        }
        // SwiftUIビューが画面に表示された直後にコードを実行
        // すぐカメラが使えるかチェック
        .onAppear{
            camera.Check()
        }
    }
}

// カメラモデル
class CameraModel: NSObject,ObservableObject,AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    // 撮影した写真の出力を管理するAVzCapturePhotoOutputインスタンスを作成し
    // 公開するためのプロパティです。
    var output = AVCapturePhotoOutput()
    
    // カメラセッションの出力を表示する
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // 写真を保存する
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    // カメラのアクセス許可の状態を確認
    // 呼び出して、アプリがビデオ（カメラ）の使用に関してどのような
    // 認証ステータスを持っているかをチェック
    func Check(){
        // .videoタイプのメディアに対するアクセス許可の状態を返します
        switch AVCaptureDevice.authorizationStatus(for: .video){
            // すでに許可が与えられている場合
            // setUp関数が呼び出されセットアップ処理が完了
            // .authorizedはユーザーがアプリにカメラへのアクセスを
            // 許可していることを意味
        case .authorized:
            setUp()
            return
            // このアプリのカメラアクセス許可を承認または拒否していない状態
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){ (status) in
                if status {
                    self.setUp()
                }
            }
            // 拒否された場合アラートを表示
        case .denied:
            self.alert.toggle()
            return
            // 許可してない場合はそのまま返す
        default:
            return
        }
    }
    
    func setUp(){
        do {
            print("セットアップ開始")
            // カメラの設定を開始
            self.session.beginConfiguration()
            // ここで一度詰まった
            //  デバイス上で利用可能なデフォルトのカメラを選択
            // 本当のところは.builtInDualCamera　だけど搭載されてないため
            // builtInWideAngleCameraに変更
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            // 選択したカメラデバイスを使用して、カメラの入力を作成
            let input = try AVCaptureDeviceInput(device: device!)
            // セッションに入力を追加できるかどうかをチェックします
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            // アウトプット
            // この出力は、撮影した写真を処理するために使用されます
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            // セッションの設定変更をコミットし、変更を適用
            self.session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
            
        }
    }
    // 写真を撮影するためのコード
    func takePic() {
        // 写真の撮影処理をバックグラウンドスレッドで非同期に実行
        DispatchQueue.global(qos: .background).async {
            // カメラで写真を撮影するためのメインの命令
            // self.outputはAVCapturePhotoOutputのインスタンスで
            // 写真撮影の機能を提供
            // ここで写真を撮影！！
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            
            // カメラのセッションを停止
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation{
                    self.isTaken.toggle()
                }
            }
        }
    }
    // 再撮影
    func reTake() {
        DispatchQueue.global(qos: .background).async {
            print("もう一度開始します")
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{
                    self.isTaken.toggle()
                    
                    self.isSaved = false
                }
            }
        }
    }
    // 写真の処理が終了した後に呼び出されます
    // 写真撮影のリクエストが行われた出力です
    // 撮影された写真のデータを含みます
    // このオブジェクトからJPEGなどのフォーマットで写真データを取得
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // エラーがある場合は、撮影に失敗したとみなす
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            print("こんにちわ")
            return
        }
        
        // 撮影した写真のデータを取得
        guard let imageData = photo.fileDataRepresentation() else {
            print("Could not get image data.")
            return
        }
        
        print("pic token...")
        
        
        
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        
        print(imageData)
        print("こんちゃ")
        
        // 取得した写真データ（imageData）をクラスのプロパティ
        // (picData)に保存
        self.picData = imageData
        
    }
    func savePic(){
        // picDataプロパティに保存された写真データ
        // からUIImageオブジェクトを生成
        print(self.picData)
        let image = UIImage(data: self.picData)!
        
        // 生成したUIImageオブジェクトをデバイスのフォトライブラリに保存
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        // 写真が正常に保存されたことを示すフラグ（isSaved）をtrueに設定
        self.isSaved = true
        
        print("saved Successfully ... ")
        
    }
}
// iOSのカメラプレビューをSwiftUIビュー内に組み込むための橋渡し役をする
// 既存のUIKitベースのコンポーネントやカスタムUIViewを直接使用するためのビルトイン
// UIViewRepresentableプロトコルを実装
struct CameraPreview_Sub: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModel
    // SwiftUIがこのカスタムビューを描画する際に
    // 実際のUIViewインスタンスを生成するために呼び出されます
    func makeUIView(context: Context) -> UIView {
        // デバイスのスクリーン全体を覆うUIViewを生成
        let view = UIView(frame: UIScreen.main.bounds)
        // カメラセッションからのリアルタイムビデオフィードを表示し
        // カメラの視点からの映像をユーザーに提供
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        // プレビューレイヤーのサイズをコンテナUIViewのサイズに合わせて調整
        camera.preview.frame = view.frame
        // プレビューレイヤー内でビデオコンテンツがどのように表示されるかを決定
        camera.preview.videoGravity = .resizeAspectFill
        // プレビューレイヤーをビューのレイヤー階層に追加します
        // これが実際にカメラの映像をビュー上に表示
        view.layer.addSublayer(camera.preview)
        
        DispatchQueue.global(qos: .background).async {
            self.camera.session.startRunning()
        }
        return view
    }
    // 対応するUIViewの状態を更新する必要がある場合に呼び出されます
    // レビューを表示するカメラデバイスを変更するなど
    // ビューの更新が必要な場合にこのメソッド内で処理
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

