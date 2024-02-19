//
//  SoundPlayer.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/14.
//

import UIKit
import AVFoundation

class SoundPlayer: NSObject {
    // カメラの音データ
    let cameraData = NSDataAsset(name: "photoShutter2")!.data
    
    // カメラ用プレイヤーの変数
    var cameraPlayer: AVAudioPlayer!
    
    func cameraPlay(){
        do{
            // カメラ用のプレイヤーに音声データーを指定
            cameraPlayer = try AVAudioPlayer(data: cameraData)
            print("再生")
            // 音声再生
            cameraPlayer.play()
            
        } catch {
            print("photoShutter2でエラーが発生しました")
        }
    }
}
