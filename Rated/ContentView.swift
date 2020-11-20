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
import SystemConfiguration

//MARK: MainView
struct MainView: View {
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @State var settings = UserDefaults.standard.value(forKey: "settings") as? Bool ?? false
    @State var rating = UserDefaults.standard.value(forKey: "rating") as? Bool ?? false
    @State var view = UserDefaults.standard.value(forKey: "view") as? Bool ?? false
    var rewardAd: Rewarded
    init() {
        self.rewardAd = Rewarded()
    }
    var body: some View {
        VStack {
            if status {
                NavigationView {
                    HomeView(rewardAd: self.rewardAd)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }.transition(.scale)
            }
            else {
                NavigationView {
                    FrontView(rewardAd: self.rewardAd)
                        .transition(.slide)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }.transition(.scale)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("StatusChange"), object: nil, queue: .main) { (_) in
                self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.settings = UserDefaults.standard.value(forKey: "settings") as? Bool ?? false
                self.rating = UserDefaults.standard.value(forKey: "rating") as? Bool ?? false
                self.view = UserDefaults.standard.value(forKey: "view") as? Bool ?? false
            }
        }
    }
}


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
                                        .foregroundColor(Color(.black).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                }.frame(width: screenwidth/2 - 80, height: 50)
                            }
                            TextField("", text: $enteredcode)
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .frame(width: screenwidth/2 - 80, height: 50)
                                .keyboardType(.numberPad)
                                .foregroundColor(.black)
                                .multilineTextAlignment(TextAlignment.center)
                            
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
                                        .foregroundColor(Color(.black))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                    ZStack {
                                        
                                        TextField("", text: $ccode)
                                            .foregroundColor(.black)
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
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
                                        .foregroundColor(Color(.black).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                }
                                TextField("", text: $phonenumber)
                                    .foregroundColor(Color(.black).opacity(0.75))
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
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


//MARK: SignUpView
struct SignUpView: View {
    @Binding var signup: Bool
    let headers = ["Phone Verification", "Phone Verification", "First Name", "Age", "Gender", "What Matters", "Rate Yourself", "Profile Pictures"]
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    @State var phonenumber = ""
    @State var ccode = "1"
    @State var coffset: CGFloat = 0
    @State var msg = ""
    @State var loading: Bool = false
    @State var alert: Bool = false
    @State var picker: Bool = false
    @State var confirm: Bool = false
    @State var verificationcode = ""
    @State var next: CGFloat = -8*UIScreen.main.bounds.width
    @State var enteredcode = ""
    @State var count: Int = 4
    @State var genders: Int = 0
    @State var genderoffest: CGFloat = 0
    @State var biocards: [String] = ["00General", "01Education", "02Occupation", "03Music", "04Sports", "05Movies", "06TV-Shows", "07Hobbies", "08Motto", "09Future"]
    @State var text: [String] = ["", "", "", "", "", "", "", "", "", ""]
    @State var selectedprompts = [true, false, false, false, false, false, false, false, false, false]
    @State var selectedinfo = [false, false, false, false, false, false, false, false, false, false]
    @State var showprofile: Bool = false
    @State var openness = [false, false, false, true, false, false, false]
    @State var conscientiousness = [false, false, false, true, false, false, false]
    @State var extraversion = [false, false, false, true, false, false, false]
    @State var agreeableness = [false, false, false, true, false, false, false]
    @State var neuroticism = [false, false, false, true, false, false, false]
    
    //Bio
    @State var edit = false
    @State var editselect: Int = 0
    
    @State var education = false
    @State var educationdata = [String]()
    
    @State var occupation = false
    @State var occupationdata = [String]()
    @State var occupationdata1 = [String]()
    
    @State var newsports = [String]()
    @State var newsportsselect = [Bool]()
    @State var sports = ["Basketball", "Hockey", "Football", "Soccer", "Baseball", "Bowling", "Swimming", "Track"]
    @State var sportsselect = [Bool](repeating: false, count: 8)
    @State var numsports: Int = 0
    @State var newitem = ""
    
    @State var hobbies = false
    @State var hobbiesdata = [String]()
    
    @State var mnt = false
    @State var mntdata = [String]()
    @State var mntgenres = [String]()
    
    @State var music = false
    @State var musicdata = [String]()
    @State var musicgenres = [String]()
    
    @State var starsign = ""
    @State var starsigns = ["Aquarius", "Aries", "Capricorn", "Cancer", "Gemini", "Leo", "Libra", "Pisces", "Sagittarius", "Scorpio", "Taurus", "Virgo"]
    @State var starsignsselect = [Bool](repeating: false, count: 12)
    
    //Image Picker
    @State var numimage: Int = 0
    @State var showimage = [false, false, false, false]
    @State var position = [0, 1, 2, 3]
    @State var current: [CGSize] = [.zero, .zero, .zero, .zero]
    @State var newcor: [CGSize] = [.zero, .zero, .zero, .zero]
    
    
    //Account Info
    @State var name = ""
    @State var age = ""
    var closedRange: ClosedRange<Date> {
        let hundredYears = Calendar.current.date(byAdding: .year, value: -99, to: Date())!
        let thenow = Date()
        
        return hundredYears...thenow
    }
    @State var bdate = ""
    @State var date = Date()
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
    
    @State var logged = false
    
    var body: some View {
        ZStack {
            ZStack {
                HStack(spacing: 0) {
                    //MARK: Phone Number 1
                    VStack(spacing: 20) {
                        Image("phone")
                            .resizable()
                            .padding(10)
                            .frame(width: 75, height: 75)
                        
                        Text("Enter Your Phone Number")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.medium)
                            .foregroundColor(Color(.black))
                        HStack(spacing: 15) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(width: self.ccode.count < 2 ? 50 : 65, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                
                                HStack(spacing: 0) {
                                    Text(self.ccode.isEmpty ? "" : "+")
                                        .foregroundColor(Color(.black))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                    ZStack {
                                        
                                        TextField("", text: $ccode)
                                            .foregroundColor(.black)
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.center)
                                    }
                                }.frame(width: self.ccode.count < 2 ? 30 : 45, height: 50)
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    //.stroke(lineWidth: 5)
                                    .foregroundColor(.white)
                                    .frame(width: screenwidth - 220, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                
                                if self.phonenumber.isEmpty {
                                    Text("Phone Number")
                                        .foregroundColor(Color(.black).opacity(0.5))
                                        .font(.body)
                                        .font(Font.custom("ProximaNova-Regular", size: 22))
                                }
                                TextField("", text: $phonenumber)
                                    .foregroundColor(Color(.black).opacity(0.75))
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .frame(width: screenwidth - 240, height: 50)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                            }
                            Button(action: {
                                /*if self.phonenumber.count == 10 {
                                    self.loading.toggle()
                                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.ccode + self.phonenumber, uiDelegate: nil) { (verificationID, error) in
                                        if error != nil {
                                            self.msg = (error?.localizedDescription)!
                                            self.loading.toggle()
                                            self.alert.toggle()
                                            return
                                        }
                                        self.loading.toggle()
                                        self.verificationcode = verificationID!*/
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    //}
                                //}
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 30, weight: .bold))
                                    .foregroundColor(self.phonenumber.count == 10 ? Color(.blue).opacity(0.5) : Color("lightgray"))
                                
                            }
                        }//.padding(.bottom, 20)
                        if loading {
                            WhiteLoader()
                        }
                        
                    }.frame(width: screenwidth, height: screenheight/1.3).offset(y: -100).animation(.spring())
                    
                    //MARK: Verification Code 2
                    VStack(spacing: 20) {
                        Image("phone")
                            .resizable()
                            .frame(width: 75, height: 75)
                        
                        Text("Enter The Verification Code")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                        
                        HStack(spacing: 15) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(width: screenwidth/2 - 60, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                if self.enteredcode.isEmpty {
                                    HStack {
                                        Text("Code")
                                            .foregroundColor(Color(.black).opacity(0.5))
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                    }.frame(width: screenwidth/2 - 80, height: 50)
                                }
                                TextField("", text: $enteredcode)
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .frame(width: screenwidth/2 - 80, height: 50)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(TextAlignment.center)
                                
                            }
                            Button(action: {
                                /*if self.enteredcode.count == 6 {
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
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                    self.logged = false
                                                    UserDefaults.standard.set(false, forKey: "signup")
                                                    UserDefaults.standard.set(true, forKey: "status")
                                                    NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                                                }
                                            }
                                            else {
                                                self.loading.toggle()*/
                                                self.next -= self.screenwidth
                                                self.count += 1/*
                                            }
                                        }
                                    }
                                }*/
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 30, weight: .bold))
                                    .foregroundColor(self.enteredcode.count == 6 ? Color(.blue).opacity(0.5) : Color("lightgray"))
                            }
                        }
                        
                        if loading {
                            WhiteLoader()
                        }
                    }.frame(width: screenwidth, height: screenheight/1.3).offset(y: -100)
                    
                    //MARK: Name 3
                    VStack {
                        Image("name")
                            .resizable()
                            .frame(width: 75, height: 75)
                        
                        Text("Enter Your First Name")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                        
                        HStack(spacing: 15) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(width: screenwidth - 120, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                if self.name.isEmpty {
                                    Text("First Name")
                                        .foregroundColor(Color(.black).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 22))
                                }
                                TextField("", text: $name)
                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                    .frame(width: screenwidth - 140, height: 50)
                                    .foregroundColor(Color(.black))
                                    .multilineTextAlignment(TextAlignment.center)
                            }
                            Button(action: {
                                if self.name.count > 0 {
                                    self.next -= self.screenwidth
                                    self.count += 1
                                }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 30, weight: .bold))
                                    .foregroundColor(self.name.count > 0 ? Color(.blue).opacity(0.5) : Color("lightgray"))
                            }
                        }
                    }.frame(width: screenwidth, height: screenheight/1.3).offset(y: -130)
                    
                    //MARK: Age 4
                    VStack {
                        Image("age")
                            .resizable()
                            .frame(width: 75, height: 75)
                        
                        Text("Enter Your Age")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                        
                        DatePicker("", selection: $date, in: closedRange, displayedComponents: .date)
                            .frame(width: screenwidth - 40)
                            .colorInvert()
                            .colorMultiply(Color.black)
                            .padding(.vertical, 10)
                            .background(Color(.white).cornerRadius(35).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                            .shadow(color: .white, radius: 15, x: -10, y: -10))
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            let components = Calendar.current.dateComponents([.year, .month, .day], from: self.date, to: Date())
                            self.age = String(components.year!)
                            print(self.date.description.prefix(10))
                            self.bdate = String(self.date.description.prefix(10))
                            if Int(self.age) ?? 0 < 18 {
                                self.msg = "You must be 18 or older to register."
                                self.alert.toggle()
                            }
                            else {
                            self.next -= self.screenwidth
                                self.count += 1
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 36, weight: .bold))
                                .foregroundColor(Calendar.current.dateComponents([.year, .month, .day], from: self.date, to: Date()).year! >= 18 ? Color(.blue).opacity(0.5) : Color("lightgray"))
                        }.padding(.top, 10)
                        
                    }.frame(width: screenwidth, height: screenheight/1.3)
                    
                    //MARK: Gender 5
                    VStack(spacing: 20) {
                        Image("gender")
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                            .frame(width: 75, height: 75)
                        
                        Text("Select Your Gender")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                        
                        ZStack {
                            Color(.white)
                                .frame(width: 270, height: 60)
                                .cornerRadius(15)
                                .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                .shadow(color: .white, radius: 15, x: -10, y: -10)
                            
                            if self.genders == 0 {
                                
                            }
                            else {
                                HStack(spacing: 0) {
                                    RoundedRectangle(cornerRadius: 15).frame(width: 85, height: 55)
                                }.foregroundColor(Color("lightgray").opacity(0.5)).offset(x: self.genderoffest)
                            }
                            
                            HStack(spacing: 0) {
                                
                                Button(action: {
                                    self.genders = 1
                                    self.genderoffest = -90
                                    self.gender = "Male"
                                }) {
                                    Text("Male")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.black))
                                }.frame(width: 90)
                                
                                Button(action: {
                                    self.genders = 2
                                    self.genderoffest = 0
                                    self.gender = "Female"
                                }) {
                                    Text("Female")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.black))
                                }.frame(width: 90)
                                
                                Button(action: {
                                    self.genders = 3
                                    self.genderoffest = 90
                                    self.gender = ""
                                }) {
                                    Text("Other")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.black))
                                }.frame(width: 90)
                                
                            }
                            
                            
                        }.animation(.spring()).padding(.bottom, self.genders != 3 ? 30 : 0)
                        
                        if self.genders == 3 {
                            Text("Specify Your Gender")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black))
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(width: screenwidth - 120, height: 50)
                                    .shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10)
                                    .shadow(color: .white, radius: 15, x: -10, y: -10)
                                
                                if self.gender.count < 1 {
                                    Text("Gender")
                                        .foregroundColor(Color(.black).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                }
                                TextField("", text: $gender)
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .frame(width: screenwidth - 140, height: 50)
                                    .foregroundColor(Color(.black))
                                    .multilineTextAlignment(TextAlignment.center)
                            }.padding(.bottom, 30)
                        }
                        
                        Button(action: {
                            if self.genders == 3 && self.gender.isEmpty || self.genders == 0 {
                                
                            }
                            else {
                                self.next -= self.screenwidth
                                self.count += 1
                            }
                        })  {
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 36, weight: .bold))
                                .foregroundColor(!(self.genders == 3 && self.gender.isEmpty || self.genders == 0) ? Color(.blue).opacity(0.5) : Color("lightgray"))
                        }
                        
                    }.animation(.spring()).frame(width: screenwidth, height: screenheight/1.3).offset(y: self.genders == 3 ? -80 : -50)
                    
                    //MARK: What Matters? 6
                    VStack {
                        HStack(spacing: 40) {
                            Image("eye")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 75, height: 80)
                                .foregroundColor(Color("appearance"))
                            
                            Image("heart")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(Color("personality"))
                        }.padding(.top, 30)
                        
                        Text("Appearance vs Personality")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                            .multilineTextAlignment(.center)
                        
                        Text("(This is how your rating will be calculated)")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkGray))
                        
                        PercentageSlider(percentage: self.$percentage)
                            .frame(width: 90, height: screenheight/2.25)
                            .accentColor(Color("personality"))
                            .padding(10)
                            .background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            .padding(.bottom, 25)
                        
                        Button(action: {
                            self.next -= self.screenwidth
                            self.count += 1
                        }) {
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 36, weight: .bold))
                                .foregroundColor(Color(.blue).opacity(0.5))
                        }
                    }.frame(width: screenwidth, height: screenheight)
                    
                    Group {
                        //MARK: Rate Yourself 7
                        VStack {
                            /*Image("rating(temp)")
                                .resizable()
                                .frame(width: 75, height: 75)*/
                            GIFView(gifName: "rategif")
                                .frame(width: 100, height: 50)
                                
                            Text("Rate Yourself")
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black))
                            
                            HStack(spacing: 45) {
                                VerticalSlider(percentage: self.$selfratingappearance, title: "Appearance")
                                    .frame(width: 90, height: screenheight/2.25)
                                    .accentColor(Color("appearance"))
                                    .padding(7.5)
                                    .background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                
                                VerticalSlider(percentage: self.$selfratingpersonality, title: "Personality")
                                    .frame(width: 90, height: screenheight/2.25)
                                    .accentColor(Color("personality"))
                                    .padding(7.5)
                                    .background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            }.padding(.vertical, 25)
                            
                            Button(action: {
                                self.next -= self.screenwidth
                                self.count += 1
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(.blue).opacity(0.5))
                            }
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Profile Pictures 8
                        VStack(spacing: 20) {
                            
                            Image("profilepic")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .padding(.top, 30)
                            
                            Text("Select Four Pictures")
                                .font(Font.custom("ProximaNova-Regular", size: 26))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            VStack(spacing: 35) {
                                HStack(spacing: 35) {
                                    Button(action: {
                                        self.picker.toggle()
                                        self.numimage = 0
                                    }) {
                                        if !self.showimage[0] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                    .cornerRadius(15)
                                                Text("1")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color(.darkGray))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[0])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                .cornerRadius(15)
                                        }
                                    }.padding(7.5)
                                    .background(Color(.white).cornerRadius(20).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                    
                                    Button(action: {
                                        self.picker.toggle()
                                        self.numimage = 1
                                    }) {
                                        if !self.showimage[1] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                    .cornerRadius(15)
                                                Text("2")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color(.darkGray))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[1])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                .cornerRadius(15)
                                        }
                                    }.padding(7.5)
                                    .background(Color(.white).cornerRadius(20).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                }
                                HStack(spacing: 35) {
                                    Button(action: {
                                        self.picker.toggle()
                                        self.numimage = 2
                                    }) {
                                        if !self.showimage[2] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                    .cornerRadius(15)
                                                Text("3")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color(.darkGray))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[2])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                .cornerRadius(15)
                                        }
                                    }.padding(7.5)
                                    .background(Color(.white).cornerRadius(20).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                    
                                    Button(action: {
                                        self.picker.toggle()
                                        self.numimage = 3
                                    }) {
                                        if !self.showimage[3] {
                                            ZStack {
                                                Color(.white)
                                                    .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                    .cornerRadius(15)
                                                Text("4")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .foregroundColor(Color(.darkGray))
                                            }
                                        }
                                        else {
                                            Image(uiImage: UIImage(data: self.profilepics[3])!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: self.screenwidth*0.267, height: self.screenheight*0.164)
                                                .cornerRadius(15)
                                        }
                                    }.padding(7.5)
                                    .background(Color(.white).cornerRadius(20).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                    
                                }
                            }.padding(20)
                            
                            Button(action: {
                                /*for val in self.showimage {
                                    if !val {
                                        return
                                    }
                                }*/	
                                self.next -= self.screenwidth
                                self.count += 1
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .foregroundColor((self.profilepics[0].count != 0 && self.profilepics[1].count != 0 && self.profilepics[2].count != 0 && self.profilepics[3].count != 0) ? Color(.blue).opacity(0.5) : Color("lightgray"))
                            }
                        }.frame(width: screenwidth, height: screenheight)
                    }
                    
                    Group {
                        //MARK: New Bio 9
                        VStack {
                            Text("Personality Traits")
                                .font(Font.custom("ProximaNova-Regular", size: 28))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.top, 80)
                            
                            VStack(spacing: 7.5) {
                                VStack(spacing: 5) {
                                    HStack {
                                        Text("Openness")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                        Image("openness")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color(.darkGray))
                                    }
                                    VStack(spacing: 2.5) {
                                        HStack {
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.openness = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.openness = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.openness = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[6] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, false, false, false, true]
                                                }
                                        }
                                        HStack(alignment: .top) {
                                            Text("calculative practical")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                            
                                            Text("neutral")
                                                .font(Font.custom("ProximaNova-Regular", size: 12))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            
                                            Spacer()
                                            
                                            Text("creative imaginative")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }.padding(.horizontal, 30)
                                    }
                                }
                                VStack(spacing: 5) {
                                    HStack {
                                        Text("Conscientiousness")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                        Image("conscientiousness")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color(.darkGray))
                                    }
                                    VStack(spacing: 2.5) {
                                        HStack {
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.conscientiousness = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[6] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, false, false, false, true]
                                                }
                                        }
                                        HStack(alignment: .top) {
                                            Text("careless disorganized")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                            
                                            Text("neutral")
                                                .font(Font.custom("ProximaNova-Regular", size: 12))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            
                                            Spacer()
                                            
                                            Text("focused organized")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }.padding(.horizontal, 30)
                                    }
                                }
                                VStack(spacing: 5) {
                                    HStack {
                                        Text("Extraverision")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                        Image("extraversion")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color(.darkGray))
                                    }
                                    
                                    VStack(spacing: 2.5) {
                                        HStack {
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.extraversion = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.extraversion = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[6] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, false, false, false, true]
                                                }
                                        }
                                        HStack(alignment: .top) {
                                            Text("reserved solitary")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                            
                                            Text("neutral")
                                                .font(Font.custom("ProximaNova-Regular", size: 12))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            
                                            Spacer()
                                            
                                            Text("outgoing adventurous")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }.padding(.horizontal, 30)
                                    }
                                }
                                VStack(spacing: 5) {
                                    HStack {
                                        Text("Agreeableness")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                        Image("agreeableness")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color(.darkGray))
                                    }
                                    
                                    VStack(spacing: 2.5) {
                                        HStack {
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.agreeableness = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.agreeableness = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[6] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, false, false, false, true]
                                                }
                                        }
                                        HStack(alignment: .top) {
                                            Text("critical \n hostile")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                            
                                            Text("neutral")
                                                .font(Font.custom("ProximaNova-Regular", size: 12))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            
                                            Spacer()
                                            
                                            Text("friendly empathetic")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }.padding(.horizontal, 30)
                                    }
                                }
                                VStack(spacing: 5) {
                                    HStack {
                                        Text("Neuroticism")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                        Image("neuroticism")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color(.darkGray))
                                    }
                                
                                    VStack(spacing: 2.5) {
                                        HStack {
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.neuroticism = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.neuroticism = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color("purp").opacity(0.6))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[6] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, false, false, false, true]
                                                }
                                        }
                                        HStack(alignment: .top) {
                                            Text("confident secure")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                            
                                            Text("neutral")
                                                .font(Font.custom("ProximaNova-Regular", size: 12))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            
                                            Spacer()
                                            
                                            Text("anxious sensitive")
                                                .font(Font.custom("ProximaNova-Regular", size: 10))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .multilineTextAlignment(.center)
                                                .frame(width: 65)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }.padding(.horizontal, 30)
                                    }
                                }
                            }
                            
                            Button(action: {
                                self.next -= self.screenwidth
                                self.count += 1
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(.blue).opacity(0.5))
                            }
                        }.frame(width: screenwidth, height: screenheight)
                        
                        
                        //MARK: Education
                        VStack(spacing: 0) {
                            Spacer()
                            Image("Education")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(spacing: 20) {
                                Text("Education")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                
                                ForEach(educationdata, id: \.self) { data in
                                    HStack {
                                        Image("education-2")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(.trailing, 10)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(data.prefix(data.count - 4))
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            Text(data.suffix(4))
                                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray).opacity(0.5))
                                        }
                                        Spacer()
                                        Rectangle()
                                            .frame(width: 2.5, height: 70)
                                            .foregroundColor(Color(.gray))
                                            .opacity(0.5)
                                        Image(systemName: "line.horizontal.3")
                                            .font(Font.system(size: 20, weight: .heavy))
                                            .foregroundColor(Color(.darkGray))
                                            .padding(.leading, 10)
                                            .onTapGesture {
                                                self.editselect = self.educationdata.firstIndex(of: data)!
                                                self.edit = true
                                                self.education.toggle()
                                                self.picker = true
                                            }
                                    }.padding(.horizontal, 20).frame(width: self.screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10)) //RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color("purp")))
                                }
                                
                                if self.educationdata.count != 0 && self.educationdata.count != 5 {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: screenwidth - 40, height: 5)
                                        .foregroundColor(Color(.darkGray))
                                }
                                
                                if self.educationdata.count != 5 {
                                    Button(action: {
                                        self.education = true
                                        self.picker.toggle()
                                    }) {
                                        HStack {
                                            Text("Add School")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            Image("education-2")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.darkGray))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(Font.system(size: 18, weight: .heavy))
                                                .foregroundColor(Color(.darkGray))
                                        }.padding(.horizontal, 20).frame(width: screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                    }
                                }
                                
                                Spacer()
                                
                                if self.educationdata.count > 0 {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .padding(.bottom, 50)
                                            .opacity(0.7)
                                    }
                                }
                                else {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .padding(.bottom, 50)
                                            .opacity(0.4)
                                    }
                                }
                            }.frame(width: screenwidth, height: screenheight/1.3)
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Occupation
                        VStack {
                            Spacer()
                            Image("Occupation")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(spacing: 20) {
                                Text("Occupation")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                
                                if self.occupationdata.count > 0 {
                                    ForEach(1...self.occupationdata.count, id: \.self) { data in
                                        HStack {
                                            Image("occupation-1")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.darkGray))
                                                .padding(.trailing, 10)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(self.occupationdata[data-1])
                                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.darkGray))
                                                Text(self.occupationdata1[data-1])
                                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.darkGray).opacity(0.5))
                                            }
                                            Spacer()
                                            Rectangle()
                                                .frame(width: 2.5, height: 70)
                                                .foregroundColor(Color(.gray))
                                                .opacity(0.5)
                                            Image(systemName: "line.horizontal.3")
                                                .font(Font.system(size: 20, weight: .heavy))
                                                .foregroundColor(Color(.darkGray))
                                                .padding(.leading, 10)
                                                .onTapGesture {
                                                    self.editselect = data - 1
                                                    self.edit = true
                                                    self.occupation.toggle()
                                                    self.picker = true
                                                }
                                        }.padding(.horizontal, 20).frame(width: self.screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color("purp")))
                                    }
                                }
                                
                                
                                if self.occupationdata.count != 0 && self.occupationdata.count != 5 {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: screenwidth - 40, height: 5)
                                        .foregroundColor(Color(.darkGray))
                                }
                                
                                if self.occupationdata.count != 5 {
                                    Button(action: {
                                        self.occupation = true
                                        self.picker.toggle()
                                    }) {
                                        HStack {
                                            Text("Add Occupation")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            Image("occupation-1")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.darkGray))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(Font.system(size: 18, weight: .heavy))
                                                .foregroundColor(Color(.darkGray))
                                        }.padding(.horizontal, 20).frame(width: screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                    }
                                }
                                
                                Spacer()
                                
                                if self.occupationdata.count > 0 {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .padding(.bottom, 50)
                                            .opacity(0.7)
                                    }
                                }
                                else {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .padding(.bottom, 50)
                                            .opacity(0.4)
                                    }
                                }
                            }.frame(width: screenwidth, height: screenheight/1.3)
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Sports
                        VStack {
                            Spacer()
                            Image("Sports")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(spacing: 15) {
                                Text("Sports")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    //.padding(.bottom, 10)
                                HStack(spacing: 15) {
                                    if self.newsports.count < 5 {
                                        ZStack {
                                            if self.newitem.count < 1 {
                                                Text("Other")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.black)
                                                    .opacity(0.5)
                                            }
                                            TextField("", text: self.$newitem)
                                                .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                                                .foregroundColor(Color(.darkGray))
                                                .padding(10)
                                                .frame(width: screenwidth - 180, height: 40)
                                                .multilineTextAlignment(.center)
                                        }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                    }
                                    Button(action: {
                                        if self.newitem.count > 0 {
                                            self.newsports.insert(self.newitem, at: 0)
                                            self.newsportsselect.insert(true, at: 0)
                                            self.newitem = ""
                                            self.numsports += 1
                                        }
                                        
                                    }) {
                                        Image(systemName: "plus")
                                            .font(Font.system(size: self.newitem.count > 0 ? 20 : 14, weight: .heavy))
                                            .foregroundColor(Color("purp"))
                                            .opacity(self.newitem.count > 0 ? 1 : 0.3)
                                    }
                                }
                                VStack(spacing: 0) {
                                    if self.newsports.count > 0 {
                                        ScrollView(showsIndicators: false) {
                                            ForEach(0...(self.newsportsselect.count-1), id: \.self) { ind in
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        Text(self.newsports[ind])
                                                            .font(Font.custom("ProximaNova-Regular", size: 16))
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(self.newsportsselect[ind] ? Color(.white) : Color(.darkGray))
                                                            .fixedSize(horizontal: true, vertical: false)
                                                            .animation(nil)
                                                    }.padding(10).frame(width: 225, height: 50)
                                                }.background(Color(self.newsportsselect[ind] ? .darkGray : .white).cornerRadius(10).shadow(color: Color(.black).opacity(self.newsportsselect[ind] ? 0 : 0.1), radius: 15, x: 10, y: 10)).padding(.vertical, 2.5).padding(.horizontal, 30)
                                                    .onTapGesture {
                                                    if self.newsportsselect[ind] {
                                                        self.numsports -= 1
                                                    }
                                                    else {
                                                        self.numsports += 1
                                                    }
                                                    self.newsportsselect[ind] = !self.newsportsselect[ind]
                                                }
                                            }
                                        }.frame(height: self.newsports.count > 1 ? 100 : 60).padding(.vertical, 10)
                                        RoundedRectangle(cornerRadius: 2)
                                            .frame(width: 260, height: 5)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(.horizontal, 10)
                                    }
                                    VStack(spacing: 0) {
                                        ScrollView(showsIndicators: false) {
                                            VStack(spacing: 5) {
                                                ForEach(0...(self.sportsselect.count-1), id: \.self) { ind in
                                                    HStack {
                                                        Image((self.sports[ind]).lowercased())
                                                            .renderingMode(.template)
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundColor(self.sportsselect[ind] ? Color(.white) : Color(.darkGray))
                                                            .padding(.leading, 10)
                                                        Text(self.sports[ind])
                                                            .font(Font.custom("ProximaNova-Regular", size: 16))
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(self.sportsselect[ind] ? Color(.white) : Color(.darkGray))
                                                            .fixedSize(horizontal: true, vertical: false)
                                                            .padding(.trailing, 10)
                                                    }.padding(10).frame(width: 225, height: 50)
                                                        .background(Color(self.sportsselect[ind] ? .darkGray : .white).cornerRadius(10).shadow(color: Color(.black).opacity(self.sportsselect[ind] ? 0 : 0.1), radius: 15, x: 10, y: 10))
                                                    .onTapGesture {
                                                        if self.sportsselect[ind] {
                                                            self.numsports -= 1
                                                        }
                                                        else {
                                                            self.numsports += 1
                                                        }
                                                        self.sportsselect[ind] = !self.sportsselect[ind]
                                                    }
                                                }
                                            }.padding(.horizontal, 30).padding(.bottom, 15)
                                        }.frame(width: 250, height: self.newsports.count > 0 ? 280 : 320).padding(10)
                                    }
                                }//.background(Color(.white).cornerRadius(20).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                Spacer()
                                
                                if self.numsports > 0 {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                        self.newitem = ""
                                    }) {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .padding(.bottom, 50)
                                            .opacity(0.7)
                                    }
                                }
                                else {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                        self.newitem = ""
                                    }) {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .padding(.bottom, 50)
                                            .opacity(0.4)
                                    }
                                }
                            }.frame(height: screenheight/1.29)
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Hobbies
                        VStack {
                            Spacer()
                            Image("Hobbies")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack {
                                Text("Hobbies")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                if self.hobbiesdata.count < 5 {
                                    HStack(spacing: 15) {
                                        ZStack {
                                            if self.newitem.count < 1 {
                                                Text("Hobby")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.black)
                                                    .opacity(0.5)
                                            }
                                            TextField("", text: self.$newitem)
                                                .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                                                .foregroundColor(Color(.darkGray))
                                                .padding(10)
                                                .frame(width: screenwidth - 180, height: 40)
                                                .multilineTextAlignment(.center)
                                        }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                        Button(action: {
                                            if self.newitem.count > 0 {
                                                self.hobbiesdata.insert(self.newitem, at: 0)
                                                self.newitem = ""
                                            }
                                            
                                        }) {
                                            Image(systemName: "plus")
                                                .font(Font.system(size: self.newitem.count > 0 ? 20 : 14, weight: .heavy))
                                                .foregroundColor(Color("purp"))
                                                .opacity(self.newitem.count > 0 ? 1 : 0.3)
                                        }
                                    }
                                }
                                ForEach(hobbiesdata, id: \.self) { hobbie in
                                    HStack {
                                        Image("hobbies-1")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(.trailing, 10)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(hobbie)
                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                        }
                                        Spacer()
                                        Rectangle()
                                            .frame(width: 2.5, height: 70)
                                            .foregroundColor(Color(.gray))
                                            .opacity(0.5)
                                        Image(systemName: "line.horizontal.3")
                                            .font(Font.system(size: 20, weight: .heavy))
                                            .foregroundColor(Color(.darkGray))
                                            .padding(.leading, 10)
                                            .onTapGesture {
                                                
                                            }
                                    }.padding(.vertical, 5).padding(.horizontal, 20).frame(width: self.screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color("purp")))
                                }
                                Spacer()
                                if self.hobbiesdata.count > 0 {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .padding(.bottom, 50)
                                            .opacity(0.7)
                                    }
                                }
                                else {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .padding(.bottom, 50)
                                            .opacity(0.4)
                                    }
                                }
                            }.frame(height: screenheight/1.3)
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Movies/TV
                        VStack {
                            Spacer()
                            Image("Movies")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(spacing: 15) {
                                Text("Movies and TV")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                if self.mntdata.count > 0 {
                                    VStack {
                                        ForEach(0...self.mntdata.count-1, id: \.self) { data in
                                            HStack {
                                                Image(self.mntgenres[data])
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(Color(.darkGray))
                                                    .padding(.trailing, 10)
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Text(self.mntdata[data])
                                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.darkGray))
                                                    Text(self.mntgenres[data])
                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.darkGray).opacity(0.5))
                                                }
                                                Spacer()
                                                Rectangle()
                                                    .frame(width: 2.5, height: 70)
                                                    .foregroundColor(Color(.gray))
                                                    .opacity(0.5)
                                                Image(systemName: "line.horizontal.3")
                                                    .font(Font.system(size: 20, weight: .heavy))
                                                    .foregroundColor(Color(.darkGray))
                                                    .padding(.leading, 10)
                                                    .onTapGesture {
                                                        self.editselect = data
                                                        self.edit = true
                                                        self.mnt.toggle()
                                                        self.picker = true
                                                    }
                                            }.padding(.horizontal, 20).frame(width: self.screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                        }
                                    }.padding(.vertical, 10)
                                }
                                
                                
                                if self.mntdata.count != 0 && self.mntdata.count != 5 {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: screenwidth - 40, height: 5)
                                        .foregroundColor(Color(.darkGray))
                                }
                                
                                if self.mntdata.count != 5 {
                                    Button(action: {
                                        self.mnt = true
                                        self.picker.toggle()
                                    }) {
                                        HStack {
                                            Text("Add Movie/Show")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            Image("movieandtv")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.darkGray))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(Font.system(size: 18, weight: .heavy))
                                                .foregroundColor(Color(.darkGray))
                                        }.padding(.horizontal, 20).frame(width: screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                    }
                                }
                                
                                Spacer()
                                
                                if self.mntdata.count > 0 {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .padding(.bottom, 50)
                                            .opacity(0.7)
                                    }
                                }
                                else {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .padding(.bottom, 50)
                                            .opacity(0.4)
                                    }
                                }
                            }.frame(height: screenheight/1.3)
                        }.frame(width: screenwidth, height: screenheight)
                        
                        
                        //MARK: Music
                        VStack {
                            Spacer()
                            Image("Music")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(spacing: 15) {
                                Text("Music")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                if self.musicdata.count > 0 {
                                    VStack {
                                        ForEach(0...self.musicdata.count-1, id: \.self) { data in
                                            HStack {
                                                Image(self.musicgenres[data])
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(Color(.darkGray))
                                                    .padding(.trailing, 10)
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Text(self.musicdata[data])
                                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.darkGray))
                                                    Text(self.musicgenres[data])
                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.darkGray).opacity(0.5))
                                                }
                                                Spacer()
                                                Rectangle()
                                                    .frame(width: 2.5, height: 70)
                                                    .foregroundColor(Color(.gray))
                                                    .opacity(0.5)
                                                Image(systemName: "line.horizontal.3")
                                                    .font(Font.system(size: 20, weight: .heavy))
                                                    .foregroundColor(Color(.darkGray))
                                                    .padding(.leading, 10)
                                                    .onTapGesture {
                                                        self.editselect = data
                                                        self.edit = true
                                                        self.music.toggle()
                                                        self.picker = true
                                                    }
                                            }.padding(.horizontal, 20).frame(width: self.screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color("purp")))
                                        }
                                    }.padding(.vertical, 10)
                                }
                                
                                
                                if self.musicdata.count != 0 && self.musicdata.count != 5 {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: screenwidth - 40, height: 5)
                                        .foregroundColor(Color(.darkGray))
                                }
                                
                                if self.musicdata.count != 5 {
                                    Button(action: {
                                        self.music = true
                                        self.picker.toggle()
                                    }) {
                                        HStack {
                                            Text("Add Song")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                            Image("song")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(.darkGray))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(Font.system(size: 18, weight: .heavy))
                                                .foregroundColor(Color(.darkGray))
                                        }.padding(.horizontal, 20).frame(width: screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                                    }
                                }
                                
                                Spacer()
                                
                                if self.musicdata.count > 0 {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .padding(.bottom, 50)
                                            .opacity(0.7)
                                    }
                                }
                                else {
                                    Button(action: {
                                        self.next -= self.screenwidth
                                        self.count += 1
                                    }) {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .padding(.bottom, 50)
                                            .opacity(0.4)
                                    }
                                }
                            }.frame(height: screenheight/1.3)
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Star Sign
                        VStack {
                            Spacer()
                            Image("Astrology")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(spacing: 15) {
                                Text("Star Sign")
                                    .font(Font.custom("ProximaNova-Regular", size: 34))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                ScrollView {
                                    VStack {
                                        ForEach(0...self.starsigns.count-1, id: \.self) { ind in
                                            VStack(spacing: 5) {
                                                Button(action: {
                                                    self.starsignsselect = [Bool](repeating: false, count: 12)
                                                    self.starsignsselect[ind] = true
                                                    self.starsign = self.starsigns[ind]
                                                }) {
                                                    HStack {
                                                        Image(self.starsigns[ind])
                                                            .renderingMode(.template)
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundColor(self.starsignsselect[ind] ? Color(.white) : Color(.darkGray).opacity(0.8))
                                                        Text(self.starsigns[ind])
                                                            .font(Font.custom("ProximaNova-Regular", size: 16))
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(self.starsignsselect[ind] ? Color(.white) : Color(.darkGray).opacity(0.8))
                                                            .fixedSize(horizontal: true, vertical: false)
                                                    }.padding(20).frame(width: 280)
                                                }.background(Color(self.starsignsselect[ind] ? .darkGray : .white).cornerRadius(10).shadow(color: Color(.black).opacity(self.starsignsselect[ind] ? 0 : 0.1), radius: 15, x: 10, y: 10))
                                            }
                                        }
                                    }.padding(.vertical, 25).padding(.horizontal, 40)
                                }.frame(height: 450)
                                
                                Spacer()
                                
                                Button(action: {
                                    self.next -= self.screenwidth
                                    self.count += 1
                                }) {
                                    if self.starsign.count > 0 {
                                        Text("Next")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.white))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(Color(.darkGray).cornerRadius(20))
                                            .opacity(0.7)
                                    }
                                    else {
                                        Text("Skip")
                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10).padding(.horizontal, 20)
                                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                            .opacity(0.4)
                                    }
                                }.padding(.bottom, 50)
                            }.frame(height: screenheight/1.3)
                        }.frame(width: screenwidth, height: screenheight)
                    }
                    
                    /*MARK: Prompts Select 9
                    VStack(spacing: 10) {
                        
                        Text("Select Topics To Create Your Bio")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .multilineTextAlignment(.center)
                        
                        Text("(Press on the topics to bring up more info. Press the checkmark to select the topics you like and then press the pencil to edit them.)")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.darkGray))
                            .padding(.horizontal, 25)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(biocards, id: \.self) { title in
                                BioCards(selected: self.$selectedprompts, showinfo: self.$selectedinfo, text: self.$text, index: (title.prefix(2) as NSString).integerValue, title: String(title.suffix(title.count-2)))
                            }
                        }.padding(.vertical, 15)
                            .frame(width: screenwidth - 60, height: screenheight/1.75)
                            .background(Color("lightgray").opacity(0.6).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            .cornerRadius(35)
                        
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
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 36, weight: .bold))
                                .foregroundColor(Color(.blue).opacity(0.5))
                        }
                    }.frame(width: screenwidth, height: screenheight)*/
                    
                    //MARK: Socials 10
                    VStack {
                        Text("Socials")
                            .font(Font.custom("ProximaNova-Regular", size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("(These social media handles will be public.)")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.darkGray))
                            .padding([.horizontal, .bottom], 20)
                        VStack(spacing: 20) {
                            HStack {
                                Image("instagram")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .padding(10)
                                if self.instagram {
                                    ZStack {
                                        if self.instagramhandle.count < 1 {
                                            Text("Instagram Handle")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .foregroundColor(.black)
                                                .opacity(0.5)
                                        }
                                        TextField("", text: self.$instagramhandle)
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                            .foregroundColor(.black)
                                            .padding(10)
                                            .frame(width: 140, height: 40)
                                            .multilineTextAlignment(.center)
                                    }.padding(5).background(Color("lightgray").opacity(0.5).cornerRadius(15))
                                }
                                Button(action: {
                                    self.instagram.toggle()
                                }) {
                                    Image(systemName: self.instagram ? "xmark" : "checkmark")
                                        .font(Font.system(size: 36, weight: .bold))
                                        .foregroundColor(self.instagram ? Color("personality") : .gray)
                                }.padding(10).buttonStyle(PlainButtonStyle())
                            }.background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            HStack {
                                Image("twitter")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .padding(10)
                                if self.twitter {
                                    ZStack {
                                        if self.twitterhandle.count < 1 {
                                            Text("Twitter Handle")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .foregroundColor(.black)
                                                .opacity(0.5)
                                        }
                                        TextField("", text: self.$twitterhandle)
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                            .foregroundColor(.black)
                                            .padding(10)
                                            .frame(width: 140, height: 40)
                                            .multilineTextAlignment(.center)
                                    }.padding(5).background(Color("lightgray").opacity(0.5).cornerRadius(15))
                                }
                                Button(action: {
                                    self.twitter.toggle()
                                }) {
                                    Image(systemName: self.twitter ? "xmark" : "checkmark")
                                        .font(Font.system(size: 36, weight: .bold))
                                        .foregroundColor(self.twitter ? Color("personality") : .gray)
                                }.padding(10).buttonStyle(PlainButtonStyle())
                            }.background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            HStack {
                                Image("snapchat")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .padding(10)
                                if self.snapchat {
                                    ZStack {
                                        if self.snapchathandle.count < 1 {
                                            Text("Snapchat Handle")
                                                .font(Font.custom("ProximaNova-Regular", size: 18))
                                                .foregroundColor(.black)
                                                .opacity(0.5)
                                        }
                                        TextField("", text: self.$snapchathandle)
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                            .foregroundColor(.black)
                                            .padding(10)
                                            .frame(width: 140, height: 40)
                                            .multilineTextAlignment(.center)
                                    }.padding(5).background(Color("lightgray").opacity(0.5).cornerRadius(15))
                                }
                                Button(action: {
                                    self.snapchat.toggle()
                                }) {
                                    Image(systemName: self.snapchat ? "xmark" : "checkmark")
                                        .font(Font.system(size: 36, weight: .bold))
                                        .foregroundColor(self.snapchat ? Color("personality") : .gray)
                                }.padding(10).buttonStyle(PlainButtonStyle())
                            }.background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                        }
                        
                        if self.loading {
                            WhiteLoader()
                        }
                        else {
                            Button(action: {
                                if self.instagram && self.instagramhandle.isEmpty || self.twitter && self.twitterhandle.isEmpty || self.snapchat && self.snapchathandle.isEmpty {
                                    
                                }
                                else {
                                    self.loading.toggle()
                                    if !self.instagram {
                                        self.instagramhandle = "N/A"
                                    }
                                    if !self.twitter {
                                        self.twitterhandle = "N/A"
                                    }
                                    if !self.snapchat {
                                        self.snapchathandle = "N/A"
                                    }
                                    let socials = [self.instagramhandle, self.snapchathandle, self.twitterhandle]
                                    
                                    let per = Double(self.percentage/10).truncate(places: 1)
                                    
                                    let overall = Double(Double(self.selfratingpersonality)*per + Double(self.selfratingappearance)*Double(1-per)).truncate(places: 1)
                                    
                                    CreateUser(name: self.name, bdate: self.bdate, gender: self.gender, percentage: per, overallrating: overall, appearancerating: Double(self.selfratingappearance).truncate(places: 1), personalityrating: Double(self.selfratingpersonality).truncate(places: 1), profilepics: self.profilepics, photopostion: self.position, bio: self.text, socials: socials) { (val) in
                                        if val {
                                            self.showprofile.toggle()
                                            self.next -= self.screenwidth
                                            self.count += 1
                                            self.observer.signedup()
                                            self.loading.toggle()
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .foregroundColor(!(self.instagram && self.instagramhandle.isEmpty || self.twitter && self.twitterhandle.isEmpty || self.snapchat && self.snapchathandle.isEmpty) ? Color(.blue).opacity(0.5) : Color("lightgray"))
                            }.padding(.top, 20)
                        }
                    }.frame(width: screenwidth, height: screenheight).offset(y: -80)
                    
                    //MARK: Your Profile 11
                    VStack(spacing: 0) {
                        Spacer()
                        if self.showprofile {
                            ZStack {
                                VStack {
                                    Text("Your Profile")
                                        .font(Font.custom("ProximaNova-Regular", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.top, 40)
                                    Spacer()
                                    Button(action: {
                                        AddImages()
                                        self.observer.signin()
                                        self.observer.refreshUsers()
                                        UserDefaults.standard.set(false, forKey: "signup")
                                        UserDefaults.standard.set(true, forKey: "status")
                                        UserDefaults.standard.set(false, forKey: "notsignedup")
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
                    
                }.animation(.spring()).offset(x: screenwidth*8.5 + next).sheet(isPresented: self.$picker) {
                    if self.edit && self.education {
                        EducationView(education: self.$education, educationdata: self.$educationdata, edit: self.$edit, picker: self.$picker, select: self.editselect)
                    }
                    else if self.education {
                        EducationView(education: self.$education, educationdata: self.$educationdata, edit: self.$edit, picker: self.$picker)
                    }
                    else if self.edit && self.occupation {
                        OccupationView(occupation: self.$occupation, occupationdata: self.$occupationdata, occupationdata1: self.$occupationdata1, edit: self.$edit, picker: self.$picker, select: self.editselect)
                    }
                    else if self.occupation {
                        OccupationView(occupation: self.$occupation, occupationdata: self.$occupationdata, occupationdata1: self.$occupationdata1, edit: self.$edit, picker: self.$picker)
                    }
                    else if self.edit && self.mnt {
                        MoviesAndTVView(mnt: self.$mnt, mntdata: self.$mntdata, mntgenres: self.$mntgenres, edit: self.$edit, picker: self.$picker, select: self.editselect)
                    }
                    else if self.mnt {
                        MoviesAndTVView(mnt: self.$mnt, mntdata: self.$mntdata, mntgenres: self.$mntgenres, edit: self.$edit, picker: self.$picker)
                    }
                    else if self.edit && self.music {
                        MusicView(music: self.$music, musicdata: self.$musicdata, musicgenres: self.$musicgenres, edit: self.$edit, picker: self.$picker, select: self.editselect)
                    }
                    else if self.music {
                        MusicView(music: self.$music, musicdata: self.$musicdata, musicgenres: self.$musicgenres, edit: self.$edit, picker: self.$picker)
                    }
                    else {
                        ImagePicker(picker: self.$picker, images: self.$profilepics, showimage: self.$showimage, num: self.$numimage)
                    }
                }
                
                VStack(spacing: 10) {
                    //MARK: Back Button
                    HStack(spacing: 5) {
                        
                        Button(action: {
                            if self.count == 1 || self.count == 3 {
                                self.signup.toggle()
                            }
                            else {
                                self.next += self.screenwidth
                                self.count -= 1
                            }
                        }) {
                            Image("back")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.darkGray))
                        }.padding(.horizontal, 15)
                        Text("Sign Up")
                            .font(Font.custom("ProximaNova-Regular", size: 36))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkGray))
                        Spacer()
                    }.frame(width: screenwidth).padding(.top, self.screenheight > 800 ? screenheight*0.055 : screenheight*0.02)
                    if self.count > 2 {
                        VStack {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2.5)
                                    .frame(width: screenwidth - 60, height: 10)
                                    .foregroundColor(Color("lightgray").opacity(0.6))
                                Rectangle()
                                    .frame(width: (screenwidth - 60)*(CGFloat(self.count-3)/15), height: 10)
                                    .foregroundColor(.gray)
                            }.cornerRadius(3.5)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    
                }.animation(.easeInOut)
                
            }.navigationBarBackButtonHidden(true)
            .navigationBarTitle("")
            .navigationBarHidden(true)
                .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
                .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
            }.offset(y: self.logged ? -screenheight*1.25 : 0).animation(.spring())
        }.background(Color("personality").edgesIgnoringSafeArea(.all))
    }
}


//MARK: EducationView
struct EducationView: View {
    @Binding var education: Bool
    @Binding var educationdata: [String]
    @Binding var edit: Bool
    @Binding var picker: Bool
    @State var school = ""
    @State var year = [Bool](repeating: false, count: 100)
    @State var yearfin = ""
    @State var select: Int = -1
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add School")
                    .font(Font.custom("ProximaNova-Regular", size: 30))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                Image("education-2")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.darkGray))
            }.padding(.vertical, 30)
            Text("School Name")
                .font(Font.custom("ProximaNova-Regular", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
            HStack {
                Spacer()
                ZStack {
                    if self.school.count < 1 {
                        Text("School Name")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                    TextField("", text: self.$school)
                        .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                        .foregroundColor(Color(.darkGray))
                        .padding(10)
                        .frame(width: screenwidth - 80, height: 50)
                        .multilineTextAlignment(.center)
                }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                Spacer()
            }
            VStack {
                Text("Select Year")
                    .font(Font.custom("ProximaNova-Regular", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                if self.yearfin.count > 0 {
                    Text(yearfin)
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.darkGray))
                        .padding(10)
                        .background(Color(.white).cornerRadius(10).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10)).padding(.top, 10)
                        .scaleEffect((self.yearfin.count > 0 && self.school.count > 0) ? 1 : 0)
                }
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEach((0...99).reversed(), id: \.self) { yr in
                            VStack {
                                Button(action: {
                                    self.year = [Bool](repeating: false, count: 100)
                                    self.year[yr] = true
                                    self.yearfin = String(yr + 1940)
                                }) {
                                    Text(String(yr + 1940))
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(self.year[yr] ? Color(.white) : Color(.darkGray).opacity(0.6))
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(5).padding(.horizontal, 20)
                                }
                            }.background(self.year[yr] ? Color(.darkGray) : Color(.clear)).cornerRadius(10)
                        }
                    }.padding(10)
                }.frame(width: 150, height: 250).background(Color(.white).cornerRadius(20).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
            }.scaleEffect(self.school.count > 0 ? 1 : 0)
            HStack {
                if self.select != -1  {
                    Button(action: {
                        self.education.toggle()
                        self.edit = false
                        self.educationdata.remove(at: self.select)
                        self.picker = false
                    }) {
                        Text("Remove")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color("personality")))
                            .padding(.bottom, 50)
                            .opacity(0.7)
                    }
                }
                Button(action: {
                    if self.school.count > 0 && self.yearfin.count > 0 {
                        if self.select != -1 {
                            self.educationdata[self.select] = self.school + self.yearfin
                        }
                        else {
                            self.educationdata.append(self.school + self.yearfin)
                        }
                        self.education.toggle()
                        self.edit = false
                        self.picker = false
                    }
                    else {
                        self.education.toggle()
                        self.picker = false
                        self.edit = false
                    }
                }) {
                    if self.school.count > 0 && self.yearfin.count > 0 {
                        Text("Confirm")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(Color(.darkGray).cornerRadius(20))
                            .opacity(0.7)
                    }
                    else {
                        Text("Cancel")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                            .opacity(0.4)
                    }
                }
            }.offset(y: self.school.count > 0 ? 0 : -275)
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)).animation(.spring())
            .onAppear {
                if self.select != -1 {
                    let info = self.educationdata[self.select]
                    self.school = String(info.prefix(info.count-4))
                    self.yearfin = String(info.suffix(4))
                    let index = Int(self.yearfin)! - 1940
                    self.year[index] = true
                }
            }.onDisappear {
                self.edit = false
                self.education = false
            }
    }
}

