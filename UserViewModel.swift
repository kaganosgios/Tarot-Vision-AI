import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var currentUserID: String?


  

    func fetchUsers() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print(" firstrpeden çekilmez.")
            return
        }

        let db = Firestore.firestore()
        let personsRef = db.collection("users").document(userID).collection("persons")

        print(" cekiyoz..")

        personsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(" cekerken hata oldu DİKKAT ET BURAYA \(error.localizedDescription)")
                return
            }

            print(" kisi verileri gelid!")

            DispatchQueue.main.async {
                self.users = snapshot?.documents.compactMap { document -> User? in
                    let data = document.data()
                    print("kisi verisi: \(data)")

                    return User(
                        id: document.documentID,
                        name: data["name"] as? String ?? "Bilinmiyor",
                        surname: data["surname"] as? String ?? "Bilinmiyor",
                        birthDate: (data["birthDate"] as? Timestamp)?.dateValue() ?? Date(),
                        iliskiDurumu: data["iliskiDurumu"] as? String ?? "Bilinmiyor",
                        job: data["job"] as? String ?? "Bilinmiyor",
                        gender: data["gender"] as? String ?? "Bilinmiyor"
                    )
                } ?? []

                print(" kayitli kis  isayisi su akdar::: \(self.users.count)")
            }
        }
    }
    


    func fetchCurrentUserID() {
        guard let user = Auth.auth().currentUser else {
            print(" oturum yok currentuserdi alamadık")
            return
        }

        DispatchQueue.main.async {
            self.currentUserID = user.uid
            print(" kullanıcı id \(self.currentUserID!)")
        }
    }
}

struct User: Identifiable {
    let id: String
    let name: String
    let surname: String
    let birthDate: Date
    let iliskiDurumu: String
    let job: String
    let gender: String
}
