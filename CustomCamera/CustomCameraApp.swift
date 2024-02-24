//
//  CustomCameraApp.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/01/24.
//

import SwiftUI

@main
struct CustomCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PhotoManager()) // PhotoManagerを環境オブジェクトとして注入
        }
    }
}
