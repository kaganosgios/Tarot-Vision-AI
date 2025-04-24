import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct tarotAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject var userViewModel = UserViewModel()
    @StateObject var coinManager = CoinManager()
    @StateObject var kartSecViewModel = KartSecViewModel()
    @StateObject var falManager = FalManager()
    @StateObject var rewardedAdManager = RewardedAdManager.shared

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                NavigationView {
                                   ContentView()
                                       .navigationBarHidden(true)
                               }
                    .environmentObject(userViewModel)
                    .environmentObject(coinManager)
                    .environmentObject(kartSecViewModel)
                    .environmentObject(falManager)
                    .environmentObject(rewardedAdManager)
                    .preferredColorScheme(.light)
            } else {
                LoginView()
                    .environmentObject(userViewModel)
                    .environmentObject(coinManager)
                    .environmentObject(kartSecViewModel)
                    .environmentObject(falManager)
                    .environmentObject(rewardedAdManager) 
                    .preferredColorScheme(.light)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        MobileAds.shared.start(completionHandler: nil)
        
        return true
    }
}
