//
//  SettingView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/08.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
            VStack{
                HStack{
                    NavigationLink(destination: Text("広告削除")) {
                        Text("広告削除")
                            .foregroundColor(.black)
                        Spacer()
                        Text("＞")
                            .foregroundColor(.black)
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
                        Button(action: {
                            // ここにメーラーを起動するコードを書く
                            let email = "ashitagogo123@gmail.com" // 送信先のメールアドレス
                            let subject = "ご意見・ご要望" // メールの件名
                            let body = "ご意見・ご要望など、お気軽にお寄せください。" // メールの本文
                            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            let mailtoURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)")!
                            openURL(mailtoURL)
                        }, label: {
                            Text("ご意見・ご要望など")
                                .foregroundColor(.black)
                            
                            Spacer()
                            Text("＞")
                                .foregroundColor(.black)
                        })
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    HStack{
                        NavigationLink(destination: Text("レビューを書く")) {
                            Text("レビューを書く")
                                .foregroundColor(.black)
                            
                            Spacer()
                            Text("＞")
                                .foregroundColor(.black)
                            
                        }
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    HStack{
                        NavigationLink(destination: TermsView()) {
                            Text("利用規約")
                                .foregroundColor(.black)
                            
                            
                            Spacer()
                            Text("＞")
                                .foregroundColor(.black)
                            
                        }
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    
                    
                    HStack{
                        NavigationLink(destination:  PrivacyPolicyView()) {
                            Text("プライバシーポリシー")
                                .foregroundColor(.black)
                            Spacer()
                            Text("＞")
                                .foregroundColor(.black)
                            
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
            .navigationBarTitle("設定",displayMode: .inline)
        
    }
}

#Preview {
    SettingView()
}
