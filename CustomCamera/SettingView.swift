//
//  SettingView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/08.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack{
            Text("設定")
                .font(.largeTitle)
                .padding()
            
            HStack{
                NavigationLink(destination: Text("広告削除")) {
                    Text("広告削除")
                    Spacer()
                    Text("＞")
                }
                
                
            }
            .padding()
            .padding(.horizontal, 10)
            
            VStack{
                HStack{
                    Text("アプリ情報")
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack{
                    NavigationLink(destination: Text("ご意見・ご要望など")) {
                        Text("ご意見・ご要望など")
                        
                        Spacer()
                        Text("＞")
                        
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                HStack{
                    NavigationLink(destination: Text("レビューを書く")) {
                        Text("レビューを書く")
                        
                        Spacer()
                        Text("＞")
                        
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                HStack{
                    NavigationLink(destination: Text("利用規約")) {
                        Text("利用規約")
                     
                    
                        Spacer()
                        Text("＞")
       
                    }
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                 
                
                
                HStack{
                    NavigationLink(destination: Text("プライバシーポリシー")) {
                        Text("プライバシーポリシー")
                      
                       
                        Spacer()
                        Text("＞")
                   
                    }
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
               
                
            }
            .padding(.top)
            .padding(.horizontal, 30)
            Spacer()
        }
    }
}

#Preview {
    SettingView()
}
