//
//  PhotoLIbraryView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/08.
//

import SwiftUI

struct PhotoLibraryView: View {
    @ObservedObject var cameraManager: CameraManager
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cameraManager.photos.indices, id: \.self) { index in
                    Image(uiImage: cameraManager.photos[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(5)
                }
            }
            .padding()
        }
    }
}
