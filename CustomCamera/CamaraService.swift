//
//  CamaraService.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/01/24.
//

import Foundation
import AVFoundation


class CamaraService {
    
    // カメラやオーディオのキャプチャセッションを管理するために使用
    // ?がついているので、このプロパティはnilも許容
    var session: AVCaptureSession?
    // 写真撮影のプロセス中に発生するさまざまなイベントを処理するために使用
    var delegate: AVCapturePhotoCaptureDelegate?
    // 写真撮影のための出力として機能
    let output = AVCapturePhotoOutput()
    // カメラが現在捉えているものをリアルタイムで表示
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping)
}
