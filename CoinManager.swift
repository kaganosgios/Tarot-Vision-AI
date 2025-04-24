import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CoinManager: ObservableObject {
    @Published var coin: Int = 0  
    private let db = Firestore.firestore()
    
    init() {
        fetchCoins()
    }

    func fetchCoins() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("  giriş yapmamış coin bilgisi alınamıyor")
            return
        }

        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("coin bilgisi alınamadı: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data(), let fetchedCoin = data["coin"] as? Int {
                DispatchQueue.main.async {
                    self.coin = fetchedCoin
                    print("çekilen coin miktarı: \(self.coin)")
                }
            } else {
                print(" varsayılan olarak 10 atanıyor.")
                self.setInitialCoins()
            }
        }
    }

    func setInitialCoins() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userID).setData(["coin": 10], merge: true) { error in
            if let error = error {
                print(" Coin başlatılırken hata oluştu: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.coin = 10
                    print(" Kullanıcı için 10 coin başlatıldı.")
                }
            }
        }
    }

    func spendCoins(amount: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        if coin >= amount {
            let newCoin = coin - amount

            db.collection("users").document(userID).updateData(["coin": newCoin]) { error in
                if let error = error {
                    print(" Coin harcarken hata oluştu: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.coin = newCoin
                        print(" \(amount) coin harcandı. Yeni bakiye: \(self.coin)")
                    }
                }
            }
        } else {
            print(" Yetersiz coin!")
        }
    }

    func addCoins(amount: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let newCoin = coin + amount

        db.collection("users").document(userID).updateData(["coin": newCoin]) { error in
            if let error = error {
                print(" Coin eklerken hata oluştu: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.coin = newCoin
                    print(" \(amount) coin eklendi. Yeni bakiye: \(self.coin)")
                }
            }
        }
    }
}
