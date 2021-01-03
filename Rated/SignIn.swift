//
//  SignIn.swift
//  Rated
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import GoogleMobileAds
import SystemConfiguration

//MARK: FrontView
struct FrontView: View {
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    @State var start = true
    @State var login = false
    @State var signup = false
    @State var phonenumber = ""
    @State var ccode = "1"
    @State var enteredcode = ""
    @State var verificationcode = ""
    @State var loading = false
    @State var msg = ""
    @State var alert = false
    @State var code = false
    @State var logged = false
    var rewardAd: Rewarded
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                
                VStack {
                    Text("RATED")
                        .font(Font.custom("ProximaNova-Regular", size: 32))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Image("rating(temp)")
                        .resizable()
                        .frame(width: screenheight*0.092, height: screenheight*0.092)
                }.padding(.bottom, 35)
                
                VStack {
                    HStack {
                        Image("phone")
                            .resizable()
                            .frame(width: 35, height: 35)
                        Text("Login With Phone")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.medium)
                            .foregroundColor(Color(.black))
                    }
                    
                    if self.code {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(.white)
                                .frame(width: screenwidth/2 - 60, height: 50)
                                .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                .shadow(color: .white, radius: 15, x: -10, y: -10)
                            if self.enteredcode.isEmpty {
                                HStack {
                                    Text("Code")
                                        .foregroundColor(Color(.darkGray).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                }.frame(width: screenwidth/2 - 80, height: 50)
                            }
                            TextField("", text: $enteredcode)
                                .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                                .frame(width: screenwidth/2 - 80, height: 50)
                                .keyboardType(.numberPad)
                                .foregroundColor(Color(.darkGray))
                                .multilineTextAlignment(.center)
                            
                        }.padding(.bottom, 20)
                    }
                    else {
                        HStack(spacing: 15) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(width: self.ccode.count < 2 ? 50 : 65, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                
                                HStack(spacing: 0) {
                                    Text(self.ccode.isEmpty ? "" : "+")
                                        .foregroundColor(Color(.darkGray))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                    ZStack {
                                        
                                        TextField("", text: $ccode)
                                            .foregroundColor(Color(.darkGray))
                                            .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.center)
                                    }
                                }.frame(width: self.ccode.count < 2 ? 30 : 45, height: 50)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(width: screenwidth - 220, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                
                                if self.phonenumber.isEmpty {
                                    Text("Phone Number")
                                        .foregroundColor(Color(.darkGray).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                }
                                TextField("", text: $phonenumber)
                                    .foregroundColor(Color(.darkGray))
                                    .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                                    .frame(width: screenwidth - 240, height: 50)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                            }
                        }.padding(.bottom, 20)
                    }
                    if loading {
                        WhiteLoader()
                    }
                    else {
                        Button(action: {
                            if self.phonenumber.count == 10 && !self.code {
                                self.loading.toggle()
                                PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.ccode + self.phonenumber, uiDelegate: nil) { (verificationID, error) in
                                    if error != nil {
                                        self.msg = (error?.localizedDescription)!
                                        self.loading.toggle()
                                        self.alert.toggle()
                                        return
                                    }
                                    self.loading.toggle()
                                    self.verificationcode = verificationID!
                                    self.code.toggle()
                                }
                            }
                            else if self.code && self.enteredcode.count == 6 {
                                self.loading.toggle()
                                let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationcode, verificationCode: self.enteredcode)
                                
                                Auth.auth().signIn(with: credential) { (authResult, error) in
                                    if error != nil {
                                        self.msg = (error?.localizedDescription)!
                                        self.loading.toggle()
                                        self.alert.toggle()
                                        return
                                    }
                                    CheckUser() { complete in
                                        if complete {
                                            self.observer.signin()
                                            self.observer.refreshUsers()
                                            self.observer.signedup()
                                            self.logged = true
                                            print(self.observer.users.count, self.observer.rated)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                self.loading.toggle()
                                                UserDefaults.standard.set(false, forKey: "signup")
                                                self.logged = false
                                                UserDefaults.standard.set(true, forKey: "status")
                                                NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                                            }
                                        }
                                        else {
                                            self.msg = "This phone number is not linked to an existing account or there is an error. Sign up to login."
                                            self.alert.toggle()
                                            self.loading.toggle()
                                            self.code = false
                                            self.enteredcode = ""
                                            self.phonenumber = ""
                                        }
                                    }
                                }
                            }
                            else if self.code {
                                self.enteredcode = ""
                                self.code = false
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .font(Font.system(size: 36, weight: .bold))
                                .foregroundColor((self.phonenumber.count == 10 && !self.code) || (self.code && self.enteredcode.count == 6) ? Color(.blue).opacity(0.5) : Color(.gray).opacity(0.3))
                                .rotationEffect(.degrees((self.phonenumber.count == 10 && !self.code) || (self.code && self.enteredcode.count == 6) ? 180 : 0)).animation(.spring())
                            
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    Text("New User? ")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .foregroundColor(Color(.darkGray))
                    NavigationLink(destination: SignUpView(signup: self.$signup), isActive: self.$signup) {
                        Button(action: {
                            self.signup.toggle()
                        }) {
                            Text("Sign Up")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .foregroundColor(Color(.blue).opacity(0.5))
                        }
                    }
                }
                VStack(spacing: 0) {
                    Text("By logging in or creating an account, you have read, understood, and agreed to our ")
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .foregroundColor(Color(.gray).opacity(0.3))
                        .multilineTextAlignment(.center)
                        
                    HStack(spacing: 0) {
                        Button(action: {
                            
                        }) {
                            Text("Terms of Use ")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .foregroundColor(Color(.gray))
                        }
                        Text("and ")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .foregroundColor(Color(.gray).opacity(0.3))
                        Button(action: {
                            
                        }) {
                            Text("Privacy Policy")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .foregroundColor(Color(.gray))
                        }
                    }
                }.fixedSize(horizontal: false, vertical: true).offset(y: screenheight*0.15)
            }.offset(y: -30).frame(width: self.screenwidth, height: self.screenheight).background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)).offset(y: self.logged ? -screenheight*1.25 : 0).animation(.spring())
            Color("personality")
                .frame(width: screenwidth, height: screenheight)
                .offset(y: self.start ? -5 : -screenheight - 5)
                .animation(.spring())
        }.background(Color("personality").edgesIgnoringSafeArea(.all)).alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.start = false
            }
        }
    }
}