/*
//MARK: HobbiesView
struct HobbiesView: View {
    @Binding var hobbies: Bool
    @Binding var hobbiesdata: [String]
    @Binding var edit: Bool
    @Binding var picker: Bool
    @State var hobby = ""
    @State var select: Int = -1
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add Hobbies")
                    .font(Font.custom("ProximaNova-Regular", size: 30))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                Image("hobby-1")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.darkGray))
            }.padding(.vertical, 30)
            VStack {
                Text("Hobbies")
                    .font(Font.custom("ProximaNova-Regular", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                HStack {
                    Spacer()
                    ZStack {
                        if self.hobby.count < 1 {
                            Text("Hobby")
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .foregroundColor(.black)
                                .opacity(0.5)
                        }
                        TextField("", text: self.$hobby)
                            .font(Font.custom("ProximaNova-Regular", size: 24).weight(.semibold))
                            .foregroundColor(Color(.darkGray))
                            .padding(10)
                            .frame(width: screenwidth - 80, height: 50)
                            .multilineTextAlignment(.center)
                    }.padding(5).background(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                    Spacer()
                }
            }
            HStack {
                if self.select != -1  {
                    Button(action: {
                        self.occupation.toggle()
                        self.edit = false
                        self.occupationdata.remove(at: self.select)
                        self.occupationdata1.remove(at: self.select)
                        self.picker = false
                    }) {
                        Text("Remove")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color("personality")))
                            .padding(.bottom, 50)
                            .opacity(0.7)
                    }
                }
                VStack {
                    if self.hobby.count > 0 {
                        Button(action: {
                            if self.select != -1 {
                                self.occupationdata[self.select] = self.title
                                self.occupationdata1[self.select] = self.company
                            }
                            else {
                                self.occupationdata.append(self.title)
                                self.occupationdata1.append(self.company)
                            }
                            self.occupation.toggle()
                            self.edit = false
                            self.picker = false
                        }) {
                            Text("Confirm")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(Color(.darkGray).cornerRadius(20))
                                .padding(.bottom, 50)
                                .opacity(0.7)
                        }
                    }
                    else {
                        Button(action: {
                            self.occupation.toggle()
                            self.edit = false
                            self.picker = false
                        }) {
                            Text("Cancel")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.darkGray))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                .padding(.bottom, 50)
                                .opacity(0.4)
                        }
                    }
                }
            }.offset(y: self.title.count > 0 ? 0 : -100)
            Spacer()
        }.edgesIgnoringSafeArea(.all)
        .background(Color(.white).edgesIgnoringSafeArea(.all)).animation(.spring())
            .onAppear {
                if self.select != -1 {
                    self.title = String(self.occupationdata[self.select])
                    self.company = String(self.occupationdata1[self.select])
                }
            }
        .onDisappear {
            self.edit = false
            self.occupation = false
        }
    }
}*/


