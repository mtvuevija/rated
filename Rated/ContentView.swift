//
//  ContentView.swift
//  Rated
//
//  Created by Michael Vu on 7/17/20.
//  Copyright © 2020 Evija Digital. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import GoogleMobileAds

//MARK: MainView
struct MainView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    var body: some View {
        VStack {
            NavigationView {
                if status {
                    HomeView()
                        .transition(.slide)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
                else {
                    FrontView()
                        .transition(.slide)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
            }
        }.animation(.easeIn)
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("StatusChange"), object: nil, queue: .main) { (_) in
                    self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                }
            }
    }
}


//MARK: FrontView
struct FrontView: View {
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    @State var login = false
    @State var signup = false
    
    var body: some View {
        ZStack {
            VStack() {
                
                HStack {
                    Spacer()
                    Image("rating(temp)")
                        .resizable()
                        .frame(width: screenwidth/4, height: screenwidth/4)
                        .padding(.top, screenheight*0.085)
                    Spacer()
                }
                
                Text("RATED")
                    .font(Font.custom("Gilroy-Light", size: 32))
                    .fontWeight(.medium)
                    .foregroundColor(Color("purp"))
                
                Spacer()
                
                NavigationLink(destination: LoginView(login: self.$login), isActive: self.$login) {
                    Button(action: {
                        /*UserDefaults.standard.set(true, forKey: "login")
                        NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)*/
                        self.login.toggle()
                    }) {
                        Text("Login With Phone")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                            .frame(width: screenwidth/1.5, height: 40)
                            .background(Color("purp").opacity(0.4))
                            .cornerRadius(20)
                    }
                }
                
                LabelledDivider(label: "or").frame(width: screenwidth/1.45)
                
                NavigationLink(destination: SignUpView(signup: self.$signup), isActive: self.$signup) {
                    Button(action: {
                        self.signup.toggle()
                    }) {
                        Text("Sign Up")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                            .frame(width: screenwidth/1.5, height: 40)
                            .background(Color("purp").opacity(0.4))
                            .cornerRadius(20)
                    }
                }
                
                Spacer().frame(height: screenheight/2.25)
            }
        }.frame(width: self.screenwidth, height: self.screenheight).background(Color("lightgray").edgesIgnoringSafeArea(.all))
    }
}


//MARK: LoginView
struct LoginView: View {
    @Binding var login: Bool
    var body: some View {
        VStack {
            HStack (spacing: 15) {
                Button(action: {
                    self.login.toggle()
                }) {
                    Image(systemName: "chevron.left.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(Color("purp"))
                }.padding(.leading, 15)
            }
            Spacer()
            HStack {
                Text("LoginView")
            }
        }.navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}


//MARK: SignUpView
struct SignUpView: View {
    @Binding var signup: Bool
    let headers = ["Phone Verification", "Phone Verification", "First Name", "Age", "Gender", "What Matters", "Rate Yourself", "Profile Pictures"]
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    @State var phonenumber = ""
    @State var ccode = ""
    @State var msg = ""
    @State var loading: Bool = false
    @State var alert: Bool = false
    @State var picker: Bool = false
    @State var confirm: Bool = false
    @State var verificationcode = ""
    @State var next: CGFloat = 0
    @State var enteredcode = ""
    @State var count: Int = 1
    @State var genders: Int = 0
    @State var genderoffest: CGFloat = 0
    @State var biocards: [String] = ["00General", "01Education", "02Occupation", "03Music", "04Sports", "05Movies", "06TV-Shows", "07Hobbies", "08Motto", "09Future"]
    @State var text: [String] = ["", "", "", "", "", "", "", "", "", ""]
    @State var selectedprompts = [true, false, false, false, false, false, false, false, false, false]
    @State var selectedinfo = [false, false, false, false, false, false, false, false, false, false]
    @State var showprofile: Bool = false
    
    //Image Picker
    @State var numimage: Int = 0
    @State var showimage = [false, false, false, false]
    @State var position = [0, 1, 2, 3]
    @State var locations: [[CGSize]] =
    [[.zero, CGSize(width: 135, height: 0), CGSize(width: 0, height: 168), CGSize(width: 135, height: 168)],
     [CGSize(width: -135, height: 0), .zero, CGSize(width: -135, height: 168), CGSize(width: 0, height: 168)],
     [CGSize(width: 0, height: -168), CGSize(width: 135, height: -168), .zero, CGSize(width: 135, height: 0)],
     [CGSize(width: -135, height: -168), CGSize(width: 0, height: -168), CGSize(width: -135, height: 0), .zero]]
    @State var current: [CGSize] = [.zero, .zero, .zero, .zero]
    @State var newcor: [CGSize] = [.zero, .zero, .zero, .zero]
    
    
    //Account Info
    @State var name = ""
    @State var age = ""
    @State var profilepics = [Data(), Data(), Data(), Data()]
    @State var gender = ""
    @State var percentage: Float = 5
    @State var selfratingappearance: Float = 5
    @State var selfratingpersonality: Float = 5
    
    @State var instagram = false
    @State var instagramhandle = ""
    @State var twitter = false
    @State var twitterhandle = ""
    @State var snapchat = false
    @State var snapchathandle = ""
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                //MARK: Phone Number 1
                VStack(spacing: 20) {
                    Image("phone")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .shadow(color: .white, radius: 60, x: 0, y: 0)
                    
                    Text("Enter Your Phone Number")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(Color(.white))
                    
                    HStack(spacing: 15) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7.5)
                                .stroke(lineWidth: 5)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 50)
                            
                            HStack(spacing: 0) {
                                Text("+")
                                    .foregroundColor(Color(.white))
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                ZStack {
                                    if self.ccode.isEmpty {
                                        Text("CCode")
                                            .foregroundColor(Color(.white).opacity(0.75))
                                            .font(Font.custom("ProximaNova-Regular", size: 12))
                                    }
                                    TextField("", text: $ccode)
                                        .foregroundColor(.white)
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .keyboardType(.numberPad)
                                }
                            }.frame(width: 50, height: 50).animation(.easeInOut(duration: 0.1))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 7.5)
                                .stroke(lineWidth: 5)
                                .foregroundColor(.white)
                                .frame(width: screenwidth - 100, height: 50)
                            
