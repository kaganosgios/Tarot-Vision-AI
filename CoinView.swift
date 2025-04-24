import SwiftUI

struct CoinView: View {
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var rewardedAdManager: RewardedAdManager
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                }.padding(.top,55)
                
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
                }.frame(width: 85, height: 55)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(Capsule())
                    .padding(.top, 40)
                
                Spacer()
                
                Button {
                    isLoading = true
                    
                    if rewardedAdManager.isRewardedAdReady {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            rewardedAdManager.showRewardedAd { didEarnReward in
                                isLoading = false
                                if didEarnReward {
                                    coinManager.addCoins(amount: 15)
                                    alertMessage = "Tebrikler! 15 yıldız kazandınız!"
                                    showingAlert = true
                                } else {
                                    alertMessage = "Reklam gösterilirken bir hata oluştu. Lütfen tekrar deneyin."
                                    showingAlert = true
                                }
                            }
                        }
                    } else {
                        alertMessage = "Reklam yükleniyor. Lütfen biraz bekleyin."
                        showingAlert = true
                        rewardedAdManager.loadRewardedAd()
                        isLoading = false
                    }
                } label: {
                    HStack{
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        
                        Text("Reklam izle 15")
                            .bold()
                            .foregroundColor(.white)
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 20, height: 18)
                        
                        Text("kazan!")
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    .frame(width: 290, height: 60)
                    .background(LinearGradient(colors: [.blue.opacity(0.3), .black.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.top,20)
                }
                .disabled(isLoading)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Bilgi"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("Tamam")) {
                            if alertMessage.contains("Tebrikler") {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    )
                }
                
                
                Text("İzlediğiniz her reklamda 15 Yıldız Kazanırsınız. Baktığınız her fal için 10 Yıldız Ödemiş Olursunuz.")
                    
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(width: .infinity,height: 75)
                    .multilineTextAlignment(.center)
                    .padding(.all)
                    .padding(.top,60)
                
                
                
                Text("Fala İnanma Falsız Da Kalma")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.headline)
                  
                    .frame(width:200,height: 80)
                    
                    .background(LinearGradient(colors: [.yellow.opacity(0.2), .black.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                    .shadow(radius: 2)
                    .cornerRadius(10)
                    .padding(.top,60)
                Spacer(minLength: 200)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if !rewardedAdManager.isRewardedAdReady && !rewardedAdManager.isAdLoading {
                rewardedAdManager.loadRewardedAd()
            }
        }
    }
}

#Preview {
    let coinManager = CoinManager()
    let rewardedAdManager = RewardedAdManager.shared
    
    return NavigationView {
        CoinView()
            .environmentObject(coinManager)
            .environmentObject(rewardedAdManager)
    }
}
