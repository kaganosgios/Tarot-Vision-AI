import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct AnaEkran: View {
    @EnvironmentObject var coinManager: CoinManager

    @EnvironmentObject var falManager: FalManager
    @EnvironmentObject var viewmodel : UserViewModel
    @State private var kisiSecViewGorunurMu = false
    @State private var secilenFal: String?
    @State private var fullScreenAcik = false
    @State private var fallar: [String] = []
    @State private var navigateToCoinView = false 

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination:
                                CoinView()
                                    .navigationBarBackButtonHidden(false)
                            ) {
                                
                                HStack {
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
                                .padding()
                                .frame(width: 80, height: 55)
                                .background(Color.gray.opacity(0.4))
                                .clipShape(Capsule())
                                
                                
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Fallarım")
                            .font(.system(size: 50))
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .padding(.bottom,6)
                        
                        Text("Gönderdiğiniz fallar 3 dakika içersinde ana ekranınızda görünür ayrıca istemediğiniz falları sola kaydırarak silebileceğinizi de unutmayın...")
                            .frame(width: 250, height: 25)
                            .font(.system(size: 6))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            
                        
                    }
                    
                    if #available(iOS 16.0, *) {
                        List(fallar, id: \.self) { fal in
                            Text("\(fal) - Tarihli Falınız")
                                .foregroundColor(.white)
                                .padding()
                                .listRowBackground(Color.gray.opacity(0.6))
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        print(" Fal seçildi: \(fal)")
                                        falManager.secilenFal = fal
                                        fullScreenAcik = true
                                        print(" fullScreenAcik: \(fullScreenAcik)")
                                    }
                                } .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteFal(tarih: fal)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(height: 400)
                    } else {
                      
                    }
                    
                    Spacer()
                    
                    HStack {
                        
                        
                        Text("Yeni bir tarot bakmak ister misin?")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        
                        NavigationLink(destination: KisiSecView().navigationBarBackButtonHidden(true), isActive: $kisiSecViewGorunurMu) {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 55, height: 55)
                                .clipShape(.circle)
                                .shadow(radius: 5)
                                .foregroundColor(.yellow)
                              
                        }
                        
                        
                        
                      
                    }
                    .padding(.all, 15)
                }
            }
            .onAppear {
                print("🔍 AnaEkran açıldı. Kullanıcı ID kontrol ediliyor...")
                viewmodel.fetchCurrentUserID()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let userID = viewmodel.currentUserID {
                        print(" Kullanıcı ID bulundu: \(userID)")
                        fetchFallarFromFirestore()
                    } else {
                        print(" Kullanıcı ID hala çekilemedi, tekrar dene!")
                    }
                }
            }
            .fullScreenCover(isPresented: $fullScreenAcik) {
                if let secilenFal = falManager.secilenFal,
                   let userID = viewmodel.currentUserID,
                   let falID = falManager.falList[secilenFal] {
                    FalDetayView(tarih: secilenFal, userID: userID, falID: falID)
                } else {
                    Text("Fal yüklenemedi, lütfen tekrar deneyin!")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func fetchFallarFromFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print(" Kullanıcı ID bulunamadı!")
            return
        }

        let db = Firestore.firestore()
        let falsRef = db.collection("users").document(userID).collection("fals")

        falsRef.order(by: "date", descending: true).addSnapshotListener() { (snapshot, error) in
            if let error = error {
                print(" Firestore Hata: \(error.localizedDescription)")
                return
            }

            print(" Firestore'dan gelen fal sayısı: \(snapshot?.documents.count ?? 0)")

            DispatchQueue.main.async {
                self.fallar = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let falID = document.documentID

                    print(" Firestore'dan gelen döküman: \(data)")

                    if let timestamp = data["date"] as? Timestamp {
                        let date = timestamp.dateValue()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy HH:mm"
                        let formattedDate = formatter.string(from: date)

                        print(" Fal bulundu: Tarih: \(formattedDate) → Fal ID: \(falID)")

                        falManager.falList[formattedDate] = falID
                        return formattedDate
                    } else {
                        print(" HATA: 'date' alanı bulunamadı veya format yanlış!")
                        return nil
                    }
                } ?? []

                print(" Firestore'dan \(self.fallar.count) fal çekildi!")
                print(" Güncel fal listesi: \(falManager.falList)")
            }
        }
    }
    func deleteFal(tarih: String) {
        if let falID = falManager.falList[tarih],
           let userID = viewmodel.currentUserID {
            
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(userID).collection("fals").document(falID)
            
            docRef.delete { error in
                if let error = error {
                    print(" Firestore silme hatası: \(error.localizedDescription)")
                } else {
                    print(" Fal silindi: \(falID)")
                    
                    DispatchQueue.main.async {
                        falManager.falList.removeValue(forKey: tarih)
                        fallar.removeAll { $0 == tarih }
                    }
                }
            }
        } else {
            print("❌ Fal ID bulunamadı!")
        }
    }
}
   #Preview {
       AnaEkran()
          .environmentObject(CoinManager())
          .environmentObject(FalManager())
          .environmentObject(UserViewModel())

  }