//MARK: OccupationView
struct OccupationView: View {
    @Binding var occupation: Bool
    @Binding var occupationdata: [String]
    @Binding var occupationdata1: [String]
    @Binding var edit: Bool
    @Binding var picker: Bool
    @State var title = ""
    @State var company = ""
    @State var select: Int = -1
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add Occupation")
                    .font(Font.custom("ProximaNova-Regular", size: 30))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                Image("occupation-1")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.darkGray))
            }.padding(.vertical, 30)
            VStack {
                Text("Job Title")
                    .font(Font.custom("ProximaNova-Regular", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                HStack {
                    Spacer()
                    ZStack {
                        if self.title.count < 1 {
                            Text("Job Title")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        TextField("", text: self.$title)
                            .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                            .foregroundColor(Color(.darkGray))
                            .padding(10)
                            .frame(width: screenwidth - 80, height: 50)
                            .multilineTextAlignment(.center)
                    }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                    Spacer()
                }
            }
            VStack {
                Text("Company Name")
                    .font(Font.custom("ProximaNova-Regular", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                HStack {
                    Spacer()
                    ZStack {
                        if self.company.count < 1 {
                            Text("Company (optional)")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        TextField("", text: self.$company)
                            .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                            .foregroundColor(Color(.darkGray))
                            .padding(10)
                            .frame(width: screenwidth - 80, height: 50)
                            .multilineTextAlignment(.center)
                    }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                    Spacer()
                }
            }.scaleEffect(self.title.count > 0 ? 1 : 0)
            HStack {
                if self.select != -1  {
                    Button(action: {
                        self.occupation.toggle()
                        self.edit = false
                        self.occupationdata.remove(at: self.select)
                        self.occupationdata1.remove(at: self.select)
                        self.picker = false
                    }) {
                        Text("Remove")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color("personality")))
                            .padding(.bottom, 50)
                            .opacity(0.7)
                    }
                }
                Button(action: {
                    if self.title.count > 0 {
                        if self.select != -1 {
                            self.occupationdata[self.select] = self.title
                            self.occupationdata1[self.select] = self.company
                        }
                        else {
                            self.occupationdata.append(self.title)
                            self.occupationdata1.append(self.company)
                        }
                        self.occupation.toggle()
                        self.edit = false
                        self.picker = false
                    }
                    else {
                        self.occupation.toggle()
                        self.edit = false
                        self.picker = false
                    }
                    
                }) {
                    if self.title.count > 0 {
                        Text("Confirm")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(Color(.darkGray).cornerRadius(20))
                            .opacity(0.7)
                    }
                    else {
                        Text("Cancel")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 60)
                            .padding(10).padding(.horizontal, 10)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                            .opacity(0.4)
                    }
                }
            }.offset(y: self.title.count > 0 ? 0 : -100)
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)).animation(.spring())
            .onAppear {
                if self.select != -1 {
                    self.title = String(self.occupationdata[self.select])
                    self.company = String(self.occupationdata1[self.select])
                }
            }
        .onDisappear {
            self.edit = false
            self.occupation = false
        }
    }
}


//MARK: MoviesAndTVView
struct MoviesAndTVView: View {
    @Binding var mnt: Bool
    @Binding var mntdata: [String]
    @Binding var mntgenres: [String]
    @Binding var edit: Bool
    @Binding var picker: Bool
    @State var title = ""
    @State var genre = ""
    @State var select: Int = -1
    let genres = ["Action", "Anime", "Comedy", "Drama", "Fantasy", "Horror", "Mystery", "Romance", "Thriller", "Western"]
    @State var genresselect = [Bool](repeating: false, count: 10)
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack {
             HStack {
                Spacer()
                Text("Add Movie/Show")
                    .font(Font.custom("ProximaNova-Regular", size: 26))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                Image("movieandtv")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.darkGray))
                Spacer()
             }.padding(.vertical, 30)
            VStack {
                Text("Movie/Show Title")
                    .font(Font.custom("ProximaNova-Regular", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                HStack {
                    Spacer()
                    ZStack {
                        if self.title.count < 1 {
                            Text("Movie/Show Title")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        TextField("", text: self.$title)
                            .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                            .foregroundColor(Color(.darkGray))
                            .padding(10)
                            .frame(width: screenwidth - 80, height: 50)
                            .multilineTextAlignment(.center)
                    }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                    Spacer()
                }
                VStack {
                    Text("Select Genre")
                        .font(Font.custom("ProximaNova-Regular", size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.darkGray))
                    VStack {
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(0...self.genres.count-1, id: \.self) { gen in
                                    VStack(spacing: 5) {
                                        Button(action: {
                                            self.genresselect = [Bool](repeating: false, count: 10)
                                            self.genresselect[gen] = true
                                            self.genre = self.genres[gen]
                                        }) {
                                            HStack {
                                                Image(self.genres[gen])
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(self.genresselect[gen] ? Color(.white) : Color(.darkGray).opacity(0.6))
                                                Text(self.genres[gen])
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(self.genresselect[gen] ? Color(.white) : Color(.darkGray).opacity(0.6))
                                                    .fixedSize(horizontal: true, vertical: false)
                                            }.padding(5).frame(width: 180, height: 50)
                                        }
                                    }.background(Color(self.genresselect[gen] ? .darkGray : .white).cornerRadius(10).shadow(color: Color(.black).opacity(self.genresselect[gen] ? 0 : 0.1), radius: 15, x: 10, y: 10)).padding(.horizontal, 30)
                                }
                            }.padding(.bottom, 30)
                        }.padding(10)
                    }.frame(width: 200, height: 400)
                }.scaleEffect(self.title.count > 0 ? 1 : 0)
                HStack {
                    if self.select != -1  {
                        Button(action: {
                            self.mnt = false
                            self.edit = false
                            self.mntdata.remove(at: self.select)
                            self.mntgenres.remove(at: self.select)
                            self.picker = false
                        }) {
                            Text("Remove")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color("personality")))
                                //.padding(.bottom, 50)
                                .opacity(0.7)
                        }
                    }
                    Button(action: {
                        if self.title.count > 0 && self.genre.count > 0 {
                            if self.select != -1 {
                                self.mntdata[self.select] = self.title
                                self.mntgenres[self.select] = self.genre
                            }
                            else {
                                self.mntdata.append(self.title)
                                self.mntgenres.append(self.genre)
                            }
                            self.mnt = false
                            self.edit = false
                            self.picker = false
                        }
                        else {
                            self.mnt = false
                            self.edit = false
                            self.picker = false
                        }
                    }) {
                        if self.title.count > 0 && self.genre.count > 0 {
                            Text("Confirm")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(Color(.darkGray).cornerRadius(20))
                                .opacity(0.7)
                        }
                        else {
                            Text("Cancel")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.darkGray))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                .opacity(0.4)
                        }
                    }
                }.offset(y: self.title.count > 0 ? 10 : -425)
            }
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)).animation(.spring())
            .onAppear {
                if self.select != -1 {
                    self.title = String(self.mntdata[self.select])
                    self.genre = String(self.mntgenres[self.select])
                    self.genresselect[self.genres.firstIndex(of: self.genre)!] = true
                }
            }
        .onDisappear {
            self.edit = false
            self.mnt = false
        }
    }
}


//MARK: MusicView
struct MusicView: View {
    @Binding var music: Bool
    @Binding var musicdata: [String]
    @Binding var musicgenres: [String]
    @Binding var edit: Bool
    @Binding var picker: Bool
    @State var title = ""
    @State var genre = ""
    @State var select: Int = -1
    let genres = ["Classical", "Country", "EDM", "Hip-Hop", "Indie", "Jazz", "K-Pop", "Metal", "Oldies", "Pop", "Rap", "R&B", "Rock", "Techno"]
    @State var genresselect = [Bool](repeating: false, count: 14)
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack {
             HStack {
                Spacer()
                Text("Add Song")
                    .font(Font.custom("ProximaNova-Regular", size: 26))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                Image("song")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.darkGray))
                Spacer()
             }.padding(.vertical, 30)
            VStack {
                Text("Song Title")
                    .font(Font.custom("ProximaNova-Regular", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                HStack {
                    Spacer()
                    ZStack {
                        if self.title.count < 1 {
                            Text("Song Title")
                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        TextField("", text: self.$title)
                            .font(Font.custom("ProximaNova-Regular", size: 20).weight(.semibold))
                            .foregroundColor(Color(.darkGray))
                            .padding(10)
                            .frame(width: screenwidth - 80, height: 50)
                            .multilineTextAlignment(.center)
                    }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                    Spacer()
                }
                VStack {
                    Text("Select Genre")
                        .font(Font.custom("ProximaNova-Regular", size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.darkGray))
                    VStack {
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(0...self.genres.count-1, id: \.self) { gen in
                                    VStack {
                                        Button(action: {
                                            self.genresselect = [Bool](repeating: false, count: 14)
                                            self.genresselect[gen] = true
                                            self.genre = self.genres[gen]
                                        }) {
                                            HStack {
                                                Image(self.genres[gen])
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(self.genresselect[gen] ? Color(.white) : Color(.darkGray).opacity(0.8))
                                                Text(self.genres[gen])
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(self.genresselect[gen] ? Color(.white) : Color(.darkGray).opacity(0.8))
                                                    .fixedSize(horizontal: true, vertical: false)
                                            }.padding(5).frame(width: 180, height: 50)//.padding(.horizontal, 20)
                                        }
                                    }.background(Color(self.genresselect[gen] ? .darkGray : .white).cornerRadius(10).shadow(color: Color(.black).opacity(self.genresselect[gen] ? 0 : 0.1), radius: 15, x: 10, y: 10)).padding(.horizontal, 30)
                                }
                            }.padding(.bottom, 30)
                        }.padding(10)
                    }.frame(width: 200, height: 400)
                }.scaleEffect(self.title.count > 0 ? 1 : 0)
                HStack {
                    if self.select != -1  {
                        Button(action: {
                            self.music = false
                            self.edit = false
                            self.musicdata.remove(at: self.select)
                            self.musicgenres.remove(at: self.select)
                            self.picker = false
                        }) {
                            Text("Remove")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color("personality")))
                                //.padding(.bottom, 50)
                                .opacity(0.7)
                        }
                    }
                    Button(action: {
                        if self.title.count > 0 && self.genre.count > 0 {
                            if self.select != -1 {
                                self.musicdata[self.select] = self.title
                                self.musicgenres[self.select] = self.genre
                            }
                            else {
                                self.musicdata.append(self.title)
                                self.musicgenres.append(self.genre)
                            }
                            self.music = false
                            self.edit = false
                            self.picker = false
                        }
                        else {
                            self.music = false
                            self.edit = false
                            self.picker = false
                        }
                    }) {
                        if self.title.count > 0 && self.genre.count > 0 {
                            Text("Confirm")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(Color(.darkGray).cornerRadius(20))
                                .opacity(0.7)
                        }
                        else {
                            Text("Cancel")
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.darkGray))
                                .frame(width: 60)
                                .padding(10).padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).foregroundColor(Color(.darkGray)))
                                .opacity(0.4)
                        }
                    }
                }.offset(y: self.title.count > 0 ? 10 : -425)
            }
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)).animation(.spring())
            .onAppear {
                if self.select != -1 {
                    self.title = String(self.musicdata[self.select])
                    self.genre = String(self.musicgenres[self.select])
                    self.genresselect[self.genres.firstIndex(of: self.genre)!] = true
                }
            }
        .onDisappear {
            self.edit = false
            self.music = false
        }
    }
}



//MARK: HomeView
struct HomeView: View {
    @EnvironmentObject var observer: observer
    @State var start = true
    @State var index: Int = 0
    @State var rating: Bool = false
    @State var showcomment: Bool = true
    @State var unlock: Bool = false
    @State var unlockindex: Int = 0
    @State var homecomment: Bool = false
    @State var showprofile: Bool = false
    @State var showkeys: Bool = false
    
    @State var recentratings: Bool = false
    @State var report = false
    @State var removerating = false
    
    @State var stats = true
    @State var settings = false
    @State var gender: CGFloat = 1
    @State var ratinggender: CGFloat = 1
    @State var width: CGFloat = 0
    @State var width1: CGFloat = 15
    @State var saved = false
    @State var changed = false
    @State var confirm = false
    @State var confirm1 = false
    @State var connectionrefresh = false
    @State var connectionrefresh2 = false
    @State var loading = false
    @State var refresh = false
    @State var refresh1 = false
    @State var refreshoffset: CGFloat = 0
    @State var connectionstatus = true
    @State var refreshing: Int = 0
    
