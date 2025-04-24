//
//  KisiSecView.swift
//  tarotApp
//
//  Created by KağanKAPLAN on 1.02.2025.
//

import SwiftUI

struct KisiSecView: View {
    @State private var showKayitliKisiler = false
       @State private var showYeniKisiEkle = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView{
            ZStack {
                Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)

                VStack{
                    HStack{

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Capsule())
                            
                            
                        }
                        .padding()
                        
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        NavigationLink(destination: KayitliKisiler().navigationBarBackButtonHidden(true), isActive: $showKayitliKisiler) {
                            Text("Kayıtlı kişilerimden seç")
                                .foregroundColor(.green)
                                .font(.system(size: 14, weight: .bold))
                                .padding()
                                .frame(maxWidth: 180, maxHeight: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 4)
                                ).onTapGesture {
                                    showKayitliKisiler = true
                                }
                        }
                        
                        
                        
                        NavigationLink(destination: YeniEkle().navigationBarBackButtonHidden(true), isActive: $showYeniKisiEkle) {
                            Text("Yeni kişi ekle")
                            
                                .foregroundColor(.purple)
                                .font(.system(size: 14, weight: .bold))
                                .padding()
                                .frame(maxWidth: 180, maxHeight: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.purple, lineWidth: 4)
                                ).onTapGesture {
                                    showYeniKisiEkle = true
                                }
                        }
                       
                        
                        
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    KisiSecView()
}
