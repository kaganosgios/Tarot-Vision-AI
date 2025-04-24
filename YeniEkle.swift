//
//  YeniEkle.swift
//  tarotApp
//
//  Created by KağanKAPLAN on 2.02.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct YeniEkle: View {
    @Environment(\.dismiss) var dismiss 

    @State private var ad : String = ""
    @State private var soyad : String = ""
    @State private var dogumTarihi = Date()
    @State private var meslek : String = ""
    @State private var selectedSex : String = "Kadın"
    @State private var iliskiDurumu : String = "Sevgilisi Var"
    @State private var alertMessage = ""
    @State private var alertShow = false
    let cinsiyetler = ["Erkek", "Kadın"]
    let iliskiler = ["Sevgilisi Var","Sevgilisi Yok","Evli","Flört","Platonik"]
    
    var body: some View {
        ZStack {
           // Color(hue: 0.795, saturation: 0.877, brightness: 0.297).opacity(0.5)
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)

            ScrollView{
                VStack {
                    HStack{
                        
                        
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Spacer()
                        
                        
                        Text("Yeni Kişi Ekle")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding(.trailing,45)
                        Spacer()
                    }.padding(.top,15)
                    
                    
                    
                    TextField("Ad", text: $ad)
                      
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .shadow(radius: 3)
                        
                    
                    
                    TextField("Soyad", text: $soyad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .shadow(radius: 3)
                       
                    
                    
                    
                    
                    
                    
                    TextField("Meslek", text: $meslek)
                       
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .shadow(radius: 3)
                    
                    HStack {
                        Text("İlişki Durumu:")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Spacer()
                        Picker("İlişki", selection: $iliskiDurumu) {
                            ForEach(iliskiler, id: \.self) { iliski in
                                Text(iliski)
                                
                            }
                        }
                        .foregroundColor(.white)
                        .pickerStyle(.automatic)
                        .padding()
                    }.padding(.horizontal,20)
                    
                    
                    
                    HStack {
                        Text("Cinsiyet seçiniz:")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Spacer()
                        Picker("Cinsiyet", selection: $selectedSex) {
                            ForEach(cinsiyetler, id: \.self) { cinsiyet in
                                Text(cinsiyet)
                                
                            }
                        }
                        .foregroundColor(.white)
                        .pickerStyle(.automatic)
                        .padding()
                    }.padding(.horizontal,20)
                    
                    DatePicker("Doğum tarihi", selection: $dogumTarihi,displayedComponents: .date)
                        .padding(.horizontal,20)
                        .padding(.vertical,15)
                        .datePickerStyle(.compact)
                        .foregroundColor(.white)
                    
                    
                    
                    Button {
                        saveUserToFirestore(name: ad, surname: soyad, birthDate: dogumTarihi, job: meslek,iliskiDurumu: iliskiDurumu, gender: selectedSex)
                       
                    } label: {
                        Text("Kişiyi Kaydet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 165, height: 60)
                            .background(LinearGradient(colors: [.blue.opacity(0.3), .black.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                    }
                    
                }.padding(.top,25)
            }
        }.alert(isPresented: $alertShow){
            Alert(title: Text("Bilgi"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("Tamam")))
        }
        
        
    }

    func saveUserToFirestore(name: String, surname: String, birthDate: Date, job: String,iliskiDurumu: String, gender: String) {
        if handleBosluk(){
            guard let userID = Auth.auth().currentUser?.uid else {
                print(" kullanııc bulunamadı griis yapmis mi kınıtrıl ett")
                return
            }

            let db = Firestore.firestore()
        let personDocument = db.collection("users").document(userID).collection("persons").document()

        let personID = personDocument.documentID
            let userData: [String: Any] = [
                "personID": personID,
                "name": name,
                "surname": surname,
                "birthDate": birthDate,
                "iliskiDurumu": iliskiDurumu,
                "job": job,
                "gender": gender
            ]

        db.collection("users").document(userID).collection("persons").document().setData(userData)
            
            dismiss()
        }
        }
    func handleBosluk() -> Bool{
        if ad.isEmpty || soyad.isEmpty || meslek.isEmpty {
            alertShow = true
            alertMessage = "Lütfen ekleyeceğiniz kişinin bilgilerini kontrol edin!"
            return false
            
        }
        return true
    }
}

#Preview {
    YeniEkle()
}
