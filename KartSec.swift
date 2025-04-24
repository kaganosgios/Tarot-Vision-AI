import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct KartSec: View {
    var selectedPerson: String = ""
    @State private var showingAlert2 = false
    @State private var alertMessage2 = ""

    @State private var selectedCategory: String? = "Genel"
    @State private var placedCards: [String: String] = ["Geçmiş": "", "Şimdiki": "", "Gelecek": ""]
    @State private var selectedPersonData: User? = nil
      @State private var selectedCards: [String] = []
    @State private var draggedCard: String? = nil
    @State private var isCoinViewacikMi : Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var showAlert: Bool = false
    @State private var isLoading2 = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isAlertPresented = false

        @State private var alertMessage: String = ""
    @State private var navigateToRoot : Bool = false
    @EnvironmentObject var rewardedAdManager: RewardedAdManager

    var selectedPersonID: String  // Firestore’daki kullanıcının ID’si
    @EnvironmentObject var kartSecViewModel: KartSecViewModel
    @EnvironmentObject var coinManager: CoinManager

   //
    //let categories = ["Geçmiş", "Günümüz", "Gelecek"] manager olmadan yaptıgım preview için örnekler
    //let categoriesForTopic = ["Aşk", "Kariyer", "Genel"]
    
    let assetImageNames = [
    "2cups","2pent","2swords","2wands","3cups","3pent","3swords","3wands","4cups","4pent","4swords","4wands","5cups","5pent","5swords","5wands","6cups","6pent","6swords","6wands","7cups","7pent","7swords","7wands","8cups","8pent","8swords","8wands","9cups","9pent","9swords","9wands","10cups","10pent","10swords","10wands","acecups","acepent","aceswords","acewands","chariot","death","devil","emperor","empress","fool","hangedman","heirophant","hermit","highpriestess","judgment","justice","kingcups","kingpent","kingswords","kingwands","knightcups","knightpent","knightwands","lovers","magician","moon","pagecups","pageswords","pagewands","queencups","queenpent","queenswords","queenwands","star","strength","sun","temperance","tower","wheeloffortune","world"
    ]
    
    
    
    
    let cardBackImage = "scrollcard"
    let totalCards = 70

    var body: some View {
        ZStack {
            
            
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            VStack {
                
                HStack {
                    
                    
                    
                        Button(action: {
                            dismiss()
                            kartSecViewModel.resetCards()

                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding(.trailing,20)
                        .padding(.horizontal)
                        
                      
                   
                  
                    Text("Falınızın konusunu seçiniz:")
                        .font(.system(size: 9 ))
                        
                        
                        .padding(.top,15)
                        .foregroundColor(.white)
                    
                    HStack {
                      
                        
                        Button {
                            isLoading2 = true
                            
                            if rewardedAdManager.isRewardedAdReady {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    rewardedAdManager.showRewardedAd { didEarnReward in
                                        isLoading2 = false
                                        if didEarnReward {
                                            coinManager.addCoins(amount: 15)
                                            alertMessage2 = "Tebrikler! 15 yıldız kazandınız!"
                                            showingAlert2 = true
                                        } else {
                                            alertMessage = "Reklam gösterilirken bir hata oluştu. Lütfen tekrar deneyin."
                                            showingAlert2 = true
                                        }
                                    }
                                }
                            } else {
                                alertMessage2 = "Reklam yükleniyor. Lütfen biraz bekleyin."
                                showingAlert2 = true
                                rewardedAdManager.loadRewardedAd()
                                isLoading2 = false
                            }
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
                        .disabled(isLoading2)
                        .alert(isPresented: $showingAlert2) {
                            Alert(
                                title: Text("Bilgi"),
                                message: Text(alertMessage2),
                                dismissButton: .default(Text("Tamam")) {
                                    if alertMessage.contains("Tebrikler") {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .frame(width: 80, height: 55)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(Capsule())
                    .padding(.leading, 40)
                    .padding(.trailing, 9)
                    
                    
                }.padding(.horizontal)
                    .padding(.top,17)
                if let person = selectedPersonData {
                                   Text("\(person.name) \(person.surname) - \(person.job)")
                                       .foregroundColor(.white)
                                       .padding()
                               } else {
                                   Text("Kişi bilgileri yükleniyor...")
                                       .foregroundColor(.gray)
                                       .padding()
                               }
                HStack {
                    ForEach(kartSecViewModel.categoriesForTopic, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .padding()
                                .background(selectedCategory == category ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                HStack {
                    ForEach(kartSecViewModel.categories, id: \.self) { category in
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 120, height: 180)
                            
                                .background(Color.gray.opacity(0.9))
                                .contentShape(Rectangle())
                            
                            if let placedCard = kartSecViewModel.placedCards[category], !placedCard.isEmpty {
                                Image("scrollcard")
                                    .resizable()
                                    .frame(width: 120, height: 180)
                                    .cornerRadius(5)
                                    .shadow(radius: 3)
                                    .overlay(
                                        VStack{
                                            HStack {
                          
                                            Spacer()
                          
                                            Button(action: {
                          
                                                kartSecViewModel.placedCards[category] = nil
                          
                                            }) {
                          
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.opacity(0.8))
                                                    .clipShape(Circle())
                          
                                            }
                          
                   .padding(5)
                          
                                        }
                                               Spacer()
                                        }
                                    )
                            } else {
                                Text(category)
                                    .font(.caption)
                            }
                        }
                        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
                            print(" onDrop tetiklendi!")
                            return providers.first?.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
                                DispatchQueue.main.async {
                                    if let data = data as? Data, let draggedCard = String(data: data, encoding: .utf8) {
                                        kartSecViewModel.placedCards[category] = draggedCard
                                        kartSecViewModel.objectWillChange.send()
                                     
                                    } else {
                                        print(" HATA: Kart alınamadı!")
                                    }
                                }
                            } != nil
                        }
                    }
                }
                .padding()
                //fal gönderme butonu
                
                Button {
                                   let kartsComplete = checkAllCardsPlaced()
                                   
                                   if !kartsComplete {
                                       alertMessage = "Lütfen tüm kart alanlarını doldurun!"
                                       showAlert = true
                                       return
                                   }
                                   
                                   if coinManager.coin < 10 {
                                       alertMessage = "Yetersiz coin! Reklam izleyerek coin kazanabilirsiniz. Reklam izlemek için sağ üst köşeden yıldız bankasına gidebilirsiniz."
                                       showAlert = true
                                       return
                                   } else {
                                       coinManager.spendCoins(amount: 10)
                                       alertMessage = "Falınız 3 dakika içinde ana ekranınızda gözükecektir!"
                                       showAlert = true
                                       sendToChatGPT()
                                       isAlertPresented = true

                                              DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                  if isAlertPresented {
                                                      dismiss()
                                                  }
                                              }
                                   }
                               } label: {
                                   HStack{
                                       
                                                   Text("Falımı Gönder")
                                                       .bold()
                                                       
                                                       .foregroundColor(.white)
                                                       

                                                   Text("10")
                                                       .bold()
                                                       .foregroundColor(.white)
                                                       .font(.subheadline)

                                                   
                                                   Image(systemName: "star.fill")
                                                       .foregroundColor(.yellow)
                                                       .shadow(radius: 2)
                                                       
                                               }
                                   .frame(width: 180, height: 60)
                                   .background(LinearGradient(colors: [.yellow.opacity(0.4), .black.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                                   .cornerRadius(8)
                                   .shadow(radius: 3)
                                               
                                   
                               }.padding(.top,20)
                               .padding(.bottom,18)
                               .alert(isPresented: $showAlert) {
                                   if alertMessage.contains("anasayfada") {
                                       return Alert(
                                           title: Text("Bilgi"),
                                           message: Text(alertMessage),
                                           dismissButton: nil 
                                       )
                                   } else {
                                       return Alert(
                                           title: Text("Bilgi"),
                                           message: Text(alertMessage),
                                           dismissButton: .default(Text("Tamam")) {
                                               isAlertPresented = false
                                           }
                                       )
                                   }
                               }.fullScreenCover(isPresented: $navigateToRoot) {
                                   ContentView()
                               }
                              
                              

                Spacer()
                Text("Kartları seçerken seçmek  istediğiniz kartın üzerine hafifçe basılı tutun sonrasında istediğiniz yere sürükleyin. Kartlarınızı iyi bir enerji ile çekmeyi unutmayın!")
                    .font(.system(size: 11))
                   
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,5)
                    .foregroundColor(.white)
                    .frame(width: .infinity, height: 55)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: -20) {
                        ForEach(1...totalCards, id: \.self) { index in
                            Image(cardBackImage)
                                .resizable()
                                .frame(width: 80, height: 150)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .onDrag {
                                    let cardName = "card_\(index)"
                                    self.draggedCard = cardName
                                    return NSItemProvider(object: cardName as NSString)
                                }
                        }
                    }
                    .padding()
                }
                .frame(height: 140)
            }
        }.onAppear {
            print(" KartSec açıldı. Seçilen kişi ID: \(selectedPersonID)")
            
                   fetchUserData(selectedPersonID: selectedPersonID)
            kartSecViewModel.resetCards()
               
        }
       }
    func fetchUserData(selectedPersonID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print(" Kullanıcı giriş yapmamış! Kayıtlı kişi bilgisi çekilemez.")
            return
        }

        let db = Firestore.firestore()
        let personRef = db.collection("users").document(currentUserID).collection("persons").document(selectedPersonID)

        personRef.getDocument { (document, error) in
            if let error = error {
                print(" Firestore Hatası: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.selectedPersonData = User(
                        id: document.documentID,
                        name: data?["name"] as? String ?? "Bilinmiyor",
                        surname: data?["surname"] as? String ?? "Bilinmiyor",
                        birthDate: (data?["birthDate"] as? Timestamp)?.dateValue() ?? Date(),
                        iliskiDurumu : data?["iliskiDurumu"] as? String ?? "Bilinmiyor",
                        job: data?["job"] as? String ?? "Bilinmiyor",
                        gender: data?["gender"] as? String ?? "Bilinmiyor"
                    )
                    print(" Seçilen kişi başarıyla yüklendi: \(self.selectedPersonData?.name ?? "Yok") \(self.selectedPersonData?.surname ?? "Yok")")
                }
            } else {
                print(" Firestore'da bu kişi bulunamadı.")
            }
        }
    }

    func checkAllCardsPlaced() -> Bool {
           for category in kartSecViewModel.categories {
               if let card = kartSecViewModel.placedCards[category], card.isEmpty {
                   return false
               }
               
               if kartSecViewModel.placedCards[category] == nil {
                   return false
               }
           }
           return true
       }
      
            func selectRandomCards() {
                selectedCards = Array(assetImageNames.shuffled().prefix(3))
                print("seçilen kartlar \(selectedCards)")
            }
        

    func sendToChatGPT() {
        guard let person = selectedPersonData, let category = selectedCategory else { return }

        selectRandomCards()

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "Sen bir falcısın. Kullanıcının bilgileri,seçtiği konuyu , yaşını, cinsiyetini, mesleğini, seçtiği kartlar dahilinde her kart üzernden en az 6şar cümlelik detaylı bir fal yorumu yap."],
                ["role": "user", "content": """
                Adım: \(person.name), Soyadım: \(person.surname), Mesleğim: \(person.job), Doğum Tarihim: \(person.birthDate), İlişki Durumu: \(person.iliskiDurumu).
                Seçtiğim fal kategorisi: \(category).
                Seçilen kartlar: \(selectedCards.joined(separator: ", ")).
                
                """]
            ],
            "temperature": 0.7,
            "max_tokens": 890
        ]

     //   let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
        let apiKey = APIKeyManager.getOpenAIKey()
        print(" key:", apiKey)
        print(" key uzunluğu:", apiKey.count)
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("!!!!! ChatGPT API Hatası: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print(" API Hata Kodu: \(httpResponse.statusCode)")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data!) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print(" ChatGPT Yanıtı: \(content)")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                        saveFalToFirestore(response: content, selectedPersonID: selectedPersonID)
                    }
                } else {
                    print("yanıt beklenilen formatta değil.")
                }
            } catch {
                print("parse Hatası: \(error.localizedDescription)")
            }
        }.resume()
    }
        //  fal kaydetme
    func saveFalToFirestore(response: String, selectedPersonID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print(" Kullanıcı giriş yapmamış! Fal eklenemez.")
            return
        }

        let db = Firestore.firestore()
        
        let falDocument = db.collection("users").document(currentUserID).collection("fals").document()
        let falID = falDocument.documentID

        let timestamp = Timestamp(date: Date())

        let falData: [String: Any] = [
            "falID": falID,
            "date": timestamp,
            "selectedPersonID": selectedPersonID, 
            "selectedCategory": selectedCategory ?? "",
            "selectedCards": selectedCards,
            "chatGPTResponse": response
        ]

        falDocument.setData(falData) { error in
            if let error = error {
                print(" Firestore'a fal kaydedilirken hata oluştu: \(error.localizedDescription)")
            } else {
                print(" Fal Firestore’a başarıyla kaydedildi. FalID: \(falID)")
            }
        }
    }
   }

   #Preview {
       KartSec(selectedPersonID: "12")
           .environmentObject(CoinManager())
           .environmentObject(KartSecViewModel())

   }