                            if self.phonenumber.isEmpty {
                                HStack {
                                    Text("Phone Number")
                                        .foregroundColor(Color(.white).opacity(0.75))
                                        .font(.body)
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                    Spacer()
                                }.frame(width: screenwidth - 140, height: 50).animation(.easeInOut(duration: 0.1))
                            }
                            TextField("", text: $phonenumber)
                                .foregroundColor(Color(.white))
                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                .frame(width: screenwidth - 140, height: 50)
                                .keyboardType(.numberPad)
                        }
                    }.padding(.bottom, 30)
                        
                    if loading {
                        Loader()
                    }
                    else {
                        Button(action: {
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
                                self.next -= self.screenwidth
                                self.count += 1
                            }
                        }) {
                            Text("Next")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 30)
                        }.background(self.phonenumber.count == 10 ? Color(.white).cornerRadius(20) : Color(.white).opacity(0.3).cornerRadius(20))
                        .shadow(color: .white, radius: 40, x: 0, y: 0)
                    }
                    Spacer()
                }.frame(width: screenwidth, height: screenheight/1.3)
                
                //MARK: Verification Code 2
                VStack(spacing: 20) {
                    Image("phone")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .shadow(color: .white, radius: 60, x: 0, y: 0)
                    
                    Text("Enter The Verification Code")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 7.5)
                            .stroke(lineWidth: 5)
                            .foregroundColor(.white)
                            .frame(width: screenwidth/2, height: 50)
                        
                        if self.enteredcode.isEmpty {
                            HStack {
                                Text("Verification Code")
                                    .foregroundColor(Color(.white).opacity(0.75))
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                Spacer()
                            }.frame(width: screenwidth/2 - 20, height: 50)
                        }
                        TextField("Verification Code", text: $enteredcode)
                            .font(Font.custom("ProximaNova-Regular", size: 18))
                            .frame(width: screenwidth/2 - 20, height: 50)
                            .keyboardType(.numberPad)
                    }.padding(.bottom, 30)
                    
                    if loading {
                        Loader()
                    }
                    else {
                        Button(action: {
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
                                        self.observer.relogin()
                                        UserDefaults.standard.set(false, forKey: "signup")
                                        UserDefaults.standard.set(true, forKey: "status")
                                        NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                                    }
                                    else {
                                        self.loading.toggle()
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }
                                }
                            }
                        }) {
                            Text("Next")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 30)
                        }.background(self.enteredcode.count == 6 ? Color(.white).cornerRadius(20) : Color(.white).opacity(0.3).cornerRadius(20))
                        .shadow(color: .white, radius: 40, x: 0, y: 0)
                    }
                    Spacer()
                }.frame(width: screenwidth, height: screenheight/1.3)
                
                //MARK: Name 3
                VStack {
                    Image("name")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .shadow(color: .white, radius: 60, x: 0, y: 0)
                    
                    Text("Enter Your First Name")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 7.5)
                            .stroke(lineWidth: 5)
                            .foregroundColor(.white)
                            .frame(width: screenwidth - 60, height: 50)
                        if self.name.isEmpty {
                            HStack {
                                Text("First Name")
                                    .foregroundColor(Color(.white).opacity(0.75))
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                Spacer()
                            }.frame(width: screenwidth - 80, height: 50)
                        }
                        TextField("", text: $name)
                            .frame(width: screenwidth - 80, height: 50)
                    }.padding(.bottom, 30)
                    
                    Button(action: {
                        if self.name.count < 1 {
                            
                        }
                        else {
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                    }) {
                        Text("Next")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                    }.background(self.name.count > 0 ? Color(.white).cornerRadius(20) : Color(.white).opacity(0.3).cornerRadius(20))
                    .shadow(color: .white, radius: 40, x: 0, y: 0)
                    Spacer()
                }.frame(width: screenwidth, height: screenheight/1.3)
                
                //MARK: Age 4
                VStack {
                    Image("age")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .shadow(color: .white, radius: 60, x: 0, y: 0)
                    
                    Text("Enter Your Age")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 7.5)
                            .stroke(lineWidth: 5)
                            .foregroundColor(.white)
                            .frame(width: screenwidth - 60, height: 50)
                        if self.age.count < 1 {
                            HStack {
                                Text("Age")
                                    .foregroundColor(Color(.white).opacity(0.75))
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                Spacer()
                            }.frame(width: screenwidth - 80, height: 50)
                        }
                        TextField("Age", text: $age)
                            .frame(width: screenwidth - 80, height: 50)
                            .keyboardType(.numberPad)
                    }.padding(.bottom, 30)
                    
                    Button(action: {
                        if self.age.count < 2 {
                            
                        }
                        else if Int(self.age) ?? 0 < 18 {
                            self.msg = "You must be 18 or older to register."
                            self.alert.toggle()
                        }
                        else {
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                    }) {
                        Text("Next")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                    }.background(self.age.count > 1 ? Color(.white).cornerRadius(20) : Color(.white).opacity(0.3).cornerRadius(20))
                    .shadow(color: .white, radius: 40, x: 0, y: 0)
                    Spacer()
                    
                }.frame(width: screenwidth, height: screenheight/1.3)
                
                //MARK: Gender 5
                VStack(spacing: 20) {
                    Image("gender")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .shadow(color: .white, radius: 60, x: 0, y: 0)
                    
                    Text("Select Your Gender")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    ZStack {
                        Color(.white)
                            .opacity(0.3)
                            .frame(width: 210, height: 50)
                            .foregroundColor(.white)
                            .background(Color(.gray).opacity(0.2))
                            .cornerRadius(15)
                        
                        if self.genders == 0 {
                            
                        }
                        else {
                            HStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 15).frame(width: 65, height: 45)
                            }.foregroundColor(Color(.white)).offset(x: self.genderoffest)
                        }
                        
                        HStack(spacing: 0) {
                            
                            Button(action: {
                                self.genders = 1
                                self.genderoffest = -70
                                self.gender = "Male"
                            }) {
                                Text("Male")
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("personality"))
                            }.frame(width: 70)
                            
                            Button(action: {
                                self.genders = 2
                                self.genderoffest = 0
                                self.gender = "Female"
                            }) {
                                Text("Female")
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("personality"))
                            }.frame(width: 70)
                            
                            Button(action: {
                                self.genders = 3
                                self.genderoffest = 70
                                self.gender = ""
                            }) {
                                Text("Other")
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                            }.frame(width: 70)
                            
                        }.foregroundColor(.white)
                        
                        
                    }.animation(.spring()).padding(.bottom, self.genders == 3 ? 30 : 0)
                    
                    if self.genders == 3 {
                        Text("Specify Your Gender")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 7.5)
                                .stroke(lineWidth: 5)
                                .foregroundColor(.white)
                                .frame(width: screenwidth - 60, height: 50)
                            if self.gender.count < 1 {
                                HStack {
                                    Text("Gender")
                                        .foregroundColor(Color(.white).opacity(0.75))
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                    Spacer()
                                }.frame(width: screenwidth - 80, height: 50)
                            }
                            TextField("", text: $gender)
                                .frame(width: screenwidth - 80, height: 50)
                                .keyboardType(.numberPad)
                        }.padding(.bottom, 30)
                    }
                    
                    Button(action: {
                        if self.genders == 3 && self.gender.isEmpty || self.genders == 0 {
                            
                        }
                        else {
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                    }) {
                        Text("Next")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                    }.background(!(self.genders == 3 && self.gender.isEmpty || self.genders == 0) ? Color(.white).cornerRadius(20) : Color(.white).opacity(0.3).cornerRadius(20))
                    .shadow(color: .white, radius: 40, x: 0, y: 0)
                    Spacer()
                    
                }.animation(.spring()).frame(width: screenwidth, height: screenheight/1.3)
                
                //MARK: What Matters? 6
                VStack {
                    HStack {
                        Image("appearance")
                            .resizable()
                            .frame(width: screenwidth/4, height: screenwidth/4)
                            .shadow(color: .white, radius: 10, x: 0, y: 0)
                        
                        Spacer()
                        
                        Image("personality")
                            .resizable()
                            .frame(width: screenwidth/4, height: screenwidth/4)
                            .shadow(color: .white, radius: 10, x: 0, y: 0)
                    }.padding(.horizontal, 75)
                    
                    Text("Appearance vs Personality")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .multilineTextAlignment(.center)
                    
                    Text("(This is how your rating will be calculated)")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.5)
                            .foregroundColor(.white)
                            .frame(width: 100, height: screenheight/2.25 + 10)
                        PercentageSlider(percentage: self.$percentage)
                            .frame(width: 90, height: screenheight/2.25)
                            .accentColor(Color("personality"))
                    }.padding(.bottom, 25)
                    
                    Button(action: {
                        self.next -= self.screenwidth
                        self.count += 1
                    }) {
                        Text("Next")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                    }.background(Color(.white).cornerRadius(20))
                .shadow(color: .white, radius: 40, x: 0, y: 0)
                }.frame(width: screenwidth, height: screenheight)
                
                Group {
                    //MARK: Rate Yourself 7
                    VStack {
                        Image("rating(temp)")
                            .resizable()
                            .frame(width: screenwidth/3, height: screenwidth/3)
                            .shadow(color: .white, radius: 20, x: 0, y: 0)
                            
                        Text("Rate Yourself")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        
                        HStack(spacing: 45) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12.5)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: screenheight/2.25 + 10)
                                VerticalSlider(percentage: self.$selfratingappearance, title: "Appearance")
                                    .frame(width: 90, height: screenheight/2.25)
                                    .accentColor(Color("appearance"))
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 12.5)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: screenheight/2.25 + 10)
                                VerticalSlider(percentage: self.$selfratingpersonality, title: "Personality")
                                    .frame(width: 90, height: screenheight/2.25)
                                    .accentColor(Color("personality"))
                            }
                            
                        }.padding(.vertical, 25)
                        
                        Button(action: {
                            self.next -= self.screenwidth
                            self.count += 1
                        }) {
                            Text("Next")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 30)
                        }.background(Color(.white).cornerRadius(20))
                        .shadow(color: .white, radius: 40, x: 0, y: 0)
                    }.frame(width: screenwidth, height: screenheight)
                    
                    //MARK: Profile Pictures 8
                    VStack(spacing: 20) {
                        
                        Image("profilepic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenwidth/3, height: screenwidth/3)
                            .shadow(color: .white, radius: 30, x: 0, y: 0)
                        
                        Text("Select Four Pictures")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 35) {
                            HStack(spacing: 35) {
                                Button(action: {
                                    self.picker.toggle()
                                    self.numimage = 0
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12.5)
                                            .foregroundColor(.white)
                                            .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                        if !self.showimage[0] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                    .cornerRadius(10)
                                                Text("1")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color("personality"))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[0])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                .cornerRadius(10)
                                        }
                                    }
                                }.offset(x: self.current[0].width, y: self.current[0].height)
                                
                                Button(action: {
                                    self.picker.toggle()
                                    self.numimage = 1
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12.5)
                                            .foregroundColor(.white)
                                            .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                        if !self.showimage[1] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                    .cornerRadius(10)
                                                Text("2")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color("personality"))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[1])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                .cornerRadius(10)
                                        }
                                    }
                                }.offset(x: self.current[1].width, y: self.current[1].height)
                                
                            }
                            HStack(spacing: 35) {
                                Button(action: {
                                    self.picker.toggle()
                                    self.numimage = 2
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12.5)
                                            .foregroundColor(.white)
                                            .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                        if !self.showimage[2] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                    .cornerRadius(10)
                                                Text("3")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color("personality"))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[2])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                .cornerRadius(10)
                                        }
                                    }
                                }.offset(x: self.current[2].width, y: self.current[2].height)
                                
                                Button(action: {
                                    self.picker.toggle()
                                    self.numimage = 3
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12.5)
                                            .foregroundColor(.white)
                                            .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                        if !self.showimage[3] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                    .cornerRadius(10)
                                                Text("4")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color("personality"))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[3])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267 - 10, height: self.screenheight*0.164 - 10)
                                                .cornerRadius(10)
                                        }
                                    }
                                }.offset(x: self.current[3].width, y: self.current[3].height)
                                
                            }
                        }.frame(width: screenwidth/1.4, height: screenheight/2.25)
                            .background(Color(.white).opacity(0.15))
                            .cornerRadius(15)
                        
                        Button(action: {
                            for val in self.showimage {
                                if !val {
                                    self.msg = "You need to select four pictures."
                                    self.alert.toggle()
                                    return
                                }
                            }
                            self.next -= self.screenwidth
                            self.count += 1
                        }) {
                            Text("Next")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 30)
                        }.background(Color(.white).cornerRadius(20))
                        .shadow(color: .white, radius: 40, x: 0, y: 0)
                    }.frame(width: screenwidth, height: screenheight)
                }
                
                //MARK: Prompts Select 9
                VStack(spacing: 10) {
                    
                    Text("Select Topics To Build Your Bio")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                    
                    Text("(Press on the topics to bring up more info. Press the checkmark to select the topics you like and then press the pencil to edit them.)")
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(biocards, id: \.self) { title in
                            BioCards(selected: self.$selectedprompts, showinfo: self.$selectedinfo, text: self.$text, index: (title.prefix(2) as NSString).integerValue, title: String(title.suffix(title.count-2)))
                        }
                    }.padding(.vertical, 15)
                        .frame(width: screenwidth - 60, height: screenheight/1.75)
                        .background(Color(.white).opacity(0.3))
                        .cornerRadius(20)
                    
                    Button(action: {
                        var check = true
                        var length = true
                        for num in 0...9 {
                            if self.selectedprompts[num] {
                                if self.text[num].isEmpty {
                                    check = false
                                }
                                if self.text[num].count > 200 {
                                    length = false
                                }
                            }
                        }
                        if check && length {
                            for num in self.biocards {
                                let index = (num.prefix(2) as NSString).integerValue
                                if self.selectedprompts[index] {
                                    self.text[index] = "1" + String(num.prefix(2)) + self.text[index]
                                }
                            }
                            print(self.text)
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                        else if !check {
                            self.msg = "You need to finish filling out the prompts you selected."
                            self.alert.toggle()
                        }
                        else if !length {
                            self.msg = "One of your prompt descriptions is too long. (No more than 200 characters)"
                            self.alert.toggle()
                        }
                    }) {
                        Text("Next")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                    }.background(Color(.white).cornerRadius(20))
                    .shadow(color: .white, radius: 40, x: 0, y: 0)
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Socials 10
                VStack {
                    Text("Socials")
                        .font(Font.custom("ProximaNova-Regular", size: 30))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("(These socials media handles will be public. If you don't want them to be seen, press skip.)")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding([.horizontal, .bottom], 20)
                    HStack {
                        Image("instagram")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(10)
                        if self.instagram {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 5)
                                    .frame(width: 180, height: 60)
                                    .foregroundColor(Color("personality"))
                                if self.instagramhandle.count < 1 {
                                    Text("Your Instagram Handle")
                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                        .foregroundColor(Color("personality"))
                                        .padding(10)
                                        .frame(width: 180, height: 60)
                                }
                                TextField("", text: self.$instagramhandle)
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .foregroundColor(Color("personality"))
                                    .padding(10)
                                    .frame(width: 180, height: 60)
                            }
                        }
                        Button(action: {
                            self.instagram.toggle()
                        }) {
                            Image(systemName: self.instagram ? "checkmark.circle.fill" : "checkmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                            .foregroundColor(Color("personality"))
                            }.padding(10).buttonStyle(PlainButtonStyle())
                    }.background(Color(.white).cornerRadius(10))
                    HStack {
                        Image("twitter")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(10)
                        if self.twitter {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 5)
                                    .frame(width: 180, height: 60)
                                    .foregroundColor(Color("personality"))
                                if self.twitterhandle.count < 1 {
                                    Text("Your Twitter Handle")
                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                        .foregroundColor(Color("personality"))
                                        .padding(10)
                                        .frame(width: 180, height: 60)
                                }
                                TextField("", text: self.$twitterhandle)
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .foregroundColor(Color("personality"))
                                    .padding(10)
                                    .frame(width: 180, height: 60)
                            }
                        }
                        Button(action: {
                            self.twitter.toggle()
                        }) {
                            Image(systemName: self.twitter ? "checkmark.circle.fill" : "checkmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                            .foregroundColor(Color("personality"))
                            }.padding(10).buttonStyle(PlainButtonStyle())
                    }.background(Color(.white).cornerRadius(10))
                    HStack {
                        Image("snapchat")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(10)
                        if self.snapchat {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 5)
                                    .frame(width: 180, height: 60)
                                    .foregroundColor(Color("personality"))
                                if self.snapchathandle.count < 1 {
                                    Text("Your Snapchat Handle")
                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                        .foregroundColor(Color("personality"))
                                        .padding(10)
                                        .frame(width: 180, height: 60)
                                }
                                TextField("", text: self.$snapchathandle)
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .foregroundColor(Color("personality"))
                                    .padding(10)
                                    .frame(width: 180, height: 60)
                            }
                        }
                        Button(action: {
                            self.snapchat.toggle()
                        }) {
                            Image(systemName: self.snapchat ? "checkmark.circle.fill" : "checkmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                            .foregroundColor(Color("personality"))
                            }.padding(10).buttonStyle(PlainButtonStyle())
                    }.background(Color(.white).cornerRadius(10))
                    
                    Button(action: {
                        if self.instagram && self.instagramhandle.isEmpty || self.twitter && self.twitterhandle.isEmpty || self.snapchat && self.snapchathandle.isEmpty {
                            
                        }
                        else {
                            if !self.instagram {
                                self.instagramhandle = "N/A"
                            }
                            if !self.twitter {
                                self.twitterhandle = "N/A"
                            }
                            if !self.snapchat {
                                self.snapchathandle = "N/A"
                            }
                            let socials = [self.instagramhandle, self.twitterhandle, self.snapchathandle]
                            
                            let per = Double(self.percentage/10).truncate(places: 1)
                            
                            let overall = Double(Double(self.selfratingpersonality)*per + Double(self.selfratingappearance)*Double(1-per)).truncate(places: 1)
                            
                            CreateUser(name: self.name, age: self.age, gender: self.gender, percentage: per, overallrating: overall, appearancerating: Double(self.selfratingappearance).truncate(places: 1), personalityrating: Double(self.selfratingpersonality).truncate(places: 1), profilepics: self.profilepics, photopostion: self.position, bio: self.text, socials: socials) { (val) in
                                if val {
                                    self.showprofile.toggle()
                                    self.next -= self.screenwidth
                                    self.count += 1
                                }
                            }
                        }
                    }) {
                        Text("Next")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                    }.background(!(self.instagram && self.instagramhandle.isEmpty || self.twitter && self.twitterhandle.isEmpty || self.snapchat && self.snapchathandle.isEmpty) ? Color(.white).cornerRadius(20) : Color(.white).opacity(0.3).cornerRadius(20))
                    .shadow(color: .white, radius: 40, x: 0, y: 0)
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Your Profile 11
                VStack(spacing: 0) {
                    Spacer()
                    if self.showprofile {
                        ZStack {
                            VStack {
                                Profile(images: self.$profilepics, bio: self.$text, selected: self.$selectedprompts, name: self.$name, age: self.$age)
                                    .scaleEffect(0.93)
                                    .padding(.top, 30)
                            }.frame(width: self.screenwidth, height: self.screenheight)
                            VStack {
                                Text("Your Profile")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.top, 40)
                                Spacer()
                                Button(action: {
                                    AddImages()
                                    self.observer.relogin()
                                    UserDefaults.standard.set(false, forKey: "signup")
                                    UserDefaults.standard.set(true, forKey: "status")
                                    NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                                }) {
                                    Text("Next")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 30)
                                }.background(Color(.white).cornerRadius(20))
                                .shadow(color: .white, radius: 40, x: 0, y: 0)
                                    .padding(.bottom, 30)
                            }
                        }.frame(width: self.screenwidth)
                    }
                }.frame(width: screenwidth, height: screenheight)
                
            }.animation(.spring()).offset(x: screenwidth*5 + next).sheet(isPresented: self.$picker) {
                ImagePicker(picker: self.$picker, images: self.$profilepics, showimage: self.$showimage, num: self.$numimage)
            }
            
            VStack {
                //MARK: Back Button
                HStack(spacing: 15) {
                    
                    Button(action: {
                        if self.count == 1 || self.count == 3 {
                            self.signup.toggle()
                        }
                        else {
                            self.next += self.screenwidth
                            self.count -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left.circle")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(Color(.white))
                        /*if self.count == 11 {
                            
                        }
                        else {
                            Image(systemName: "chevron.left.circle")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color(.white))
                        }*/
                    }.padding(.leading, 15)
                    Spacer()
                }.frame(width: screenwidth).padding(.top, screenheight*0.055)
                
                Spacer()
                
            }.animation(.easeInOut)
        }.navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
            .background(LinearGradient(gradient: Gradient(colors: [Color("personality"), Color("personality")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
            .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
    }
}


//MARK: HomeView
struct HomeView: View {
    @EnvironmentObject var observer: observer
    @State var show: Bool = false
    @State var index: Int = 0
    @State var rating: Bool = false
    @State var next: Bool = false
    @State var showrating: Bool = false
    @State var norating: Bool = false
    @State var showcomment: Bool = false
    @State var comment = ""
    @State var unlock: Bool = false
    @State var unlockindex: Int = 0
    @State var homecomment: Bool = false
    @State var showprofile: Bool = false
    @State var showkeys: Bool = false
    @State var ratingnum: Int = 0
    
    @State var ad: Bool = false
    @State var showad: Bool = false
    @State var adappear: Bool = false
    @State var recentratings: Bool = false
    var rewardAd: Rewarded
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    init() {
        self.rewardAd = Rewarded()
    }
    var body: some View {
        ZStack {
            //MARK: Hold
            VStack {
                Color(.white)
                Spacer()
            }.background(Color(.white).edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.all)
            //MARK: White Border
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 130, height: self.screenheight*0.049)
                        .foregroundColor(Color("lightgray").opacity(0.75))
                        .padding(.leading, 10)
                        .offset(y: CGFloat(index)*self.screenheight*0.049)
                    Spacer()
                }.padding(.top, self.screenheight*0.11)
                Spacer()
            }.frame(height: self.screenheight).offset(x: self.show ? 0 : -150).animation(.easeInOut(duration: 0.5))
            
            //MARK: RatingView
            VStack {
                if self.index == 2 {
                    VStack {
                        HStack {
                            Button(action: {
                                self.show.toggle()
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .resizable()
                                    .frame(width: 37, height: 30)
                                    .foregroundColor(Color("personality"))
                            }.padding(.leading, 15)
                            Spacer()
                        }.padding(.top, self.screenheight*0.0554)
                        Spacer()
                    }
                }
                //MARK: Profile
                else if self.index == 1 {
                    ZStack {
                        VStack {
                            HomeProfile(images: UserDefaults.standard.value(forKey: "ProfilePics") as! [String], bio: UserDefaults.standard.value(forKey: "Bio") as! [String], name: UserDefaults.standard.value(forKey: "Name") as! String, age: UserDefaults.standard.value(forKey: "Age") as! String).frame(width: screenwidth-20, height: screenheight/1.15).padding(.top, 60).shadow(radius: 40)
                        }
                        VStack {
                            HStack {
                                Button(action: {
                                    self.show.toggle()
                                }) {
                                    Image(systemName: "line.horizontal.3")
                                        .resizable()
                                        .frame(width: 37, height: 30)
                                        .foregroundColor(Color("personality"))
                                }.padding(.leading, 15)
                                Spacer()
                            }.padding(.top, self.screenheight*0.0554)
                            Spacer()
                        }
                    }
                }
                //MARK: Home
                else if self.index == 0 {
                    ZStack {
                        VStack {
                            HStack {
                                Button(action: {
                                    self.show.toggle()
                                }) {
                                    Image(systemName: "line.horizontal.3")
                                        .resizable()
                                        .frame(width: 37, height: 30)
                                        .foregroundColor(Color("personality"))
                                }.padding(.leading, 15)
                                Spacer()
                                Button(action: {
                                    self.showkeys = true
                                }) {
                                    HStack {
                                        Text(String(self.observer.keys))
                                            .font(Font.custom("ProximaNova-Regular", size: 24))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("personality"))
                                            .animation(nil)
                                        Image("key")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                            .foregroundColor(Color("personality"))
                                    }
                                }.padding(.trailing, 10)
                            }.padding(.top, self.screenheight*0.0554)
                            //MARK: Your Stats
                            HStack {
                                Text("Your Statistics")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("personality"))
                                    .padding(.leading, 40)
                                Spacer()
                            }
                            YourStatistics()
                            //MARK: Recent Ratings
                            HStack {
                                Text("Recent Ratings")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("personality"))
                                    .padding(.leading, 40)
                                Spacer()
                            }
                            if self.observer.userrates.count == 0 && self.recentratings {
                                ZStack {
                                    Color(.white)
                                        .frame(width: screenwidth/1.25, height: screenheight*0.3)
                                        .cornerRadius(10)
                                        .shadow(color: Color("personality"), radius: 15, x: 0, y: 0)
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 5)
                                        .frame(width: screenwidth/1.25, height: screenheight*0.3)
                                        .foregroundColor(Color("personality"))
                                    Text("No Ratings Yet")
                                        .font(Font.custom("ProximaNova-Regular", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("purp"))
                                }
                            }
                            else if self.observer.userrates.count == 0 {
                                ZStack {
                                    Color(.white)
                                        .frame(width: screenwidth/1.25, height: screenheight*0.3)
                                        .cornerRadius(10)
                                        .shadow(color: Color("personality"), radius: 15, x: 0, y: 0)
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 5)
                                        .frame(width: screenwidth/1.25, height: screenheight*0.3)
                                        .foregroundColor(Color("personality"))
                                    Loader()
                                }
                                
                            }
                            else {
                                ZStack {
                                    RecentRatings(unlockindex: self.$unlockindex, unlock: self.$unlock, homecomment: self.$homecomment, showprofile: self.$showprofile).frame(width: screenwidth/1.25, height: screenheight*0.3)
                                }
                            }
                            //MARK: Rate Button
                            NavigationLink(destination: RatingView(rating: self.$rating, ad: self.$ad, showad: self.$showad, norating: self.$norating, rewardAd: self.rewardAd), isActive: $rating) {
                                Button(action: {
                                    self.rating.toggle()
                                    print(self.observer.users.count, self.observer.rated)
                                }) {
                                    Text("Rate")
                                        .font(Font.custom("Gilroy-Light", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.white))
                                        .frame(width: screenwidth/1.25, height: 50)
                                        .background(Color("personality"))
                                        .cornerRadius(15)
                                }.padding(.top, 10)
                            }.animation(.spring())
                            Spacer()
                            //MARK: Ad
                            if self.adappear {
                                ZStack {
                                    Color(.white)
                                        .frame(width: screenwidth - 40, height: 70)
                                        .cornerRadius(10)
                                        .shadow(color: Color("personality"), radius: 10, x: 0, y: 0)
                                    RatingAd()
                                        .frame(width: screenwidth - 50, height: 60)
                                }.padding(.bottom, 10)
                            }
                        }
                        //MARK: Unlock
                        if self.observer.comments.count != 0 {
                            ZStack {
                                Button(action: {
                                    self.unlock = false
                                }) {
                                    Color(.white)
                                        .opacity(0.4)
                                        .frame(width: self.screenwidth, height: self.screenheight)
                                }
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("lightgray"))
                                    .frame(width: self.screenwidth/1.5, height: self.screenheight/2.5)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 5)
                                    .foregroundColor(Color("personality"))
                                    .frame(width: self.screenwidth/1.5, height: self.screenheight/2.5)
                                    .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                                
                                VStack {
                                    Text("Unlock Profile")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(width: self.screenwidth/1.5 - 80, height: self.screenwidth/1.5 - 80)
                                        
                                        ZStack {
                                            WebImage(url: URL(string: self.observer.ratesinfo[self.unlockindex].ProfilePics[0]))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth/3, height: self.screenwidth/3)
                                                .cornerRadius(25)
                                                .blur(radius: !self.observer.lock[self.unlockindex] ? 10 : 0)
                                            if !self.observer.lock[self.unlockindex] {
                                                Image("lock")
                                                    .resizable()
                                                    .frame(width: self.screenwidth/4, height: self.screenwidth/4)
                                            }
                                        }
                                    }
                                    HStack {
                                        Button(action: {
                                            self.homecomment = true
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(Color("personality"))
                                                    .frame(width: 50, height: 50)
                                                Image("comment")
                                                    .resizable()
                                                    .frame(width: 35, height: 35)
                                            }
                                        }.buttonStyle(PlainButtonStyle())
                                        Button(action: {
                                            if self.observer.keys > 0 && !self.observer.lock[self.unlockindex] {
                                                self.observer.lock[self.unlockindex] = true
                                                self.observer.keys = self.observer.keys-1
                                                Unlock(keys: self.observer.keys, lock: self.observer.lock)
                                                let seconds = 0.5
                                                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                    self.unlock = false
                                                    self.showprofile = true
                                                }
                                            }
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(Color("personality"))
                                                    .frame(width: self.screenwidth/1.5 - 110, height: 50)
                                                HStack(spacing: 0) {
                                                    Text("Unlock ")
                                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .animation(nil)
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 5)
                                                            .foregroundColor(Color(.white).opacity(0.6))
                                                            .frame(width: 50, height: 30)
                                                        HStack(spacing: 5) {
                                                            Text("-1")
                                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(Color("personality"))
                                                                .animation(nil)
                                                            Image("key")
                                                                .resizable()
                                                                .frame(width: 15, height: 15)
                                                                .foregroundColor(Color("personality"))
                                                        }
                                                    }.frame(width: 50, height: 30)
                                                }
                                            }
                                        }
                                    }
                                }.frame(width: self.screenwidth/1.5 - 15, height: self.screenheight/2.5 - 15)
                            }.offset(y: self.unlock ? 0 : self.screenheight).opacity(self.unlock ? 1 : 0).animation(.easeInOut(duration: 0.2))
                        }
                        //MARK: HomeComment
                        if self.observer.comments.count != 0 {
                            ZStack {
                                Button(action: {
                                    self.homecomment = false
                                }) {
                                    Color(.white)
                                        .opacity(0.4)
                                        .frame(width: self.screenwidth, height: self.screenheight)
                                }
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("lightgray"))
                                    .frame(width: self.screenwidth/1.5, height: self.screenheight/3.5)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 5)
                                    .foregroundColor(Color("personality"))
                                    .frame(width: self.screenwidth/1.5, height: self.screenheight/3.5)
                                    .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                                VStack {
                                    HStack {
                                        Image("comment")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .padding([.leading, .top], 10)
                                        Spacer()
                                        Button(action: {
                                            
                                        }) {
                                            Image("report")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }.padding([.trailing, .top], 10)
                                            .buttonStyle(PlainButtonStyle())
                                    }.frame(width: self.screenwidth/1.5 - 30)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        Text(self.observer.comments[self.unlockindex])
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("personality"))
                                            .animation(nil)
                                            .padding(.horizontal, 10)
                                            .frame(width: self.screenwidth/1.5 - 40)
                                    }.frame(width: self.screenwidth/1.5 - 40).background(Color(.white).opacity(0.4)).cornerRadius(10)
                                    Spacer()
                                }.frame(width: self.screenwidth/1.5 - 15, height: self.screenheight/3.5 - 15)
                            }.offset(y: self.homecomment ? 0 : self.screenheight).opacity(self.homecomment ? 1 : 0).animation(.easeInOut(duration: 0.2))
                        }
                        if self.observer.comments.count != 0 {
                            //MARK: ShowProfile
                            ZStack {
                                Button(action: {
                                    self.showprofile = false
                                }) {
                                    Color(.white)
                                        .opacity(0.75)
                                        .frame(width: self.screenwidth, height: self.screenheight)
                                }
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("lightgray"))
                                    .frame(width: self.screenheight/2.5, height: self.screenheight/1.35)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 5)
                                    .foregroundColor(Color("personality"))
                                    .frame(width: self.screenheight/2.5, height: self.screenheight/1.35)
                                    .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            self.showprofile = false
                                        }) {
                                            Image(systemName: "xmark.circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(Color("personality"))
                                        }.padding([.trailing, .top], 10)
                                    }
                                    ShowProfile(index: self.$unlockindex)
                                    Spacer()
                                }.frame(width: self.screenheight/2.5 - 15, height: self.screenheight/1.35 - 15)
                            }.offset(y: self.showprofile ? 0 : self.screenheight).opacity(self.showprofile ? 1 : 0).animation(.easeInOut(duration: 0.2))
                        }
                        //MARK: ShowKeys
                        ZStack {
                            Button(action: {
                                self.showkeys = false
                            }) {
                                Color(.white)
                                    .opacity(0.75)
                                    .frame(width: self.screenwidth, height: self.screenheight)
                            }
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color("personality"))
                                .frame(width: self.screenheight/3, height: self.screenheight/2)
                                .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("lightgray"))
                                .frame(width: self.screenheight/3 - 15, height: self.screenheight/2 - 15)
                            VStack {
                                HStack {
                                    Text("Keys")
                                        .font(Font.custom("ProximaNova-Regular", size: 30))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                    Image("key")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("personality"))
                                }.padding(.top, 10)
                                Spacer()
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        HStack(spacing: 5) {
                                            Text("Remove Ads")
                                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.white))
                                        }.frame(width: 70).padding(.leading, 10)
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Text("$2.99")
                                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("personality"))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                        }.background(Color(.white).cornerRadius(10)).padding(.trailing, 10)
                                    }.frame(width: self.screenheight/3 - 55, height: 60).background(Color("personality").cornerRadius(10))
                                }
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        HStack(spacing: 5) {
                                            Text("∞")
                                                .font(Font.custom("ProximaNova-Regular", size: 30))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.white))
                                            Image("key")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.white))
                                        }.padding(.leading, 10)
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Text("$4.99")
                                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("personality"))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                        }.background(Color(.white).cornerRadius(10)).padding(.trailing, 10)
                                    }.frame(width: self.screenheight/3 - 55, height: 60).background(Color("personality").cornerRadius(10))
                                }
                                Button(action: {
                                    self.rewardAd.showAd(rewardFunction: {
                                        self.observer.keys += 3
                                        KeyChange(keys: self.observer.keys)
                                    })
                                }) {
                                    HStack {
                                        HStack(spacing: 5) {
                                            Text("+3")
                                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.white))
                                            Image("key")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.white))
                                        }.frame(width: 70).padding(.leading, 10)
                                        Spacer()
                                        HStack(spacing: 0) {
                                            VStack(spacing: 0) {
                                                Text("Watch")
                                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color("personality"))
                                                Text("Ad")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color("personality"))
                                            }.frame(width: 45).padding(.vertical, 5).padding(.leading, 2.5)
                                            Image("ad")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .padding(.trailing, 5)
                                        }.background(Color(.white).cornerRadius(10)).padding(.trailing, 10)
                                    }.frame(width: self.screenheight/3 - 55, height: 60).background(Color("personality").cornerRadius(10))
                                }.buttonStyle(PlainButtonStyle()).padding(.bottom, 20)
                            }.frame(width: self.screenheight/3 - 15, height: self.screenheight/2 - 15)
                        }.offset(y: self.showkeys ? 0 : self.screenheight).opacity(self.showkeys ? 1 : 0).animation(.easeInOut(duration: 0.2))
                    }
                }
            }.frame(width: screenwidth, height: screenheight).background(Color("lightgray").edgesIgnoringSafeArea(.all))
            .animation(.spring())
            .cornerRadius(self.show ? 30 : 0)
            .scaleEffect(self.show ? 0.95 : 1)
            .offset(x: self.show ? screenwidth/2.75 : 0, y: self.show ? 2 : 0)
            
            //MARK: Menu
            HStack {
                VStack(alignment: .leading, spacing: self.screenheight*0.0185) {
                    Text("Menu")
                        .font(Font.custom("ProximaNova-Regular", size: self.screenheight*0.0345))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black).opacity(0.3))
                    Button(action: {
                        self.index = 0
                        self.show.toggle()
                    }) {
                        HStack {
                            Image("home")
                                .resizable()
                                .frame(width: self.screenheight*0.03, height: self.screenheight*0.03)
                            Text("Home")
                                .font(Font.custom("ProximaNova-Regular", size: self.screenheight*0.025))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black).opacity(0.3))
                            Spacer()
                        }.frame(width: 120).padding(.leading, 10)
                    }.buttonStyle(PlainButtonStyle())
                    Button(action: {
                        self.index = 1
                        self.show.toggle()
                    }) {
                        HStack {
                            Image("profile")
                                .resizable()
                                .frame(width: self.screenheight*0.03, height: self.screenheight*0.03)
                            Text("Profile")
                                .font(Font.custom("ProximaNova-Regular", size: self.screenheight*0.025))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black).opacity(0.3))
                            Spacer()
                        }.frame(width: 120).padding(.leading, 10)
                    }.buttonStyle(PlainButtonStyle())
                    Button(action: {
                        self.index = 2
                        self.show.toggle()
                    }) {
                        HStack {
                            Image("settings")
                                .resizable()
                                .frame(width: self.screenheight*0.03, height: self.screenheight*0.03)
                            Text("Settings")
                                .font(Font.custom("ProximaNova-Regular", size: self.screenheight*0.025))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black).opacity(0.3))
                            Spacer()
                        }.frame(width: 120).padding(.leading, 10)
                    }.buttonStyle(PlainButtonStyle())
                    Rectangle().frame(width: 120, height: 2).foregroundColor(Color("personality")).padding(.vertical, 15)
                    Button(action: {
                        let firebaseAuth = Auth.auth()
                        do {
                          try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                          print ("Error signing out: %@", signOutError)
                        }
                        UserDefaults.standard.set(false, forKey: "status")
                        NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                    }) {
                        HStack {
                            Image("signout")
                                .resizable()
                                .frame(width: self.screenheight*0.03, height: self.screenheight*0.03)
                            Text("LogOut")
                                .font(Font.custom("ProximaNova-Regular", size: self.screenheight*0.025))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                            Spacer()
                        }.frame(width: 120).padding(.leading, 10)
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                }.frame(height: self.screenheight).padding(.top, self.screenheight*0.117).padding(.leading, 10)
                Spacer()
            }.frame(height: self.screenheight).offset(x: self.show ? 0 : -150).animation(.easeInOut(duration: 0.5))
        }.edgesIgnoringSafeArea(.all).onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.recentratings = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.adappear = true
            }
        }
    }
}


