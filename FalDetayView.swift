import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct FalDetayView: View {
    var tarih: String
    var userID: String
    var falID: String   

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var kartManager : KartSecViewModel
    @EnvironmentObject var userViewModel : UserViewModel

    @State private var kartlar: [String] = []
    @State private var chatGPTYaniti: String? = nil
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
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
                    VStack {
                        Text("Fal Detayı")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.trailing, 115)
                        
                        Text("Tarih: \(tarih)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.trailing, 125)
                    }
                }

               
                HStack {
                    ForEach(kartlar, id: \.self) { kart in
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 120, height: 180)
                                    .background(Color.gray.opacity(0.9))
                                    .contentShape(Rectangle())

                                Image(kart)
                                    .resizable()
                                    .frame(width: 120, height: 180)
                                    .cornerRadius(5)
                                    .shadow(radius: 3)
                            }

                            Text(kart)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 4)
                        }
                    }
                }
                    .padding()

                    if let yanit = chatGPTYaniti {
                        ScrollView {
                            Text(yanit)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .multilineTextAlignment(.center)
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(10)
                                .padding(.top, 20)
                        }
                    } else {
                        Text("Yanıt yükleniyor...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                
                Spacer()
            }
        }
        .onAppear {
            print(" FalDetayView açıldı.")
              print(" Gelen userID: \(userID)")
              print(" Gelen falID: \(falID)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                fetchFalDetails(userID: userID, falID: falID)
            }
        }
    }

    func fetchFalDetails(userID: String, falID: String) {
        print(" Fal detayları çekiliyor...")
        print(" Gelen userID: \(userID)")
        print(" Gelen falID: \(falID)")

        guard !userID.isEmpty, !falID.isEmpty else {
            print("  ID veya Fal ID boş olamaz!")
            return
        }

        let db = Firestore.firestore()
        let falRef = db.collection("users").document(userID).collection("fals").document(falID)

        falRef.getDocument { document, error in
            if let error = error {
                print("  \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.kartlar = data?["selectedCards"] as? [String] ?? []
                    self.chatGPTYaniti = data?["chatGPTResponse"] as? String
                    self.isLoading = false

                    print(" Fal Kartları: \(self.kartlar)")
                    print(" ChatGPT Yanıtı: \(self.chatGPTYaniti ?? "Yok")")
                }
            } else {
                print(" firestore fal bulunamadı yanli sfal id!")
            }
        }
    }

       
}

#Preview {
    FalDetayView(tarih: "12.12.2024", userID: "testUserID", falID: "testFalID")
        .environmentObject(KartSecViewModel())
}