    var rewardAd: Rewarded
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            //MARK: Hold
            VStack {
                Color(.white)
                Spacer()
            }.background(Color(.white).edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.all)
            ZStack {
                ZStack {
                    VStack(spacing: screenheight*0.009) {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.settings.toggle()
                                }
                            }) {
                                HStack(spacing: 2.5) {
                                    Image(systemName: "chevron.left")
                                        .font(Font.system(size: 18, weight: .heavy))
                                        .foregroundColor(Color(.darkGray))
                                    Image("settings-1")
                                        //.renderingMode(.template)
                                        .resizable()
                                        .frame(width: screenheight*0.047, height: screenheight*0.047)
                                        //.foregroundColor(Color(.darkGray))
                                }
                            }.buttonStyle(PlainButtonStyle()).padding(.leading, screenwidth*0.05)
                            Spacer()
                            Button(action: {
                                self.showkeys = true
                            }) {
                                HStack(spacing: 2.5) {
                                    Text(String(self.observer.keys))
                                        .font(Font.custom("ProximaNova-Regular", size: 32))
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .foregroundColor(Color(.blue).opacity(0.4))
                                        .frame(height: screenheight*0.035)
                                        .minimumScaleFactor(0.02)
                                        .animation(nil)
                                        .shadow(radius: 5)
                                    Image("key")
                                        .resizable()
                                        .frame(width: screenheight*0.044, height: screenheight*0.044)
                                        .foregroundColor(Color(.blue).opacity(0.4))
                                }//.padding(2.5).background(Color(.blue).opacity(0.4).cornerRadius(10))
                            }/*.padding(5).background(Color(.white).cornerRadius(12.5).shadow(color: Color("lightgray"), radius: 5))*/.padding(.trailing, screenwidth*0.05)
                        }.padding(.top, self.screenheight > 800 ? self.screenheight*0.05 : screenheight*0.035)
                        //MARK: Recent Ratings
                        HStack {
                            Text("Recent Ratings")
                                .font(Font.custom("ProximaNova-Regular", size: 30))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(Color(.darkGray))
                                .frame(height: screenheight*0.05)
                                .minimumScaleFactor(0.02)
                                .padding(.leading, 25)
                            Spacer()
                        }
                        TrackableScrollView(.vertical, showIndicators: false, contentOffset: $refreshoffset) {
                            ZStack(alignment: .top) {
                                ZStack {
                                    if self.refresh {
                                        WhiteLoader()
                                    }
                                    else {
                                        Image(systemName: "arrow.down")
                                            .font(Font.system(size: 24, weight: .bold))
                                            .foregroundColor(Color(.gray))
                                            .rotationEffect(.init(degrees: self.refresh1 ? 180 : 0))
                                    }
                                }.frame(height: 30)
                                    .opacity(self.recentratings ? 1 : 0).offset(y: self.refresh1 ? 15 : -38)
                                VStack {
                                    if self.observer.userrates.count == 0 && self.recentratings {
                                        Text("No Ratings Yet")
                                            .font(Font.custom("ProximaNova-Regular", size: 24))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.black))
                                            .frame(height: screenheight*0.35)
                                    }
                                    else if self.observer.userrates.count == 0 {
                                        WhiteLoader()
                                            .frame(height: screenheight*0.35)
                                    }
                                    else {
                                        RecentRatings(unlockindex: self.$unlockindex, unlock: self.$unlock, homecomment: self.$homecomment, showprofile: self.$showprofile)
                                            .frame(width: screenwidth*0.85)
                                    }
                                }.frame(width: screenwidth*0.85).offset(y: self.refresh1 ? 50 : 0)
                            }
                        }.frame(width: screenwidth*0.85, height: screenheight*0.35)
                            .background(Color(.white))
                            .cornerRadius(25)
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                if value[0] < -60 && !self.start && !self.refresh1 {
                                    self.refresh1.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        self.refresh.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                            self.observer.signin()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                self.refresh.toggle()
                                                self.refresh1.toggle()
                                            }
                                        }
                                    }
                                }
                            }.animation(.spring())
                        //MARK: Rate Button
                        if self.stats {
                            NavigationLink(destination: RatingView(rating1: self.$rating, rewardAd: self.rewardAd), isActive: self.$rating) {
                                VStack(spacing: 2.5) {
                                    Button(action: {
                                        if self.observer.users.count == 0 {
                                            
                                        }
                                        else if self.changed {
                                            self.observer.refreshUsers()
                                            self.changed = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                self.rating = true
                                            }
                                        }
                                        else {
                                            self.rating = true
                                        }
                                    }) {
                                        HStack(spacing: 0) {
                                            GIFView(gifName: "rategif")
                                                .frame(width: 80, height: 45)
                                        }.frame(width: screenwidth/2).padding(2.5)
                                            .background(Color(.blue).opacity(0.4).cornerRadius(screenheight*0.02))
                                    }.padding(5).background(Color(.white).cornerRadius(screenheight*0.02 + 2.5))
                                        .padding(.top, screenheight*0.01)
                                }
                            }
                        }
                        Spacer()
                    }
                    //MARK: Your Stats
                    ZStack {
                        VStack(spacing: 0) {
                            Spacer()
                            Color(.white)
                                .frame(width: screenwidth, height: 30)
                        }.frame(width: self.screenwidth, height: self.screenheight)
                        VStack(spacing: 0) {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: self.screenwidth, height: self.stats ? self.screenheight/2.75 : self.screenheight/2.15)
                                    .foregroundColor(Color(.white))
                                VStack(spacing: screenheight*0.006) {
                                    Spacer().frame(height: screenheight*0.012)
                                    HStack(spacing: screenwidth*0.08) {
                                        Button(action: {
                                            self.stats = true
                                        }) {
                                            VStack(spacing: 2.5) {
                                                Text("Statistics")
                                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .foregroundColor(self.stats ? Color(.black) : Color(.gray).opacity(0.5))
                                                    .minimumScaleFactor(0.01)
                                                Circle()
                                                    .foregroundColor(Color("personality"))
                                                    .frame(width: 10, height: 10)
                                                    .opacity(self.stats ? 1 : 0.1)
                                                    
                                            }.frame(width: screenwidth/2.5, height: screenheight*0.05)
                                        }
                                        Button(action: {
                                            self.stats = false
                                        }) {
                                            VStack(spacing: 2.5) {
                                                Text("Preferences")
                                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .foregroundColor(self.stats ? Color(.gray).opacity(0.5) : Color(.black))
                                                    .minimumScaleFactor(0.01)
                                                Circle()
                                                    .foregroundColor(Color("personality"))
                                                    .frame(width: 10, height: 10)
                                                    .opacity(self.stats ? 0.1 : 1)
                                            }.frame(width: screenwidth/2.5, height: screenheight*0.025)
                                        }
                                    }.padding(.bottom, self.stats ? 10 : 5)
                                    if self.stats {
                                        YourStatistics()
                                    }
                                    else {
                                        ZStack {
                                            RatingSettings(gender: self.$gender, ratinggender: self.$ratinggender, width: self.$width, width1: self.$width1)
                                            Text("SAVED")
                                                .font(Font.custom("ProximaNova-Regular", size: 26))
                                                .fontWeight(.semibold)
                                                .padding(15).padding(.horizontal, 15)
                                                .foregroundColor(.white)
                                                .background(Color(.gray).cornerRadius(25))
                                                .opacity(self.saved ? 1 : 0).animation(.spring())
                                        }
                                        if self.loading {
                                            WhiteLoader()
                                                .padding(.top, screenheight*0.01)
                                        }
                                        else {
                                            Button(action: {
                                                self.loading.toggle()
                                                var preferences = ["", "", ""]
                                                if self.gender == -1 {
                                                    preferences[0] = "Male"
                                                }
                                                else if self.gender == 0 {
                                                    preferences[0] = "Female"
                                                }
                                                else {
                                                    preferences[0] = "Everyone"
                                                }
                                                
                                                if self.ratinggender == -1 {
                                                    preferences[1] = "Male"
                                                }
                                                else if self.ratinggender == 0 {
                                                    preferences[1] = "Female"
                                                }
                                                else {
                                                    preferences[1] = "Everyone"
                                                }
                                                
                                                preferences[2] = self.width < 0 ? "18-" : (String(Int(self.width/2.71 + 18)) + "-")
                                                preferences[2] = (self.width1 > 220 || Int(self.width1/2.71 + 18) >= 99) ? preferences[2]+"60" : preferences[2]+String(Int(self.width1/2.71 + 18))
                                                
                                                preferences[2] = self.width < 0 ? "18-" : (String(Int(self.width/2.71 + 18)) + "-")
                                                preferences[2] = self.width1 > 220 || Int(self.width1/2.71 + 18) >= 99 ? preferences[2]+"99" : preferences[2]+String(Int(self.width1/2.71 + 18))
                                                
                                                let db = Firestore.firestore()
                                                let uid = Auth.auth().currentUser?.uid
                                                db.collection("users").document(uid!).updateData(["Preferences": preferences]) { (err) in
                                                    if err != nil {
                                                        return
                                                    }
                                                    self.observer.myprofile.Preferences = preferences
                                                    self.changed = true
                                                    self.saved = true
                                                    self.loading.toggle()
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                                                        self.saved = false
                                                    }
                                                }
                                            }) {
                                                Text("Save")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .frame(width: screenwidth/3.5 - 20, height: screenheight*0.05 - 10)
                                                    .background(Color(.blue).opacity(0.4).cornerRadius(screenheight*0.015))
                                            }.padding(5).background(Color(.white).cornerRadius(screenheight*0.015 + 2.5).shadow(color: Color(.lightGray).opacity(0.5), radius: 5)).padding(.top, screenheight*0.01)
                                        }
                                    }
                                    Spacer()
                                }.frame(width: self.screenwidth, height: self.stats ? self.screenheight/2.75 : self.screenheight/2.15)
                            }
                        }.frame(width: self.screenwidth, height: self.screenheight)
                    }
                }.blur(radius: self.unlock || self.homecomment || self.showkeys || self.showprofile ? 2.5 : 0)
                //MARK: Unlock
                if self.observer.comments.count != 0 {
                    ZStack {
                        Button(action: {
                            self.unlock = false
                        }) {
                            Color(.white)
                                .opacity(0)
                                .frame(width: self.screenwidth, height: self.screenheight)
                        }
                        VStack {
                            Text("Unlock Profile")
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            ZStack {
                                if self.unlock {
                                    WebImage(url: URL(string: self.observer.ratesinfo[self.unlockindex].ProfilePics[0]))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: self.screenwidth/3, height: self.screenwidth/3)
                                        .cornerRadius(25)
                                        .blur(radius: !self.observer.lock[self.unlockindex] ? 10 : 0)
                                    if !self.observer.lock[self.unlockindex] {
                                        Image("lock")
                                            //.renderingMode(.template)
                                            .resizable()
                                            .frame(width: self.screenwidth/4, height: self.screenwidth/4)
                                            //.foregroundColor(Color("personality"))
                                    }
                                }
                            }.padding(10).background(Color("lightgray").cornerRadius(15)).padding(.bottom, screenheight*0.0037)
                            HStack {
                                Button(action: {
                                    if self.observer.keys > 0 && !self.observer.lock[self.unlockindex] {
                                        var newlock = self.observer.lock
                                        newlock[self.unlockindex] = true
                                        let changekeys = self.observer.keys - 1
                                        Unlock(keys: changekeys, lock: newlock) { (complete) in
                                            if complete {
                                                self.observer.keys = changekeys
                                                self.observer.lock = newlock
                                            }
                                            else {
                                                return
                                            }
                                        }
                                        let seconds = 0.5
                                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                            self.unlock = false
                                            self.showprofile = true
                                        }
                                    }
                                    else {
                                        self.showkeys.toggle()
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color("appearance"))
                                            .frame(width: self.screenwidth/2.25, height: screenwidth*0.133)// - screenwidth*0.293, height: screenwidth*0.133)
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
                                                        .lineLimit(1)
                                                        .frame(height: screenheight*0.02)
                                                        .foregroundColor(Color("appearance"))
                                                        .minimumScaleFactor(0.02)
                                                        .animation(nil)
                                                    Image("key")
                                                        .resizable()
                                                        .frame(width: screenheight*0.02, height: screenheight*0.02)
                                                        .foregroundColor(Color("appearance"))
                                                }
                                            }.frame(width: screenwidth*0.133, height: screenheight*0.037)
                                        }
                                    }
                                }
                            }
                        }.padding(25).background(Color(.white).cornerRadius(30).shadow(radius: 10)).blur(radius: self.homecomment || self.showkeys ? 2 : 0)
                    }.offset(y: self.unlock ? 0 : self.screenheight).opacity(self.unlock ? 1 : 0)
                }
                //MARK: HomeComment
                if self.observer.comments.count != 0 {
                    ZStack {
                        Button(action: {
                            self.homecomment = false
                            self.report = false
                            self.showcomment = true
                            self.confirm = false
                            self.confirm1 = false
                            self.removerating = false
                        }) {
                            Color(.white)
                                .opacity(0)
                                .frame(width: self.screenwidth, height: self.screenheight)
                        }
                        VStack {
                            HStack {
                                Button(action: {
                                    self.showcomment = true
                                    self.report = false
                                    self.confirm = false
                                    self.confirm1 = false
                                    self.removerating = false
                                }) {
                                    Image("commentbutton")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color(.blue).opacity(0.5).cornerRadius(15))
                                }
                                Spacer()
                                Button(action: {
                                    self.report = true
                                    self.showcomment = false
                                }) {
                                    Image("report")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Color("personality").cornerRadius(15))
                                }.buttonStyle(PlainButtonStyle())
                            }.frame(width: self.screenwidth/1.75).padding(.horizontal, 5)
                            if self.showcomment {
                                Text("Comment:")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.blue).opacity(0.5))
                            }
                            if self.homecomment && self.showcomment {
                                Text(self.observer.comments[self.unlockindex])
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                    .frame(width: self.screenwidth/1.75)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            if self.report {
                                VStack(spacing: 20) {
                                    if self.confirm {
                                        VStack {
                                            Text("Are You Sure You Want To Remove This Rating?")
                                                .font(Font.custom("ProximaNova-Regular", size: 22))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.black))
                                                .animation(nil)
                                                .multilineTextAlignment(.center)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            
                                            if self.removerating {
                                                Button(action: {
                                                    self.removerating = false
                                                }) {
                                                    VStack(spacing: 2.5) {
                                                        HStack(spacing: 0) {
                                                            ZStack() {
                                                                Rectangle()
                                                                    .fill(Color("appearance"))
                                                                    .frame(width: (self.screenwidth/20)*CGFloat((self.observer.userrates[self.unlockindex].prefix(3) as NSString).doubleValue), height: screenheight*0.036)
                                                                    .cornerRadius(5)
                                                                Text(String((self.observer.userrates[self.unlockindex].prefix(3) as NSString).doubleValue))
                                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(Color(.white))
                                                                    .animation(nil)
                                                            }
                                                            Spacer().frame(width: ((self.screenwidth/20)*10) - (self.screenwidth/20)*CGFloat((self.observer.userrates[self.unlockindex].prefix(3) as NSString).doubleValue))
                                                        }.frame(width: self.screenwidth/2).background(Color("lightgray")).cornerRadius(12.5)
                                                        HStack {
                                                            ZStack {
                                                                Rectangle()
                                                                    .fill(Color("personality"))
                                                                    .frame(width: (self.screenwidth/20)*CGFloat((self.observer.userrates[self.unlockindex].prefix(6).suffix(3) as NSString).doubleValue), height: screenheight*0.036)
                                                                    .cornerRadius(5)
                                                                Text(String((self.observer.userrates[self.unlockindex].prefix(6).suffix(3) as NSString).doubleValue))
                                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(Color(.white))
                                                                    .animation(nil)
                                                            }
                                                            Spacer().frame(width: ((self.screenwidth/20)*10) - (self.screenwidth/20)*CGFloat((self.observer.userrates[self.unlockindex].prefix(6).suffix(3) as NSString).doubleValue))
                                                        }.frame(width: self.screenwidth/2).background(Color("lightgray")).cornerRadius(12.5)
                                                    }.frame(width: self.screenwidth/2)
                                                }
                                            }
                                            else {
                                                HStack {
                                                    Button(action: {
                                                        self.removerating = true
                                                    }) {
                                                        ZStack {
                                                            Rectangle()
                                                                .fill(Color("purp"))
                                                                .frame(width: (self.screenwidth/20)*CGFloat((self.observer.userrates[self.unlockindex].prefix(9).suffix(3) as NSString).doubleValue), height: screenheight*0.074)
                                                                .cornerRadius(5)
                                                            Text(String((self.observer.userrates[self.unlockindex].prefix(9).suffix(3) as NSString).doubleValue))
                                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(Color(.white))
                                                        }
                                                    }
                                                    Spacer().frame(width: ((self.screenwidth/20)*10) - (self.screenwidth/20)*CGFloat((self.observer.userrates[self.unlockindex].prefix(9).suffix(3) as NSString).doubleValue))
                                                }.frame(width: self.screenwidth/2).background(Color("lightgray").cornerRadius(5)).cornerRadius(20)
                                            }
                                        }.frame(width: screenwidth/1.5)
                                    }
                                    else if self.confirm1 {
                                        if !self.observer.reported[self.unlockindex] {
                                            VStack {
                                                Text("Are You Sure You Want To Report This User?")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.black))
                                                    .animation(nil)
                                                    .multilineTextAlignment(.center)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding(.bottom, 5)
                                                
                                                Text("(Report this user if the comment or the profile is inappropriate or hateful. If the user's socials are inaccurate, you may also report.")
                                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.darkGray))
                                                    .animation(nil)
                                                    .multilineTextAlignment(.center)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }.frame(width: screenwidth/1.5)
                                        }
                                    }
                                    Button(action: {
                                        withAnimation {
                                            if self.confirm {
                                                if self.observer.keys >= 3 {
                                                    let db = Firestore.firestore()
                                                    let uid = Auth.auth().currentUser?.uid
                                                    self.homecomment = false
                                                    self.report = false
                                                    self.showcomment = true
                                                    self.confirm = false
                                                    self.confirm1 = false
                                                    self.removerating = false
                                                    self.observer.numrates -= 1
                                                    
                                                    self.observer.comments.remove(at: self.unlockindex)
                                                    self.observer.reported.remove(at: self.unlockindex)
                                                    self.observer.userrates.remove(at: self.unlockindex)
                                                    self.observer.lock.remove(at: self.unlockindex)
                                                    self.observer.ratesinfo.remove(at: self.unlockindex)
                                                    
                                                    self.confirm.toggle()
                                                    let total = CGFloat(self.observer.userrates.count + 1)
                                                    var atotal: CGFloat = self.observer.selfratings.appearance
                                                    var ptotal: CGFloat = self.observer.selfratings.personality
                                                    var ototal: CGFloat = self.observer.selfratings.overall
                                                    for num in self.observer.userrates {
                                                        atotal += CGFloat((num.prefix(3) as NSString).doubleValue)
                                                        ptotal += CGFloat((num.prefix(6).suffix(3) as NSString).doubleValue)
                                                        ototal += CGFloat((num.prefix(9).suffix(3) as NSString).doubleValue)
                                                    }
                                                    self.observer.keys -= 3
                                                    self.observer.myprofile.OverallRating = Double(ototal/total).truncate(places: 1)
                                                    self.observer.myprofile.AppearanceRating = Double(atotal/total).truncate(places: 1)
                                                    self.observer.myprofile.PersonalityRating = Double(ptotal/total).truncate(places: 1)
                                                    self.observer.rating = ratingtype(overall: CGFloat(self.observer.myprofile.OverallRating), appearance: CGFloat(self.observer.myprofile.AppearanceRating), personality: CGFloat(self.observer.myprofile.PersonalityRating))
                                                    db.collection("users").document(uid!).updateData(["Rates": self.observer.userrates, "Comments": self.observer.comments, "Lock": self.observer.lock, "OverallRating": self.observer.myprofile.OverallRating, "AppearanceRating": self.observer.myprofile.AppearanceRating, "PersonalityRating": self.observer.myprofile.PersonalityRating, "Keys": self.observer.keys, "Reported": self.observer.reported])
                                                    //db.collection("users").document(uid!).updateData(["Keys": self.observer.keys])
                                                }
                                                else {
                                                    self.showkeys.toggle()
                                                }
                                            }
                                            else if self.confirm1 {
                                                let db = Firestore.firestore()
                                                let uid = Auth.auth().currentUser?.uid
                                                self.homecomment = false
                                                self.report = false
                                                self.showcomment = true
                                                self.confirm = false
                                                self.confirm1 = false
                                                self.removerating = false
                                                
                                                self.observer.ratesinfo[self.unlockindex].Report += 1
                                                self.observer.reported[self.unlockindex] = true
                                                db.collection("users").document(self.observer.ratesinfo[self.unlockindex].id).updateData(["Report": self.observer.ratesinfo[self.unlockindex].Report])
                                                db.collection("users").document(uid!).updateData(["Reported": self.observer.reported])
                                            }
                                            else {
                                                self.confirm.toggle()
                                            }
                                        }
                                    }) {
                                        HStack(spacing: 2.5) {
                                            if self.confirm {
                                                Text("Confirm")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .animation(nil)
                                                    .foregroundColor(.black)
                                                    .frame(height: 50)
                                                Spacer().frame(width: 2.5)
                                                HStack(spacing: 2.5) {
                                                    Text("-3")
                                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                                        .fontWeight(.semibold)
                                                        .animation(nil)
                                                        .foregroundColor(Color(.white))
                                                    Image("key")
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .frame(width: 22.5, height: 22.5)
                                                        .foregroundColor(Color(.white))
                                                }.padding(5).background(Color("personality").opacity(0.8).cornerRadius(7.5))
                                            }
                                            else if self.confirm1 {
                                                Text("Confirm")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .animation(nil)
                                                    .foregroundColor(.black)
                                                    .frame(height: 50)
                                            }
                                            else {
                                                Text("Remove Rating")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .animation(nil)
                                                    .foregroundColor(.black)
                                                    .frame(height: 50)
                                            }
                                        }.frame(width: screenwidth/1.5).background(Color(.white).cornerRadius(25).shadow(color: Color("lightgray").opacity(0.9), radius: 10))
                                    }
                                    if (self.confirm || self.confirm1) || !self.observer.reported[self.unlockindex] {
                                        Button(action: {
                                            if self.confirm {
                                                self.confirm.toggle()
                                            }
                                            else {
                                                self.confirm1.toggle()
                                            }
                                            self.removerating = false
                                        }) {
                                            HStack {
                                                Text(self.confirm || self.confirm1 ? "Cancel" : "Report User")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .animation(nil)
                                                    .foregroundColor(self.confirm || self.confirm1 ? .white : Color(.black))
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 50)
                                            }.frame(width: screenwidth/1.5).background((self.confirm || self.confirm1 ? Color("personality") : Color(.white)).cornerRadius(25).shadow(color: Color("lightgray").opacity(0.9), radius: 10))
                                        }
                                    }
                                }.padding(.top, 10)
                            }
                        }.padding(20).background(Color(.white).cornerRadius(25).shadow(radius: 15)).blur(radius: self.showkeys ? 2 : 0)
                    }.offset(y: self.homecomment ? 0 : self.screenheight).opacity(self.homecomment ? 1 : 0)
                }
                
                //MARK: ShowKeys
                ZStack {
                    Button(action: {
                        self.showkeys = false
                    }) {
                        Color(.white)
                            .opacity(0)
                            .frame(width: self.screenwidth, height: self.screenheight)
                    }
                    VStack {
                        VStack(spacing: 20) {
                            HStack {
                                Text(String(self.observer.keys))
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                Image("key")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(.white))
                            }.padding(5).padding(.horizontal, 5).background(Color(.blue).opacity(0.5).cornerRadius(15)).padding(.top, 10)
                            HStack(spacing: 15) {
                                Button(action: {
                                    self.rewardAd.showAd(rewardFunction: {
                                        let changekeys = self.observer.keys + 3
                                        KeyChange(keys: changekeys) { (complete) in
                                            if complete {
                                                self.observer.keys = changekeys
                                            }
                                        }
                                    })
                                }) {
                                    ZStack() {
                                        Color("appearance")
                                            .cornerRadius(25)
                                        VStack {
                                            Image("ad")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(Color(.white))
                                            VStack(spacing: 2.5) {
                                                Text("Watch Ad")
                                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                HStack(spacing: 2.5) {
                                                    Text("+3")
                                                        .font(Font.custom("ProximaNova-Regular", size: 24))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                    Image("key")
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(Color(.white))
                                                }
                                            }
                                        }
                                    }.frame(width: 130, height: 160).padding(.leading, 10)
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        Button(action: {
                                            
                                        }) {
                                            ZStack {
                                                Color("personality")
                                                    .cornerRadius(25)
                                                ZStack {
                                                    //GIFView(gifName: "keynew")
                                                        //.frame(width: 50, height: 70)
                                                    Image("key")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 50, height: 50)
                                                        .foregroundColor(.white)
                                                    Text("+20")
                                                        .font(Font.custom("ProximaNova-Regular", size: 30))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .shadow(radius: 5)
                                                        .padding(.top, 50)
                                                }.offset(y: -10)
                                                VStack(spacing: 0) {
                                                    Spacer()
                                                    Text("$0.99")
                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .padding(.bottom, 5)
                                                }
                                            }.frame(width: 110, height: 140)
                                        }
                                        Button(action: {
                                            
                                        }) {
                                            ZStack {
                                                Color("personality")
                                                    .cornerRadius(25)
                                                ZStack {
                                                    Image("key")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.white)
                                                        .offset(x: -15)
                                                    Image("key")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.white)
                                                        .offset(x: 15)
                                                    Text("+50")
                                                        .font(Font.custom("ProximaNova-Regular", size: 30))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .shadow(radius: 5)
                                                        .padding(.top, 50)
                                                }.offset(y: -10)
                                                VStack {
                                                    Spacer()
                                                    Text("$1.99")
                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .padding(.bottom, 5)
                                                }
                                            }.frame(width: 110, height: 140)
                                        }
                                        Button(action: {
                                            
                                        }) {
                                            ZStack {
                                                Color("personality")
                                                    .cornerRadius(25)
                                                ZStack {
                                                    Image("key")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 35, height: 35)
                                                        .foregroundColor(.white)
                                                        .offset(x: -25)
                                                    Image("key")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 35, height: 35)
                                                        .foregroundColor(.white)
                                                    Image("key")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 35, height: 35)
                                                        .foregroundColor(.white)
                                                        .offset(x: 25)
                                                    Text("+150")
                                                        .font(Font.custom("ProximaNova-Regular", size: 30))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .shadow(radius: 5)
                                                        .padding(.top, 50)
                                                }.offset(y: -10)
                                                VStack {
                                                    Spacer()
                                                    Text("$4.99")
                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .padding(.bottom, 5)
                                                }
                                            }.frame(width: 110, height: 140)
                                        }
                                        Button(action: {
                                            
                                        }) {
                                            ZStack {
                                                Color("personality")
                                                    .cornerRadius(25)
                                                HStack(spacing: 2.5) {
                                                    Text("+500")
                                                        .font(Font.custom("ProximaNova-Regular", size: 26))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                    Image("key")
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(Color(.white))
                                                }
                                                VStack {
                                                    Spacer()
                                                    Text("$9.99")
                                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.white))
                                                        .padding(.vertical, 5)
                                                }
                                            }.frame(width: 110, height: 140)
                                        }
                                    }
                                }.frame(height: 140)
                                .padding(5).overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 10)
                                    .foregroundColor(Color("personality.5"))).padding(5).background(Color("personality").opacity(0.5).cornerRadius(25)).padding(.trailing, 10)
                            }
                            HStack {
                                Text("Remove Ads")
                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                Image("ad")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(Color(.white))
                                Spacer()
                                Text("$4.99")
                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                            }.padding(20).background(Color("personality").cornerRadius(25)).padding(.horizontal, 10)
                        }.frame(width: screenwidth).padding(.vertical, self.screenheight > 800 ? 20 : 10).padding(.top, self.screenheight > 800 ? 20 : 10).background(Color(.white).cornerRadius(25).shadow(radius: 10))
                        Spacer()
                    }.frame(height: screenheight)
                }.offset(y: self.showkeys ? 0 : -self.screenheight).opacity(self.showkeys ? 1 : 0).animation(.spring())
                if self.observer.comments.count != 0 && self.observer.userrates.count != 0 && self.observer.ratesinfo.count != 0{
                    //MARK: ShowProfile
                    ShowProfile(index: self.$unlockindex, showprofile: self.$showprofile)
                        .offset(y: self.showprofile ? 0 : self.screenheight).animation(.spring())
                }
            }.background(Color("lightgray").edgesIgnoringSafeArea(.all)).frame(width: self.screenwidth, height: self.screenheight)
                .animation(.spring()).blur(radius: !self.connectionstatus ? 10 : 0)
            
            
            //MARK: Settings
            SettingView(settings: self.$settings, start: self.$start)
                .offset(x: self.settings ? 0 : -screenwidth).animation(.spring())
            
            /*if !Reachability.isConnectedToNetwork() {
                ZStack {
                    Color("lightgray")
                        .frame(width: screenwidth, height: screenheight)
                        .opacity(0.1)
                    VStack {
                        Image("noconnection")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("No Internet Connection")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                        Button(action: {
                            if !self.connectionrefresh {
                                self.connectionrefresh = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    if self.connectionrefresh {
                                        self.connectionrefresh = false
                                    }
                                }
                            }
                        }) {
                            if self.connectionrefresh {
                                WhiteLoader()
                            }
                            else {
                                VStack(spacing: 5) {
                                    Text("Refresh")
                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.darkGray))
                                    Image(systemName: "arrow.clockwise.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color(.darkGray))
                                }
                            }
                        }.padding(.top, 30)
                    }.padding(20)
                    .background(Color(.white).cornerRadius(20).shadow(radius: 15))
                }.animation(.spring())
            }*/
            
            ZStack {
                Color("personality")
                    .frame(width: screenwidth, height: screenheight)
                VStack(spacing: 15) {
                    if !self.start {
                        Text("Connection Error")
                            .font(Font.custom("ProximaNova-Regular", size: 28))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        
                    }
                    GIFView(gifName: "rategif")
                        .frame(width: 100, height: 50)
                    if !self.start {
                        Text("Reconnecting")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 0 ? 1 : 0.3))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 1 ? 1 : 0.3))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 2 ? 1 : 0.3))
                        }
                    }
                }.onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        if self.refreshing != 2 {
                            self.refreshing += 1
                        }
                        else {
                            self.refreshing = 0
                        }
                    }
                }
                
            }.offset(y: (self.start || !self.connectionstatus) ? 0 : -screenheight)
            .animation(.spring())
            
            
        }.edgesIgnoringSafeArea(.all).animation(.spring()).onAppear {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                self.connectionstatus = Reachability.isConnectedToNetwork()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.start = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.recentratings = true
            }
        }
    }
}


//MARK: RatingView
struct RatingView: View {
    @EnvironmentObject var observer: observer
    @Binding var rating1: Bool
    @State var ad: Bool = UserDefaults.standard.value(forKey: "ad") as? Bool ?? false
    @State var showad: Bool = UserDefaults.standard.value(forKey: "showad") as? Bool ?? false
    @State var count: Int = 0
    @State var next: Bool = false
    @State var showrating: Bool = false
    @State var appearance: Float = 5
    @State var personality: Float = 5
    @State var showcomment: Bool = false
    @State var comment = ""
    @State var unlocksocials: Bool = false
    //@State var unlock: Bool = false
    @State var newkey: CGFloat = UIScreen.main.bounds.height
    @State var newkeyx: CGFloat = 0
    @State var showkey: Bool = false
    @State var showkeys = false
    @State var showsocials: Bool = false
    @State var nonext = false
    @State var msg = ""
    @State var alert = false
    