//MARK: RatingView
struct RatingView: View {
    @EnvironmentObject var observer: observer
    @Binding var rating: Bool
    @Binding var ad: Bool
    @Binding var showad: Bool
    @Binding var norating: Bool
    @State var count: Int = 0
    @State var next: Bool = false
    @State var showrating: Bool = false
    @State var appearance: Float = 5
    @State var personality: Float = 5
    @State var showcomment: Bool = false
    @State var comment = ""
    @State var unlocksocials: Bool = false
    @State var unlock: Bool = false
    @State var newkey: CGFloat = UIScreen.main.bounds.height
    @State var newkeyx: CGFloat = 0
    @State var showkey: Bool = false
    @State var showkeys = false
    @State var showsocials: Bool = false
    @State var nonext = false
    @State var msg = ""
    @State var alert = false
    var rewardAd: Rewarded
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            if self.observer.users.count == 0 || self.norating {
                VStack {
                    WhiteLoader()
                }.frame(width: self.screenwidth, height: self.screenheight).edgesIgnoringSafeArea(.all)
            }
            //MARK: RatingAd
            else if self.ad {
                VStack {
                    Spacer().frame(height: self.screenheight/8)
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: screenwidth - 20, height: screenheight/1.25)
                            .foregroundColor(Color("personality"))
                        RatingAd()
                            .frame(width: screenwidth - 35, height: screenheight/1.25 - 15)
                            .background(Color("lightgray"))
                            .cornerRadius(15)
                    }.scaleEffect(self.showad ? 1 : 0).animation(.easeInOut(duration: 0.5))
                }.frame(width: self.screenwidth, height: self.screenheight)
                    .edgesIgnoringSafeArea(.all)
            }
            else {
                ZStack {
                    VStack {
                        //MARK: RatingUI
                        RatingProfile(show: self.$showsocials, appearance: self.$appearance, personality: self.$personality, showrating: self.$showrating, unlock: self.$unlocksocials, count: self.$count)
                            .padding(.all, 2.5)
                            .background(Color("personality").cornerRadius(20).shadow(color: Color("personality"), radius: 15, x: 0, y: 0))
                            .scaleEffect(self.next ? 0 : 0.95)
                            .animation(.spring())
                    }.edgesIgnoringSafeArea(.all)
                    //MARK: Comment
                    ZStack {
                        Button(action: {
                            self.showcomment = false
                        }) {
                            Color(.white)
                                .opacity(0.5)
                                .frame(width: self.screenwidth, height: self.screenheight)
                        }
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: self.screenwidth/1.5, height: self.screenheight/3.5)
                                .foregroundColor(Color("lightgray"))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 5)
                                .frame(width: self.screenwidth/1.5, height: self.screenheight/3.5)
                                .foregroundColor(Color("personality"))
                                .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                            
                            VStack(spacing: 5) {
                                HStack {
                                    Image("comment")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(.leading, 10)
                                    Text("Comment:")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                    Spacer()
                                }.padding(.top, 10)
                                if self.showcomment {
                                    ResizingTextFieldRed(text: self.$comment)
                                        .frame(width: self.screenwidth/1.5 - 20)
                                        .cornerRadius(5)
                                }
                                HStack(spacing: 0) {
                                    Spacer()
                                    Text(String(self.comment.count))
                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor((self.comment.count <= 100) ? Color(.white) : Color("personality"))
                                        .animation(nil)
                                    Text("/100 Characters")
                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor((self.comment.count <= 100) ? Color(.white) : Color("personality"))
                                }.padding(.trailing, 10)
                                HStack(spacing: 5) {
                                    Button(action: {
                                        self.showcomment = false
                                        self.next.toggle()
                                        self.comment = "N/A"
                                        //UpdateRating(user: self.observer.users[self.observer.rated], appearance: Double(self.appearance), personality: Double(self.personality), keys: self.observer.keys, comment: self.comment)
                                        self.showrating = false
                                        self.showsocials = false
                                        self.count = 0
                                        let seconds = 0.5
                                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                            self.appearance = 5
                                            self.personality = 5
                                            if self.observer.users.count != self.observer.rated+1 {
                                                self.observer.rated += 1
                                                if self.observer.ratings == 1 {
                                                    self.ad = true
                                                    self.nonext.toggle()
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                        self.nonext.toggle()
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                        self.showad.toggle()
                                                        self.observer.ratings = 0
                                                    }
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                        self.next.toggle()
                                                        self.observer.ratings += 1
                                                    }
                                                }
                                            }
                                            else {
                                                self.norating = true
                                            }
                                        }
                                        self.comment = ""
                                        self.observer.socialunlock = false
                                        self.unlocksocials = false
                                    }) {
                                        Text("No Comment")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                    }.frame(width: self.screenwidth/3.25 - 5, height: 40).background(Color("personality").cornerRadius(5))
                                    
                                    Button(action: {
                                        if self.comment.count > 100 {
                                            self.msg = "Your comment is too long. (Max is 100 characters)"
                                            self.alert.toggle()
                                            return
                                        }
                                        self.showcomment = false
                                        self.next.toggle()
                                        //UpdateRating(user: self.observer.users[self.observer.rated], appearance: Double(self.appearance), personality: Double(self.personality), keys: self.observer.keys, comment: self.comment)
                                        self.showrating = false
                                        self.showsocials = false
                                        self.count = 0
                                        let seconds = 0.5
                                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                            self.appearance = 5
                                            self.personality = 5
                                            if self.observer.users.count != self.observer.rated+1 {
                                                self.observer.rated += 1
                                                if self.observer.ratings == 4 {
                                                    self.ad = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                        self.showad.toggle()
                                                        self.observer.ratings = 0
                                                    }
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                        self.next.toggle()
                                                        self.observer.ratings += 1
                                                    }
                                                }
                                            }
                                            else {
                                                self.norating = true
                                            }
                                        }
                                        self.comment = ""
                                        self.observer.socialunlock = false
                                        self.unlocksocials = false
                                    }) {
                                        Text("Send")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                    }.frame(width: self.screenwidth/3.25 - 5, height: 40).background(Color("personality").cornerRadius(5))
                                }.padding(.bottom, 5)
                            }.frame(width: self.screenwidth/1.5, height: self.screenheight/3.5)
                        }
                    }.opacity(self.showcomment ? 1 : 0).animation(.easeInOut(duration: 0.2))
                    //MARK: Socials
                    ZStack {
                        Button(action: {
                            self.unlocksocials = false
                        }) {
                            Color(.white)
                                .opacity(0.5)
                        }
                    
                        RoundedRectangle(cornerRadius: 7.5)
                            .frame(width: self.screenwidth/1.5, height: self.screenheight/4.5)
                            .foregroundColor(Color("lightgray"))
                        RoundedRectangle(cornerRadius: 7.5)
                            .stroke(lineWidth: 5)
                            .frame(width: self.screenwidth/1.5, height: self.screenheight/4.5)
                            .foregroundColor(Color("personality"))
                            .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                        
                        VStack {
                            Text("Unlock Socials")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                            ZStack {
                                HStack(spacing: 10) {
                                    if self.observer.users[self.observer.rated].Socials[0] != "N/A" {
                                        Image("instagram")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    }
                                    if self.observer.users[self.observer.rated].Socials[1] != "N/A" {
                                        Image("snapchat")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    }
                                    if self.observer.users[self.observer.rated].Socials[2] != "N/A" {
                                        Image("twitter")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    }
                                }.padding(.all, 10).background(Color(.white).cornerRadius(15)).blur(radius: !self.unlock ? 5: 0)
                                Image("lock")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                            Button(action: {
                                if self.observer.keys == 0 {
                                    self.showkeys = true
                                }
                                else {
                                    self.observer.socialunlock = true
                                    self.observer.keys -= 1
                                    KeyChange(keys: self.observer.keys)
                                    self.unlocksocials = false
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("personality"))
                                    HStack(spacing: 0) {
                                        Text("Unlock ")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .animation(nil)
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundColor(Color(.white).opacity(0.6))
                                                .frame(width: 50, height: 30)
                                            HStack(spacing: 5) {
                                                Text("-1")
                                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color("personality"))
                                                    .animation(nil)
                                                Image("key")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundColor(Color("personality"))
                                            }
                                        }
                                    }
                                }
                            }.padding(.horizontal, self.screenwidth*0.12)
                        }.frame(width: self.screenwidth/1.5 - 25, height: self.screenheight/4.5 - 25)
                    }.opacity(self.unlocksocials ? 1 : 0).animation(.easeInOut(duration: 0.2))
                }
            }
            //MARK: TopBar
            VStack {
                HStack {
                    Button(action: {
                        self.rating = false
                    }) {
                        Image(systemName: "chevron.left.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("personality"))
                    }.padding(.leading, 15)
                    Spacer()
                    Button(action: {
                        self.showkeys.toggle()
                    }) {
                        HStack {
                            Text(String(self.observer.keys))
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .animation(nil)
                            Image("key")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color("personality"))
                        }
                    }.padding(.trailing, 10)
                }.padding(.top, self.screenheight*0.044)
                Spacer()
                Button(action: {
                    if self.nonext {
                        
                    }
                    else if self.ad {
                        self.newkey = 0
                        self.showkey = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.newkey = -self.screenheight/2 + 57.5
                            self.newkeyx = self.screenwidth/2 - 45
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showkey = false
                                self.observer.keys += 1
                                KeyChange(keys: self.observer.keys)
                                self.newkey = self.screenheight
                                self.newkeyx = 0
                            }
                        }
                        
                        self.showad = false
                        self.next = true
                        let seconds = 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.ad = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                self.next = false
                            }
                        }
                        self.observer.socialunlock = false
                        self.unlocksocials = false
                    }
                    else {
                        self.showcomment.toggle()
                    }
                }) {
                    Text("Next")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(self.nonext ? Color(.gray).opacity(0.3) : Color("personality"))
                        .cornerRadius(20)
                }.padding(.bottom, self.screenheight*0.0325)
            }//.edgesIgnoringSafeArea(self.ad ? .all : .horizontal)
            //MARK: ShowKeys
            ZStack {
                Button(action: {
                    self.showkeys = false
                }) {
                    Color(.white)
                        .opacity(0.75)
                        .frame(width: self.screenwidth, height: self.screenheight)
                }
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("personality"))
                    .frame(width: self.screenheight/3, height: self.screenheight/2)
                    .shadow(color: Color("personality"), radius: 20, x: 0, y: 0)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("lightgray"))
                    .frame(width: self.screenheight/3 - 15, height: self.screenheight/2 - 15)
                VStack {
                    HStack {
                        Text("Keys")
                            .font(Font.custom("ProximaNova-Regular", size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                        Image("key")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("personality"))
                    }.padding(.top, 10)
                    Spacer()
                    Button(action: {
                        
                    }) {
                        HStack {
                            HStack(spacing: 5) {
                                Text("Remove Ads")
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                            }.frame(width: 70).padding(.leading, 10)
                            Spacer()
                            HStack(spacing: 0) {
                                Text("$2.99")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("personality"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                            }.background(Color(.white).cornerRadius(10)).padding(.trailing, 10)
                        }.frame(width: self.screenheight/3 - 55, height: 60).background(Color("personality").cornerRadius(10))
                    }
                    Button(action: {
                        
                    }) {
                        HStack {
                            HStack(spacing: 5) {
                                Text("∞")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                Image("key")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.white))
                            }.padding(.leading, 10)
                            Spacer()
                            HStack(spacing: 0) {
                                Text("$4.99")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("personality"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                            }.background(Color(.white).cornerRadius(10)).padding(.trailing, 10)
                        }.frame(width: self.screenheight/3 - 55, height: 60).background(Color("personality").cornerRadius(10))
                    }
                    Button(action: {
                        self.rewardAd.showAd(rewardFunction: {
                            self.observer.keys += 3
                            KeyChange(keys: self.observer.keys)
                        })
                    }) {
                        HStack {
                            HStack(spacing: 5) {
                                Text("+3")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                Image("key")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.white))
                            }.frame(width: 70).padding(.leading, 10)
                            Spacer()
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    Text("Watch")
                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                    Text("Ad")
                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                }.frame(width: 45).padding(.vertical, 5).padding(.leading, 2.5)
                                Image("ad")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 5)
                            }.background(Color(.white).cornerRadius(10)).padding(.trailing, 10)
                        }.frame(width: self.screenheight/3 - 55, height: 60).background(Color("personality").cornerRadius(10))
                    }.buttonStyle(PlainButtonStyle()).padding(.bottom, 20)
                }.frame(width: self.screenheight/3 - 15, height: self.screenheight/2 - 15)
            }.offset(y: self.showkeys ? 0 : self.screenheight).opacity(self.showkeys ? 1 : 0).animation(.easeInOut(duration: 0.2))
            //MARK: Key
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .blur(radius: 30)
                HStack(spacing: 5) {
                    Text("+1")
                        .font(Font.custom("ProximaNova-Regular", size: 30))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("personality"))
                    Image("key")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("personality"))
                        .frame(width: 35, height: 35)
                }
            }.animation(.spring()).offset(x: self.newkeyx, y: self.newkey).scaleEffect((self.newkey < 0) ? 1 : 1.9).opacity((self.showkey) ? 1 : 0)
            
            
        }.background(Color("lightgray").edgesIgnoringSafeArea(.all))
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
    }
}



