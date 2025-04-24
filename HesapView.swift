import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct HesapView: View {
    @EnvironmentObject var coinManager: CoinManager
    @State private var navigateToCoinView = false 
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)

                VStack{
                    HStack {
                        Spacer()
                        
                        HStack {
                            NavigationLink(destination: CoinView(), isActive: $navigateToCoinView) {
                                EmptyView()
                            }
                            .hidden()
                                   
                            Button {
                                navigateToCoinView = true
                            } label: {
                                Text("\(coinManager.coin)")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 18)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.yellow)
                                    .frame(width: 20, height: 18)
                            }
                        }
                        .padding()
                        .frame(width: 80, height: 55)
                        .background(Color.gray.opacity(0.4))
                        .clipShape(Capsule())
                        .padding(.leading, 40)
                        .padding(.trailing, 9)
                    }
                    
                    Image("ppfortune")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 170)
                        .clipShape(.circle)
                    
                    Text("Fallar, bilinmeze açılan küçük bir penceredir; kimi zaman umut, kimi zaman merak getirir. Geleceği bilmek imkânsız olsa da, bir fal bazen kalbe fısıldayan bir teselli olabilir. Gerçek mi değil mi bilinmez, ama insan her zaman güzel bir haber duymak ister.")
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 45)
                        .padding(.horizontal, 15)
                        
                    Spacer()
                    
                    
                    
                    Button {
                        // firebase çıış yapma fonksiyonu
                        isLoggedIn = false
                        signOutUser()
                    } label: {
                        Text("Çıkış Yap")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                            .padding(.bottom, 25)
                    }
                    
                    VStack{
                      
                        
                 
                        Button {
                           deleteAccount()
                            isLoggedIn = false
                        } label: {
                            Text("X")
                                .frame(width: 20)
                                .font(.title2)
                                
                                .foregroundColor(.white)
                               
                                .background(Color.purple)
                                .clipShape(Capsule())
                                .shadow(radius: 3)
                                .padding(.bottom, 15)
                            
                        }
                        Text("HESABI KALICI SİLMEK İÇİN \("X") BAS")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                    }

                }
            }
            .navigationBarHidden(true)
            .onAppear {
                coinManager.fetchCoins()
            }
        }
    }
  


    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        
        let db = Firestore.firestore()
        
        let falsRef = db.collection("users").document(userId).collection("fals")
        deleteCollection(reference: falsRef) {
            
            let personsRef = db.collection("users").document(userId).collection("persons")
            deleteCollection(reference: personsRef) {
                
                db.collection("users").document(userId).delete { error in
                    if let error = error {
                        print(" kullanıcı verileri silinemedi: \(error.localizedDescription)")
                    } else {
                        print("kullanıcı verileri silindi")
                        
                        user.delete { error in
                            if let error = error {
                                print(" hesap silme hattasi: \(error.localizedDescription)")
                            } else {
                                print(" hesap silindi")
                                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            }
                        }
                    }
                }
            }
        }
    }

    func deleteCollection(reference: CollectionReference, completion: @escaping () -> Void) {
        reference.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("alt kolkslyon olamadı: \(error?.localizedDescription ?? " hata")")
                completion()
                return
            }
            
            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                document.reference.delete { error in
                    if let error = error {
                        print("belge silnemedi: \(error.localizedDescription)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }

    func signOutUser() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            print("  başarıyla çıkış yaptı!")
        } catch let signOutError as NSError {
            print("  hata oluştu: \(signOutError.localizedDescription)")
        }
    }
}

#Preview {
    HesapView()
        .environmentObject(CoinManager())
}