    @State var rating = false
    @State var bio = false
    @State var report = false
    @State var reportmessage = false
    @State var confirm = false
    @State var confirm1 = false
    @State var wait = false
    @State var loading = false
    @State var connectionstatus = true
    @State var refreshing: Int = 0
    let categories = ["General", "Education", "Occupation", "Music", "Sports", "Movies", "TV-Shows", "Hobbies", "Motto", "Future"]
    var rewardAd: Rewarded
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    Circle()
                        .frame(width: self.screenwidth * 4)
                        .foregroundColor(.white)
                        .offset(y: -self.screenheight/1.25)
                    Spacer()
                }.frame(width: self.screenwidth, height: self.screenheight)
                
                if self.observer.users.count == 0 {
                    VStack {
                        WhiteLoader()
                    }.frame(width: self.screenwidth, height: self.screenheight).edgesIgnoringSafeArea(.all)
                }
                //MARK: RatingAd
                else if self.ad {
                    VStack {
                        Spacer().frame(height: self.screenheight/8)
                        RatingAd()
                            .frame(width: screenwidth - 60, height: (screenwidth - 20)*1.6 - 10)
                            .cornerRadius(30)
                            .padding(5)
                            .background(Color(.white).cornerRadius(35).shadow(color: Color("lightgray"), radius: 10))
                            .scaleEffect(self.showad ? 1 : 0).animation(.easeInOut(duration: 0.5))
                            .padding(.bottom, 10)
                            .padding(.top, 20)
                        Button(action: {
                            let changekeys = self.observer.keys + 1
                            KeyChange(keys: changekeys) { (complete) in
                                if complete {
                                    self.newkey = 0
                                    self.showkey = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.newkey = -self.screenheight/2 + 57.5
                                        self.newkeyx = self.screenwidth/2 - 45
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.showkey = false
                                            self.observer.keys = changekeys
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
                                    self.wait = false
                                }
                                else {
                                    self.msg = "There was an error"
                                    self.alert.toggle()
                                    return
                                }
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 40, weight: .bold))
                                .foregroundColor(self.wait ? Color(.blue).opacity(0.5) : Color("lightgray"))
                        }.buttonStyle(PlainButtonStyle())
                    }.frame(width: self.screenwidth, height: self.screenheight)
                        .edgesIgnoringSafeArea(.all)
                }
                else {
                    VStack {
                        WhiteLoader().opacity(self.next ? 0 : 1)
                    }
                    VStack {
                        Spacer()
                        //MARK: RatingUI
                        if self.observer.users.count != 0 {
                                
                            if self.observer.users[self.observer.rated].ProfilePics[count].count != 0 {
                                VStack(spacing: 20) {
                                    //MARK: Image
                                    ZStack {
                                        if self.loading {
                                            WhiteLoader()
                                        }
                                        ZStack {
                                            WebImage(url: URL(string: self.observer.users[self.observer.rated].ProfilePics[self.count]))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: screenwidth - 20, height: screenheight*0.7)
                                                .animation(nil)
                                                .shadow(radius: 10)
                                            VStack(spacing: 0) {
                                                HStack(spacing: 0) {
                                                    RoundedRectangle(cornerRadius: 1.5)
                                                        .frame(width: (screenwidth-20)/4 - 10, height: 7.5)
                                                        .foregroundColor(self.count == 0 ? .white : .clear)
                                                    RoundedRectangle(cornerRadius: 1.5)
                                                        .frame(width: (screenwidth-20)/4 - 10, height: 7.5)
                                                        .foregroundColor(self.count == 1 ? .white : .clear)
                                                    RoundedRectangle(cornerRadius: 1.5)
                                                        .frame(width: (screenwidth-20)/4 - 10, height: 7.5)
                                                        .foregroundColor(self.count == 2 ? .white : .clear)
                                                    RoundedRectangle(cornerRadius: 1.5)
                                                        .frame(width: (screenwidth-20)/4 - 10, height: 7.5)
                                                        .foregroundColor(self.count == 3 ? .white : .clear)
                                                }.padding(1).background(Color(.lightGray).opacity(0.5)).cornerRadius(3).padding(.top, screenheight*0.025).animation(nil)
                                                Spacer()
                                                HStack {
                                                    Text(self.observer.users[self.observer.rated].Name.uppercased() + " " + self.observer.users[self.observer.rated].Age)
                                                        .font(Font.custom("ProximaNova-Regular", size: 60))
                                                        .fontWeight(.semibold)
                                                        .lineLimit(1)
                                                        .frame(maxWidth: screenwidth/1.5)
                                                        .foregroundColor(.white)
                                                        .shadow(radius: 10)
                                                        .minimumScaleFactor(0.02)
                                                        .padding(.leading, self.screenheight*0.015)
                                                        .padding(.bottom, self.screenheight*0.015)
                                                    Spacer()
                                                }
                                                
                                            }.frame(width: screenwidth - 20, height: screenheight*0.7)
                                        }.blur(radius: self.bio ? 6 : 0)
                                        ScrollView([]) {
                                            VStack(spacing: 0) {
                                                HStack {
                                                    Button(action: {
                                                        if self.count != 0 {
                                                            self.count -= 1
                                                        }
                                                    }) {
                                                        Color(.white).opacity(0)
                                                            .frame(width: screenwidth/3, height: screenheight*0.7)
                                                    }
                                                    Spacer()
                                                    Button(action: {
                                                        if self.count != 3 {
                                                            self.count += 1
                                                        }
                                                    }) {
                                                        Color(.white).opacity(0)
                                                            .frame(width: screenwidth/3, height: screenheight*0.7)
                                                    }
                                                }.frame(height: screenheight*0.7)
                                                ZStack {
                                                    Color(.white)
                                                        .opacity(0.5)
                                                        .frame(width: screenwidth - 20, height: screenheight*0.7)
                                                        .cornerRadius(25)
                                                    ScrollView(.vertical, showsIndicators: false) {
                                                        VStack(spacing: 0) {
                                                            ForEach(self.observer.users[self.observer.rated].Bio, id: \.self) { bio in
                                                                VStack(spacing: 0) {
                                                                    VStack(spacing: 5) {
                                                                        HStack {
                                                                            Text(self.categories[(bio.prefix(2) as NSString).integerValue])
                                                                                .font(Font.custom("ProximaNova-Regular", size: 25))
                                                                                .fontWeight(.semibold)
                                                                                .lineLimit(1)
                                                                                .foregroundColor(Color(.white))
                                                                                .frame(height: 15)
                                                                                .minimumScaleFactor(0.02)
                                                                            Image(self.categories[(bio.prefix(2) as NSString).integerValue])
                                                                                .resizable()
                                                                                .frame(width: 25, height: 25)
                                                                            Spacer()
                                                                        }
                                                                        Text(bio.suffix(bio.count - 2))
                                                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                            //.fontWeight(.semibold)
                                                                            .foregroundColor(Color(.white))
                                                                            .fixedSize(horizontal: false, vertical: true)
                                                                    }.padding(15)
                                                                        .frame(width: self.screenwidth-40)
                                                                        //.background(Color(.blue).opacity(0.4))
                                                                        
                                                                }.background(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 10).foregroundColor(.white))
                                                                    .cornerRadius(15)
                                                                    .padding(.horizontal, 20)
                                                                    .padding(.vertical, 2.5)
                                                                    //.shadow(color: Color("lightgray"), radius: 7.5)
                                                            }
                                                        }.padding(.vertical, 10)//.background(Color("lightgray").opacity(0.7))
                                                    }.frame(width: screenwidth - 20, height: screenheight*0.7 - 20).background(Color(.clear)).cornerRadius(30)
                                                    
                                                }
                                                
                                            }.offset(y: self.bio ? -screenheight*0.35 : screenheight*0.35)
                                        }.frame(width: screenwidth - 20, height: screenheight*0.7).cornerRadius(25)
                                    }.frame(width: screenwidth - 20, height: screenheight*0.7).cornerRadius(25).scaleEffect(self.next ? 0 : 1)
                                    //Spacer()
                                    //MARK: Bottom UI Buttons
                                    HStack(spacing: 10) {
                                        if !self.rating {
                                            Button(action: {
                                                self.report.toggle()
                                            }) {
                                                Image(systemName: "ellipsis")
                                                    .resizable()
                                                    .frame(width: 30, height: 6)
                                                    .foregroundColor(Color(.blue).opacity(0.5))
                                                    .padding(10)
                                            }
                                            Button(action: {
                                                self.unlocksocials.toggle()
                                            }) {
                                                ZStack {
                                                    Image("social")
                                                        .resizable()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                        .padding(20)
                                                        .background(Circle().frame(width: 65, height: 65).foregroundColor(.blue).shadow(color: .blue, radius: 5))
                                                }
                                            }
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 37.5)
                                                .frame(width: self.rating ? 265 : 65, height: self.rating ? 75 : 65)
                                                .foregroundColor(self.rating ? .white : .yellow)
                                                .shadow(color: self.rating ? Color("lightgray") : .yellow, radius: 5)
                                            
                                            if self.rating {
                                                HStack {
                                                    Button(action: {
                                                        self.rating.toggle()
                                                    }) {
                                                        Image(systemName: "chevron.left")
                                                            .font(Font.system(size: 32, weight: .semibold))
                                                            .foregroundColor(.gray)
                                                    }.padding(.trailing, 5)
                                                    Text(self.bio ? String(Double(self.personality).truncate(places: 1)) : String(Double(self.appearance).truncate(places: 1)))
                                                        .font(Font.custom("ProximaNova-Regular", size: 30))
                                                        .fontWeight(.semibold)
                                                        .lineLimit(1)
                                                        .frame(width: 50, height: 40)
                                                        .foregroundColor(self.bio ? Color("personality") : Color("appearance"))
                                                        .minimumScaleFactor(0.02)
                                                        .animation(nil)
                                                    ProfileRatingSlider(percentage: self.bio ? self.$personality : self.$appearance, bio: self.$bio)
                                                        .frame(width: 160, height: 55)
                                                        .cornerRadius(27.5)
                                                        .accentColor(self.bio ? Color("personality") : Color("appearance"))
                                                }
                                            }
                                            else {
                                                Button(action: {
                                                    self.rating.toggle()
                                                }) {
                                                    Image("rate")
                                                        .resizable()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                        .padding(20)
                                                }
                                            }
                                        }
                                        Button(action: {
                                            self.bio.toggle()
                                        }) {
                                            Image(self.bio ? "eye" : "heart")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .padding(20)
                                                .foregroundColor(.white)
                                                .background(Circle().frame(width: 65, height: 65).foregroundColor(Color(self.bio ? "appearance" : "personality")).shadow(color: Color(self.bio ? "appearance" : "personality"), radius: 5))
                                        }
                                        if !self.rating {
                                            Button(action: {
                                                if self.nonext {
                                                    
                                                }
                                                else {
                                                    self.showcomment.toggle()
                                                }
                                            }) {
                                                Image(systemName: "arrow.right")
                                                    .font(Font.system(size: 32, weight: .bold))
                                                    .foregroundColor(Color(.blue).opacity(0.5))
                                                    .padding(10)
                                            }
                                        }
                                    }
                                }.frame(width: screenwidth-20, height: screenheight/1.2).padding(.all, 2.5)
                                    .padding(.bottom, self.screenheight > 800 ? screenheight*0.1 : screenheight*0.05)
                            }
                        }
                    }.edgesIgnoringSafeArea(.all)
                }
                //MARK: TopBar
                VStack {
                    HStack {
                        Button(action: {
                            self.rating1.toggle()
                        }) {
                            Image("back")
                                .resizable()
                                .frame(width: 37, height: 35)
                                .foregroundColor(Color(.gray))
                        }.padding(.leading, 15)
                        Spacer()
                        Button(action: {
                            self.showkeys.toggle()
                        }) {
                            HStack {
                                Text(String(self.observer.keys))
                                    .font(Font.custom("ProximaNova-Regular", size: 32))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.blue).opacity(0.5))
                                    .animation(nil)
                                Image("key")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(.blue).opacity(0.5))
                            }
                        }.padding(.trailing, 10)
                    }.padding(.top, self.screenheight > 800 ? self.screenheight*0.05 : self.screenheight*0.035)
                    Spacer()
                }
            }.blur(radius: self.unlocksocials || self.showkeys || self.showcomment || self.report ? 4 : 0).animation(.spring())
            //MARK: Comment
            ZStack {
                Button(action: {
                    self.showcomment = false
                }) {
                    Color(.white)
                        .opacity(0)
                        .frame(width: self.screenwidth, height: self.screenheight)
                }
                ZStack {
                    VStack(spacing: 5) {
                        HStack(spacing: 30) {
                            VStack(spacing: 0) {
                                Image("eye")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 25, height: 27.5)
                                    .foregroundColor(Color("appearance"))
                                Text(String(Double(self.appearance).truncate(places: 1)))
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .frame(height: 20)
                                    .minimumScaleFactor(0.02)
                                    .foregroundColor(Color("appearance"))
                            }
                            VStack(spacing: 0) {
                                Image("heart")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("personality"))
                                Text(String(Double(self.personality).truncate(places: 1)))
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .frame(height: 20)
                                    .minimumScaleFactor(0.02)
                                    .foregroundColor(Color("personality"))
                            }
                        }
                        HStack {
                            Image("commentbutton")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color(.blue).opacity(0.5).cornerRadius(10))
                                .padding(.leading, 10)
                            Text("Comment:")
                                .font(Font.custom("ProximaNova-Regular", size: 30))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .frame(height: 30)
                                .minimumScaleFactor(0.02)
                                .foregroundColor(Color(.blue).opacity(0.5))
                            Spacer()
                        }.padding(.vertical, 5)
                        if self.showcomment {
                            ResizingTextFieldRed(text: self.$comment)
                                .frame(width: self.screenwidth/1.5 - 40, height: 100)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color("lightgray").opacity(0.4).cornerRadius(15))
                                .animation(.spring())
                            HStack(spacing: 0) {
                                Spacer()
                                Text(String(self.comment.count) + "/100 Characters")
                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor((self.comment.count <= 100) ? Color(.gray) : Color("personality"))
                                    .animation(nil)
                            }.frame(width: self.screenwidth/1.5 - 20).padding(.trailing, 10).padding(.bottom, 10).animation(.spring())
                        }
                        HStack(spacing: 5) {
                            Button(action: {
                                self.showcomment = false
                                self.bio = false
                                self.next.toggle()
                                self.comment = "No Comment"
                                UpdateRating(user: self.observer.users[self.observer.rated], appearance: Double(self.appearance), personality: Double(self.personality), keys: self.observer.keys, comment: self.comment) { (complete) in
                                    if complete {
                                        self.showrating = false
                                        self.showsocials = false
                                        self.count = 0
                                        let seconds = 0.5
                                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                            self.appearance = 5
                                            self.personality = 5
                                            if self.observer.users.count != self.observer.rated+1 {
                                                self.observer.rated += 1
                                                if self.observer.ratings == 0 {
                                                    self.ad = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                        self.showad.toggle()
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                            self.wait = true
                                                        }
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
                                            }
                                        }
                                        self.comment = ""
                                        self.observer.socialunlock = false
                                        self.unlocksocials = false
                                    }
                                    else {
                                        self.msg = "There was an err"
                                        self.alert.toggle()
                                    }
                                }
                            }) {
                                Text("No Comment")
                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.black))
                            }.frame(width: self.screenwidth/3.25 - 5, height: 40).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            
                            Button(action: {
                                if self.comment.count > 100 {
                                    self.msg = "Your comment is too long. (Max is 100 characters)"
                                    self.alert.toggle()
                                    return
                                }
                                if self.comment == "" {
                                    self.comment = "No Comment"
                                }
                                self.showcomment = false
                                self.bio = false
                                self.next.toggle()
                                UpdateRating(user: self.observer.users[self.observer.rated], appearance: Double(self.appearance), personality: Double(self.personality), keys: self.observer.keys, comment: self.comment) { (complete) in
                                    if complete {
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
                                            }
                                        }
                                        self.comment = ""
                                        self.observer.socialunlock = false
                                        self.unlocksocials = false
                                    }
                                    else {
                                        self.msg = "There was an err"
                                        self.alert.toggle()
                                    }
                                }
                            }) {
                                Text("Send")
                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.black))
                            }.frame(width: self.screenwidth/3.25 - 5, height: 40).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                        }
                        
                    }.frame(width: screenwidth/1.5).padding(20).background(Color(.white).cornerRadius(25).shadow(radius: 10))
                }
            }.opacity(self.showcomment ? 1 : 0).offset(y: -30).animation(.spring())
            
            //MARK: Report
            ZStack {
                Button(action: {
                    self.report.toggle()
                    self.confirm = false
                    self.confirm1 = false
                }) {
                    Color(.white)
                        .opacity(0)
                        .frame(width: screenwidth - 60, height: (screenwidth - 60)*1.6 + 105)
                }.offset(y: self.report ? 0 : screenheight)
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        if self.confirm {
                            VStack {
                                Text("Are You Sure You Want To Report This User's Socials?")
                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.black))
                                    .animation(nil)
                                    .multilineTextAlignment(.center)
                                    .padding(5)
                                Text("(Report if the socials don't work or if they don't match the user)")
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                    .animation(nil)
                                    .multilineTextAlignment(.center)
                                    .padding(5)
                            }
                        }
                        else if self.confirm1 {
                            VStack {
                                Text("Are You Sure You Want To Report This User?")
                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.black))
                                    .animation(nil)
                                    .multilineTextAlignment(.center)
                                    .padding(5)
                                Text("(Report if there are any inappropriate images or messages in the bio.)")
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                    .animation(nil)
                                    .multilineTextAlignment(.center)
                                    .padding(5)
                            }
                        }
                        if !self.confirm && !self.confirm1 && self.observer.socialunlock {
                            Button(action: {
                                self.confirm.toggle()
                            }) {
                                Text("Report Socials")
                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .animation(nil)
                                    .foregroundColor(Color(.black))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50).padding(.horizontal, 20).background(Color(.white).cornerRadius(25).shadow(color: Color("lightgray").opacity(0.9), radius: 10))
                            }
                        }
                        Button(action: {
                            if self.confirm || self.confirm1 {
                                /*let db = Firestore.firestore()
                                let uid = Auth.auth().currentUser?.uid
                                let reports = self.observer.users[self.observer.rated].Report + 1
                                self.observer.users[self.observer.rated].Reports.append(uid!)
                                db.collection("users").document(self.observer.users[self.observer.rated].id).updateData(["Report": reports, "Reports": self.observer.users[self.observer.rated].Reports]) { (err) in
                                    if err != nil {
                                        self.msg = "There was an error"
                                        self.alert.toggle()
                                        return
                                    }*/
                                    self.report.toggle()
                                    self.confirm1 = false
                                    self.confirm = false
                                    self.showcomment = false
                                    self.bio = false
                                    self.next.toggle()
                                    self.showrating = false
                                    self.showsocials = false
                                    self.count = 0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.appearance = 5
                                        self.personality = 5
                                        if self.observer.users.count != self.observer.rated + 1 {
                                            self.observer.rated += 1
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                self.next.toggle()
                                            }
                                        }
                                        else {
                                        }
                                    }
                                    self.comment = ""
                                    self.observer.socialunlock = false
                                    self.unlocksocials = false
                                //}
                            }
                            else {
                                self.confirm1.toggle()
                            }
                        }) {
                            Text(self.confirm || self.confirm1 ? "Confirm" : "Report User")
                                .font(Font.custom("ProximaNova-Regular", size: 22))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .animation(nil)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .padding(.horizontal, 20)
                                .background(Color(.white).cornerRadius(25).shadow(color: Color("lightgray").opacity(0.9), radius: 10))
                        }
                        Button(action: {
                            if self.confirm {
                                self.confirm.toggle()
                            }
                            else if self.confirm1 {
                                self.confirm1.toggle()
                            }
                            else {
                                self.report.toggle()
                            }
                        }) {
                            Text("Cancel")
                                .font(Font.custom("ProximaNova-Regular", size: 22))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .animation(nil)
                                .foregroundColor(Color(.white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50).padding(.horizontal, 20).background(Color("personality").cornerRadius(25).shadow(color: Color("lightgray").opacity(0.6), radius: 10))
                        }
                        
                    }.padding(20).background(Color(.white).cornerRadius(25).shadow(radius: 10)).padding(20).offset(y: self.report ? 0 : self.screenheight).padding(.bottom, 10).animation(.spring())
                }.frame(height: screenheight)
            }
            //MARK: Socials
            if self.observer.users[self.observer.rated].Socials[0] == "N/A" && self.observer.users[self.observer.rated].Socials[1] == "N/A" && self.observer.users[self.observer.rated].Socials[2] == "N/A" {
                ZStack {
                    Button(action: {
                        self.unlocksocials = false
                    }) {
                        Color(.white)
                            .opacity(0)
                    }
                    VStack {
                        Text("No Socials")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        ZStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                            Image("social")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 55, height: 55)
                                .foregroundColor(.red)
                        }
                    }.padding(20).background(Color(.white).cornerRadius(20).shadow(radius: 10))
                }.offset(y: self.unlocksocials ? 0 : screenheight).animation(.spring())
            }
            else {
                ZStack {
                    Button(action: {
                        self.unlocksocials = false
                    }) {
                        Color(.white)
                            .opacity(0)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Socials")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        ZStack {
                            HStack(spacing: 10) {
                                if self.observer.users[self.observer.rated].Socials[0] != "N/A" {
                                    Button(action: {
                                        if self.observer.socialunlock {
                                            let link = "https://instagram.com/" + self.observer.users[self.observer.rated].Socials[0]
                                            UIApplication.shared.open(URL(string: link)!)
                                        }
                                    }) {
                                        Image("instagram")
                                            .resizable()
                                            .frame(width: 50, height: 50)
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
                                            .frame(width: 50, height: 50)
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
                                            .frame(width: 50, height: 50)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            }.padding(.all, 10).background(Color(.white).cornerRadius(15)).blur(radius: !self.observer.socialunlock ? 6: 0)
                            if !self.observer.socialunlock {
                                Image("lock")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            }
                        }
                        if !self.observer.socialunlock {
                            Button(action: {
                                if self.observer.keys == 0 {
                                    self.showkeys = true
                                }
                                else {
                                    let changekeys = self.observer.keys - 1
                                    KeyChange(keys: changekeys) { (complete) in
                                        if complete {
                                            self.observer.keys = changekeys
                                            self.observer.socialunlock = true
                                        }
                                        else {
                                            self.msg = "There was an error"
                                            self.alert.toggle()
                                            return
                                        }
                                    }
                                }
                            }) {
                                HStack(spacing: 5) {
                                    Text("Unlock ")
                                        .font(Font.custom("ProximaNova-Regular", size: 22))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.white))
                                        .animation(nil)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(Color(.white).opacity(0.8))
                                            .frame(width: 50, height: 30)
                                        HStack(spacing: 5) {
                                            Text("-1")
                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("appearance"))//Color("personality"))
                                                .animation(nil)
                                            Image("key")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(Color("appearance"))//Color("personality"))
                                        }
                                    }
                                }.padding(10).background(Color("appearance").cornerRadius(10)).padding(.top, 10)
                            }//.padding(.horizontal, self.screenwidth*0.12)
                        }
                    }.padding(20).background(Color(.white).cornerRadius(20).shadow(radius: 10))
                }.offset(y: self.unlocksocials ? 0 : screenheight).animation(.spring())
            }
            //MARK: ShowKeys
            ZStack {
                Button(action: {
                    self.showkeys = false
                }) {
                    Color(.white)
                        .opacity(0)
                        .frame(width: self.screenwidth, height: self.screenheight)
                }
                VStack {
                    VStack(spacing: 20) {
                        HStack {
                            Text(String(self.observer.keys))
                                .font(Font.custom("ProximaNova-Regular", size: 30))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                            Image("key")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.white))
                        }.padding(5).padding(.horizontal, 5).background(Color(.blue).opacity(0.5).cornerRadius(15)).padding(.top, 10)
                        HStack(spacing: 15) {
                            Button(action: {
                                self.rewardAd.showAd(rewardFunction: {
                                    let changekeys = self.observer.keys + 3
                                    KeyChange(keys: changekeys) { (complete) in
                                        if complete {
                                            self.observer.keys = changekeys
                                        }
                                        else {
                                            self.msg = "There was an error."
                                            self.alert.toggle()
                                            return
                                        }
                                    }
                                })
                            }) {
                                ZStack() {
                                    Color("appearance")
                                        .cornerRadius(25)
                                    VStack {
                                        Image("ad")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(.white))
                                        VStack(spacing: 2.5) {
                                            Text("Watch Ad")
                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.white))
                                            HStack(spacing: 2.5) {
                                                Text("+3")
                                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                Image("key")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Color(.white))
                                            }
                                        }
                                    }
                                }.frame(width: 130, height: 160).padding(.leading, 10)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Button(action: {
                                        
                                    }) {
                                        ZStack {
                                            Color("personality")
                                                .cornerRadius(25)
                                            HStack(spacing: 2.5) {
                                                Text("+20")
                                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                Image("key")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color(.white))
                                            }
                                            VStack {
                                                Spacer()
                                                Text("$0.99")
                                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                    .padding(.vertical, 5)
                                            }
                                        }.frame(width: 110, height: 140)
                                    }
                                    Button(action: {
                                        
                                    }) {
                                        ZStack {
                                            Color("personality")
                                                .cornerRadius(25)
                                            HStack(spacing: 2.5) {
                                                Text("+50")
                                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                Image("key")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color(.white))
                                            }
                                            VStack {
                                                Spacer()
                                                Text("$1.99")
                                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                    .padding(.vertical, 5)
                                            }
                                        }.frame(width: 110, height: 140)
                                    }
                                    Button(action: {
                                        
                                    }) {
                                        ZStack {
                                            Color("personality")
                                                .cornerRadius(25)
                                            HStack(spacing: 2.5) {
                                                Text("+150")
                                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                Image("key")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color(.white))
                                            }
                                            VStack {
                                                Spacer()
                                                Text("$4.99")
                                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                    .padding(.vertical, 5)
                                            }
                                        }.frame(width: 110, height: 140)
                                    }
                                    Button(action: {
                                        
                                    }) {
                                        ZStack {
                                            Color("personality")
                                                .cornerRadius(25)
                                            HStack(spacing: 2.5) {
                                                Text("+500")
                                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                Image("key")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color(.white))
                                            }
                                            VStack {
                                                Spacer()
                                                Text("$9.99")
                                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                                    .padding(.vertical, 5)
                                            }
                                        }.frame(width: 110, height: 140)
                                    }
                                }
                            }.frame(height: 140)
                            .padding(5).overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 10)
                                .foregroundColor(Color("personality.5"))).padding(5).background(Color("personality").opacity(0.5).cornerRadius(25)).padding(.trailing, 10)
                        }
                        HStack {
                            Text("Remove Ads")
                                .font(Font.custom("ProximaNova-Regular", size: 22))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                            Image("ad")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color(.white))
                            Spacer()
                            Text("$4.99")
                                .font(Font.custom("ProximaNova-Regular", size: 26))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                        }.padding(20).background(Color("personality").cornerRadius(25)).padding(.horizontal, 10)
                    }.frame(width: screenwidth).padding(.vertical, 20).padding(.top, 20).background(Color(.white).cornerRadius(25).shadow(radius: 10))
                    Spacer()
                }.frame(height: screenheight)
            }.offset(y: self.showkeys ? 0 : -self.screenheight).animation(.spring())
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
                        .foregroundColor(Color(.blue).opacity(0.5))
                    Image("key")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 35, height: 35)
                }
            }.animation(.spring()).offset(x: self.newkeyx, y: self.newkey).scaleEffect((self.newkey < 0) ? 1 : 1.9).opacity(self.showkey ? 1 : 0)
            
            //MARK: Connection
                ZStack {
                    Color("personality")
                        .frame(width: screenwidth, height: screenheight)
                    VStack(spacing: 15) {
                        Text("Connection Error")
                            .font(Font.custom("ProximaNova-Regular", size: 28))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        GIFView(gifName: "rategif")
                            .frame(width: 100, height: 50)
                        Text("Reconnecting")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 0 ? 1 : 0.3))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 1 ? 1 : 0.3))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 2 ? 1 : 0.3))
                        }
                    }.onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            if self.refreshing != 2 {
                                self.refreshing += 1
                            }
                            else {
                                self.refreshing = 0
                            }
                        }
                    }
                    
                }.offset(y: !self.connectionstatus ? -5 : -screenheight - 10)
                .animation(.spring())
        }.background(Color(.white).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }.onAppear {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                self.connectionstatus = Reachability.isConnectedToNetwork()
            }
        }.onDisappear {
            UserDefaults.standard.set(self.ad, forKey: "ad")
            UserDefaults.standard.set(self.showad, forKey: "showad")
        }
    }
}