//MARK: ShowProfile
struct ShowProfile: View {
    @EnvironmentObject var observer: observer
    @Binding var index: Int
    @State var count: Int = 0
    @State var y: CGFloat = 0
    @State var social: Bool = false
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack {
            ZStack {
                WebImage(url: URL(string: self.observer.ratesinfo[self.index].ProfilePics[self.count]))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: self.screenheight/3, height: self.screenheight/3 * 1.33)
                    .animation(nil)
                    .cornerRadius(20)
                
                HStack(spacing: 0) {
                    Button(action: {
                        if self.count != 0 {
                            self.count -= 1
                        }
                    }) {
                        Color(.white)
                            .opacity(0.0)
                            .frame(width: self.screenheight/6)
                    }
                    Button(action: {
                        if self.count != 3 {
                            self.count += 1
                        }
                    }) {
                        Color(.white)
                            .opacity(0.0)
                            .frame(width: self.screenheight/6)
                    }
                }.frame(width: self.screenheight/3, height: self.screenheight/3 * 1.33)
                
                VStack() {
                    Spacer()
                    ZStack {
                        HStack {
                            Button(action: {
                                
                            }) {
                                Color(.white)
                                    .frame(width: 100, height: 30)
                                    .opacity(self.social ? 1 : 0)
                                    .cornerRadius(10)
                                    .padding(.leading, 15)
                            }.offset(y: self.y)
                            Spacer()
                        }
                        HStack {
                            Button(action: {
                                self.y -= 40
                                self.social = true
                            }) {
                                HStack {
                                    Text(self.observer.ratesinfo[self.index].Name.uppercased())
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                        .padding(.leading, 5)
                                    Text(self.observer.ratesinfo[self.index].Age)
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality").opacity(0.5))
                                        .padding(.trailing, 5)
                                }.frame(height: 35).background(Color(.white).opacity(0.75).cornerRadius(10)).padding(.leading, 10)
                            }
                            Spacer()
                            ImageIndicator(count: self.$count)
                                .scaleEffect(0.9)
                                .padding([.bottom, .trailing], 20)
                        }
                    }
                }.frame(width: self.screenheight/3, height: self.screenheight/3 * 1.33)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: self.screenheight/3)
                    .foregroundColor(Color(.white).opacity(0.5))
                    .cornerRadius(15)
                ScrollView(.vertical, showsIndicators: true) {
                    ForEach(self.observer.ratesinfo[index].Bio, id: \.self) { str in
                        VStack {
                            BioCardsFP(index: (String(str.prefix(2)) as NSString).integerValue, text: String(str)[2..<str.count], size1: 16, size2: 12).animation(nil)
                        }
                    }
                }.cornerRadius(15).padding([.horizontal, .vertical], 5)
            }.padding(.bottom, 10).padding(.horizontal, 20)
        }
    }
}


