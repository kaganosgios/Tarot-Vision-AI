//
//  ContentView.swift
//  tarotApp
//
//  Created by KağanKAPLAN on 11.01.2025.
//

import SwiftUI
struct Fal: Identifiable {
    let id = UUID()
    let kisi: Kisi
    let kategori: FalKategori
    let tarih: Date
    let kartlar: [String]
    var yorum: String?
    var yorumGeldi: Bool
}

struct Kisi: Identifiable {
    let id = UUID()
    let ad: String
    let soyad: String
    let dogumTarihi: Date
    let yas: Int
    let meslek: String
}

enum FalKategori: String, CaseIterable {
    case ask = "Aşk"
    case kariyer = "Kariyer"
    case genel = "Genel"
}

struct ContentView: View {
    init() {
           let appearance = UITabBarAppearance()
           appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.gray
           appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
           appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
           appearance.stackedLayoutAppearance.selected.iconColor = UIColor.yellow
           appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.yellow] 
           
           UITabBar.appearance().standardAppearance = appearance
           UITabBar.appearance().scrollEdgeAppearance = appearance
       }
    
    @State private var fallar: [Fal] = []

    var body: some View {
        
            TabView {
                AnaEkran()
                    .tabItem{
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("Fallarım")
                            .foregroundColor(.white)

                    }
                
                HesapView()
                    .tabItem{
                        Image(systemName: "person")
                            .foregroundColor(.yellow)

                        Text("Hesabım")
                            .foregroundColor(.white)

                    }
            }
           
        
    }
}

#Preview {
    ContentView()
}