//MARK: SettingsView
struct SettingView: View {
    @EnvironmentObject var observer: observer
    @Binding var settings: Bool
    @Binding var start: Bool
    @State var profile = true
    @State var social = false
    @State var photos = false
    @State var bio = false
    @State var more = false
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        self.settings.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.profile = true
                        }
                    }
                }) {
                    Image("back")
                        .resizable()
                        .frame(width: 30, height: 27.5)
                        .foregroundColor(Color(.darkGray))
                        .rotationEffect(Angle(degrees: 180))
                }.padding(.trailing, 20)
            }.padding(.top, self.screenheight > 800 ? self.screenheight*0.055 : screenheight*0.035)
            HStack {
                HStack {
                    Image("user")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(.gray))
                        .opacity(self.profile ? 1 : 0.3)
                    Text("Profile")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.darkGray).opacity(self.profile ? 1 : 0.3))
                }
                Spacer()
            }.frame(width: screenwidth - 50).padding(.vertical, 10)
            //MARK: Profile Edit
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    HStack {
                        Text("Name")
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                            .frame(height: 30)
                            .minimumScaleFactor(0.02)
                            .padding(.top, 15)
                            .padding(.leading, 20)
                        Spacer()
                        Text(self.observer.myprofile.Name)
                            .font(Font.custom("ProximaNova-Regular", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.gray))
                            .frame(height: 30)
                            .minimumScaleFactor(0.01)
                            .frame(width: 100)
                            .lineLimit(1)
                            .padding(.top, 15)
                            .padding(.trailing, 20)
                    }
                    
                    Divider().frame(width: screenwidth - 40)
                }
                
                HStack {
                    Text("Age")
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .frame(height: 30)
                        .padding(.leading, 20)
                    Spacer()
                    Text(self.observer.myprofile.Age)
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.gray))
                        .frame(height: 30)
                        .padding(.trailing, 20)
                }
                
                Divider().frame(width: screenwidth - 40)
                
                HStack {
                    Text("Socials")
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .frame(height: 30)
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink(destination: Socials(social: self.$social), isActive: self.$social) {
                        Button(action: {
                            self.social.toggle()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                        }
                    }
                }
                
                Divider().frame(width: screenwidth - 40)
                
                HStack {
                    Text("Photos")
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .frame(height: 30)
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink(destination: Photos(photos: self.$photos), isActive: self.$photos) {
                        Button(action: {
                            self.photos.toggle()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                        }
                    }
                }
                
                Divider().frame(width: screenwidth - 40)
                
                HStack {
                    Text("Bio")
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .frame(height: 30)
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink(destination: Bio(bio: self.$bio), isActive: self.$bio) {
                        Button(action: {
                            self.bio.toggle()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                        }
                    }
                }.padding(.bottom, 15)
            }.frame(width: screenwidth - 40).background(Color(.white).cornerRadius(30).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10)).padding(.bottom, 40)
            Spacer()
            
            HStack {
                Text("More Settings")
                    .font(Font.custom("ProximaNova-Regular", size: 26))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.black))
                    .frame(height: 30)
                    .padding(.leading, 20)
                Spacer()
                NavigationLink(destination: MoreSettings(more: self.$more, start: self.$start), isActive: self.$more) {
                    Button(action: {
                        self.more.toggle()
                    }) {
                        HStack(spacing: 5) {
                            Image("settings-1")
                                .resizable()
                                .frame(width: 35, height: 35)
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 24, weight: .bold))
                                .padding(.trailing, 15)
                                .foregroundColor(Color(.darkGray))
                        }
                    }.buttonStyle(PlainButtonStyle())
                }.buttonStyle(PlainButtonStyle())
            }.frame(width: screenwidth - 40).padding(.vertical, 15).background(Color(.white).cornerRadius(30).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10)).opacity(0.7).padding(.bottom, 40)
        }.frame(width: screenwidth, height: screenheight).background(LinearGradient(gradient: Gradient(colors: [Color("lightgray"), Color(.white)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
    }
}


//MARK: Socials
struct Socials: View {
    @EnvironmentObject var observer: observer
    @Binding var social: Bool
    @State var alert = false
    @State var msg = ""
    @State var loading = false
    @State var edit = false
    @State var newinsta = ""
    @State var newsnap = ""
    @State var newtwitter = ""
    @State var refreshing: Int = 0
    @State var connectionstatus = true
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation {
                            self.social.toggle()
                        }
                    }) {
                        Image("back")//systemName: "chevron.left.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(.gray))
                    }.padding(.leading, 15)
                    Spacer()
                }.padding(.top, self.screenheight > 800 ? self.screenheight*0.055 : screenheight*0.035)
                Text("Socials")
                    .font(Font.custom("ProximaNova-Regular", size: 34))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                    .padding(.vertical, screenheight*0.025)
                //MARK: Instagram
                VStack(spacing: 15) {
                    VStack {
                        HStack {
                            Text("Instagram")
                                .font(Font.custom("ProximaNova-Regular", size: 26))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black))
                                .padding(.leading, 20)
                            Image("instagram")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Spacer()
                            HStack {
                                Spacer()
                                Text(self.observer.myprofile.Socials[0])
                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                    .padding(.trailing, 20)
                            }.frame(width: 150)
                        }
                        
                        if self.edit {
                            ZStack {
                                if self.newinsta.isEmpty {
                                    Text("New Handle")
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .lineLimit(1)
                                        .foregroundColor(Color(.gray))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                TextField("", text: self.$newinsta)
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                    .foregroundColor(Color(.black))
                                    .multilineTextAlignment(.center)
                                    
                            }.frame(width: screenwidth/2.15, height: 40)
                                .background(Color("lightgray").opacity(0.5).cornerRadius(15))
                        }
                    }.padding(.vertical, 15).frame(width: screenwidth - 40).background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                    
                    //MARK: Snapchat
                    VStack {
                        HStack {
                            Text("Snapchat")
                                .font(Font.custom("ProximaNova-Regular", size: 26))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black))
                                .padding(.leading, 20)
                            Image("snapchat")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Spacer()
                            HStack {
                                Spacer()
                                Text(self.observer.myprofile.Socials[1])
                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                    .padding(.trailing, 20)
                            }.frame(width: 150)
                        }
                        if self.edit {
                            ZStack {
                                if self.newsnap.isEmpty {
                                    Text("New Handle")
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .foregroundColor(Color(.gray))
                                }
                                TextField("", text: self.$newsnap)
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                    .foregroundColor(Color(.black))
                                    .frame(width: screenwidth/2.5, height: 40)
                                    .multilineTextAlignment(.center)
                                    
                            }.frame(width: screenwidth/2.15, height: 40)
                            .background(Color("lightgray").opacity(0.5).cornerRadius(15))
                        }
                    }.padding(.vertical, 15).frame(width: screenwidth - 40).background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                    
                    
                    //MARK: Twitter
                    VStack {
                        HStack {
                            Text("Twitter")
                                .font(Font.custom("ProximaNova-Regular", size: 26))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.black))
                                .padding(.leading, 20)
                            Image("twitter")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Spacer()
                            HStack {
                                Spacer()
                                Text(self.observer.myprofile.Socials[2])
                                    .font(Font.custom("ProximaNova-Regular", size: 26))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                    .padding(.trailing, 20)
                            }.frame(width: 150)
                        }
                        if self.edit {
                            ZStack {
                                if self.newtwitter.isEmpty {
                                    Text("New Handle")
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .foregroundColor(Color(.gray))
                                }
                                TextField("", text: self.$newtwitter)
                                    .font(Font.custom("ProximaNova-Regular", size: 18))
                                    .foregroundColor(Color(.black))
                                    .multilineTextAlignment(.center)
                            }.frame(width: screenwidth/2.15, height: 40)
                                .background(Color("lightgray").opacity(0.5).cornerRadius(15))
                        }
                    }.padding(.vertical, 15).frame(width: screenwidth - 40).background(Color(.white).cornerRadius(25).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                }.padding(.bottom, screenheight*0.025)
                if self.loading {
                    WhiteLoader()
                }
                else if self.edit {
                    HStack(spacing: 20) {
                        Button(action: {
                            self.loading.toggle()
                            let db = Firestore.firestore()
                            let uid = Auth.auth().currentUser?.uid
                            var newsocials = self.observer.myprofile.Socials
                            if self.newinsta != "" {
                                newsocials[0] = self.newinsta
                            }
                            if self.newsnap != "" {
                                newsocials[1] = self.newsnap
                            }
                            if self.newtwitter != "" {
                                newsocials[2] = self.newtwitter
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                if self.loading {
                                    self.msg = "Something Went Wrong"
                                    self.alert.toggle()
                                    self.edit.toggle()
                                    self.newinsta = ""
                                    self.newsnap = ""
                                    self.newtwitter = ""
                                    self.loading.toggle()
                                }
                            }
                            db.collection("users").document(uid!).updateData(["Socials": newsocials]) { (err) in
                                if err != nil {
                                    print((err?.localizedDescription)!)
                                    return
                                }
                                self.loading.toggle()
                                self.observer.myprofile.Socials = newsocials
                                self.newinsta = ""
                                self.newsnap = ""
                                self.newtwitter = ""
                                self.edit = false
                            }
                        }) {
                            HStack {
                                Text("Confirm")
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                Image(systemName: "checkmark")
                                    .font(Font.system(size: 18, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        Button(action: {
                            withAnimation {
                                self.edit.toggle()
                                self.newinsta = ""
                                self.newsnap = ""
                                self.newtwitter = ""
                            }
                        }) {
                            HStack {
                                Text("Cancel")
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 18, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                else {
                    Button(action: {
                        withAnimation {
                            self.edit.toggle()
                        }
                    }) {
                        HStack {
                            Text("Edit Socials")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.gray))
                            Image(systemName: "pencil")
                                .font(Font.system(size: 18, weight: .bold))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }.frame(width: screenwidth, height: screenheight)
                .background(Color("lightgray").edgesIgnoringSafeArea(.all)).animation(.spring())
            
            //MARK: Connection
            ZStack {
                Color("personality")
                    .frame(width: screenwidth, height: screenheight)
                VStack(spacing: 15) {
                    Text("Connection Error")
                        .font(Font.custom("ProximaNova-Regular", size: 28))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    GIFView(gifName: "rategif")
                        .frame(width: 100, height: 50)
                    Text("Reconnecting")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(.white).opacity(self.refreshing == 0 ? 1 : 0.3))
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(.white).opacity(self.refreshing == 1 ? 1 : 0.3))
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(.white).opacity(self.refreshing == 2 ? 1 : 0.3))
                    }
                }.onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        if self.refreshing != 2 {
                            self.refreshing += 1
                        }
                        else {
                            self.refreshing = 0
                        }
                    }
                }
                
            }.offset(y: !self.connectionstatus ? -5 : -screenheight - 10)
            .animation(.spring())
        }.onAppear {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                self.connectionstatus = Reachability.isConnectedToNetwork()
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
    }
}