//MARK: RatingMeter
struct RatingMeter: View {
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack {
            Spacer()
            Image("rateneedle")
                .resizable()
                .frame(width: 29, height: 60)
                .rotationEffect(Angle(degrees: Double(observer.rating.overall*18)-90), anchor: UnitPoint(x: 0.5, y: 0.78))
                .animation(.spring())
        }.frame(width: 140, height: 82)
    }
}


//MARK: OverallMeter
struct OverallMeter: View {
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            Text("Overall")
                .font(Font.custom("ProximaNova-Regular", size: 24))
                .fontWeight(.semibold)
                .foregroundColor(Color("purp"))
            Text(String(Double(self.observer.rating.overall)))
                .font(Font.custom("ProximaNova-Regular", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color("purp"))
            ZStack {
                VStack {
                    ZStack {
                        Meter(endangle: 180)
                            .rotation(Angle(degrees: 180), anchor: .bottom)
                            .frame(width: 140, height: 70)
                            .foregroundColor(Color("lightgray"))
                        Meter(endangle: Double(self.observer.rating.overall*18))
                            .rotation(Angle(degrees: 180), anchor: .bottom)
                            .frame(width: 140, height: 70)
                            .foregroundColor(Color("purp"))
                            .animation(.spring())
                        VStack {
                            Spacer()
                            Meter(endangle: Double(180))
                                .rotation(Angle(degrees: 180), anchor: .bottom)
                                .frame(width: 80, height: 40)
                                .foregroundColor(Color(.white))
                        }.frame(width: 140, height: 70)
                    }
                    Spacer()
                }
                RatingMeter()
            }.frame(width: 140, height: 80)
            Text(String(self.observer.userrates.count) + " Ratings")
                .font(Font.custom("ProximaNova-Regular", size: 12))
                .fontWeight(.semibold)
                .foregroundColor(Color("purp"))
                .padding(.bottom, 15)
        }.frame(height: screenheight*0.234)
    }
}


//MARK: DetailsMeter
struct DetailsMeter: View {
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack {
            HStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("Appearance")
                        .font(Font.custom("ProximaNova-Regular", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("appearance"))
                        .padding(.top, 10)
                    Text(String(Double(self.observer.rating.appearance)))
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("appearance"))
                    ZStack {
                        VStack {
                            ZStack {
                                Meter(endangle: 180)
                                    .rotation(Angle(degrees: 180), anchor: .bottom)
                                    .frame(width: 100, height: 50)
                                    .foregroundColor(Color("lightgray"))
                                Meter(endangle: Double(self.observer.rating.appearance*18))
                                    .rotation(Angle(degrees: 180), anchor: .bottom)
                                    .frame(width: 100, height: 50)
                                    .foregroundColor(Color("appearance"))
                                    .animation(.spring())
                                VStack {
                                    Spacer()
                                    Meter(endangle: Double(180))
                                        .rotation(Angle(degrees: 180), anchor: .bottom)
                                        .frame(width: 50, height: 25)
                                        .foregroundColor(Color(.white))
                                }.frame(width: 100, height: 50)
                            }
                            Spacer()
                        }
                        VStack {
                            Spacer()
                            Image("rateneedle")
                                .resizable()
                                .frame(width: 20, height: 40)
                                .rotationEffect(Angle(degrees: Double(observer.rating.appearance*18)-90), anchor: UnitPoint(x: 0.5, y: 0.78))
                        }.frame(width: 100, height: 53)
                    }.frame(width: 100, height: 60)
                }
                VStack(spacing: 5) {
                    Text("Personality")
                        .font(Font.custom("ProximaNova-Regular", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("personality"))
                        .padding(.top, 10)
                    Text(String(Double(self.observer.rating.personality)))
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("personality"))
                    ZStack {
                        VStack {
                            ZStack {
                                Meter(endangle: 180)
                                    .rotation(Angle(degrees: 180), anchor: .bottom)
                                    .frame(width: 100, height: 50)
                                    .foregroundColor(Color("lightgray"))
                                Meter(endangle: Double(self.observer.rating.personality*18))
                                    .rotation(Angle(degrees: 180), anchor: .bottom)
                                    .frame(width: 100, height: 50)
                                    .foregroundColor(Color("personality"))
                                    .animation(.spring())
                                VStack {
                                    Spacer()
                                    Meter(endangle: Double(180))
                                        .rotation(Angle(degrees: 180), anchor: .bottom)
                                        .frame(width: 50, height: 25)
                                        .foregroundColor(Color(.white))
                                }.frame(width: 100, height: 50)
                            }
                            Spacer()
                        }
                        VStack {
                            Spacer()
                            Image("rateneedle")
                                .resizable()
                                .frame(width: 20, height: 40)
                                .rotationEffect(Angle(degrees: Double(observer.rating.personality*18)-90), anchor: UnitPoint(x: 0.5, y: 0.78))
                        }.frame(width: 100, height: 53)
                    }.frame(width: 100, height: 60)
                }
            }.padding(.bottom, 15)
        }.frame(height: screenheight*0.234)
    }
}


//MARK: Your Statistics
struct YourStatistics: View {
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    let images = UserDefaults.standard.value(forKey: "ProfilePics") as! [String]
    @State var x: CGFloat = 0
    @State var tempx: CGFloat = 0
    @State var index = 0
    @EnvironmentObject var observer: observer
    var body: some View {
        ZStack {
            Color(.white)
                .frame(width: screenwidth/1.25, height: screenheight*0.234)
                .cornerRadius(10)
                .shadow(color: Color("personality"), radius: 15, x: 0, y: 0)
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 5)
                .frame(width: screenwidth/1.25, height: screenheight*0.234)
                .foregroundColor(Color("personality"))
            ScrollView([]) {
                HStack {
                    OverallMeter()
                        .frame(width: screenwidth/1.25)
                    DetailsMeter()
                        .frame(width: screenwidth/1.25)
                }.frame(width: self.screenwidth/1.25)
                .offset(x: (screenwidth/2.5)+x+tempx)
                .highPriorityGesture(DragGesture().onChanged({ (value) in
                    self.tempx = value.translation.width
                }).onEnded({ (value) in
                    if value.translation.width < -self.screenwidth/4 && self.index == 0 {
                        self.x = -self.screenwidth/1.25
                        self.index = 1
                    }
                    else if value.translation.width > self.screenwidth/4 && self.index == 1 {
                        self.x = 0
                        self.index = 0
                    }
                    else if self.index == 0 {
                        self.x = 0
                        
                    }
                    else if self.index == 1 {
                        self.x = -self.screenwidth/1.25
                    }
                    self.tempx = 0
                }))
            }.frame(height: screenheight*0.234)
        }.frame(width: screenwidth/1.25)
    }
}


//MARK: Recent Ratings
struct RecentRatings: View {
    @Binding var unlockindex: Int
    @Binding var unlock: Bool
    @Binding var homecomment: Bool
    @Binding var showprofile: Bool
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Color(.white)
                    .frame(width: screenwidth/1.25, height: screenheight*0.3)
                    .cornerRadius(10)
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 5)
                    .frame(width: screenwidth/1.25, height: screenheight*0.3)
                    .foregroundColor(Color("personality"))
                    .shadow(color: Color("personality"), radius: 15, x: 0, y: 0)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 13) {
                        ForEach((0...self.observer.numrates).reversed(), id:\.self) {index in
                            Bar(unlockindex: self.$unlockindex, unlock: self.$unlock, homecomment: self.$homecomment, showprofile: self.$showprofile, index: index, rating: ratingtype(overall: CGFloat((self.observer.userrates[index].prefix(9).suffix(3) as NSString).doubleValue), appearance: CGFloat((self.observer.userrates[index].prefix(3) as NSString).doubleValue), personality: CGFloat((self.observer.userrates[index].prefix(6).suffix(3) as NSString).doubleValue)))
                        }
                    }.padding(.vertical, 10)
                }.frame(width: screenwidth/1.25, height: screenheight*0.3)
                    .cornerRadius(15)
            }
        }
    }
}


//MARK: Profile
struct Profile: View {
    @Binding var images: [Data]
    @Binding var bio: [String]
    @Binding var selected: [Bool]
    @Binding var name: String
    @Binding var age: String
    @State var count: Int = 0
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Image(uiImage: UIImage(data: self.images[self.count])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenwidth - 20, height: (screenwidth - 20)*1.3)
                        .animation(nil)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    HStack {
                        Button(action: {
                            if self.count == 0 {
                            }
                            else {
                                self.count -= 1
                            }
                        }) {
                            Color(.white).opacity(0.0)
                                .frame(width: screenwidth/3, height: (screenwidth - 20)*1.3)
                        }
                        Spacer()
                        Button(action: {
                            if self.count == 3 {
                            }
                            else {
                                self.count += 1
                            }
                        }) {
                            Color(.white).opacity(0.0)
                                .frame(width: screenwidth/3, height: (screenwidth - 20)*1.3)
                        }
                    }.padding(.horizontal, 20)
                }
                Spacer()
            }.frame(width: screenwidth-20, height: screenheight/1.15)
                .cornerRadius(20)
            VStack {
                Spacer()
                HStack {
                    HStack {
                        Text(self.name.uppercased())
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.leading, 10)
                            .animation(nil)
                        Text(self.age)
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality").opacity(0.5))
                            .padding(.trailing, 10)
                            .animation(nil)
                    }.background(Color(.white).opacity(0.75).frame(height: 40).cornerRadius(7.5).shadow(radius: 20)).padding(.leading, 10)
                    Spacer()
                }
                ZStack {
                    ZStack {
                        Color("lightgray")
                            .opacity(0.95)
                            .frame(width: screenwidth - 20, height: screenheight/3.25)
                            .cornerRadius(20)
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            ForEach(self.bio, id: \.self) { str in
                                VStack(spacing: 0) {
                                    if (String(str.prefix(1)) as NSString).integerValue == 1 {
                                        BioCardsFP(index: (String(str.prefix(3).suffix(2)) as NSString).integerValue, text: String(str)[3..<str.count]).animation(nil)
                                    }
                                }.frame(width: self.screenwidth - 40)
                            }
                        }.frame(width: screenwidth - 40, height: screenheight/3.25 - 20).cornerRadius(15)
                    }
                }.frame(height: screenheight/3.25)
            }.frame(width: screenwidth-20, height: screenheight/1.25)
            .cornerRadius(20)
            VStack {
                ImageIndicator(count: self.$count)
                Spacer()
            }.frame(width: screenwidth - 20, height: screenheight/1.15)
        }.frame(width: screenwidth, height: screenheight)
    }
}


