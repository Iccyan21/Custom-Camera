//
//  UIImageExtension.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/20.
//

import Foundation
import UIKit

extension UIImage {
    func resized() -> UIImage? {
        // リザイズの比率の計算
        let rate = 1024.0 / self.size.width
        // リサイズ後の画像サイズを計算
        let targetSize = CGSize(width: self.size.width * rate, height: self.size.height * rate)
        
        // 新しいサイズ基づいて画像レンダラーを作成
        let randerer = UIGraphicsImageRenderer(size: targetSize)
        
        // 新しいサイズに基づいて元の画像を壁画
        return randerer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