//MARK: Photos
struct Photos: View {
    @EnvironmentObject var observer: observer
    @Binding var photos: Bool
    @State var edit = false
    @State var newphotos = [false, false, false, false]
    @State var confirm = false
    @State var index = -1
    @State var profilepics = [Data(), Data(), Data(), Data()]
    @State var picker = false
    @State var num = 0
    @State var loading = false
    @State var alert = false
    @State var msg = ""
    @State var connectionstatus = true
    @State var refreshing: Int = 0
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        if !self.loading {
                            withAnimation {
                                self.photos.toggle()
                            }
                        }
                    }) {
                        Image("back")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(.gray))
                    }.padding(.leading, 15)
                    Spacer()
                }.padding(.top, self.screenheight > 800 ? self.screenheight*0.055 : screenheight*0.035)
                HStack {
                    Text("Photos")
                        .font(Font.custom("ProximaNova-Regular", size: 34))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.darkGray))
                        
                    /*Button(action: {
                        
                    }) {
                        Image(systemName: "pencil")
                            .font(Font.system(size: 28, weight: .heavy))
                            .foregroundColor(Color(.darkGray))
                            
                    }*/
                }.padding(.horizontal, 60).padding(.vertical, screenheight*0.025)
                //MARK: Photo 1
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        ZStack {
                            if self.profilepics[0].count != 0 {
                                Image(uiImage: UIImage(data: self.profilepics[0])!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            else if self.newphotos[0] {
                                Color("lightgray")
                                    .opacity(0.3)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .cornerRadius(25)
                            }
                            else {
                                WebImage(url: URL(string: self.observer.myprofile.ProfilePics[0]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            if self.edit {
                                VStack {
                                    if self.newphotos[0] {
                                        Button(action: {
                                            withAnimation {
                                                self.num = 0
                                                self.picker.toggle()
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.white)
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.gray)
                                            }.shadow(color: .white, radius: 20, x: 0, y: 0)
                                        }
                                    }
                                    else {
                                        Button(action: {
                                            withAnimation {
                                                self.newphotos[0].toggle()
                                                self.profilepics[0] = Data()
                                            }
                                        }) {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                    Image(systemName: "xmark")
                                                        .font(Font.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color("personality"))
                                                }.padding(10)
                                            }
                                        }
                                        Spacer()
                                    }
                                }.frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                            }
                        }.padding(10).background(Color(.white).cornerRadius(35).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                        //MARK: Photo 2
                        ZStack {
                            if self.profilepics[1].count != 0 {
                                Image(uiImage: UIImage(data: self.profilepics[1])!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            else if self.newphotos[1] {
                                Color("lightgray")
                                    .opacity(0.3)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .cornerRadius(25)
                            }
                            else {
                                WebImage(url: URL(string: self.observer.myprofile.ProfilePics[1]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            if self.edit {
                                VStack {
                                    if self.newphotos[1] {
                                        Button(action: {
                                            withAnimation {
                                                self.num = 1
                                                self.picker.toggle()
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.white)
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.gray)
                                            }.shadow(color: .white, radius: 20, x: 0, y: 0)
                                        }
                                    }
                                    else {
                                        Button(action: {
                                            withAnimation {
                                                self.newphotos[1].toggle()
                                                self.profilepics[1] = Data()
                                            }
                                        }) {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                    Image(systemName: "xmark")
                                                        .font(Font.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color("personality"))
                                                }
                                                .padding(10)
                                            }
                                        }
                                        Spacer()
                                    }
                                }.frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                            }
                        }.padding(10).background(Color(.white).cornerRadius(35).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                    }
                    
                    HStack(spacing: 20) {
                        //MARK: Photo 3
                        ZStack {
                            if self.profilepics[2].count != 0 {
                                Image(uiImage: UIImage(data: self.profilepics[2])!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            else if self.newphotos[2] {
                                Color("lightgray")
                                    .opacity(0.3)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .cornerRadius(25)
                            }
                            else {
                                WebImage(url: URL(string: self.observer.myprofile.ProfilePics[2]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            if self.edit {
                                VStack {
                                    if self.newphotos[2] {
                                        Button(action: {
                                            withAnimation {
                                                self.num = 2
                                                self.picker.toggle()
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.white)
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.gray)
                                            }.shadow(color: .white, radius: 20, x: 0, y: 0)
                                        }
                                    }
                                    else {
                                        Button(action: {
                                            withAnimation {
                                                self.newphotos[2].toggle()
                                                self.profilepics[2] = Data()
                                            }
                                        }) {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                    Image(systemName: "xmark")
                                                        .font(Font.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color("personality"))
                                                }
                                                .padding(10)
                                            }
                                        }
                                        Spacer()
                                    }
                                }.frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                            }
                        }.padding(10).background(Color(.white).cornerRadius(35).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                        //MARK: Photo 4
                        ZStack {
                            if self.profilepics[3].count != 0 {
                                Image(uiImage: UIImage(data: self.profilepics[3])!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            else if self.newphotos[3] {
                                Color("lightgray")
                                    .opacity(0.3)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .cornerRadius(25)
                            }
                            else {
                                WebImage(url: URL(string: self.observer.myprofile.ProfilePics[3]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                                    .animation(nil)
                                    .cornerRadius(25)
                            }
                            if self.edit {
                                VStack {
                                    if self.newphotos[3] {
                                        Button(action: {
                                            withAnimation {
                                                self.num = 3
                                                self.picker.toggle()
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.white)
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.gray)
                                            }.shadow(color: .white, radius: 20, x: 0, y: 0)
                                        }
                                    }
                                    else {
                                        Button(action: {
                                            withAnimation {
                                                self.newphotos[3].toggle()
                                                self.profilepics[3] = Data()
                                            }
                                        }) {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                    Image(systemName: "xmark")
                                                        .font(Font.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color("personality"))
                                                }
                                                .padding(10)
                                            }
                                        }
                                        Spacer()
                                    }
                                }.frame(width: self.screenwidth/2 - 60, height: (self.screenwidth/2 - 60)*1.3)
                            }
                        }.padding(10).background(Color(.white).cornerRadius(35).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                    }
                }/*.padding(20).background(Color(.white).cornerRadius(35).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))*/.padding(.bottom, screenheight*0.025)
                //MARK: Edit Photos
                if loading {
                    WhiteLoader()
                }
                else if self.edit {
                    HStack(spacing: 20) {
                        Button(action: {
                            var newprofilepic = self.observer.myprofile.ProfilePics
                            self.loading.toggle()
                            let storage = Storage.storage().reference()
                            let db = Firestore.firestore()
                            let uid = Auth.auth().currentUser?.uid
                            var check = true
                            for num in 0...3 {
                                if self.newphotos[num] && self.profilepics[num].count == 0 {
                                    check = false
                                }
                            }
                            if check {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    if self.loading {
                                        withAnimation {
                                            self.msg = "Something Went Wrong"
                                            self.alert.toggle()
                                            self.edit.toggle()
                                            self.loading.toggle()
                                            self.profilepics = [Data(), Data(), Data(), Data()]
                                            self.newphotos = [false, false, false, false]
                                            return
                                        }
                                    }
                                }
                                withAnimation {
                                    for num in 0...3 {
                                        if self.profilepics[num].count != 0 {
                                            print("bruh")
                                            let metadata = StorageMetadata.init()
                                            metadata.contentType = "image/jpeg"
                                            let upload = storage.child("ProfilePics").child(uid! + String(num)).putData(self.profilepics[num], metadata: metadata) { (_, err) in
                                                if err != nil {
                                                    self.msg = (err?.localizedDescription)!
                                                    return
                                                }
                                            }
                                            upload.observe(.success) { snapshot in
                                                storage.child("ProfilePics").child(uid! + String(num)).downloadURL { (url, err) in
                                                    if err != nil {
                                                        self.msg = (err?.localizedDescription)!
                                                        return
                                                    }
                                                    newprofilepic[num] = "\(url!)"
                                                    db.collection("users").document(uid!).updateData(["ProfilePics": newprofilepic]) { (err) in
                                                        if err != nil {
                                                            self.msg = (err?.localizedDescription)!
                                                            return
                                                        }
                                                        self.observer.myprofile.ProfilePics = newprofilepic
                                                        self.edit.toggle()
                                                        self.loading.toggle()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            else {
                                self.loading.toggle()
                                self.msg = "You must have four pictures."
                                self.alert.toggle()
                            }
                        }) {
                            HStack {
                                Text("Confirm")
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                Image(systemName: "checkmark")
                                    .font(Font.system(size: 18, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        Button(action: {
                            withAnimation {
                                self.edit.toggle()
                                self.profilepics = [Data(), Data(), Data(), Data()]
                                self.newphotos = [false, false, false, false]
                            }
                        }) {
                            HStack {
                                Text("Cancel")
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.gray))
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 18, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                else {
                    Button(action: {
                        withAnimation {
                            self.edit.toggle()
                        }
                    }) {
                        HStack {
                            Text("Edit")
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.gray))
                            Image(systemName: "pencil")
                                .font(Font.system(size: 18, weight: .bold))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }.frame(width: screenwidth, height: screenheight)
                .background(Color("lightgray").edgesIgnoringSafeArea(.all)).animation(.spring())
            
            //MARK: Connection
                ZStack {
                    Color("personality")
                        .frame(width: screenwidth, height: screenheight)
                    VStack(spacing: 15) {
                        Text("Connection Error")
                            .font(Font.custom("ProximaNova-Regular", size: 28))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        GIFView(gifName: "rategif")
                            .frame(width: 100, height: 50)
                        Text("Reconnecting")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 0 ? 1 : 0.3))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 1 ? 1 : 0.3))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.white).opacity(self.refreshing == 2 ? 1 : 0.3))
                        }
                    }.onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            if self.refreshing != 2 {
                                self.refreshing += 1
                            }
                            else {
                                self.refreshing = 0
                            }
                        }
                    }
                    
                }.offset(y: !self.connectionstatus ? -5 : -screenheight - 10)
                .animation(.spring())
            
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                self.connectionstatus = Reachability.isConnectedToNetwork()
            }
        }//.edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: self.$picker) {
            ImageRePicker(picker: self.$picker, images: self.$profilepics, newimage: self.$newphotos, num: self.$num)
        }.alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
    }
}


//MARK: Bio
struct Bio: View {
    @EnvironmentObject var observer: observer
    @Binding var bio: Bool
    @State var loading = false
    @State var edit = false
    let categories = ["General", "Education", "Occupation", "Music", "Sports", "Movies", "TV-Shows", "Hobbies", "Motto", "Future"]
    let colors = [Color(.black), Color(.blue), Color(.brown), Color(.black), Color(.red), Color(.black), Color(.lightGray), Color(.green), Color(.cyan), Color(.systemPink)]
    @State var selected = [false, false, false, false, false, false, false, false, false, false]
    @State var newbio = [String](repeating: "", count: 10)
    @State var tempbio = [String]()
    @State var index: Int = 0
    @State var shift = false
    @State var des = ""
    @State var alert = false
    @State var msg = ""
    @State var connectionstatus = true
    @State var refreshing: Int = 0
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation {
                            self.bio.toggle()
                        }
                    }) {
                        Image("back")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(.gray))
                    }.padding(.leading, screenwidth * 0.04)
                    Spacer()
                }.padding(.top, self.screenheight > 800 ? self.screenheight*0.055 : screenheight*0.035)
                VStack(spacing: 5) {
                    if !self.edit {
                        Text("Bio")
                            .font(Font.custom("ProximaNova-Regular", size: 30))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .frame(height: screenheight * 0.05)
                            .minimumScaleFactor(0.01)
                            .foregroundColor(Color(.darkGray))
                            .padding(.top, 5)
                    }
                    VStack(spacing: 0) {
                        ForEach(self.categories, id: \.self) { cat in
                            VStack(spacing: 0) {
                                if self.newbio[self.categories.firstIndex(of: cat)!] != "" || self.edit {
                                    VStack(spacing: self.screenheight * 0.009) {
                                        HStack {
                                            Image(cat)
                                                //.renderingMode(.template)
                                                .resizable()
                                                .frame(width: self.screenheight * 0.03, height: self.screenheight * 0.03)
                                                .padding(.leading, self.screenwidth * 0.053)
                                                //.foregroundColor(self.colors[self.categories.firstIndex(of: cat)!])
                                            Text(cat)
                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                                .frame(height: self.screenheight * 0.032)
                                                .foregroundColor(Color(.black))
                                            Spacer()
                                            Button(action: {
                                                withAnimation {
                                                    self.des = ""
                                                    self.index = self.categories.firstIndex(of: cat)!
                                                    if self.selected[self.index] {
                                                        self.selected[self.index] = false
                                                    }
                                                    else {
                                                        for num in 0...9 {
                                                            self.selected[num] = false
                                                        }
                                                        self.selected[self.index] = true
                                                    }
                                                    for str in self.observer.myprofile.Bio {
                                                        if self.index == (String(str.prefix(2)) as NSString).integerValue {
                                                            self.des = String(str)[2..<str.count]
                                                        }
                                                    }
                                                }
                                            }) {
                                                if self.edit {
                                                    Image(systemName: self.selected[self.categories.firstIndex(of: cat)!] ? "chevron.up" : "pencil")
                                                        .font(Font.system(size: 22, weight: .bold))
                                                        .foregroundColor(self.selected[self.categories.firstIndex(of: cat)!] ? .red : .gray)
                                                }
                                                else {
                                                    ZStack {
                                                        Color(.white)
                                                            .frame(width: self.screenheight * 0.03, height: self.screenheight * 0.03)
                                                        Image(systemName: "chevron.up")
                                                            .font(Font.system(size: 22, weight: .bold))
                                                            .rotationEffect(.degrees(self.selected[self.categories.firstIndex(of: cat)!] ? 0 : 180))
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }.padding(.trailing, self.screenwidth * 0.0533)
                                        }.frame(width: self.screenwidth - self.screenwidth*0.16)
                                            .padding(.vertical, self.screenheight*0.013)
                                        if self.selected[self.categories.firstIndex(of: cat)!] && self.edit {
                                            ResizingTextField(text: self.$newbio[self.index], shift: self.$shift, color: "gray")
                                                .frame(width: self.screenwidth - self.screenwidth*0.25, height: self.screenheight*0.098)
                                                .padding(2.5)
                                                .padding(.leading, 5)
                                                .background(Color("lightgray").opacity(0.3).cornerRadius(15))
                                                .padding(.bottom, self.screenheight*0.0061)
                                            HStack {
                                                Button(action: {
                                                    self.newbio[self.index] = ""
                                                    self.selected = [false, false, false, false, false, false, false, false, false, false]
                                                }) {
                                                    HStack(spacing: self.screenwidth*0.013) {
                                                        Text("Clear")
                                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                                            .fontWeight(.semibold)
                                                            .lineLimit(1)
                                                            .foregroundColor(Color("personality"))
                                                            .minimumScaleFactor(0.02)
                                                            .frame(height: self.screenheight*0.018)
                                                        Image(systemName: "xmark")
                                                            .font(Font.system(size: 13, weight: .bold))
                                                            .foregroundColor(Color("personality"))
                                                    }
                                                }.padding(.leading, self.screenwidth*0.08)
                                                Spacer()
                                                Text(String(self.newbio[self.index].count) + "/200 Characters")
                                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .foregroundColor(self.newbio[self.index].count > 200 ? Color(.red) : Color(.gray))
                                                    .frame(height: self.screenheight*0.018)
                                                    .minimumScaleFactor(0.02)
                                                    .padding(.trailing, self.screenwidth*0.08)
                                            }.frame(width: self.screenwidth - self.screenwidth*2*0.08).padding(.bottom, self.screenheight*0.012)
                                        }
                                        else if self.selected[self.categories.firstIndex(of: cat)!] {
                                            Text(self.des)
                                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.gray))
                                                .fixedSize(horizontal: false, vertical: true)
                                                .frame(width: 0.68*self.screenwidth)
                                                .padding(.bottom, self.screenheight*0.012)
                                        }
                                    }.cornerRadius(15).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10)).padding(.vertical, 5)
                                }
                            }
                        }
                    }.padding(.vertical, 5)
                    //MARK: Edit Bio
                    if self.loading {
                        WhiteLoader()
                    }
                    else if self.edit {
                        HStack(spacing: screenwidth*0.053) {
                            Button(action: {
                                self.loading.toggle()
                                var check = true
                                for bio in self.newbio {
                                    if bio.count > 200 {
                                        check = false
                                    }
                                }
                                if check {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                        if self.loading {
                                            withAnimation {
                                                self.msg = "Something Went Wrong"
                                                self.alert.toggle()
                                                self.newbio = self.tempbio
                                                self.edit.toggle()
                                                self.loading.toggle()
                                                return
                                            }
                                        }
                                    }
                                    let db = Firestore.firestore()
                                    let uid = Auth.auth().currentUser?.uid
                                    for num in 0...9 {
                                        if self.newbio[num] != "" {
                                            self.newbio[num] = "0" + String(num) + self.newbio[num]
                                        }
                                    }
                                    var newnewbio = [String]()
                                    for bio in self.newbio {
                                        if bio != "" {
                                            newnewbio.append(bio)
                                        }
                                    }
                                    db.collection("users").document(uid!).updateData(["Bio": newnewbio]) { (err) in
                                        if err != nil {
                                            print((err?.localizedDescription)!)
                                            print("BRUHHHHHHHHHLFJDLKS IFJE JFDSKLFJKJKJDLKJF JLKF")
                                            return
                                        }
                                        self.observer.myprofile.Bio = newnewbio
                                        for str in newnewbio {
                                            self.newbio[(String(str.prefix(2)) as NSString).integerValue] = String(str)[2..<str.count]
                                        }
                                        withAnimation {
                                            self.selected = [Bool](repeating: false, count: 10)
                                            self.edit.toggle()
                                        }
                                    }
                                }
                                else {
                                    self.msg = "One of the prompts has too many characters. (Max of 200 characters)"
                                    self.alert.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Confirm")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .foregroundColor(Color(.gray))
                                        .fontWeight(.semibold)
                                    Image(systemName: "checkmark")
                                        .font(Font.system(size: 18, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                            Button(action: {
                                withAnimation {
                                    self.edit.toggle()
                                }
                                self.newbio = self.tempbio
                            }) {
                                HStack {
                                    Text("Cancel")
                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                        .foregroundColor(Color(.gray))
                                        .fontWeight(.semibold)
                                    Image(systemName: "xmark")
                                        .font(Font.system(size: 18, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    else {
                        Button(action: {
                            withAnimation {
                                self.edit.toggle()
                                self.tempbio = self.newbio
                            }
                        }) {
                            HStack {
                                Text("Edit Bio")
                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                    .foregroundColor(Color(.gray))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .frame(height: screenheight*0.025)
                                    .minimumScaleFactor(0.02)
                                Image(systemName: "pencil")
                                    .font(Font.system(size: 20, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }.offset(y: self.shift ? CGFloat(-32*self.index) : 0).animation(.spring())
                Spacer()
            }.frame(width: screenwidth, height: screenheight).offset(y: self.edit ? -15 : 0)
            .background(Color("lightgray").edgesIgnoringSafeArea(.all)).animation(.spring())
            
            //MARK: Connection
            ZStack {
                Color("personality")
                    .frame(width: screenwidth, height: screenheight)
                VStack(spacing: 15) {
                    Text("Connection Error")
                        .font(Font.custom("ProximaNova-Regular", size: 28))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    GIFView(gifName: "rategif")
                        .frame(width: 100, height: 50)
                    Text("Reconnecting")
                        .font(Font.custom("ProximaNova-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(.white).opacity(self.refreshing == 0 ? 1 : 0.3))
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(.white).opacity(self.refreshing == 1 ? 1 : 0.3))
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(.white).opacity(self.refreshing == 2 ? 1 : 0.3))
                    }
                }.onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        if self.refreshing != 2 {
                            self.refreshing += 1
                        }
                        else {
                            self.refreshing = 0
                        }
                    }
                }
                
            }.offset(y: !self.connectionstatus ? -5 : -screenheight - 10)
            .animation(.spring())
        }//.edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                    self.connectionstatus = Reachability.isConnectedToNetwork()
                }
                for str in self.observer.myprofile.Bio {
                    self.newbio[(String(str.prefix(2)) as NSString).integerValue] = String(str)[2..<str.count]
                }
        }.alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
    }
}


//MARK: More Settings
struct MoreSettings: View {
    @Binding var more: Bool
    @Binding var start: Bool
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        self.more.toggle()
                    }
                }) {
                    Image("back")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(.gray))
                }.padding(.leading, screenwidth * 0.04)
                Spacer()
            }.padding(.top, self.screenheight > 800 ? self.screenheight*0.055 : screenheight*0.035)
            Text("More Settings")
                .font(Font.custom("ProximaNova-Regular", size: 30))
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(height: screenheight * 0.05)
                .minimumScaleFactor(0.01)
                .foregroundColor(Color(.darkGray))
                .padding(.top, 5)
            VStack(alignment: .leading) {
                HStack {
                    Text("Account Settings")
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .padding(.leading, 20)
                    Spacer()
                    Button(action: {
                    }) {
                        Image(systemName: "chevron.right")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                            .padding(.trailing, 15)
                    }
                }.padding(.top, 15)
                
                Divider().frame(width: screenwidth - 40)
                
                HStack {
                    Text("Contact")
                        .font(Font.custom("ProximaNova-Regular", size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .padding(.leading, 20)
                    Spacer()
                    Button(action: {
                    }) {
                        Image(systemName: "chevron.right")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                            .padding(.trailing, 15)
                    }
                }.padding(.bottom, 15)
            }.frame(width: screenwidth - 40).background(Color(.white).cornerRadius(30).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10)).cornerRadius(30).padding(.bottom, 10)
            HStack {
                Button(action: {
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                            UserDefaults.standard.set(false, forKey: "ad")
                            UserDefaults.standard.set(false, forKey: "showad")
                            self.start = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                UserDefaults.standard.set(true, forKey: "notsignedup")
                                UserDefaults.standard.set(false, forKey: "status")
                                NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                            }
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                }) {
                    Text("Log Out")
                        .font(Font.custom("ProximaNova-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: self.screenwidth - 40, height: 50)
                        .background(Color("personality").shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(25))
                }
            }
            Spacer()
        }.background(Color("lightgray").edgesIgnoringSafeArea(.all)).animation(.spring())
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}



//MARK: ShowProfile
struct ShowProfile: View {
    @EnvironmentObject var observer: observer
    @Binding var index: Int
    @Binding var showprofile: Bool
    @State var count: Int = 0
    @State var bio = false
    @State var unlocksocials = false
    @State var confirm = false
    @State var confirm1 = false
    let categories = ["General", "Education", "Occupation", "Music", "Sports", "Movies", "TV-Shows", "Hobbies", "Motto", "Future"]
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            if self.observer.ratesinfo.count > self.index {
                Button(action: {
                    self.showprofile = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.count = 0
                        self.bio = false
                    }
                }) {
                    Color(.white)
                        .opacity(0)
                        .frame(width: screenwidth, height: screenheight)
                }
                VStack(spacing: 20) {
                    //MARK: Image
                    ZStack {
                        VStack {
                            Loader()
                        }
                        ZStack {
                            WebImage(url: URL(string: self.observer.ratesinfo[self.index].ProfilePics[self.count]))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 0.84*screenwidth, height: screenheight*0.62)
                                .animation(nil)
                                .shadow(radius: 10)
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .frame(width: (0.84*screenwidth)/4 - 10, height: 7.5)
                                        .foregroundColor(self.count == 0 ? .white : .clear)
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .frame(width: (0.84*screenwidth)/4 - 10, height: 7.5)
                                        .foregroundColor(self.count == 1 ? .white : .clear)
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .frame(width: (0.84*screenwidth)/4 - 10, height: 7.5)
                                        .foregroundColor(self.count == 2 ? .white : .clear)
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .frame(width: (0.84*screenwidth)/4 - 10, height: 7.5)
                                        .foregroundColor(self.count == 3 ? .white : .clear)
                                }.padding(1).background(Color(.lightGray).opacity(0.2)).cornerRadius(3).padding(.top, screenheight*0.02).animation(nil)
                                Spacer()
                                HStack {
                                    Text(self.observer.ratesinfo[self.index].Name.uppercased() + " " + self.observer.ratesinfo[self.index].Age)
                                        .font(Font.custom("ProximaNova-Regular", size: 60))
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .frame(width: screenwidth/2, height: 50)
                                        .foregroundColor(.white)
                                        .shadow(radius: 10)
                                        .minimumScaleFactor(0.02)
                                        .padding(.leading, 30)
                                        .padding(.bottom, 20)
                                    Spacer()
                                }
                                
                            }.frame(width: 0.84*screenwidth, height: screenheight*0.62)
                        }.blur(radius: self.bio ? 6 : 0)
                        ScrollView([]) {
                            VStack(spacing: 0) {
                                HStack {
                                    Button(action: {
                                        if self.count != 0 {
                                            self.count -= 1
                                        }
                                    }) {
                                        Color(.white).opacity(0)
                                            .frame(width: screenwidth/3, height: screenheight*0.62)
                                    }
                                    Spacer()
                                    Button(action: {
                                        if self.count != 3 {
                                            self.count += 1
                                        }
                                    }) {
                                        Color(.white).opacity(0)
                                            .frame(width: screenwidth/3, height: screenheight*0.62)
                                    }
                                }.frame(height: screenheight*0.62)
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        ForEach(self.observer.ratesinfo[self.index].Bio, id: \.self) { bio in
                                            VStack(spacing: 5) {
                                                HStack {
                                                    Image(self.categories[(bio.prefix(2) as NSString).integerValue])
                                                        .resizable()
                                                        .frame(width: 25, height: 25)
                                                    Text(self.categories[(bio.prefix(2) as NSString).integerValue])
                                                        .font(Font.custom("ProximaNova-Regular", size: 25))
                                                        .fontWeight(.semibold)
                                                        .lineLimit(1)
                                                        .foregroundColor(Color(.black))
                                                        .frame(height: 15)
                                                        .minimumScaleFactor(0.02)
                                                    Spacer()
                                                }
                                                Text(bio.suffix(bio.count - 2))
                                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.gray).opacity(0.8))
                                                    
                                            }.padding(15)
                                            .background(Color(.white).cornerRadius(20).shadow(radius: 5))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                        }
                                    }
                                }.frame(width: 0.84*screenwidth, height: screenheight*0.62 - 20)
                            }.offset(y: self.bio ? -screenheight*0.31 : screenheight*0.31)
                        }.frame(width: 0.84*screenwidth, height: screenheight*0.62).cornerRadius(25)
                    }.frame(width: 0.84*screenwidth, height: screenheight*0.62).cornerRadius(35)
                    
                    //MARK: Bottom UI Buttons
                    HStack(spacing: 10) {
                        Button(action: {
                            withAnimation {
                                self.unlocksocials.toggle()
                            }
                        }) {
                            ZStack {
                                Image("social")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    .padding(20)
                                    .background(Circle().frame(width: 65, height: 65).foregroundColor(.blue).shadow(color: .blue, radius: 5))
                            }
                        }
                        Button(action: {
                            self.bio.toggle()
                        }) {
                            Image(self.bio ? "eye" : "heart")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(20)
                                .foregroundColor(.white)
                                .background(Circle().frame(width: 65, height: 65).foregroundColor(Color(self.bio ? "appearance" : "personality")).shadow(color: Color(self.bio ? "appearance" : "personality"), radius: 5))
                        }
                    }
                }.blur(radius: self.unlocksocials ? 4 : 0).padding(20).background(Color(.white).cornerRadius(50).shadow(radius: 10))
                
                //MARK: Socials
                if self.unlocksocials {
                    if self.observer.ratesinfo[self.index].Socials[0] == "N/A" && self.observer.ratesinfo[self.index].Socials[1] == "N/A" && self.observer.ratesinfo[self.index].Socials[2] == "N/A" {
                        ZStack {
                            Button(action: {
                                withAnimation {
                                    self.unlocksocials.toggle()
                                }
                            }) {
                                Color(.white)
                                    .opacity(0)
                            }
                            VStack {
                                Text("No Socials")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                ZStack {
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.blue)
                                    Image("social")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .frame(width: 55, height: 55)
                                        .foregroundColor(.red)
                                }
                            }.padding(20).background(Color(.white).cornerRadius(20).shadow(radius: 10))
                        }.offset(y: self.unlocksocials ? 0 : screenheight).animation(.spring())
                    }
                    else {
                        ZStack {
                            Button(action: {
                                withAnimation {
                                    self.unlocksocials.toggle()
                                }
                            }) {
                                Color(.white)
                                    .opacity(0)
                            }
                            
                            VStack(spacing: 10) {
                                Text("Socials")
                                    .font(Font.custom("ProximaNova-Regular", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                ZStack {
                                    HStack(spacing: 10) {
                                        if self.observer.ratesinfo[self.index].Socials[0] != "N/A" {
                                            Button(action: {
                                                let link = "https://instagram.com/" + self.observer.ratesinfo[self.index].Socials[0]
                                                UIApplication.shared.open(URL(string: link)!)
                                            }) {
                                                Image("instagram")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                            }.buttonStyle(PlainButtonStyle())
                                        }
                                        if self.observer.ratesinfo[self.index].Socials[1] != "N/A" {
                                            Button(action: {
                                                let link = "https://snapchat.com/add/" + self.observer.ratesinfo[self.index].Socials[1]
                                                UIApplication.shared.open(URL(string: link)!)
                                            }) {
                                                Image("snapchat")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                            }.buttonStyle(PlainButtonStyle())
                                        }
                                        if self.observer.ratesinfo[self.index].Socials[2] != "N/A" {
                                            Button(action: {
                                                let link = "https://twitter.com/" + self.observer.ratesinfo[self.index].Socials[2]
                                                UIApplication.shared.open(URL(string: link)!)
                                            }) {
                                                Image("twitter")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                            }.buttonStyle(PlainButtonStyle())
                                        }
                                    }.padding(.all, 10).background(Color(.white).cornerRadius(15))
                                }
                            }.padding(20).background(Color(.white).cornerRadius(20).shadow(radius: 10))
                        }.animation(.spring())
                    }
                }
            }
        }
    }
}


//MARK: RatingMeter
struct RatingMeter: View {
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        ZStack(alignment: .bottom) {
            /*Image("rateneedle")
                .resizable()*/
            RoundedRectangle(cornerRadius: 3.5)
                .frame(width: 7, height: screenheight*0.074)//screenheight*0.0357, height: screenheight*0.074)
                .rotationEffect(Angle(degrees: Double(observer.rating.overall*18)-90), anchor: UnitPoint(x: 0.5, y: 1))
                .foregroundColor(Color(.darkGray))
                .animation(.spring())
            Circle()
                .frame(width: 15, height: 15)
                .foregroundColor(Color(.darkGray))
                .offset(y: 7.5)
        }.frame(width: screenheight*0.17, height: screenheight*0.074)
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
                            .frame(width: screenheight*0.17, height: screenheight*0.085)
                            .foregroundColor(Color("lightgray"))
                        Meter(endangle: Double(self.observer.rating.overall*18))
                            .rotation(Angle(degrees: 180), anchor: .bottom)
                            .frame(width: screenheight*0.17, height: screenheight*0.085)
                            .foregroundColor(Color("purp"))
                            .animation(.spring())
                        VStack {
                            Spacer()
                            Meter(endangle: Double(180))
                                .rotation(Angle(degrees: 180), anchor: .bottom)
                                .frame(width: screenheight*0.099, height: screenheight*0.0495)
                                .foregroundColor(Color(.white))
                        }.frame(width: screenheight*0.17, height: screenheight*0.085)
                    }
                    Spacer()
                }
                RatingMeter()
            }.frame(width: screenheight*0.17, height: screenheight*0.085)
                .padding(.bottom, 5)
            Text(self.observer.userrates.count == 1 ? String(self.observer.userrates.count) + " Rating" : String(self.observer.userrates.count) + " Ratings")
                .font(Font.custom("ProximaNova-Regular", size: 12))
                .fontWeight(.semibold)
                .foregroundColor(.black)
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
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 2.5)
                                .frame(width: 5, height: 40)
                                .rotationEffect(Angle(degrees: Double(observer.rating.appearance*18)-90), anchor: UnitPoint(x: 0.5, y: 1))
                                .foregroundColor(Color(.darkGray))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.darkGray))
                                .offset(y: 5)
                        }.frame(width: 100, height: 40)
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
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 2.5)
                                .frame(width: 5, height: 40)
                                .rotationEffect(Angle(degrees: Double(observer.rating.personality*18)-90), anchor: UnitPoint(x: 0.5, y: 1))
                                .foregroundColor(Color(.darkGray))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.darkGray))
                                .offset(y: 5)
                        }.frame(width: 100, height: 40)
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
    @State var x: CGFloat = 0
    @State var tempx: CGFloat = 0
    @State var index = 0
    @EnvironmentObject var observer: observer
    var body: some View {
        ZStack {
            ScrollView([]) {
                HStack {
                    OverallMeter()
                        .frame(width: screenwidth/1.25)
                    DetailsMeter()
                        .frame(width: screenwidth/1.25)
                }.frame(width: self.screenwidth/1.25).padding(.bottom, 10)
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
            VStack {
                Spacer()
                HStack(spacing: 5) {
                    Circle()
                        .foregroundColor(self.index == 0 ? Color(.gray).opacity(0.8) : Color("lightgray"))
                        .frame(width: self.index == 0 ? 7.5 : 6.5, height: self.index == 0 ? 7.5 : 6.5)
                    Circle()
                        .foregroundColor(self.index != 0 ? Color(.gray).opacity(0.8) : Color("lightgray"))
                        .frame(width: self.index != 0 ? 7.5 : 6.5, height: self.index != 0 ? 7.5 : 6.5)
                }.padding(.bottom, 5)
            }.frame(height: screenheight*0.234)
        }.frame(width: screenwidth/1.25).padding(5).background(Color(.white).cornerRadius(25).shadow(color: Color("lightgray").opacity(0.6), radius: 10))
    }
}