//MARK: RatingProfile
struct RatingProfile: View {
    @EnvironmentObject var observer: observer
    @Binding var show: Bool
    @Binding var appearance: Float
    @Binding var personality: Float
    @Binding var showrating: Bool
    @Binding var unlock: Bool
    @Binding var count: Int
    @State var y: CGFloat = 45
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            if self.observer.users[self.observer.rated].ProfilePics[count].count != 0 {
                VStack {
                    //MARK: Image
                    ZStack {
                        WebImage(url: URL(string: self.observer.users[self.observer.rated].ProfilePics[self.count]))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenwidth - 20, height: (screenwidth - 20)*1.3)
                            .animation(nil)
                            .cornerRadius(20)
                        HStack {
                            Button(action: {
                                if self.count == 0 {
                                }
                                else {
                                    self.count -= 1
                                }
                            }) {
                                Color(.white).opacity(0.0)
                                    .frame(width: screenwidth/3, height: (screenwidth - 20)*1.3)
                            }
                            Spacer()
                            Button(action: {
                                if self.count == 3 {
                                }
                                else {
                                    self.count += 1
                                }
                            }) {
                                Color(.white).opacity(0.0)
                                    .frame(width: screenwidth/3, height: (screenwidth - 20)*1.3)
                            }
                        }.padding(.horizontal, 20)
                    }
                    Spacer()
                }.frame(width: screenwidth-20, height: screenheight/1.25)
                    .cornerRadius(20)
            }
            VStack {
                Spacer()
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            //MARK: Socials
                            ZStack {
                                if self.observer.users[self.observer.rated].Socials[0] == "N/A" && self.observer.users[self.observer.rated].Socials[1] == "N/A" && self.observer.users[self.observer.rated].Socials[2] == "N/A" {
                                    HStack(spacing: 5) {
                                        ZStack {
                                            Image("instagram")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                            Image("no")
                                                .resizable()
                                                .frame(width: 35, height: 35)
                                        }
                                        Text("No Socials")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("personality"))
                                    }.background(Color(.white).cornerRadius(7.5))
                                    
                                }
                                else {
                                    if !self.observer.socialunlock {
                                        HStack(spacing: 5) {
                                            if self.observer.users[self.observer.rated].Socials[0] != "N/A" {
                                                Button(action: {
                                                    if self.observer.socialunlock {
                                                        let link = "https://instagram.com/" + self.observer.users[self.observer.rated].Socials[0]
                                                        UIApplication.shared.open(URL(string: link)!)
                                                    }
                                                }) {
                                                    Image("instagram")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                }.buttonStyle(PlainButtonStyle())
                                            }
                                            if self.observer.users[self.observer.rated].Socials[1] != "N/A" {
                                                Button(action: {
                                                    if self.observer.socialunlock {
                                                        let link = "https://snapchat.com/add/" + self.observer.users[self.observer.rated].Socials[1]
                                                        UIApplication.shared.open(URL(string: link)!)
                                                    }
                                                }) {
                                                    Image("snapchat")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                }.buttonStyle(PlainButtonStyle())
                                            }
                                            if self.observer.users[self.observer.rated].Socials[2] != "N/A" {
                                                Button(action: {
                                                    if self.observer.socialunlock {
                                                        let link = "https://twitter.com/" + self.observer.users[self.observer.rated].Socials[2]
                                                        UIApplication.shared.open(URL(string: link)!)
                                                    }
                                                }) {
                                                    Image("twitter")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                }.buttonStyle(PlainButtonStyle())
                                            }
                                        }.blur(radius: 2)
                                    }
                                    else {
                                        HStack(spacing: 5) {
                                            if self.observer.users[self.observer.rated].Socials[0] != "N/A" {
                                                Button(action: {
                                                    if self.observer.socialunlock {
                                                        let link = "https://instagram.com/" + self.observer.users[self.observer.rated].Socials[0]
                                                        UIApplication.shared.open(URL(string: link)!)
                                                    }
                                                }) {
                                                    Image("instagram")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                }.buttonStyle(PlainButtonStyle())
                                            }
                                            if self.observer.users[self.observer.rated].Socials[1] != "N/A" {
                                                Button(action: {
                                                    if self.observer.socialunlock {
                                                        let link = "https://snapchat.com/add/" + self.observer.users[self.observer.rated].Socials[1]
                                                        UIApplication.shared.open(URL(string: link)!)
                                                    }
                                                }) {
                                                    Image("snapchat")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                }.buttonStyle(PlainButtonStyle())
                                            }
                                            if self.observer.users[self.observer.rated].Socials[2] != "N/A" {
                                                Button(action: {
                                                    if self.observer.socialunlock {
                                                        let link = "https://twitter.com/" + self.observer.users[self.observer.rated].Socials[2]
                                                        UIApplication.shared.open(URL(string: link)!)
                                                    }
                                                }) {
                                                    Image("twitter")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                }.buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    
                                    if !self.observer.socialunlock {
                                        Button(action: {
                                            self.unlock = true
                                        }) {
                                            Image("lock")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }.buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }.padding(.horizontal, 7.5).padding(.vertical, 5).background(Color(.white).opacity(!self.observer.socialunlock ? 1 : 0.75).cornerRadius(7.5))
                            .padding(.leading, 10)
                            .offset(y: self.show ? 0 : 45)
                            .scaleEffect(self.show ? 1 : 0)
                            Spacer()
                        }
                        //MARK: Name and Age
                        HStack {
                            Button(action: {
                                self.show.toggle()
                            }) {
                                HStack {
                                    Text(self.observer.users[self.observer.rated].Name.uppercased())
                                        .font(Font.custom("ProximaNova-Regular", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality"))
                                        .padding(.leading, 10)
                                        .animation(nil)
                                    Text(self.observer.users[self.observer.rated].Age)
                                        .font(Font.custom("ProximaNova-Regular", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("personality").opacity(0.5))
                                        .padding(.trailing, 10)
                                        .animation(nil)
                                }.background(Color(.white).opacity(0.75).frame(height: 40).cornerRadius(7.5).shadow(radius: 20)).padding([.leading, .bottom], 10)
                            }
                            Spacer()
                        }
                    }
                    //MARK: Rating Button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Button(action: {
                                    self.showrating.toggle()
                                }) {
                                    if self.showrating {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    VStack {
                                                        Spacer()
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .foregroundColor(Color("lightgray"))
                                                            .frame(width: 45, height: 65)
                                                    }
                                                    VStack {
                                                        Spacer()
                                                        Image(systemName: "chevron.down")
                                                            .resizable()
                                                            .frame(width: 20, height: 10)
                                                            .foregroundColor(Color("personality"))
                                                            .padding(.bottom, 10)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        ZStack {
                                            Circle()
                                                .foregroundColor(Color(.white).opacity(0.9))
                                                .frame(width: 45, height: 45)
                                            
                                            Image("rating(temp)")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                                }.buttonStyle(PlainButtonStyle())
                                if self.showrating {
                                    ZStack {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Rectangle()
                                                    .foregroundColor(Color("lightgray"))
                                                    .frame(width: 120, height: 180)
                                                    .cornerRadius(15)
                                            }
                                        }
                                        VStack(spacing: 5) {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                HStack {
                                                    ProfileRatingSlider(percentage: self.$appearance, title: "appearance").accentColor(Color("appearance")).padding(.leading, 15)
                                                    Spacer()
                                                    ProfileRatingSlider(percentage: self.$personality, title: "personality").accentColor(Color("personality")).padding(.trailing, 15)
                                                }.frame(width: 120, height: 150)
                                            }
                                        }.offset(y: -12.5)
                                    }.offset(y: -25)
                                }
                            }
                        }.padding(.trailing, 10)
                    }.animation(.easeInOut(duration: 0.2))
                }
                //MARK: Bio
                ZStack {
                    ZStack {
                        Color("lightgray")
                            .opacity(0.95)
                            .frame(width: screenwidth - 20, height: screenheight/3.25)
                            .cornerRadius(20)
                        ScrollView(.vertical, showsIndicators: true) {
                            
                            ForEach(self.observer.users[self.observer.rated].Bio, id: \.self) { str in
                                VStack {
                                    BioCardsFP(index: (String(str.prefix(2)) as NSString).integerValue, text: String(str)[2..<str.count]).animation(nil)
                                }.frame(width: self.screenwidth - 40)
                            }
                        }.frame(width: screenwidth - 40, height: screenheight/3.25 - 20).cornerRadius(20)
                    }
                }.frame(height: screenheight/3.25)
            }.frame(width: screenwidth-20, height: screenheight/1.25)
            .cornerRadius(20)
            VStack {
                ImageIndicator(count: self.$count)
                Spacer()
            }.frame(width: screenwidth - 20, height: screenheight/1.25)
        }
    }
}


//MARK: HomeProfile
struct HomeProfile: View {
    @State var images = [String]()
    @State var bio = [String]()
    @State var name = ""
    @State var age = ""
    @State var count: Int = 0
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    WebImage(url: URL(string: self.images[count]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenwidth - 20, height: (screenwidth - 20)*1.3)
                        .animation(nil)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    HStack {
                        Button(action: {
                            if self.count == 0 {
                            }
                            else {
                                self.count -= 1
                            }
                        }) {
                            Color(.white).opacity(0.0)
                                .frame(width: screenwidth/3, height: (screenwidth - 20)*1.3)
                        }
                        Spacer()
                        Button(action: {
                            if self.count == 3 {
                            }
                            else {
                                self.count += 1
                            }
                        }) {
                            Color(.white).opacity(0.0)
                                .frame(width: screenwidth/3, height: (screenwidth - 20)*1.3)
                        }
                    }.padding(.horizontal, 20)
                }
                Spacer()
            }.frame(width: screenwidth-20, height: screenheight/1.15)
                .cornerRadius(20)
            VStack {
                Spacer()
                HStack {
                    HStack {
                        Text(self.name.uppercased())
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.leading, 10)
                            .animation(nil)
                        Text(self.age)
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality").opacity(0.5))
                            .padding(.trailing, 10)
                            .animation(nil)
                    }.background(Color(.white).opacity(0.75).frame(height: 40).cornerRadius(7.5).shadow(radius: 20)).padding(.leading, 10)
                    Spacer()
                }
                ZStack {
                    ZStack {
                        Color("lightgray")
                            .opacity(0.95)
                            .frame(width: screenwidth - 20, height: screenheight/3.25)
                            .cornerRadius(20)
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            ForEach(self.bio, id: \.self) { str in
                                VStack {
                                    BioCardsFP(index: (String(str.prefix(2)) as NSString).integerValue, text: String(str)[2..<str.count]).animation(nil)
                                }.frame(width: self.screenwidth - 40)
                            }
                            }.frame(width: screenwidth - 40, height: screenheight/3.25 - 20).cornerRadius(15)
                    }
                }.frame(height: screenheight/3.25)
            }.frame(width: screenwidth-20, height: screenheight/1.25)
            .cornerRadius(20)
            VStack {
                ImageIndicator(count: self.$count)
                Spacer()
            }.frame(width: screenwidth - 20, height: screenheight/1.15)
        }.frame(width: screenwidth, height: screenheight)
    }
}


//MARK: BioCardsForProfile
struct BioCardsFP: View {
    @State var index: Int = 0
    @State var text = ""
    @State var categories = ["General", "Education", "Occupation", "Music", "Sports", "Movies", "TV-Shows", "Hobbies", "Motto", "Future"]
    @State var size1: CGFloat = 18
    @State var size2: CGFloat = 16
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("personality").opacity(0.75))
            
            VStack(spacing: 5) {
                HStack {
                    if self.index != 0 {
                        Image(self.categories[self.index])
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(self.categories[self.index] + ":")
                        .font(Font.custom("ProximaNova-Regular", size: self.size1))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    Spacer()
                }.padding(.leading, 10)
                Text(self.text)
                    .font(Font.custom("ProximaNova-Regular", size: self.size2))
                    .foregroundColor(Color(.white).opacity(0.8))
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(.vertical, 10)
        }
    }
}


