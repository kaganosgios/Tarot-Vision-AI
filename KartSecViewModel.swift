//
//  KartSecViewModel.swift
//  tarotApp
//
//  Created by KağanKAPLAN on 6.02.2025.
//


import Foundation

class KartSecViewModel: ObservableObject {
    @Published var selectedCategory: String = "Genel"
    @Published var placedCards: [String: String] = ["Geçmiş": "", "Şimdiki": "", "Gelecek": ""]
    @Published var draggedCard: String? = nil
    let categories = ["Geçmiş", "Günümüz", "Gelecek"]
    let categoriesForTopic = ["Aşk", "Kariyer", "Genel"]
    let cardBackImage = "scrollcard"
    let totalCards = 70

    func resetCards() {
           self.placedCards = ["Geçmiş": "", "Şimdiki": "", "Gelecek": ""]
       }
}
