//
//  SuccessCumera.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/05.
//

import SwiftUI
import UIKit
import Combine
import AVFoundation

struct SuccessView: View {
    @ObservedObject private var avFoundationVM = AVFoundationVM()
    
    var body: some View {
        VStack {
            if avFoundationVM.image == nil {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    CALayerView(caLayer: avFoundationVM.previewLayer)
                    
                    Button(action: {
                        self.avFoundationVM.takePhoto()
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                    }
                    .padding(.bottom, 100.0)
                }.onAppear {
                    self.avFoundationVM.startSession()
                }.onDisappear {
                    self.avFoundationVM.endSession()
                }
                
                Spacer()
            } else {
                ZStack(alignment: .topLeading) {
                    VStack {
                        Spacer()
                        
                        Image(uiImage: avFoundationVM.image!)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                        
                        Spacer()
                    }
                    Button(action: {
                        self.avFoundationVM.image = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(.white)
                            .background(Color.gray)
                    }
                    .frame(width: 80, height: 80, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

class AVFoundationVM: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    ///撮影した画像
    @Published var image: UIImage?
    ///プレビュー用レイヤー
    var previewLayer:CALayer!
    
    ///撮影開始フラグ
    private var _takePhoto:Bool = false
    ///セッション
    private let captureSession = AVCaptureSession()
    ///撮影デバイス
    private var capturepDevice:AVCaptureDevice!
    
    override init() {
        super.init()
        
        prepareCamera()
        beginSession()
    }
    
    func takePhoto() {
        _takePhoto = true
    }
    
    private func prepareCamera() {
        captureSession.sessionPreset = .photo
        
        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first {
            capturepDevice = availableDevice
        }
    }
    
    private func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: capturepDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "FromF.github.com.AVFoundationSwiftUI.AVFoundation")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    func startSession() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }
    
    func endSession() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if _takePhoto {
            _takePhoto = false
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
    
    private func getImageFromSampleBuffer (buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        
        return nil
    }
}

struct CALayerView: UIViewControllerRepresentable {
    var caLayer:CALayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
        let viewController = UIViewController()
        
        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}