//MARK: ImageIndicator
struct ImageIndicator: View {
    @Binding var count: Int
    var body: some View {
        HStack(spacing: 5) {
            if count == 0 {
                Circle()
                    .foregroundColor(Color("personality"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            if count == 1 {
                Circle()
                    .foregroundColor(Color("personality"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            if count == 2 {
                Circle()
                    .foregroundColor(Color("personality"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            if count == 3 {
                Circle()
                    .foregroundColor(Color("personality"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }.padding(.top, 20).background(Color(.white).opacity(0.75).frame(width: 64, height: 19).cornerRadius(9.5).padding(.top, 20))
    }
}


//MARK: BioCards
struct BioCards: View {
    @Binding var selected: [Bool]
    @Binding var showinfo: [Bool]
    @Binding var text: [String]
    @State var edit: Bool = false
    @State var index: Int = 0
    @State var confirm: Bool = false
    @State var moreinfo: [String] =
        ["Although a bio on an app can’t possibly represent you entirely, try to be as descriptive as possible to paint a clear picture of your personality. Whatever topics the other prompts can’t cover, write them here.", "Whether you like it or not, you probably had to go to school. Write about a degree or write about your current school. Maybe a dream school?", "Money doesn’t grow on trees so sometimes jobs are necessary. Talk about past jobs or your current job. You could always mention a career you're working towards.", "", "Like playing with balls or watching people play with balls? Write about your favorite teams or your favorite players.", "", "", "", "\"Get your money up, not your funny up\" - Big Dilf. These are words I live by. Got a motto like this? Write it here.", "What does the future hold? I don't know but you can write about your's here. What are you hoping for? Kids? Money? Job?"]
    @State var title = ""
    let screenwidth = UIScreen.main.bounds.width
    var body: some View {
        VStack {
            //MARK: Show Info
            if self.showinfo[index] {
                ZStack {
                    Color(.white)
                        .frame(width: self.screenwidth - 85)
                        .cornerRadius(10)
                    
                    VStack {
                        HStack {
                            if self.title != "General" {
                                Image(title)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            Text(title + ": ")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Button(action: {
                                self.showinfo[self.index] = false;
                            }) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("personality"))
                            }
                        }.padding(.horizontal, 10).padding(.top, 10)
                        Text(moreinfo[index])
                            .font(Font.custom("PromximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(nil)
                    }
                }.frame(width: self.screenwidth - 85)
                .cornerRadius(10)
            }
            //MARK: Edit Mode
            else if edit {
                ZStack {
                    Color(.white)
                        .frame(width: self.screenwidth - 85)
                        .cornerRadius(10)
                    
                    VStack(spacing: 0) {
                        HStack {
                            if self.title != "General" {
                                Image(title)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            Text(title + ": ")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                            Spacer()
                            Button(action: {
                                self.edit.toggle()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("personality"))
                            }
                        }.padding(.horizontal, 15).padding(.top, 10)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 5)
                                .frame(width: self.screenwidth - 105, height: 100)
                                .foregroundColor(Color("personality"))
                            
                            ResizingTextField(text: self.$text[index])
                                .frame(width: self.screenwidth - 115, height: 100)
                                .cornerRadius(10)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        }.padding(.top, 10)
                        
                        HStack(spacing: 0) {
                            Spacer()
                            Text("Characters: " + String(self.text[index].count) + "/200")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(self.text[index].count > 200 ? Color("personality") : Color(.gray).opacity(0.4))
                                .padding([.bottom, .trailing], 10)
                                .animation(nil)
                        }
                    }
                }.frame(width: self.screenwidth - 85)
                .cornerRadius(10)
            }
            //MARK: Default
            else {
                HStack {
                    if self.title != "General" {
                        Image(title)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 10)
                    }
                    Button(action: {
                        for num in 0...8 {
                            self.showinfo[num] = false
                        }
                        self.showinfo[self.index] = true
                    }) {
                        HStack {
                            Text(title + ":")
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                        }
                    }.padding(.leading, self.title == "General" ? 10 : 0)
                    Spacer()
                    if self.selected[self.index] {
                        Button(action: {
                            self.edit.toggle()
                        }) {
                            Image(systemName: "pencil.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("personality"))
                        }.padding(.trailing, self.title != "General" ? 0 : 10)
                    }
                    if self.title != "General" {
                        Button(action: {
                            self.selected[self.index].toggle()
                        }) {
                            Image(systemName: self.selected[self.index] ? "checkmark.circle.fill" : "checkmark.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("personality"))
                        }.padding(.trailing, 10)
                    }
                }.frame(width: screenwidth - 85, height: 65)
                    .background(Color(.white))
                    .cornerRadius(10)
            }
        }.frame(width: self.screenwidth).onAppear {
            if self.title == "General" {
                self.edit = true
            }
        }
    }
}


//MARK: Loader
struct Loader : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Loader>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Loader>) {
    }
}


//MARK: WhiteLoader
struct WhiteLoader : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<WhiteLoader>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<WhiteLoader>) {
    }
}


//MARK: PercentageSlider
struct PercentageSlider: View {
    @Binding var percentage: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(Color("appearance"))
                Rectangle()
                    .foregroundColor(.accentColor)
                    .opacity(0.75)
                    .frame(height: geometry.size.height * CGFloat(self.percentage / 10))
                    .cornerRadius(0)
                VStack(spacing: 0) {
                    Image("appearance")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.top, 10)
                    Text("Appearance")
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    Text(String(Int(100 - Double(self.percentage).truncate(places: 1)*10)) + "%" )
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                    Spacer()
                    Image("personality")
                        .resizable()
                        .frame(width: 35, height: 35)
                    Text("Personality")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    Text(String(Int(Double(self.percentage).truncate(places: 1)*10)) + "%")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                        .padding(.bottom, 10)
                }
            }.cornerRadius(10)
                .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                    self.percentage = 10 - min(max(0, Float(value.location.y / geometry.size.height * 100)), 100)/10
                }))
        }
    }
}


//MARK: VerticalSlider
struct VerticalSlider: View {
    @Binding var percentage: Float
    @State var title = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(height: geometry.size.height * CGFloat(self.percentage / 10))
                    .cornerRadius(0)
                VStack {
                    Image(self.title.lowercased())
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.top, 15)
                    
                    Text(self.title)
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    Text(String(Double(self.percentage).truncate(places: 1)))
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                    Spacer()
                }
            }.cornerRadius(10)
                .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                    self.percentage = 10 - min(max(0, Float(value.location.y / geometry.size.height * 100)), 100)/10
                }))
        }
    }
}


//MARK: ProfileRatingSlider
struct ProfileRatingSlider: View {
    @Binding var percentage: Float
    @State var title = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(height: geometry.size.height * CGFloat(self.percentage / 10))
                    .cornerRadius(0)
                VStack(spacing: 0) {
                    Image(self.title.lowercased())
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.top, 15)
                    
                    Text(String(Double(self.percentage).truncate(places: 1)))
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                    Spacer()
                }
            }.cornerRadius(10)
                .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                    self.percentage = 10 - min(max(0, Float(value.location.y / geometry.size.height * 100)), 100)/10
                }))
        }
    }
}


//MARK: ImagePicker
struct ImagePicker : UIViewControllerRepresentable {
    @Binding var picker : Bool
    @Binding var images: [Data]
    @Binding var showimage: [Bool]
    @Binding var num: Int
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePicker.Coordinator(parent1: self)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    class Coordinator : NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        var parent : ImagePicker
        init(parent1 : ImagePicker) {
            parent = parent1
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.picker.toggle()
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as! UIImage
            let data = image.jpegData(compressionQuality: 0.5)
            self.parent.images[parent.num] = data!
            self.parent.showimage[parent.num] = true
            self.parent.picker.toggle()
        }
    }
}


//MARK: Double Truncate
extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


//MARK: Observer
class observer: ObservableObject {
    @Published var users = [UserData]()
    @Published var userrates = [String]()
    @Published var ratesinfo = [UserData]()
    @Published var lock = [Bool]()
    @Published var rating: ratingtype = ratingtype(overall: 0, appearance: 0, personality: 0)
    @Published var showratings = [Bool]()
    @Published var numrates: Int = 0
    @Published var keys: Int = 0
    @Published var comments = [String]()
    @Published var socialunlock = false
    @Published var ratings: Int = 0
    @Published var rated: Int = 0
    var id = Auth.auth().currentUser?.uid
    init() {
        self.users = [UserData]()
        print(self.users)
        if (UserDefaults.standard.value(forKey: "ID") as? String ?? "NA") == "NA" {
            return
        }
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if self.id! == (document.get("ID") as! String) {
                        UserDefaults.standard.set(document.get("Bio") as! [String], forKey: "Bio")
                        self.lock = document.get("Lock") as! [Bool]
                        self.userrates = document.get("Rates") as! [String]
                        self.keys = document.get("Keys") as! Int
                        self.comments = document.get("Comments") as! [String]
                        self.rating = ratingtype(overall: CGFloat(document.get("OverallRating") as! Double), appearance: CGFloat(document.get("AppearanceRating") as! Double), personality: CGFloat(document.get("PersonalityRating") as! Double))
                        self.numrates = self.userrates.count-1
                        if self.numrates > -1 {
                            for _ in 0...self.numrates {
                                self.showratings.append(false)
                            }
                        }
                    }
                    else if self.users.count < 50 {
                        var check = true
                        for rate in document.get("Rates") as! [String] {
                            if String(rate.suffix(rate.count-9)) == UserDefaults.standard.value(forKey: "ID") as! String {
                                check = false
                            }
                        }
                        if check {
                            let age = document.get("Age") as! String
                            let bio = document.get("Bio") as! [String]
                            let gender = document.get("Gender") as! String
                            let id = document.get("ID") as! String
                            let name = document.get("Name") as! String
                            let percentage = document.get("Percentage") as! Double
                            let profilepics = document.get("ProfilePics") as! [String]
                            let rates = document.get("Rates") as! [String]
                            let overallrating = document.get("OverallRating") as! Double
                            let appearancerating = document.get("AppearanceRating") as! Double
                            let personalityrating = document.get("PersonalityRating") as! Double
                            let selfrating = document.get("SelfRating") as! Double
                            let socials = document.get("Socials") as! [String]
                            self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials))
                        }
                    }
                }
                self.users.shuffle()
                for users in self.userrates {
                    for document in querySnapshot!.documents {
                        if document.get("ID") as! String == users.substring(fromIndex: 9) {
                            let age = document.get("Age") as! String
                            let bio = document.get("Bio") as! [String]
                            let gender = document.get("Gender") as! String
                            let id = document.get("ID") as! String
                            let name = document.get("Name") as! String
                            let percentage = document.get("Percentage") as! Double
                            let profilepics = document.get("ProfilePics") as! [String]
                            let rates = document.get("Rates") as! [String]
                            let overallrating = document.get("OverallRating") as! Double
                            let appearancerating = document.get("AppearanceRating") as! Double
                            let personalityrating = document.get("PersonalityRating") as! Double
                            let selfrating = document.get("SelfRating") as! Double
                            let socials = document.get("Socials") as! [String]
                            self.ratesinfo.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials))
                        }
                    }
                }
            }
        }
    }
    func relogin() {
        self.users = [UserData]()
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if uid! == document.get("ID") as! String {
                        self.lock = document.get("Lock") as! [Bool]
                        self.userrates = document.get("Rates") as! [String]
                        self.keys = document.get("Keys") as! Int
                        self.comments = document.get("Comments") as! [String]
                        self.rating = ratingtype(overall: CGFloat(document.get("OverallRating") as! Double), appearance: CGFloat(document.get("AppearanceRating") as! Double), personality: CGFloat(document.get("PersonalityRating") as! Double))
                        self.numrates = self.userrates.count-1
                        if self.numrates > -1 {
                            for _ in 0...self.numrates {
                                self.showratings.append(false)
                            }
                        }
                    }
                    else if self.users.count < 50 {
                        var check = true
                        for rate in document.get("Rates") as! [String] {
                            if String(rate.suffix(rate.count-9)) == UserDefaults.standard.value(forKey: "ID") as! String {
                                check = false
                            }
                        }
                        if check {
                            let age = document.get("Age") as! String
                            let bio = document.get("Bio") as! [String]
                            let gender = document.get("Gender") as! String
                            let id = document.get("ID") as! String
                            let name = document.get("Name") as! String
                            let percentage = document.get("Percentage") as! Double
                            let profilepics = document.get("ProfilePics") as! [String]
                            let rates = document.get("Rates") as! [String]
                            let overallrating = document.get("OverallRating") as! Double
                            let appearancerating = document.get("AppearanceRating") as! Double
                            let personalityrating = document.get("PersonalityRating") as! Double
                            let selfrating = document.get("SelfRating") as! Double
                            let socials = document.get("Socials") as! [String]
                            self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials))
                        }
                    }
                }
                self.users.shuffle()
                for users in self.userrates {
                    for document in querySnapshot!.documents {
                        if document.get("ID") as! String == users.substring(fromIndex: 9) {
                            let age = document.get("Age") as! String
                            let bio = document.get("Bio") as! [String]
                            let gender = document.get("Gender") as! String
                            let id = document.get("ID") as! String
                            let name = document.get("Name") as! String
                            let percentage = document.get("Percentage") as! Double
                            let profilepics = document.get("ProfilePics") as! [String]
                            let rates = document.get("Rates") as! [String]
                            let overallrating = document.get("OverallRating") as! Double
                            let appearancerating = document.get("AppearanceRating") as! Double
                            let personalityrating = document.get("PersonalityRating") as! Double
                            let selfrating = document.get("SelfRating") as! Double
                            let socials = document.get("Socials") as! [String]
                            self.ratesinfo.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials))
                        }
                    }
                }
            }
        }
    }
    func wipeRates() {
        self.userrates = [String]()
        self.rating = ratingtype(overall: CGFloat(UserDefaults.standard.value(forKey: "SelfRating") as! Double), appearance: CGFloat(UserDefaults.standard.value(forKey: "AppearanceRating") as! Double), personality: CGFloat(UserDefaults.standard.value(forKey: "PersonalityRating") as! Double))
    }
    func refreshRates() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if (UserDefaults.standard.value(forKey: "ID") as! String) == (document.get("ID") as! String) {
                        self.userrates = document.get("Rates") as! [String]
                        self.rating = ratingtype(overall: CGFloat(document.get("OverallRating") as! Double), appearance: CGFloat(document.get("AppearanceRating") as! Double), personality: CGFloat(document.get("PersonalityRating") as! Double))
                    }
                }
            }
        }
    }
    func addMoreUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if (UserDefaults.standard.value(forKey: "ID") as! String) != (document.get("ID") as! String) && self.users.count < 50 {
                        var check = true
                        for rate in document.get("Rates") as! [String] {
                            if String(rate.suffix(rate.count-9)) == UserDefaults.standard.value(forKey: "ID") as! String {
                                check = false
                            }
                        }
                        if check {
                            let age = document.get("Age") as! String
                            let bio = document.get("Bio") as! [String]
                            let gender = document.get("Gender") as! String
                            let id = document.get("ID") as! String
                            let name = document.get("Name") as! String
                            let percentage = document.get("Percentage") as! Double
                            let profilepics = document.get("ProfilePics") as! [String]
                            let rates = document.get("Rates") as! [String]
                            let overallrating = document.get("OverallRating") as! Double
                            let appearancerating = document.get("AppearanceRating") as! Double
                            let personalityrating = document.get("PersonalityRating") as! Double
                            let selfrating = document.get("SelfRating") as! Double
                            let socials = document.get("Socials") as! [String]
                            self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials))
                        }
                    }
                }
            }
        }
    }
}


//MARK: CreateUser
func CreateUser(name: String, age: String, gender: String, percentage: Double, overallrating: Double, appearancerating: Double, personalityrating: Double, profilepics: [Data], photopostion: [Int], bio: [String], socials: [String], complete: @escaping (Bool)-> Void) {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    var newbio = [String]()
    
    db.collection("users").document(uid!).setData(["Name": name, "Age": age, "Gender": gender, "Percentage": percentage, "SelfRating": overallrating, "ProfilePics": [String](), "Bio": [String](), "Rates": [String](), "OverallRating": overallrating, "AppearanceRating": appearancerating, "PersonalityRating": personalityrating, "ID": uid!, "Lock": [Bool](), "Keys": 0, "Comments": [String](), "Socials": socials]) { (err) in
        if err != nil{
            print((err?.localizedDescription)!)
            complete(false)
            return
        }
    }
    
    for num in 0...9 {
        if bio[num].prefix(1) == "1" {
            db.collection("users").document(uid!).updateData(["Bio": FieldValue.arrayUnion([String(bio[num])[1..<bio[num].count]])]) { (err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    complete(false)
                    return
                }
                newbio.append(String(bio[num])[1..<bio[num].count])
            }
        }
    }
    
    for num in 0...3 {
        if profilepics[num].count != 0 {
            let metadata = StorageMetadata.init()
            metadata.contentType = "image/jpeg"
            let upload = storage.child("ProfilePics").child(uid! + String(num)).putData(profilepics[num], metadata: metadata) { (_, err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    complete(false)
                    return
                }
            }
            upload.observe(.success) { snapshot in
                storage.child("ProfilePics").child(uid! + String(num)).downloadURL { (url, err) in
                    if err != nil{
                        print((err?.localizedDescription)!)
                        complete(false)
                        return
                    }
                    images.append(String(num) + "\(url!)")
                    UserDefaults.standard.set(images, forKey: "ProfilePics")
                    if num == 3 {
                        UserDefaults.standard.set(name, forKey: "Name")
                        UserDefaults.standard.set(String(age), forKey: "Age")
                        UserDefaults.standard.set(gender, forKey: "Gender")
                        UserDefaults.standard.set(percentage, forKey: "Percentage")
                        UserDefaults.standard.set(overallrating, forKey: "SelfRating")
                        UserDefaults.standard.set(newbio, forKey: "Bio")
                        UserDefaults.standard.set(uid!, forKey: "ID")
                        UserDefaults.standard.set(appearancerating, forKey: "AppearanceRating")
                        UserDefaults.standard.set(personalityrating, forKey: "PersonalityRating")
                        complete(true)
                    }
                }
            }
        }
    }
}


