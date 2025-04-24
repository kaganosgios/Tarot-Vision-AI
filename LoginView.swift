import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var selectedPicker = 1
    @State private var sifreGizli : Bool = true
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isContentViewVisible: Bool = false
        
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
        
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                ZStack{
                    if selectedPicker == 1{  LinearGradient(colors: [.blue.opacity(0.3) , .yellow.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)}
                    else{
                        LinearGradient(colors: [.purple.opacity(0.3) , .yellow.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    VStack{
                        if selectedPicker == 1{
                            Image(systemName: "person.2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue)
                                .frame(width: 130, height: 95)
                                .padding(.bottom,50)
                        }else{
                            Image(systemName: "person")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.purple)
                                .frame(width: 130, height: 95)
                                .padding(.bottom,50)
                        }
                        
                        Picker("", selection: $selectedPicker) {
                            Text("Kayıt Ol").tag(1)
                            Text("Giriş Yap").tag(2)
                        }.pickerStyle(.segmented)
                            .padding()
                            .padding(.bottom,15)
                        HStack {
                            ZStack(alignment: .leading) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                
                                TextField("  E-mail", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .autocapitalization(.none)
                                    .padding(.leading, 30)
                            }
                        }
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        HStack {
                            Image(systemName: "key.horizontal.fill")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            
                            ZStack(alignment: .trailing) {
                                if sifreGizli {
                                    SecureField("Şifre", text: $password)
                                        .padding(.trailing, 30)
                                } else {
                                    TextField("Şifre", text: $password)
                                        .padding(.trailing, 30)
                                }
                                
                                Button(action: { sifreGizli.toggle() }) {
                                    Image(systemName: sifreGizli ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 8)
                            }
                        }
                        .padding(10)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                        .padding()
                        
                        
                        Button {
                            if selectedPicker == 1{
                                // signup firebase fonksiyonu eklencek
                                signUp()
                            }else{
                                // login firebase fonsiyonu
                                logIn()
                            }
                            
                        } label: {
                            Text(selectedPicker == 1 ? "Kayıt Ol" : "Giriş Yap  ")
                                .frame(maxWidth: .infinity , maxHeight: 45)
                                .background(selectedPicker == 1 ? Color.blue : Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        NavigationLink(destination: ContentView(), isActive: $isLoggedIn) {
                            ContentView()
                        }
                        .hidden()
                        
                        
                        Spacer()
                    }
                    .padding(.top,95)
                    
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Bilgi"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("Tamam"))
                    )
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
        
    func signUp(){
        if !handleGiris() {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorCode = (error as NSError).code
                
                if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                    alertMessage = "Bu e-posta adresi zaten kullanılıyor."
                } else {
                    alertMessage = "Kayıt yapılamadı: \(error.localizedDescription)"
                }
                showAlert = true
            } else {
                if let user = Auth.auth().currentUser {
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData([
                        "email": email,
                        "createdAt": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            print("Firestore kullanıcı oluşturma hatası: \(error.localizedDescription)")
                        }
                    }
                }
                
                isLoggedIn = true
                alertMessage = "Kayıt başarılı! Ana ekrana yönlendiriliyorsunuz."
                showAlert = true
                isContentViewVisible = true
            }
        }
    }
    
    func logIn(){
        if !handleGiris() {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorCode = (error as NSError).code
                
                if errorCode == AuthErrorCode.userNotFound.rawValue {
                    alertMessage = "Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı."
                } else if errorCode == AuthErrorCode.wrongPassword.rawValue {
                    alertMessage = "Hatalı şifre girdiniz."
                } else {
                    alertMessage = "Giriş yapılamadı: \(error.localizedDescription)"
                }
                showAlert = true
            } else {
                isLoggedIn = true
                alertMessage = "Giriş başarılı! Ana ekrana yönlendiriliyorsunuz."
                showAlert = true
                isContentViewVisible = true
            }
        }
    }
    
    func handleGiris() -> Bool {
        if email.isEmpty || password.isEmpty {
            alertMessage = "E-mail ya da şifre boş olamaz!"
            showAlert = true
            return false
            
        }
        if !email.contains("@") || !email.contains("."){
            alertMessage = "Geçerli bir e-posta adresi girin!"
            showAlert = true
            return false
        }
        if password.count < 6 {
            alertMessage = "Şifreniz en az 6 karakterden oluşmalıdır!"
            showAlert = true
            return false
        }
        return true
    }
    
  
        
    func checkLoginStatus() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}

#Preview {
    LoginView()
}
