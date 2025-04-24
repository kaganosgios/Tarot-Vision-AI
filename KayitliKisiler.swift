import SwiftUI
import FirebaseFirestore
import Firebase

struct KayitliKisiler: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var kartSecViewModel: KartSecViewModel
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var rewardedAdManager : RewardedAdManager
    @Environment(\.dismiss) var dismiss

    @State private var navigateToKartSec = false
    @State private var selectedPersonID: String? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)

            VStack {
               

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Text("Kayıtlı Kişiler")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding(.trailing,45)
                    
                    Spacer()
                }.padding(.top,30)

                if userViewModel.users.isEmpty {
                    Text("Kayıtlı kişi bulunamadı!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    if #available(iOS 16.0, *) {
                        List(userViewModel.users) { user in
                            Text("\(user.name) \(user.surname)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .listRowBackground(Color.gray.opacity(0.7))
                                .onTapGesture {
                                    print(" Seçilen kişi ID'si: \(user.id)")
                                    selectedPersonID = user.id
                                }
                                .swipeActions{
                                    Button(role: .destructive){
                                        deleteUser(userID: user.id)
                                    }label:{
                                        Label("",systemImage: "trash")
                                    }
                                }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    } else {
                        List(userViewModel.users) { user in
                            Text("\(user.name) \(user.surname)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                
                                .listRowBackground(Color.gray.opacity(0.7))
                                .onTapGesture {
                                    selectedPersonID = user.id
                                }
                                .swipeActions{
                                    Button(role: .destructive){
                                        deleteUser(userID: user.id)
                                    }label:{
                                        Label("",systemImage: "trash")
                                    }
                                }
                        }
                        .onAppear {
                            UITableView.appearance().backgroundColor = UIColor.clear
                        }
                    }
                }
            }
            .onAppear {
                userViewModel.fetchUsers()
            }
        }
        .onChange(of: selectedPersonID) { newID in
            if let newID = newID {
                print(" onChange tetiklendi: \(newID)")
                DispatchQueue.main.async {
                    navigateToKartSec = true
                    print(" navigateToKartSec set oldu knk")
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToKartSec, onDismiss: {
            navigateToKartSec = false
            selectedPersonID = nil
        }) {
            if let selectedPersonID = selectedPersonID {
                KartSec(selectedPerson: "test", selectedPersonID: selectedPersonID)
                    .environmentObject(userViewModel)
                    .environmentObject(coinManager)
                    .environmentObject(kartSecViewModel)
                    .environmentObject(rewardedAdManager)
            } else {
                ProgressView("Kişi yükleniyor...")
            }
        }
    }
    func deleteUser(userID: String) {
            let db = Firestore.firestore()
            guard let currentUserID = userViewModel.currentUserID else { return }

            db.collection("users").document(currentUserID).collection("persons").document(userID).delete { error in
                if let error = error {
                    print("kisi silinerken haa \(error.localizedDescription)")
                } else {
                    print("person delete successs")
                    userViewModel.fetchUsers()
                }
            }
        }
}

#Preview {
    KayitliKisiler()
        .environmentObject(UserViewModel())
}