//MARK: CheckUser
func CheckUser(complete: @escaping (Bool)->Void) {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    db.collection("users").getDocuments() { (querySnapshot, err) in
        if err != nil {
            print((err?.localizedDescription)!)
            return
        }
        else {
            for document in querySnapshot!.documents {
                if uid! == document.get("ID") as! String {
                    UserDefaults.standard.set(document.get("Age") as! String, forKey: "Age")
                    UserDefaults.standard.set(document.get("Bio") as! [String], forKey: "Bio")
                    UserDefaults.standard.set(document.get("Gender") as! String, forKey: "Gender")
                    UserDefaults.standard.set(document.get("ID") as! String, forKey: "ID")
                    UserDefaults.standard.set(document.get("Name") as! String, forKey: "Name")
                    UserDefaults.standard.set(document.get("Percentage") as! Double, forKey: "Percentage")
                    UserDefaults.standard.set(document.get("ProfilePics") as! [String], forKey: "ProfilePics")
                    UserDefaults.standard.set(document.get("Rates") as! [String], forKey: "Rates")
                    UserDefaults.standard.set(document.get("OverallRating") as! Double, forKey: "OverallRating")
                    UserDefaults.standard.set(document.get("AppearanceRating") as! Double, forKey: "AppearanceRating")
                    UserDefaults.standard.set(document.get("PersonalityRating") as! Double, forKey: "PersonalityRating")
                    UserDefaults.standard.set(document.get("SelfRating") as! Double, forKey: "SelfRating")
                    complete(true)
                }
            }
        }
    }
    complete(false)
}


//MARK: UpdateRating
func UpdateRating(user: UserData, appearance: Double, personality: Double, keys: Int, comment: String) {
    let overall = Double(Double(personality)*Double(user.Percentage).truncate(places: 2) + Double(appearance)*Double(1-user.Percentage).truncate(places: 2)).truncate(places: 1)
    let newoverall = Double(user.OverallRating*Double(user.Rates.count+1) + overall)/Double(user.Rates.count+2).truncate(places: 1)
    let newappearance = Double(user.AppearanceRating*Double(user.Rates.count+1) + appearance)/Double(user.Rates.count+2).truncate(places: 1)
    let newpersonality = Double(user.PersonalityRating*Double(user.Rates.count+1) + personality)/Double(user.Rates.count+2).truncate(places: 1)
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    db.collection("users").document(user.id).updateData(["OverallRating": newoverall.truncate(places: 1), "AppearanceRating": newappearance.truncate(places: 1), "PersonalityRating": newpersonality.truncate(places: 1), "Rates": FieldValue.arrayUnion([String(appearance.truncate(places: 1)) + String(personality.truncate(places: 1)) + String(overall) + uid!]), "Comments": FieldValue.arrayUnion([comment])])
    db.collection("users").document(uid!).updateData(["Key": keys])
    db.collection("users").document(user.id).updateData(["Lock": FieldValue.arrayUnion([false])])
    print(user.Percentage, newappearance, newpersonality, newoverall)
}


//MARK: Unlock
func Unlock(keys: Int, lock: [Bool]) {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    db.collection("users").document(uid!).updateData(["Keys": keys, "Lock": lock])
}


//MARK: Unlock Socials
func KeyChange(keys: Int) {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    db.collection("users").document(uid!).updateData(["Keys": keys])
}


//MARK: AddImages
func AddImages() {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    for num in 0...3 {
        for nu in 0...3 {
            if num == ((UserDefaults.standard.value(forKey: "ProfilePics") as! [String])[nu].prefix(1) as NSString).integerValue {
                images.append((UserDefaults.standard.value(forKey: "ProfilePics") as! [String])[nu].substring(fromIndex: 1))
                db.collection("users").document(uid!).updateData(["ProfilePics": FieldValue.arrayUnion([(UserDefaults.standard.value(forKey: "ProfilePics") as! [String])[nu].substring(fromIndex: 1)])])
            }
        }
    }
    if images.count == 4 {
        UserDefaults.standard.set(images, forKey: "ProfilePics")
    }
}


//MARK: ResizingTextField
struct ResizingTextField: UIViewRepresentable {
    @Binding var text: String
    func makeCoordinator() -> ResizingTextField.Coordinator {
        return ResizingTextField.Coordinator(parent1: self)
    }
    func makeUIView(context: UIViewRepresentableContext<ResizingTextField>) -> UITextView {
        let view = UITextView()
        view.font = UIFont(name: "ProximaNova-Regular", size: 15)
        if text.count == 0 {
            view.textColor = UIColor(named: "personality")!.withAlphaComponent(0.7)
            view.text = "Write Something"
        }
        else {
            view.textColor = UIColor(named: "personality")
            view.text = text
        }
        view.backgroundColor = .clear//UIColor(named: "lightgray")!.withAlphaComponent(0.3)
        view.delegate = context.coordinator
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.isScrollEnabled = true
        return view
    }
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<ResizingTextField>) {
    }
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: ResizingTextField
        init(parent1: ResizingTextField) {
            parent = parent1
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.text.count == 0 {
                textView.text = ""
                textView.textColor = UIColor(named: "personality")
            }
        }
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text!
        }
    }
}


//MARK: ResizingTextFieldRed
struct ResizingTextFieldRed: UIViewRepresentable {
    @Binding var text: String
    func makeCoordinator() -> ResizingTextFieldRed.Coordinator {
        return ResizingTextFieldRed.Coordinator(parent1: self)
    }
    func makeUIView(context: UIViewRepresentableContext<ResizingTextFieldRed>) -> UITextView {
        let view = UITextView()
        view.font = UIFont(name: "ProximaNova-Regular", size: 15)
        if text.count == 0 {
            view.textColor = UIColor(named: "personality")!.withAlphaComponent(0.25)
            view.text = "Leave a comment on what you liked the most about this person. Be Nice."
        }
        else {
            view.textColor = UIColor(named: "personality")
            view.text = text
        }
        view.backgroundColor = .white
        view.delegate = context.coordinator
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.isScrollEnabled = true
        return view
    }
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<ResizingTextFieldRed>) {
    }
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: ResizingTextFieldRed
        init(parent1: ResizingTextFieldRed) {
            parent = parent1
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = UIColor(named: "personality")
        }
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text!
        }
    }
}


//MARK: Bottom
struct BottomShape : Shape {
    func path(in rect: CGRect) -> Path {
        return Path{path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addArc(center: CGPoint(x: 8*rect.width/10, y: 0), radius: 25, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: false)
        }
    }
}


//MARK: Meter
struct Meter: Shape {
    var endangle: Double = 0
    func path(in rect: CGRect) -> Path {
        return Path {path in
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addArc(center: CGPoint(x: rect.width/2, y: rect.height), radius: rect.width/2, startAngle: .zero, endAngle: .init(degrees: endangle), clockwise: false)
            //path.addLine(to: CGPoint(x: (rect.width/2)*CGFloat(1+cos((180-endangle)*Double.pi/180)), y: rect.height-(rect.width/2*CGFloat(sin((180-endangle)*Double.pi/180)))))
            path.addLine(to: CGPoint(x: rect.width/2, y: rect.width/2))
            path.addLine(to: CGPoint(x: rect.width/2, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            //path.move(to: CGPoint(x: (rect.width/2)*CGFloat(1+cos((180-endangle)*Double.pi/180)), y: (rect.width/4)*CGFloat(sin((180-endangle)*Double.pi/180))))
            //path.addArc(center: CGPoint(x: rect.width/2, y: rect.height), radius: rect.width/4, startAngle: .init(degrees: endangle), endAngle: .zero, clockwise: false)*/
        }
    }
}


//MARK: Bar
struct Bar: View {
    @Binding var unlockindex: Int
    @Binding var unlock: Bool
    @Binding var homecomment: Bool
    @Binding var showprofile: Bool
    var index: Int = 0
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var rating: ratingtype
    @EnvironmentObject var observer: observer
    var body: some View {
        HStack(spacing: 10){
            Button(action: {
                if !self.observer.lock[self.index] {
                    self.unlockindex = self.index
                    self.unlock.toggle()
                }
                else {
                    self.unlockindex = self.index
                    self.showprofile = true
                }
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(Color("lightgray"))
                        .frame(width: 45, height: 45)
                    WebImage(url: URL(string: self.observer.ratesinfo[self.index].ProfilePics[0]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(25)
                        .blur(radius: !self.observer.lock[self.index] ? 4 : 0)
                    if !self.observer.lock[self.index] {
                        Image("lock")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }.padding(.leading, 10)
            }.buttonStyle(PlainButtonStyle())
            if self.observer.showratings[self.index] {
                Button(action: {
                    self.observer.showratings[self.index] = false
                }) {
                    VStack(spacing: 2.5) {
                        HStack(spacing: 0) {
                            ZStack() {
                                Rectangle()
                                    .fill(Color("appearance"))
                                    .frame(width: (self.screenwidth/22)*rating.appearance, height: self.screenheight*0.027)
                                    .cornerRadius(2.5)
                                Text(String(Double(rating.appearance)))
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("lightgray"))
                                    .animation(nil)
                            }
                            Spacer().frame(width: ((self.screenwidth/22)*10) - (self.screenwidth/22)*rating.appearance)
                        }.frame(width: self.screenwidth/2.2).background(Color("lightgray").cornerRadius(2.5))
                        HStack {
                            ZStack {
                                Rectangle()
                                    .fill(Color("personality"))
                                    .frame(width: (self.screenwidth/22)*rating.personality, height: self.screenheight*0.027)
                                    .cornerRadius(2.5)
                                Text(String(Double(rating.personality)))
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("lightgray"))
                                    .animation(nil)
                            }
                            Spacer().frame(width: ((self.screenwidth/22)*10) - (self.screenwidth/22)*rating.personality)
                        }.frame(width: self.screenwidth/2.2).background(Color("lightgray").cornerRadius(2.5))
                    }.frame(width: self.screenwidth/2.2)
                }
            }
            else {
                HStack {
                    Button(action: {
                        for num in 0...self.observer.numrates {
                            if num != self.index {
                                self.observer.showratings[num] = false
                            }
                        }
                        self.observer.showratings[self.index] = true
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(Color("purp"))
                                .frame(width: (self.screenwidth/22)*rating.overall, height: self.screenheight*0.057)
                                .cornerRadius(5)
                            Text(String(Double(rating.overall)))
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("lightgray"))
                        }
                    }
                    Spacer().frame(width: ((self.screenwidth/22)*10) - (self.screenwidth/22)*rating.overall)
                }.frame(width: self.screenwidth/2.2).background(Color("lightgray").cornerRadius(5))
            }
            Button(action: {
                self.unlockindex = self.index
                self.homecomment.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 45, height: 37.5)
                        .foregroundColor(Color("lightgray"))
                    Image("comment")
                        .resizable()
                        .frame(width: 35, height: 30)
                }
            }.buttonStyle(PlainButtonStyle())
                .padding(.trailing, 10)
        }
    }
}


//MARK: Rewarded
final class Rewarded: NSObject, GADRewardedAdDelegate{
    var rewardedAd:GADRewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-8107068593888585/2703558577") //"ca-app-pub-4206140009989967/9044631871")
    var rewardFunction: (() -> Void)? = nil
    override init() {
        super.init()
        LoadRewarded()
    }
    func LoadRewarded(){
        let req = GADRequest()
        self.rewardedAd.load(req)
    }
    func showAd(rewardFunction: @escaping () -> Void){
        if self.rewardedAd.isReady{
            self.rewardFunction = rewardFunction
            let root = UIApplication.shared.windows.first?.rootViewController
            self.rewardedAd.present(fromRootViewController: root!, delegate: self)
        }
       else{
           print("Not Ready")
       }
    }
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rf = rewardFunction {
            rf()
        }
    }
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/5224354917")
        //"ca-app-pub-8107068593888585/2703558577") //"ca-app-pub-4206140009989967/9044631871")
        LoadRewarded()
    }
}


//MARK: RatingAd
struct RatingAd : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<RatingAd>) -> GADBannerView {
        let ad = GADBannerView(adSize: kGADAdSizeBanner)
        //TODO: Redo
        ad.adUnitID = "ca-app-pub-8107068593888585/9123279654"
        //"ca-app-pub-4206140009989967/1095302745"
        ad.rootViewController = UIApplication.shared.windows.first?.rootViewController
        ad.load(GADRequest())
        return ad
    }
    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}


//MARK: Substring Extension
extension String {
    var length: Int {
        return count
    }
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


//MARK: LabelledDivider
struct LabelledDivider: View {
    let label: String
    let horizontalPadding: CGFloat
    let color: Color
    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }
    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
            line
        }
    }
    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}


//MARK: HideKeyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


//MARK: Ratingtype
struct ratingtype {
    var overall: CGFloat
    var appearance: CGFloat
    var personality: CGFloat
}


//MARK: UserData
struct UserData: Identifiable {
    var Age: String
    var Bio: [String]
    var Gender: String
    var id: String
    var Name: String
    var Percentage: Double
    var ProfilePics: [String]
    var Rates: [String]
    var OverallRating: Double
    var AppearanceRating: Double
    var PersonalityRating: Double
    var SelfRating: Double
    var Socials: [String]
}