//MARK: Rating Settings
struct RatingSettings: View {
    @EnvironmentObject var observer: observer
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @Binding var gender: CGFloat
    @Binding var ratinggender: CGFloat
    @Binding var width: CGFloat
    @Binding var width1: CGFloat
    @State var first = false
    @State var second = false
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Rate:")
                .font(Font.custom("ProximaNova-Regular", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.top, screenheight*0.0123)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("lightgray"))
                    .frame(width: 240, height: screenheight*0.05)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(width: 80, height: screenheight*0.05 - 2)
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 80, height: screenheight*0.05 - 2)
                }.offset(x: self.gender*80)
                HStack(spacing: 0) {
                    Button(action: {
                        self.gender = -1
                        //self.observer.myprofile.Preferences[0] = "Male"
                    }) {
                        Text("Male")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.gender = 0
                        //self.observer.myprofile.Preferences[0] = "Female"
                    }) {
                        Text("Female")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.gender = 1
                        //self.observer.myprofile.Preferences[0] = "Everyone"
                    }) {
                        Text("Everyone")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                }.frame(width: 240, height: screenheight*0.05)
            }
            Text("Get Rated By:")
                .font(Font.custom("ProximaNova-Regular", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("lightgray"))
                    .frame(width: 240, height: screenheight*0.05)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(width: 80, height: screenheight*0.05 - 2)
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 80, height: screenheight*0.05 - 2)
                }.offset(x: self.ratinggender*80)
                HStack(spacing: 0) {
                    Button(action: {
                        self.ratinggender = -1
                        //self.observer.myprofile.Preferences[1] = "Male"
                    }) {
                        Text("Male")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.ratinggender = 0
                        //self.observer.myprofile.Preferences[1] = "Female"
                    }) {
                        Text("Female")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.ratinggender = 1
                        //self.observer.myprofile.Preferences[1] = "Everyone"
                    }) {
                        Text("Everyone")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                }.frame(width: 240, height: screenheight*0.05)
            }
            
            HStack(spacing: 0) {
                Text("Age Range:")
                    .font(Font.custom("ProximaNova-Regular", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.trailing, 10)
                Text(self.width < 0 ? "18 - " : String(Int(self.width/2.71 + 18)) + " - ")
                    .font(Font.custom("ProximaNova-Regular", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.blue).opacity(0.5))
                    .animation(nil)
                Text(self.width1 > 220 || Int(self.width1/2.71 + 18) >= 99 ? "99" : String(Int(self.width1/2.71 + 18)))
                    .font(Font.custom("ProximaNova-Regular", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.blue).opacity(0.5))
                    .animation(nil)
                Spacer()
            }.frame(width: 240)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2.5)
                    .frame(width: 220, height: 5)
                    .foregroundColor(Color("lightgray"))
                    .padding(.leading, 10)
                    .animation(nil)
                RoundedRectangle(cornerRadius: 2.5)
                    .frame(width: self.width1 - self.width + 15, height: 5)
                    .foregroundColor(Color(.blue).opacity(0.5))
                    .background(Color(.white))
                    .offset(x: self.width)
                    .animation(nil)
                Circle()
                    .foregroundColor(Color(.blue).opacity(0.5))
                    .frame(width: self.first ? 20 : 15, height: self.first ? 20 : 15)
                    .background(Circle().foregroundColor(.white))
                    .offset(x: self.width)
                    .gesture(DragGesture().onChanged({ (value) in
                        if value.location.x >= -5 && value.location.x <= self.width1 - 15 {
                            self.width = value.location.x
                        }
                        self.first = true
                    }).onEnded({ (value) in
                        self.first.toggle()
                    })).animation(nil)
                Circle()
                    .foregroundColor(Color(.blue).opacity(0.5))
                    .frame(width: self.second ? 20 : 15, height: self.second ? 20 : 15)
                    .background(Circle().foregroundColor(.white))
                    .offset(x: self.width1)
                    .highPriorityGesture(DragGesture().onChanged({ (value) in
                        if value.location.x <= 225 && value.location.x >= self.width + 15 {
                            self.width1 = value.location.x
                        }
                        self.second = true
                    }).onEnded({ (value) in
                        self.second.toggle()
                    })).animation(nil)
                if self.first {
                    Text(self.width < 0 ? "18" : String(Int(self.width/2.71 + 18)))
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .offset(x: self.width+1.5, y: -15)
                        .animation(nil)
                }
                if self.second {
                    Text(self.width1 > 220 || Int(self.width1/2.71 + 18) >= 99 ? "99" : String(Int(self.width1/2.71 + 18)))
                        .font(Font.custom("ProximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .offset(x: self.width1+1.5, y: -15)
                        .animation(nil)
                }
            }.frame(height: screenheight*0.05)
        }.frame(width: screenwidth/1.25).background(Color(.white).cornerRadius(25).shadow(color: Color("lightgray").opacity(0.6), radius: 10)).onAppear {
            if self.observer.myprofile.Preferences[0] == "Male" {
                self.gender = -1
            }
            else if self.observer.myprofile.Preferences[0] == "Female" {
                self.gender = 0
            }
            else {
                self.gender = 1
            }
            if self.observer.myprofile.Preferences[1] == "Male" {
                self.ratinggender = -1
            }
            else if self.observer.myprofile.Preferences[1] == "Female" {
                self.ratinggender = 0
            }
            else {
                self.ratinggender = 1
            }
            self.width = CGFloat((self.observer.myprofile.Preferences[2].prefix(2) as NSString).doubleValue-18)*2.71
            self.width1 = CGFloat((self.observer.myprofile.Preferences[2].suffix(2) as NSString).doubleValue-18)*2.71
            
        }
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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 13) {
                    if self.observer.numrates >= 0 {
                        ForEach((0...self.observer.numrates).reversed(), id:\.self) {index in
                            Bar(unlockindex: self.$unlockindex, unlock: self.$unlock, homecomment: self.$homecomment, showprofile: self.$showprofile, index: index, rating: ratingtype(overall: CGFloat((self.observer.userrates[index].prefix(9).suffix(3) as NSString).doubleValue), appearance: CGFloat((self.observer.userrates[index].prefix(3) as NSString).doubleValue), personality: CGFloat((self.observer.userrates[index].prefix(6).suffix(3) as NSString).doubleValue)))
                        }
                    }
                }.padding(.vertical, 10)
            }.frame(maxHeight: screenheight*0.35)
        }.frame(maxHeight: screenheight*0.35)
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
            }.frame(width: screenwidth-20, height: screenheight/1.25)
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
    @State var padding: CGFloat = 10
    @State var horizontalpadding: CGFloat = 20
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
                    .padding(.horizontal, self.horizontalpadding)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(.vertical, self.padding)
        }
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
    @State var shift = false
    let screenwidth = UIScreen.main.bounds.width
    var body: some View {
        VStack {
            //MARK: Show Info
            if self.showinfo[index] {
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
                            .foregroundColor(Color(.black))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Button(action: {
                            self.showinfo[self.index] = false;
                        }) {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 18, weight: .bold))
                                .foregroundColor(Color("personality"))
                        }
                    }.padding(.horizontal, 10).padding(.top, 10)
                    Text(moreinfo[index])
                        .font(Font.custom("PromximaNova-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.darkGray))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(nil)
                }.frame(width: self.screenwidth - 105)
                    .padding(10)
                    .background(Color(.white).cornerRadius(25)).padding(.bottom, 10)
            }
            //MARK: Edit Mode
            else if edit {
                VStack(spacing: 0) {
                    HStack {
                        if self.title != "General" {
                            Image(title)
                                .resizable()
                                .frame(width: 23, height: 23)
                        }
                        Text(title + ": ")
                            .font(Font.custom("ProximaNova-Regular", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                        Spacer()
                        Button(action: {
                            self.edit.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 20, weight: .bold))
                                .foregroundColor(Color("personality"))
                        }
                    }.padding(.horizontal, 10).padding(.top, 10)
                    
                    ResizingTextField(text: self.$text[index], shift: self.$shift, color: "gray")
                        .frame(width: self.screenwidth - 115, height: 100)
                        .cornerRadius(10)
                        .padding(5)
                        .background(Color("lightgray").opacity(0.4).cornerRadius(15))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .padding(.top, 5)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Text(String(self.text[index].count) + "/200 Characters")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(self.text[index].count > 200 ? Color("personality") : Color(.gray).opacity(0.7))
                            .padding([.bottom, .trailing], 10)
                            .animation(nil)
                    }
                }.frame(width: self.screenwidth - 105)
                    .padding(.horizontal, 10)
                    .background(Color(.white).cornerRadius(25))
                    .padding(.bottom, 5)
            }
            //MARK: Default
            else {
                HStack {
                    if self.title != "General" {
                        Image(title)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 5)
                    }
                    Button(action: {
                        for num in 0...8 {
                            self.showinfo[num] = false
                        }
                        self.showinfo[self.index] = true
                    }) {
                        Text(title)
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.black))
                    }.padding(.leading, self.title == "General" ? 5 : 0)
                    Spacer()
                    if self.selected[self.index] {
                        Button(action: {
                            self.edit.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .font(Font.system(size: 24, weight: .bold))
                                .foregroundColor(Color(.darkGray))
                        }.padding(.trailing, self.title != "General" ? 0 : 10)
                    }
                    if self.title != "General" {
                        Button(action: {
                            self.selected[self.index].toggle()
                        }) {
                            Image(systemName: self.selected[self.index] ? "xmark" : "checkmark")
                                .font(Font.system(size: 24, weight: .bold))
                                .foregroundColor(self.selected[self.index] ? Color("personality") : Color(.darkGray))
                        }.padding(.trailing, 10)
                    }
                }.frame(width: screenwidth - 105, height: 65)
                    .padding(.horizontal, 10)
                    .background(Color(.white).cornerRadius(27.5))
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
        indicator.color = .gray
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
                    .frame(height: geometry.size.height * CGFloat(self.percentage / 10))
                    .cornerRadius(0)
                    .animation(nil)
                VStack(spacing: 0) {
                    Image("eye")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
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
                    Image("heart")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
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
            }.cornerRadius(20)
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
                    .animation(nil)
                VStack {
                    Image(self.title.lowercased() == "appearance" ? "eye" : "heart")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.top, 15)
                        .foregroundColor(.white)
                    
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
            }.cornerRadius(20)
                .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                    self.percentage = 10 - min(max(0, Float(value.location.y / geometry.size.height * 100)), 100)/10
                }))
        }
    }
}


//MARK: ProfileRatingSlider
struct ProfileRatingSlider: View {
    @Binding var percentage: Float
    @Binding var bio: Bool
    @State var title = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 10))
                    .cornerRadius(0)
                    .animation(nil)
                Image(self.bio ? "heart" : "eye")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: self.bio ? 25 : 30, height: self.bio ? 25 : 30)
                    .foregroundColor(.white)
                    .offset(x: (geometry.size.width * CGFloat(self.percentage / 10)) - 35)
                    .animation(nil)
            }.cornerRadius(15)
                .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                    self.percentage = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)/10
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


//MARK: ImageRePicker
struct ImageRePicker : UIViewControllerRepresentable {
    @Binding var picker : Bool
    @Binding var images: [Data]
    @Binding var newimage: [Bool]
    @Binding var num: Int
    func makeCoordinator() -> ImageRePicker.Coordinator {
        return ImageRePicker.Coordinator(parent1: self)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageRePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImageRePicker>) {
    }
    class Coordinator : NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        var parent : ImageRePicker
        init(parent1 : ImageRePicker) {
            parent = parent1
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.picker.toggle()
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as! UIImage
            let data = image.jpegData(compressionQuality: 0.5)
            self.parent.images[parent.num] = data!
            self.parent.newimage[parent.num] = false
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
    @Published var myprofile: UserData = UserData(Age: "", Bio: [String](), Gender: "", id: "", Name: "", Percentage: 0, ProfilePics: [String](), Rates: [String](), OverallRating: 0, AppearanceRating: 0, PersonalityRating: 0, SelfRating: 0, Socials: [String](), Report: 0, Reports: [String](), Preferences: [String]())
    @Published var users = [UserData]()
    @Published var userrates = [String]()
    @Published var ratesinfo = [UserData]()
    @Published var reported = [Bool]()
    @Published var lock = [Bool]()
    @Published var rating: ratingtype = ratingtype(overall: 0, appearance: 0, personality: 0)
    @Published var selfratings: ratingtype = ratingtype(overall: 0, appearance: 0, personality: 0)
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
        self.ratesinfo = [UserData]()
        if id == nil || UserDefaults.standard.value(forKey: "notsignedup") as? Bool ?? true {
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
                        self.reported = document.get("Reported") as! [Bool]
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
                        
                        let bdate = document.get("Birthdate") as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: bdate)!
                        let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                        let age = String(components.year!)
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
                        let report = document.get("Report") as! Double
                        let preferences = document.get("Preferences") as! [String]
                        let reports = document.get("Reports") as! [String]
                        self.myprofile = UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences)
                        self.selfratings = ratingtype(overall: CGFloat(selfrating), appearance: document.get("SelfARating") as! CGFloat, personality: document.get("SelfPRating") as! CGFloat)
                    }
                }
                for document in querySnapshot!.documents {
                    if document.get("ID") as! String != self.id! && self.users.count < 100 {
                        
                        let bdate = document.get("Birthdate") as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: bdate)!
                        let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                        let age1 = components.year!
                        
                        if (document.get("Gender") as! String == self.myprofile.Preferences[0] && (document.get("Preferences") as! [String])[1] == self.myprofile.Gender) || ((document.get("Preferences") as! [String])[1] == "Everyone" && ((document.get("Gender") as! String == self.myprofile.Preferences[0]))) || (self.myprofile.Preferences[0] == "Everyone" && ((document.get("Preferences") as! [String])[1] == self.myprofile.Gender)) ||  (self.myprofile.Preferences[0] == "Everyone" && (document.get("Preferences") as! [String])[1] == "Everyone") {
                            
                            if (age1 >= (self.myprofile.Preferences[2].prefix(2) as NSString).integerValue && age1 <= (self.myprofile.Preferences[2].suffix(2) as NSString).integerValue) && Int(self.myprofile.Age) ?? 0 >= ((document.get("Preferences") as! [String])[2].prefix(2) as NSString).integerValue && Int(self.myprofile.Age) ?? 0 <= ((document.get("Preferences") as! [String])[2].suffix(2) as NSString).integerValue {
                                
                                var check = true
                                for rate in document.get("Rates") as! [String] {
                                    if String(rate.suffix(rate.count-9)) == self.id! {
                                        check = false
                                    }
                                }
                                print(document.get("Name") as! String)
                                var check1 = true
                                for reports in document.get("Reports") as! [String] {
                                    if reports == self.id! {
                                        check1 = false
                                    }
                                }
                                if check && check1 {
                                    let age = String(age1)
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
                                    let report = document.get("Report") as! Double
                                    let preferences = document.get("Preferences") as! [String]
                                    let reports = document.get("Reports") as! [String]
                                    self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
                                    print(name)
                                }
                            }
                            else {
                            }
                        }
                    }
                }
                self.users.shuffle()
                for users in self.userrates {
                    for document in querySnapshot!.documents {
                        if document.get("ID") as! String == users.substring(fromIndex: 9) {
                            let bdate = document.get("Birthdate") as! String
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: bdate)!
                            let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                            let age = String(components.year!)
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
                            let report = document.get("Report") as! Double
                            let preferences = document.get("Preferences") as! [String]
                            let reports = document.get("Reports") as! [String]
                            self.ratesinfo.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
                        }
                    }
                }
            }
        }
    }
    func refreshUsers() {
        id = Auth.auth().currentUser?.uid
        var newusers = [UserData]()
        self.rated = 0
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            for document in querySnapshot!.documents {
                if document.get("ID") as! String != self.id! && self.users.count < 100 {
                    
                    let bdate = document.get("Birthdate") as! String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from: bdate)!
                    let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                    let age1 = components.year!
                    
                    if (document.get("Gender") as! String == self.myprofile.Preferences[0] && (document.get("Preferences") as! [String])[1] == self.myprofile.Gender) || ((document.get("Preferences") as! [String])[1] == "Everyone" && ((document.get("Gender") as! String == self.myprofile.Preferences[0]))) || (self.myprofile.Preferences[0] == "Everyone" && ((document.get("Preferences") as! [String])[1] == self.myprofile.Gender)) ||  (self.myprofile.Preferences[0] == "Everyone" && (document.get("Preferences") as! [String])[1] == "Everyone") {
                        
                        if (age1 >= (self.myprofile.Preferences[2].prefix(2) as NSString).integerValue && age1 <= (self.myprofile.Preferences[2].suffix(2) as NSString).integerValue) && age1 >= ((document.get("Preferences") as! [String])[2].prefix(2) as NSString).integerValue && age1 <= ((document.get("Preferences") as! [String])[2].suffix(2) as NSString).integerValue {
                            var check = true
                            for rate in document.get("Rates") as! [String] {
                                if String(rate.suffix(rate.count-9)) == self.id! {
                                    check = false
                                }
                            }
                            if check {
                                let age = String(age1)
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
                                let report = document.get("Report") as! Double
                                let preferences = document.get("Preferences") as! [String]
                                let reports = document.get("Reports") as! [String]
                                newusers.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
                                self.users = newusers
                                print(name)
                            }
                        }
                        else {
                        }
                    }
                }
            }
        }
    }
    func signin() {
        id = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        self.ratesinfo = [UserData]()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if self.id! == (document.get("ID") as! String) {
                        self.reported = document.get("Reported") as! [Bool]
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
                        
                        let bdate = document.get("Birthdate") as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: bdate)!
                        let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                        let age = String(components.year!)
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
                        let report = document.get("Report") as! Double
                        let preferences = document.get("Preferences") as! [String]
                        let reports = document.get("Reports") as! [String]
                        self.myprofile = UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences)
                    }
                }
                for users in self.userrates {
                    for document in querySnapshot!.documents {
                        if document.get("ID") as! String == users.substring(fromIndex: 9) {
                            let bdate = document.get("Birthdate") as! String
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: bdate)!
                            let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                            let age = String(components.year!)
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
                            let report = document.get("Report") as! Double
                            let preferences = document.get("Preferences") as! [String]
                            let reports = document.get("Reports") as! [String]
                            self.ratesinfo.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
                        }
                    }
                }
            }
        }
    }
    
    func signedup() {
        UserDefaults.standard.set(false, forKey: "notsignedup")
    }
}


//MARK: CreateUser
func CreateUser(name: String, bdate: String, gender: String, percentage: Double, overallrating: Double, appearancerating: Double, personalityrating: Double, profilepics: [Data], photopostion: [Int], bio: [String], socials: [String], complete: @escaping (Bool)-> Void) {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    var newbio = [String]()
    
    db.collection("users").document(uid!).setData(["Name": name, "Birthdate": bdate, "Gender": gender, "Percentage": percentage, "SelfRating": overallrating, "SelfARating": appearancerating, "SelfPRating": personalityrating, "ProfilePics": [String](), "Bio": [String](), "Rates": [String](), "OverallRating": overallrating, "AppearanceRating": appearancerating, "PersonalityRating": personalityrating, "ID": uid!, "Lock": [Bool](), "Keys": 0, "Comments": [String](), "Socials": socials, "Report": 0, "Preferences": ["Everyone", "Everyone", "18-99"], "Reports": [String](), "Reported": [Bool]()]) { (err) in
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
        let metadata = StorageMetadata.init()
        metadata.contentType = "image/jpeg"
        let upload = storage.child("ProfilePics").child(uid! + String(num)).putData(profilepics[num], metadata: metadata) { (_, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                print("BRUHHHHH")
                complete(false)
                return
            }
        }
        upload.observe(.success) { snapshot in
            storage.child("ProfilePics").child(uid! + String(num)).downloadURL { (url, err) in
                if err != nil{
                    print((err?.localizedDescription)!)
                    print("BRUHHHHH")
                    complete(false)
                    return
                }
                images.append(String(num) + "\(url!)")
                UserDefaults.standard.set(images, forKey: "ProfilePics")
                if num == 3 {
                    complete(true)
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
            complete(false)
            return
        }
        else {
            for document in querySnapshot!.documents {
                if uid! == document.get("ID") as! String {
                    UserDefaults.standard.set(false, forKey: "notsignedup")
                    complete(true)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                if UserDefaults.standard.value(forKey: "notsignedup") as! Bool {
                    complete(false)
                }
            }
        }
    }
}


//MARK: UpdateRating
func UpdateRating(user: UserData, appearance: Double, personality: Double, keys: Int, comment: String, complete: @escaping (Bool)->Void) {
    var check = true
    var stroverall = ""
    var strappearance = ""
    var strpersonality = ""
    let overall = Double(Double(personality)*Double(user.Percentage).truncate(places: 2) + Double(appearance)*Double(1-user.Percentage).truncate(places: 2)).truncate(places: 1)
    let newoverall = Double(user.OverallRating*Double(user.Rates.count+1) + overall)/Double(user.Rates.count+2).truncate(places: 1)
    let newappearance = Double(user.AppearanceRating*Double(user.Rates.count+1) + appearance)/Double(user.Rates.count+2).truncate(places: 1)
    let newpersonality = Double(user.PersonalityRating*Double(user.Rates.count+1) + personality)/Double(user.Rates.count+2).truncate(places: 1)
    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    if overall == 10.0 {
        stroverall = "10."
    }
    else {
        stroverall = String(overall)
    }
    if appearance == 10.0 {
        strappearance = "10."
    }
    else {
        strappearance = String(appearance.truncate(places: 1))
    }
    if personality == 10.0 {
        strpersonality = "10."
    }
    else {
        strpersonality = String(personality.truncate(places: 1))
    }
    
    db.collection("users").document(user.id).updateData(["OverallRating": newoverall.truncate(places: 1), "AppearanceRating": newappearance.truncate(places: 1), "PersonalityRating": newpersonality.truncate(places: 1), "Rates": FieldValue.arrayUnion([strappearance + strpersonality + stroverall + uid!]), "Comments": FieldValue.arrayUnion([comment]), "Lock": FieldValue.arrayUnion([false]), "Reported": FieldValue.arrayUnion([false])]) { (err) in
        if err != nil {
            print((err?.localizedDescription)!)
            return
        }
        db.collection("users").document(uid!).updateData(["Keys": keys]) { (err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            check = false
            complete(true)
        }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        if check {
            complete(false)
        }
    }
}


//MARK: Unlock
func Unlock(keys: Int, lock: [Bool], complete: @escaping (Bool)-> Void) {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    db.collection("users").document(uid!).updateData(["Keys": keys, "Lock": lock]) { (err) in
        if err != nil{
            print((err?.localizedDescription)!)
            complete(false)
            return
        }
        complete(true)
    }
}


//MARK: Key Change
func KeyChange(keys: Int, complete: @escaping (Bool)-> Void) {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    db.collection("users").document(uid!).updateData(["Keys": keys]) { (err) in
        if err != nil{
            print((err?.localizedDescription)!)
            complete(false)
            return
        }
        complete(true)
    }
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

//MARK: UIFont
extension UIFont {
    var bold: UIFont { return withWeight(.bold) }
    var semibold: UIFont { return withWeight(.semibold) }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}


//MARK: ResizingTextField
struct ResizingTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var shift: Bool
    @State var color = "personality"
    func makeCoordinator() -> ResizingTextField.Coordinator {
        return ResizingTextField.Coordinator(parent1: self)
    }
    func makeUIView(context: UIViewRepresentableContext<ResizingTextField>) -> UITextView {
        let view = UITextView()
        let basefont = UIFont(name: "ProximaNova-Regular", size: 15)!
        view.font = basefont.semibold
        if text.count == 0 {
            view.textColor = UIColor(named: color)!.withAlphaComponent(0.4)
            view.text = "Write Something"
        }
        else {
            view.textColor = UIColor(named: color)
            view.text = text
        }
        view.backgroundColor = .clear
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
                textView.textColor = UIColor(named: self.parent.color)
            }
            self.parent.shift = true
        }
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text!
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            self.parent.shift = false
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
        let basefont = UIFont(name: "ProximaNova-Regular", size: 15)!
        view.font = basefont.semibold
        if text.count == 0 {
            view.textColor = .gray//UIColor(named: "personality")!.withAlphaComponent(0.25)
            view.text = "Leave a comment on what you liked the most about this person. Be Nice."
        }
        else {
            view.textColor = .gray
            view.text = text
        }
        view.backgroundColor = .clear
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
            if parent.text.count != 0 {
                textView.text = parent.text
                textView.textColor = .gray
            }
            else {
                textView.text = ""
                textView.textColor = .gray
            }
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
        HStack(spacing: 5) {
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
                    if self.index < self.observer.ratesinfo.count {
                        WebImage(url: URL(string: self.observer.ratesinfo[self.index].ProfilePics[0]))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenheight*0.061, height: screenheight*0.061)
                            .blur(radius: !self.observer.lock[self.index] ? 4 : 0)
                            .cornerRadius(screenheight*0.018)
                        if !self.observer.lock[self.index] {
                            Image("lock")
                                .resizable()
                                .frame(width: screenwidth*0.08, height: screenwidth*0.08)
                        }
                    }
                }
            }.buttonStyle(PlainButtonStyle())
                .frame(width: screenheight*0.061 + 7, height: screenheight*0.061 + 7)
                .background(Color(.blue).opacity(0.5).cornerRadius(screenheight*0.022))
                .animation(nil)
            if self.observer.showratings[self.index] {
                Button(action: {
                    self.observer.showratings[self.index] = false
                }) {
                    VStack(spacing: 2.5) {
                        HStack(spacing: 0) {
                            ZStack() {
                                Rectangle()
                                    .fill(Color("appearance"))
                                    .frame(width: (self.screenwidth/20)*rating.appearance, height: screenheight*0.036)
                                    .cornerRadius(5)
                                Text(String(Double(rating.appearance)))
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                    .animation(nil)
                            }
                            Spacer().frame(width: ((self.screenwidth/20)*10) - (self.screenwidth/20)*rating.appearance)
                        }.frame(width: self.screenwidth/2).background(Color("lightgray")).cornerRadius(12.5)
                        HStack {
                            ZStack {
                                Rectangle()
                                    .fill(Color("personality"))
                                    .frame(width: (self.screenwidth/20)*rating.personality, height: screenheight*0.036)
                                    .cornerRadius(5)
                                Text(String(Double(rating.personality)))
                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                    .animation(nil)
                            }
                            Spacer().frame(width: ((self.screenwidth/20)*10) - (self.screenwidth/20)*rating.personality)
                        }.frame(width: self.screenwidth/2).background(Color("lightgray")).cornerRadius(12.5)
                    }.frame(width: self.screenwidth/2)
                }
            }
            else {
                Button(action: {
                    for num in 0...self.observer.numrates {
                        if num != self.index {
                            self.observer.showratings[num] = false
                        }
                    }
                    self.observer.showratings[self.index] = true
                }) {
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(Color("purp"))
                                .frame(width: (self.screenwidth/20)*rating.overall, height: screenheight*0.074)
                                .cornerRadius(5)
                            Text(String(Double(rating.overall)))
                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                        }
                        Spacer().frame(width: ((self.screenwidth/20)*10) - (self.screenwidth/20)*rating.overall)
                    }
                }.frame(width: self.screenwidth/2).background(Color("lightgray").cornerRadius(5)).cornerRadius(20)
            }
            Button(action: {
                self.unlockindex = self.index
                self.homecomment.toggle()
            }) {
                Image(systemName: "ellipsis")
                    .resizable()
                    .frame(width: screenheight*0.032, height: screenheight*0.007)
                    .aspectRatio(contentMode: .fit)
                    .padding(screenheight*0.01).padding(.vertical, screenheight*0.011)
                    .foregroundColor(Color(.blue).opacity(0.5))
                    //.foregroundColor(.white)
                    //.background(Color(.blue).opacity(0.3).cornerRadius(screenheight*0.015))
            }.buttonStyle(PlainButtonStyle())
        }
    }
}


//MARK: Rewarded
final class Rewarded: NSObject, GADRewardedAdDelegate {
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
    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .white) {
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
    var Report: Double
    var Reports: [String]
    var Preferences: [String]
}


//MARK: Connection Check
public class Reachability {

    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}


struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: Content
    
    init(_ axes: Axis.Set = .vertical, showIndicators: Bool = true, contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
                    }
                    VStack {
                        self.content
                    }
                }
            }.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.contentOffset = value[0]
            }
        }
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
        } else {
            return outsideProxy.frame(in: .global).minX - insideProxy.frame(in: .global).minX
        }
    }
}

class GIFPlayerView: UIView {
    private let imageView = UIImageView()

    convenience init(gifName: String) {
       self.init()
       let gif = UIImage.gif(asset: gifName)
       imageView.image = gif
       imageView.contentMode = .scaleAspectFit
       self.addSubview(imageView)
    }

    override init(frame: CGRect) {
       super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}

struct GIFView: UIViewRepresentable {
    var gifName: String

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GIFView>) {

    }


    func makeUIView(context: Context) -> UIView {
        return GIFPlayerView(gifName: gifName)
    }
}

extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImage {

    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        for index in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }

}


/*extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}*/
