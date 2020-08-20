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

//MARK: MainView
struct MainView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @State var signup = UserDefaults.standard.value(forKey: "signup") as? Bool ?? false
    @State var login = UserDefaults.standard.value(forKey: "login") as? Bool ?? false
    @State var images = UserDefaults.standard.value(forKey: "ProfilePics")
    var body: some View {
        VStack {
            if status {
                HomeView().transition(.slide)
            }
            else {
                if signup {
                    SignUpView()
                }
                else if login {
                    LoginView()
                }
                else {
                    FrontView().transition(.slide)
                }
            }
        }.animation(.easeIn)
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("StatusChange"), object: nil, queue: .main) { (_) in
                    self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                    self.signup = UserDefaults.standard.value(forKey: "signup") as? Bool ?? false
                    self.login = UserDefaults.standard.value(forKey: "login") as? Bool ?? false
                }
            }
    }
}


//MARK: FrontView
struct FrontView: View {
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            VStack() {
                
                Image("rating(temp)")
                    .resizable()
                    .frame(width: screenwidth/4, height: screenwidth/4)
                    .padding(.top, screenheight*0.085)
                
                Text("RATED")
                    .font(Font.custom("Gilroy-Light", size: 32))
                    .fontWeight(.medium)
                    .foregroundColor(Color("purp"))
                
                Spacer()
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "login")
                    NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                }) {
                    Text("Login With Phone")
                        .font(Font.custom("Gilroy-Light", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .frame(width: screenwidth/1.5, height: 40)
                        .background(Color("purp").opacity(0.4))
                        .cornerRadius(20)
                }
                
                LabelledDivider(label: "or").frame(width: screenwidth/1.45)
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "signup")
                    NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                }) {
                    Text("Sign Up")
                        .font(Font.custom("Gilroy-Light", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .frame(width: screenwidth/1.5, height: 40)
                        .background(Color("purp").opacity(0.4))
                        .cornerRadius(20)
                }
                
                Spacer().frame(height: screenheight/2.25)
            }
        }
    }
}


//MARK: LoginView
struct LoginView: View {
    var body: some View {
        VStack {
            HStack (spacing: 15) {
                Button(action: {
                    UserDefaults.standard.set(false, forKey: "login")
                    NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
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
        }
    }
}


//MARK: SignUpView
struct SignUpView: View {
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
    @State var selectedprompts = [false, false, false, false, false, false, false, false, false, false]
    @State var selectedinfo = [false, false, false, false, false, false, false, false, false, false]
    
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
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                //MARK: Phone Number 1
                VStack() {
                    
                    Spacer()
                    
                    Image("phone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .padding(.bottom, 25)
                    
                    Text("Enter Your Phone Number")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    HStack {
                        ZStack {
                            Color(.gray)
                                .opacity(0.1)
                                .frame(width: 60, height: 50)
                                .cornerRadius(7.5)
                            
                            TextField("+1", text: $ccode)
                                .frame(width: 30, height: 50)
                        }
                        
                        ZStack {
                            Color(.gray)
                                .opacity(0.1)
                                .frame(width: screenwidth - 100, height: 50)
                                .cornerRadius(7.5)
                            
                            TextField("Phone Number", text: $phonenumber)
                                .font(Font.custom("Gilroy-Light", size: 16))
                                .frame(width: screenwidth - 140, height: 50)
                                .keyboardType(.numberPad)
                        }
                    }
                        
                    Spacer().frame(height: screenheight/2.25)
                    
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Verification Code 2
                VStack {
                    
                    Spacer()
                    
                    Image("phone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .padding(.bottom, 25)
                    
                    Text("Enter The Verification Code")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    ZStack {
                        Color(.gray)
                            .opacity(0.1)
                            .frame(width: screenwidth - 60, height: 50)
                            .cornerRadius(7.5)
                        
                        TextField("Verification Code", text: $enteredcode)
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .frame(width: screenwidth - 80, height: 50)
                            .keyboardType(.numberPad)
                    }
                    
                    Spacer().frame(height: screenheight/2.25)
                    
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Name 3
                VStack {
                    
                    Spacer()
                    
                    Image("name")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .padding(.bottom, 25)
                    
                    Text("Enter Your First Name")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    ZStack {
                        Color(.gray)
                            .opacity(0.1)
                            .frame(width: screenwidth - 60, height: 50)
                            .cornerRadius(7.5)
                        
                        TextField("First Name", text: $name)
                            .frame(width: screenwidth - 80, height: 50)
                    }
                    
                    Spacer().frame(height: screenheight/2.25)
                    
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Age 4
                VStack {
                    
                    Spacer()
                    
                    Image("age")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenwidth/2, height: screenwidth/2)
                        .padding(.bottom, 25)
                    
                    Text("Enter Your Age")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    ZStack {
                        Color(.gray)
                            .opacity(0.1)
                            .frame(width: screenwidth - 60, height: 50)
                            .cornerRadius(7.5)
                        
                        TextField("Age", text: $age)
                            .frame(width: screenwidth - 80, height: 50)
                            .keyboardType(.numberPad)
                    }
                    
                    Spacer().frame(height: screenheight/2.25)
                    
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Gender 5
                VStack {
                    
                    Spacer()
                    
                    Image("gender")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenwidth/2.25, height: screenwidth/2.25)
                        .padding(.bottom, 25)
                    
                    Text("Select Your Gender")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    ZStack {
                        Color(.gray)
                            .opacity(0.2)
                            .frame(width: 210, height: 50)
                            .foregroundColor(.white)
                            .background(Color(.gray).opacity(0.2))
                            .cornerRadius(15)
                        
                        if self.genders == 0 {
                            
                        }
                        else {
                            HStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 15).frame(width: 65, height: 45)
                            }.foregroundColor(Color("purp").opacity(0.8)).offset(x: self.genderoffest)
                        }
                        
                        HStack(spacing: 0) {
                            
                            Button(action: {
                                self.genders = 1
                                self.genderoffest = -70
                                self.gender = "Male"
                            }) {
                                Text("Male")
                                    .font(Font.custom("Gilroy-Light", size: 16))
                                    .fontWeight(.semibold)
                            }.frame(width: 70)
                            
                            Button(action: {
                                self.genders = 2
                                self.genderoffest = 0
                                self.gender = "Female"
                            }) {
                                Text("Female")
                                    .font(Font.custom("Gilroy-Light", size: 16))
                                    .fontWeight(.semibold)
                            }.frame(width: 70)
                            
                            Button(action: {
                                self.genders = 3
                                self.genderoffest = 70
                                self.gender = ""
                            }) {
                                Text("Other")
                                    .font(Font.custom("Gilroy-Light", size: 16))
                                    .fontWeight(.semibold)
                            }.frame(width: 70)
                            
                        }.foregroundColor(.white)
                        
                        
                    }.animation(.spring())
                    
                    if self.genders == 3 {
                        Text("Specify Your Gender")
                            .font(Font.custom("Gilroy-Light", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("purp").opacity(0.8))
                        
                        ZStack {
                            Color(.gray)
                                .opacity(0.1)
                                .frame(width: screenwidth - 60, height: 50)
                                .cornerRadius(7.5)
                            
                            TextField("Gender", text: $gender)
                                .frame(width: screenwidth - 80, height: 50)
                                .keyboardType(.numberPad)
                        }
                        Spacer().frame(height: screenheight/2.75)
                    }
                    else {
                        Spacer().frame(height: screenheight/2.25)
                    }
                    
                }.animation(.spring()).frame(width: screenwidth, height: screenheight)
                
                //MARK: What Matters? 6
                ZStack {
                    VStack {
                        HStack {
                            Image("appearance")
                                .resizable()
                                .frame(width: screenwidth/4, height: screenwidth/4)
                            
                            Spacer()
                            
                            Image("personality")
                                .resizable()
                                .frame(width: screenwidth/4, height: screenwidth/4)
                        }.padding(.horizontal, 75)
                        Text("Appearance vs Personality")
                            .font(Font.custom("Gilroy-Light", size: 24))
                            .fontWeight(.semibold)
                            .frame(width: screenwidth)
                            .foregroundColor(Color("purp").opacity(0.8))
                            .padding(.bottom, 5)
                            .multilineTextAlignment(.center)
                        
                        Text("(This is how your rating will be calculated)")
                            .font(Font.custom("Gilroy-Light", size: 14))
                            .fontWeight(.semibold)
                            .frame(width: screenwidth - 10)
                            .foregroundColor(Color("purp").opacity(0.8))
                            .padding(.bottom, 45)
                        
                        PercentageSlider(percentage: self.$percentage)
                            .frame(width: 90, height: screenheight/2.25)
                            .accentColor(Color("personality"))
                            .padding(.bottom, 25)
                    
                    }.frame(width: screenwidth, height: screenheight)
                    if self.confirm {
                        VStack {
                            Spacer().frame(height: 50)
                            ZStack {
                                Rectangle()
                                    .frame(width: screenwidth/1.75, height: 125)
                                    .cornerRadius(15)
                                    .foregroundColor(Color("lightgray"))
                                
                                VStack {
                                    Text("Are You Sure?")
                                        .font(Font.custom("Gilroy-Light", size: 18))
                                        .fontWeight(.semibold)
                                        .frame(width: screenwidth/2 - 20)
                                        .foregroundColor(Color("purp").opacity(0.8))
                                        .padding(.top, 25)
                                    
                                    Text("This cannot be changed later.")
                                        .font(Font.custom("Gilroy-Light", size: 14))
                                        .fontWeight(.semibold)
                                        //.frame(width: screenwidth/2 )
                                        .foregroundColor(Color("purp").opacity(0.8))
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Button(action: {
                                            self.next -= self.screenwidth
                                            self.count += 1
                                            self.confirm.toggle()
                                        }) {
                                            Text("Yes")
                                                .fontWeight(.medium)
                                                .frame(width: 75, height: 30)
                                                .foregroundColor(.white)
                                                .background(Color("purp").opacity(0.8))
                                                .cornerRadius(7.5)
                                        }
                                        Button(action: {
                                            self.confirm.toggle()
                                        }) {
                                            Text("No")
                                                .fontWeight(.medium)
                                                .frame(width: 75, height: 30)
                                                .foregroundColor(.white)
                                                .background(Color("purp").opacity(0.8))
                                                .cornerRadius(7.5)
                                        }
                                    }.padding(.bottom, 10)
                                }.frame(width: screenwidth/1.75, height: 125)
                            }
                        }
                    }
                }
                
                //MARK: Rate Yourself 7
                ZStack {
                    VStack {
                        Image("rating(temp)")
                            .resizable()
                            .frame(width: screenwidth/3, height: screenwidth/3)
                            
                        Text("Rate Yourself")
                            .font(Font.custom("Gilroy-Light", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("purp").opacity(0.8))
                        
                        HStack(spacing: 45) {
                            VerticalSlider(percentage: self.$selfratingappearance, title: "Appearance")
                                .frame(width: 90, height: screenheight/2.25)
                                .accentColor(Color("appearance"))
                            
                            VerticalSlider(percentage: self.$selfratingpersonality, title: "Personality")
                                .frame(width: 90, height: screenheight/2.25)
                                .accentColor(Color("personality"))
                            
                        }.padding(.top, 25)
                        
                    }.frame(width: screenwidth, height: screenheight)
                    if self.confirm {
                        VStack {
                            Spacer().frame(height: 50)
                            ZStack {
                                Rectangle()
                                    .frame(width: screenwidth/2, height: 125)
                                    .cornerRadius(15)
                                    .foregroundColor(Color("lightgray"))
                                
                                VStack {
                                    Text("Are You Sure?")
                                        .font(Font.custom("Gilroy-Light", size: 14))
                                        .fontWeight(.semibold)
                                        .frame(width: screenwidth - 10)
                                        .foregroundColor(Color("purp").opacity(0.8))
                                        .padding(.top, 35)
                                    
                                    Text("Your Rating: " + String(Double(Double(self.selfratingpersonality)*Double(self.percentage/10).truncate(places: 2) + Double(self.selfratingappearance)*Double(1-self.percentage/10).truncate(places: 2)).truncate(places: 1)))
                                        .font(Font.custom("Gilroy-Light", size: 14))
                                        .fontWeight(.semibold)
                                        .frame(width: screenwidth - 10)
                                        .foregroundColor(Color("purp").opacity(0.8))
                                        .animation(nil)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Button(action: {
                                            self.next -= self.screenwidth
                                            self.count += 1
                                            self.confirm.toggle()
                                        }) {
                                            Text("Yes")
                                                .fontWeight(.medium)
                                                .frame(width: 75, height: 30)
                                                .foregroundColor(.white)
                                                .background(Color("purp").opacity(0.8))
                                                .cornerRadius(7.5)
                                        }
                                        Button(action: {
                                            self.confirm.toggle()
                                        }) {
                                            Text("No")
                                                .fontWeight(.medium)
                                                .frame(width: 75, height: 30)
                                                .foregroundColor(.white)
                                                .background(Color("purp").opacity(0.8))
                                                .cornerRadius(7.5)
                                        }
                                    }.padding(.bottom, 10)
                                }.frame(width: screenwidth/2, height: 125)
                            }
                        }
                    }
                }
                
                //MARK: Profile Pictures 8
                VStack {
                    
                    Image("profilepic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenwidth/3, height: screenwidth/3)
                        .padding(.bottom, 25)
                    
                    Text("Select Four Pictures")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    VStack(spacing: 35) {
                        HStack(spacing: 35) {
                            Button(action: {
                                self.picker.toggle()
                                self.numimage = 0
                            }) {
                                if !self.showimage[0] {
                                    ZStack {
                                        Color(.white)
                                            .frame(width: 100, height: 133)
                                            .cornerRadius(15)
                                        Text("1")
                                            .font(Font.custom("Gilroy-Light", size: 16))
                                            .foregroundColor(Color("purp"))
                                    }
                                }
                                else {
                                    Image(uiImage: UIImage(data: self.profilepics[0])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(15)
                                }
                            }.offset(x: self.current[0].width, y: self.current[0].height)
                            .highPriorityGesture(DragGesture().onChanged({ (value) in
                                self.current[0] = CGSize(width: value.location.x-50, height: value.location.y-67)
                            }).onEnded({ (value) in
                                let x = value.location.x - 50
                                let y = value.location.y - 67
                                if self.position[0] == 0 {
                                    if x > 90 && x < 170 && y > 130 && y < 200 {
                                        self.current[0] = CGSize(width: 135, height: 168)
                                        self.current[self.position[3]] = self.locations[self.position[3]][0]
                                        self.position[0] = self.position[3]
                                        self.position[3] = 0
                                        
                                    }
                                    else if x > 90 && x < 170 && y < 50 && y > -50 {
                                        self.current[0] = CGSize(width: 135, height: 0)
                                        self.current[self.position[1]] = self.locations[self.position[1]][0]
                                        self.position[0] = self.position[1]
                                        self.position[1] = 0
                                        
                                    }
                                    else if y > 130 && y < 200 && x < 50 && x > -50 {
                                        self.current[0] = CGSize(width: 0, height: 168)
                                        self.current[self.position[2]] = self.locations[self.position[2]][0]
                                        self.position[0] = self.position[2]
                                        self.position[2] = 0
                                        
                                    }
                                    else {
                                        self.current[0] = .zero
                                    }
                                }
                                else if self.position[1] == 0 {
                                    if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[0] = .zero
                                        self.current[self.position[0]] = self.locations[self.position[0]][1]
                                        self.position[1] = self.position[0]
                                        self.position[0] = 0
                                        
                                    }
                                    else if y > 130 && y < 200 && x < 50 && x > -50 {
                                        self.current[0] = CGSize(width: 0, height: 168)
                                        self.current[self.position[2]] = self.locations[self.position[2]][1]
                                        self.position[1] = self.position[2]
                                        self.position[2] = 0
                                        
                                    }
                                    else if x > 90 && x < 170 && y > 130 && y < 200 {
                                        self.current[0] = CGSize(width: 135, height: 168)
                                        print("bruh")
                                        self.current[self.position[3]] = self.locations[self.position[3]][1]
                                        self.position[1] = self.position[3]
                                        self.position[3] = 0
                                    }
                                    else {
                                        self.current[0] = self.locations[0][1]
                                    }
                                }
                                else if self.position[2] == 0 {
                                    if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[0] = .zero
                                        self.current[self.position[0]] = self.locations[self.position[0]][2]
                                        self.position[2] = self.position[0]
                                        self.position[0] = 0
                                        
                                    }
                                    else if x > 90 && x < 170 && y < 50 && y > -50 {
                                        self.current[0] = CGSize(width: 135, height: 0)
                                        self.current[self.position[1]] = self.locations[self.position[1]][2]
                                        self.position[2] = self.position[1]
                                        self.position[1] = 0
                                        
                                    }
                                    else if x > 90 && x < 170 && y > 130 && y < 200 {
                                        self.current[0] = CGSize(width: 135, height: 168)
                                        self.current[self.position[3]] = self.locations[self.position[3]][2]
                                        self.position[2] = self.position[3]
                                        self.position[3] = 0
                                        
                                    }
                                    else {
                                        self.current[0] = self.locations[0][2]
                                    }
                                }
                                else if self.position[3] == 0 {
                                    if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[0] = .zero
                                        self.current[self.position[0]] = self.locations[self.position[0]][3]
                                        self.position[3] = self.position[0]
                                        self.position[0] = 0
                                        
                                    }
                                    else if x > 90 && x < 170 && y < 50 && y > -50 {
                                        self.current[0] = CGSize(width: 135, height: 0)
                                        self.current[self.position[1]] = self.locations[self.position[1]][3]
                                        self.position[3] = self.position[1]
                                        self.position[1] = 0
                                        
                                    }
                                    else if y > 130 && y < 300 && x < 50 && x > -50 {
                                        self.current[0] = CGSize(width: 0, height: 168)
                                        self.current[self.position[2]] = self.locations[self.position[2]][3]
                                        self.position[3] = self.position[2]
                                        self.position[2] = 0
                                        
                                    }
                                    else {
                                        self.current[0] = self.locations[0][3]
                                    }
                                }
                            }))
                            
                            Button(action: {
                                self.picker.toggle()
                                self.numimage = 1
                            }) {
                                if !self.showimage[1] {
                                    ZStack {
                                        Color(.white)
                                            .frame(width: 100, height: 133)
                                            .cornerRadius(15)
                                        
                                        Text("2")
                                            .font(Font.custom("Gilroy-Light", size: 16))
                                            .foregroundColor(Color("purp"))
                                    }
                                }
                                else {
                                    Image(uiImage: UIImage(data: self.profilepics[1])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(15)
                                }
                            }.offset(x: self.current[1].width, y: self.current[1].height)
                                .highPriorityGesture(DragGesture().onChanged({ (value) in
                                    self.current[1] = CGSize(width: value.location.x-50, height: value.location.y-67)
                                }).onEnded({ (value) in
                                    let x = value.location.x-50
                                    let y = value.location.y-67
                                    if self.position[0] == 1 {
                                        if x < 50 && x > -50 && y < 50 && y > -50 {
                                            self.current[1] = self.locations[1][1]
                                            self.current[self.position[1]] = self.locations[self.position[1]][0]
                                            self.position[0] = self.position[1]
                                            self.position[1] = 1
                                        }
                                        else if y > 130 && y < 200 && x < -90 && x > -170 {
                                            self.current[1] = self.locations[1][2]
                                            self.current[self.position[2]] = self.locations[self.position[2]][0]
                                            self.position[0] = self.position[2]
                                            self.position[2] = 1
                                        }
                                        else if x > -50 && x < 50 && y > 130 && y < 200 {
                                            self.current[1] = self.locations[1][3]
                                            self.current[self.position[3]] = self.locations[self.position[3]][0]
                                            self.position[0] = self.position[3]
                                            self.position[3] = 1
                                        }
                                        else {
                                            self.current[1] = self.locations[1][0]
                                        }
                                    }
                                    else if self.position[1] == 1 {
                                        if x < -90 && x > -170 && y < 50 && y > -50 {
                                            self.current[1] = self.locations[1][0]
                                            self.current[self.position[0]] = self.locations[self.position[0]][1]
                                            self.position[1] = self.position[0]
                                            self.position[0] = 1
                                        }
                                        else if y > 130 && y < 200 && x < -90 && x > -170 {
                                            self.current[1] = self.locations[1][2]
                                            self.current[self.position[2]] = self.locations[self.position[2]][1]
                                            self.position[1] = self.position[2]
                                            self.position[2] = 1
                                        }
                                        else if x > -50 && x < 50 && y > 130 && y < 200 {
                                            self.current[1] = self.locations[1][3]
                                            self.current[self.position[3]] = self.locations[self.position[3]][1]
                                            self.position[1] = self.position[3]
                                            self.position[3] = 1
                                        }
                                        else {
                                            self.current[1] = self.locations[1][1]
                                        }
                                    }
                                    else if self.position[2] == 1 {
                                        if x < -90 && x > -170 && y < 50 && y > -50 {
                                            self.current[1] = self.locations[1][0]
                                            self.current[self.position[0]] = self.locations[self.position[0]][2]
                                            self.position[2] = self.position[0]
                                            self.position[0] = 1
                                        }
                                        else if x < 50 && x > -50 && y < 50 && y > -50 {
                                            self.current[1] = self.locations[1][1]
                                            self.current[self.position[1]] = self.locations[self.position[1]][2]
                                            self.position[2] = self.position[1]
                                            self.position[1] = 1
                                        }
                                        else if x > -50 && x < 50 && y > 130 && y < 200 {
                                            self.current[1] = self.locations[1][3]
                                            self.current[self.position[3]] = self.locations[self.position[3]][2]
                                            self.position[2] = self.position[3]
                                            self.position[3] = 1
                                        }
                                        else {
                                            self.current[1] = self.locations[1][2]
                                        }
                                    }
                                    else if self.position[3] == 1 {
                                        if x < -90 && x > -170 && y < 50 && y > -50 {
                                            self.current[1] = self.locations[1][0]
                                            self.current[self.position[0]] = self.locations[self.position[0]][3]
                                            self.position[3] = self.position[0]
                                            self.position[0] = 1
                                        }
                                        else if x < 50 && x > -50 && y < 50 && y > -50 {
                                            self.current[1] = self.locations[1][1]
                                            self.current[self.position[1]] = self.locations[self.position[1]][3]
                                            self.position[3] = self.position[1]
                                            self.position[1] = 1
                                        }
                                        else if y > 130 && y < 200 && x < -90 && x > -170 {
                                            self.current[1] = self.locations[1][2]
                                            self.current[self.position[2]] = self.locations[self.position[2]][3]
                                            self.position[3] = self.position[2]
                                            self.position[2] = 1
                                        }
                                        else {
                                            self.current[1] = self.locations[1][3]
                                        }
                                    }
                                }))
                        }
                        HStack(spacing: 35) {
                            Button(action: {
                                self.picker.toggle()
                                self.numimage = 2
                            }) {
                                if !self.showimage[2] {
                                    ZStack {
                                        Color(.white)
                                            .frame(width: 100, height: 133)
                                            .cornerRadius(15)
                                        Text("3")
                                            .font(Font.custom("Gilroy-Light", size: 16))
                                            .foregroundColor(Color("purp"))
                                    }
                                }
                                else {
                                    Image(uiImage: UIImage(data: self.profilepics[2])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(15)
                                }
                            }.offset(x: self.current[2].width, y: self.current[2].height)
                            .highPriorityGesture(DragGesture().onChanged({ (value) in
                                self.current[2] = CGSize(width: value.location.x-50, height: value.location.y-67)
                            }).onEnded({ (value) in
                                let x = value.location.x-50
                                let y = value.location.y-67
                                if self.position[0] == 2 {
                                    if x > 90 && x < 170 && y < -130 && y > -200 {
                                        self.current[2] = self.locations[2][1]
                                        self.current[self.position[1]] = self.locations[self.position[1]][0]
                                        self.position[0] = self.position[1]
                                        self.position[1] = 2
                                    }
                                    else if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[2] = self.locations[2][2]
                                        self.current[self.position[2]] = self.locations[self.position[2]][0]
                                        self.position[0] = self.position[2]
                                        self.position[2] = 2
                                    }
                                    else if x > 90 && x < 170 && y > -50 && y < 50 {
                                        self.current[2] = self.locations[2][3]
                                        self.current[self.position[3]] = self.locations[self.position[3]][0]
                                        self.position[0] = self.position[3]
                                        self.position[3] = 2
                                    }
                                    else {
                                        self.current[2] = self.locations[2][0]
                                    }
                                }
                                else if self.position[1] == 2 {
                                    if x > -50 && x < 50 && y < -130 && y > -200 {
                                        self.current[2] = self.locations[2][0]
                                        self.current[self.position[0]] = self.locations[self.position[0]][1]
                                        self.position[1] = self.position[0]
                                        self.position[0] = 2
                                    }
                                    else if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[2] = self.locations[2][2]
                                        self.current[self.position[2]] = self.locations[self.position[2]][1]
                                        self.position[1] = self.position[2]
                                        self.position[2] = 2
                                    }
                                    else if x > 90 && x < 170 && y > -50 && y < 50 {
                                        self.current[2] = self.locations[2][3]
                                        self.current[self.position[3]] = self.locations[self.position[3]][1]
                                        self.position[1] = self.position[3]
                                        self.position[3] = 2
                                    }
                                    else {
                                        self.current[2] = self.locations[2][1]
                                    }
                                }
                                else if self.position[2] == 2 {
                                    if x > -50 && x < 50 && y < -130 && y > -200 {
                                        self.current[2] = self.locations[2][0]
                                        self.current[self.position[0]] = self.locations[self.position[0]][2]
                                        self.position[2] = self.position[0]
                                        self.position[0] = 2
                                    }
                                    else if x > 90 && x < 170 && y < -130 && y > -200 {
                                        self.current[2] = self.locations[2][1]
                                        self.current[self.position[1]] = self.locations[self.position[1]][2]
                                        self.position[2] = self.position[1]
                                        self.position[1] = 2
                                    }
                                    else if x > 90 && x < 170 && y > -50 && y < 50 {
                                        self.current[2] = self.locations[2][3]
                                        self.current[self.position[3]] = self.locations[self.position[3]][2]
                                        self.position[2] = self.position[3]
                                        self.position[3] = 2
                                    }
                                    else {
                                        self.current[2] = self.locations[2][2]
                                    }
                                }
                                else if self.position[3] == 2 {
                                    if x > -50 && x < 50 && y < -130 && y > -200 {
                                        self.current[2] = self.locations[2][0]
                                        self.current[self.position[0]] = self.locations[self.position[0]][3]
                                        self.position[3] = self.position[0]
                                        self.position[0] = 2
                                    }
                                    else if x > 90 && x < 170 && y < -130 && y > -200 {
                                        self.current[2] = self.locations[2][1]
                                        self.current[self.position[1]] = self.locations[self.position[1]][3]
                                        self.position[3] = self.position[1]
                                        self.position[1] = 2
                                    }
                                    else if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[2] = self.locations[2][2]
                                        self.current[self.position[2]] = self.locations[self.position[2]][3]
                                        self.position[3] = self.position[2]
                                        self.position[2] = 2
                                    }
                                    else {
                                        self.current[2] = self.locations[2][3]
                                    }
                                }
                            }))
                            
                            Button(action: {
                                self.picker.toggle()
                                self.numimage = 3
                            }) {
                                if !self.showimage[3] {
                                    ZStack {
                                        Color(.white)
                                            .frame(width: 100, height: 133)
                                            .cornerRadius(15)
                                        Text("4")
                                            .font(Font.custom("Gilroy-Light", size: 16))
                                            .foregroundColor(Color("purp"))
                                    }
                                }
                                else {
                                    Image(uiImage: UIImage(data: self.profilepics[3])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(15)
                                }
                            }.offset(x: self.current[3].width, y: self.current[3].height)
                            .highPriorityGesture(DragGesture().onChanged({ (value) in
                                self.current[3] = CGSize(width: value.location.x-50, height: value.location.y-67)
                            }).onEnded({ (value) in
                                let x = value.location.x-50
                                let y = value.location.y-67
                                if self.position[0] == 3 {
                                    if x > -50 && x < 50 && y < -130 && y > -200 {
                                        self.current[3] = self.locations[3][1]
                                        self.current[self.position[1]] = self.locations[self.position[1]][0]
                                        self.position[0] = self.position[1]
                                        self.position[1] = 3
                                    }
                                    else if x > -170 && x < -90 && y > -50 && y < 50 {
                                        self.current[3] = self.locations[3][2]
                                        self.current[self.position[2]] = self.locations[self.position[2]][0]
                                        self.position[0] = self.position[2]
                                        self.position[2] = 3
                                    }
                                    else if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[3] = self.locations[3][3]
                                        self.current[self.position[3]] = self.locations[self.position[3]][0]
                                        self.position[0] = self.position[3]
                                        self.position[3] = 3
                                    }
                                    else {
                                        self.current[3] = self.locations[3][0]
                                    }
                                }
                                else if self.position[1] == 3 {
                                    if x > -170 && x < -90 && y < -130 && y > -200 {
                                        self.current[3] = self.locations[3][0]
                                        self.current[self.position[0]] = self.locations[self.position[0]][1]
                                        self.position[1] = self.position[0]
                                        self.position[0] = 3
                                    }
                                    else if x > -170 && x < -90 && y > -50 && y < 50 {
                                        self.current[3] = self.locations[3][2]
                                        self.current[self.position[2]] = self.locations[self.position[2]][1]
                                        self.position[1] = self.position[2]
                                        self.position[2] = 3
                                    }
                                    else if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[3] = self.locations[3][3]
                                        self.current[self.position[3]] = self.locations[self.position[3]][1]
                                        self.position[1] = self.position[3]
                                        self.position[3] = 3
                                    }
                                    else {
                                        self.current[3] = self.locations[3][1]
                                    }
                                }
                                else if self.position[2] == 3 {
                                    if x > -170 && x < -90 && y < -130 && y > -200 {
                                        self.current[3] = self.locations[3][0]
                                        self.current[self.position[0]] = self.locations[self.position[0]][2]
                                        self.position[2] = self.position[0]
                                        self.position[0] = 3
                                    }
                                    else if x > -50 && x < 50 && y < -130 && y > -200 {
                                        self.current[3] = self.locations[3][1]
                                        self.current[self.position[1]] = self.locations[self.position[1]][2]
                                        self.position[2] = self.position[1]
                                        self.position[1] = 3
                                    }
                                    else if x > -50 && x < 50 && y > -50 && y < 50 {
                                        self.current[3] = self.locations[3][3]
                                        self.current[self.position[3]] = self.locations[self.position[3]][2]
                                        self.position[2] = self.position[3]
                                        self.position[3] = 3
                                    }
                                    else {
                                        self.current[3] = self.locations[3][2]
                                    }
                                }
                                else if self.position[3] == 3 {
                                    if x > -170 && x < -90 && y < -130 && y > -200 {
                                        self.current[3] = self.locations[3][0]
                                        self.current[self.position[0]] = self.locations[self.position[0]][3]
                                        self.position[3] = self.position[0]
                                        self.position[0] = 3
                                    }
                                    else if x > -50 && x < 50 && y < -130 && y > -200 {
                                        self.current[3] = self.locations[3][1]
                                        self.current[self.position[1]] = self.locations[self.position[1]][3]
                                        self.position[3] = self.position[1]
                                        self.position[1] = 3
                                    }
                                    else if x > -170 && x < -90 && y > -50 && y < 50 {
                                        self.current[3] = self.locations[3][2]
                                        self.current[self.position[2]] = self.locations[self.position[2]][3]
                                        self.position[3] = self.position[2]
                                        self.position[2] = 3
                                    }
                                    else {
                                        self.current[3] = self.locations[3][3]
                                    }
                                }
                            }))
                        }
                    }.frame(width: screenwidth/1.4, height: screenheight/2.25)
                        .background(Color(.gray).opacity(0.15))
                    .cornerRadius(20)
                    
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Prompts Select 9
                VStack {
                    
                    Text("Select Topics To Build Your Bio")
                        .font(Font.custom("Gilroy-Light", size: 20))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("purp").opacity(0.8))
                    
                    Text("(Press on the topics to bring up more info. Press the checkmark to select the topics you like and then press the pencil to edit them.)")
                        .font(Font.custom("Gilroy-Light", size: 14))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("purp").opacity(0.6))
                        .padding(.horizontal, 25)
                        .padding(.bottom, 25)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        ForEach(biocards, id: \.self) { title in
                            BioCards(selected: self.$selectedprompts, showinfo: self.$selectedinfo, text: self.$text, index: (title.prefix(2) as NSString).integerValue, title: String(title.suffix(title.count-2))).animation(.spring())
                        }
                        
                    }.padding(.vertical, 15)
                        .frame(width: screenwidth - 60, height: screenheight/1.75)
                        .background(Color(.gray).opacity(0.15))
                        .cornerRadius(20)
                }.frame(width: screenwidth, height: screenheight)
                
                //MARK: Your Profile 10
                VStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        VStack {
                            Text("Your Profile")
                                .font(Font.custom("Gilroy-Light", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("purp").opacity(0.8))
                            
                            Profile(images: self.$profilepics, bio: self.$text, name: self.$name, age: self.$age).frame(width: self.screenwidth - 20, height: self.screenheight/1.15)
                        }
                        VStack {
                            Spacer()
                            Button(action: {
                                AddImages()
                                UserDefaults.standard.set(false, forKey: "signup")
                                UserDefaults.standard.set(true, forKey: "status")
                                NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                            }) {
                                Text("Next")
                                    .font(Font.custom("Gilroy-Light", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 40)
                                    .background(Color("purp"))
                                    .cornerRadius(20)
                            }.padding(.bottom, 25)
                        }
                    }
                }.frame(width: screenwidth, height: screenheight)
                
            }.animation(.spring()).offset(x: screenwidth*9/2 + next).sheet(isPresented: self.$picker) {
                ImagePicker(picker: self.$picker, images: self.$profilepics, showimage: self.$showimage, num: self.$numimage)
            }
            
            VStack {
                //MARK: Back Button
                HStack(spacing: 15) {
                    
                    Button(action: {
                        if self.count == 1 || self.count == 3 {
                            UserDefaults.standard.set(false, forKey: "signup")
                            NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                        }
                        else {
                            self.next += self.screenwidth
                            self.count -= 1
                        }
                    }) {
                        if self.count == 10 {
                            
                        }
                        else {
                            Image(systemName: "chevron.left.circle")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(Color("purp"))
                        }
                    }.padding(.leading, 15)
                    
                    Spacer()
                    
                }.frame(width: screenwidth).padding(.top, screenheight*0.055)
                
                Spacer()
                
                //MARK: Send/Next Button
                Button(action: {
                    if self.count == 1 {
                        self.loading.toggle()
                        PhoneAuthProvider.provider().verifyPhoneNumber(self.ccode + self.phonenumber, uiDelegate: nil) { (verificationID, error) in
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
                    }
                    else if self.count == 2 {
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
                    }
                    else if self.count == 3 {
                        if self.name.count < 1 {
                        }
                        else {
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                    }
                    else if self.count == 4 {
                        if Int(self.age) ?? 0 < 18 {
                            self.msg = "You must be 18 or older to register."
                            self.alert.toggle()
                        }
                        else {
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                    }
                    else if self.count == 5 {
                        if self.gender.count > 0 {
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                        else {
                        }
                    }
                    else if self.count == 6 || self.count == 7 {
                        self.confirm.toggle()
                    }
                    else if self.count == 8 {
                        var all = true
                        for check in self.showimage {
                            if !check {
                                all = false
                            }
                        }
                        if all {
                            var temp = [Data]()
                            for index in self.position {
                                temp.append(self.profilepics[index])
                            }
                            self.profilepics = temp
                            self.next -= self.screenwidth
                            self.count += 1
                        }
                        else {
                            self.msg = "You need to select 4 images."
                            self.alert.toggle()
                        }
                        print(self.position)
                    }
                    else if self.count == 9 {
                        self.loading.toggle()
                        for num in self.biocards {
                            let index = (num.prefix(2) as NSString).integerValue
                            if self.selectedprompts[index] {
                                self.text[index] = "1" + String(num.prefix(2)) + self.text[index]
                            }
                        }
                        let selfratingg = Double(Double(self.selfratingpersonality)*Double(self.percentage/10).truncate(places: 2) + Double(self.selfratingappearance)*Double(1-self.percentage/10).truncate(places: 2)).truncate(places: 1)
                        CreateUser(name: self.name.uppercased(), age: self.age, gender: self.gender, percentage: Double(self.percentage/10).truncate(places: 2), overallrating: selfratingg, appearancerating: Double(self.selfratingappearance).truncate(places: 1), personalityrating: Double(self.selfratingpersonality).truncate(places: 1), profilepics: self.profilepics, photopostion: self.position, bio: self.text) { (complete) in
                            
                            if complete {
                                self.loading.toggle()
                                self.next -= self.screenwidth
                                self.count += 1
                                self.observer.wipeRates()
                            }
                        }
                    }
                    else {
                        self.next -= self.screenwidth
                        self.count += 1
                    }
                }) {
                    if self.count <= 2 {
                        if self.loading {
                            Loader()
                        }
                        else {
                            Text("Send")
                                .font(Font.custom("Gilroy-Light", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color("purp"))
                                .cornerRadius(20)
                        }
                    }
                    else if self.name.count > 0 && self.count == 3 {
                        Text("Next")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(Color("purp"))
                            .cornerRadius(20)
                    }
                    else if self.age.count > 0 && self.count == 4 {
                        Text("Next")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(Color("purp"))
                            .cornerRadius(20)
                    }
                    else if self.gender.count > 0 && self.count == 5 {
                        Text("Next")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(Color("purp"))
                            .cornerRadius(20)
                    }
                    else if self.count == 6  || self.count == 7 {
                        Text("Next")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(Color("purp"))
                            .cornerRadius(20)
                    }
                    else if self.count == 9 {
                        if self.loading {
                            Loader()
                        }
                        else {
                            Text("Next")
                                .font(Font.custom("Gilroy-Light", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color("purp"))
                                .cornerRadius(20)
                        }
                    }
                    else if self.count == 10 {
                    }
                    else {
                        Text("Next")
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(Color(.gray).opacity(0.15))
                            .cornerRadius(20)
                    }
                }.padding(.bottom, screenheight*0.074)
            }.animation(.easeInOut)
        }.alert(isPresented: $alert) {
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
    @State var usercount: Int = 0
    @State var next: Bool = false
    @State var showrating: Bool = false
    @State var norating: Bool = false
    @State var appearance: Float = 5
    @State var personality: Float = 5
    @State var showcomment: Bool = false
    @State var comment = ""
    @State var unlock: Bool = false
    @State var unlockindex: Int = 0
    @State var homecomment: Bool = false
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
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
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 130, height: self.screenheight*0.049)
                        .foregroundColor(Color("lightgray").opacity(0.75))
                        .padding(.leading, 10)
                        .offset(y: CGFloat(index)*self.screenheight*0.049)
                    Spacer()
                }.padding(.top, self.screenheight*0.11)
                Spacer()
            }.frame(height: self.screenheight)//.background(Color(.white).edgesIgnoringSafeArea(.all))
                
            //MARK: Menu
            HStack {
                VStack(alignment: .leading, spacing: self.screenheight*0.0185) {
                    Text("Menu")
                        .font(Font.custom("ProximaNova-Regular", size: self.screenheight*0.0345))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("personality"))
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
                                .foregroundColor(Color("personality"))
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
                                .foregroundColor(Color("personality"))
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
                                .foregroundColor(Color("personality"))
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
            }.frame(height: self.screenheight)
            
            //MARK: RatingView
            VStack {
                if rating {
                    if self.observer.users.count == 0 || self.observer.users.count == self.usercount || self.norating {
                        VStack {
                            HStack {
                                Button(action: {
                                    self.rating.toggle()
                                }) {
                                    Image(systemName: "chevron.left.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("personality"))
                                }
                                Spacer()
                            }.padding(.leading, 15)
                                .padding(.top, self.screenheight*0.043)
                            
                            VStack {
                                WhiteLoader()
                            }.frame(width: screenwidth - 20, height: screenheight/1.25)
                            Spacer()
                        }
                    }
                    else {
                        ZStack {
                            VStack {
                                Spacer()
                                RatingProfile(index: self.$usercount, show: self.$next, appearance: self.$appearance, personality: self.$personality, showrating: self.$showrating)
                                    .offset(x: 0, y: 0)
                                    .padding(.bottom, 27)
                                    .animation(.spring())
                                    .shadow(radius: 40)
                                    .scaleEffect(self.next ? 0 : 1)
                            }
                            VStack {
                                HStack {
                                    Button(action: {
                                        self.rating.toggle()
                                    }) {
                                        Image(systemName: "chevron.left.circle")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color("personality"))
                                    }
                                    Spacer()
                                }.padding(.leading, 15)
                                    .padding(.top, 35)
                                Spacer()
                                Button(action: {
                                    self.showcomment.toggle()
                                }) {
                                    Text("Next")
                                        .font(Font.custom("Gilroy-Light", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 40)
                                        .background(Color("personality"))
                                        .cornerRadius(20)
                                }.padding(.bottom, 20)
                            }
                            if self.showcomment {
                                ZStack {
                                    Button(action: {
                                        self.showcomment = false
                                    }) {
                                        Color(.white)
                                            .opacity(0.2)
                                            .frame(width: self.screenwidth, height: self.screenheight)
                                    }
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: self.screenwidth/1.5 + 30, height: self.screenheight/4.25 + 30)
                                        .foregroundColor(Color("personality"))
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: self.screenwidth/1.5, height: self.screenheight/4.25)
                                        .foregroundColor(Color("lightgray"))
                                    
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
                                        ResizingTextFieldRed(text: self.$comment)
                                            .frame(width: self.screenwidth/1.5 - 20)
                                            .cornerRadius(5)
                                        HStack(spacing: 5) {
                                            Button(action: {
                                                self.next = false
                                                self.showcomment = false
                                                self.observer.keys += 1
                                                UpdateRating(user: self.observer.users[self.usercount], appearance: Double(self.appearance), personality: Double(self.personality), keys: self.observer.keys)
                                                self.showrating = false
                                                let seconds = 0.5
                                                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                    self.appearance = 5
                                                    self.personality = 5
                                                    if self.observer.users.count != self.usercount+1 {
                                                        self.usercount += 1
                                                        self.next.toggle()
                                                    }
                                                    else {
                                                        self.norating = true
                                                    }
                                                }
                                            }) {
                                                Text("No Comment")
                                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                            }.frame(width: self.screenwidth/3.25 - 5, height: 40).background(Color("personality").cornerRadius(5))
                                            
                                            Button(action: {
                                                
                                            }) {
                                                Text("Send")
                                                    .font(Font.custom("ProximaNova-Regular", size: 14))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(.white))
                                            }.frame(width: self.screenwidth/3.25 - 5, height: 40).background(Color("personality").cornerRadius(5))
                                        }.padding(.bottom, 5)
                                    }.frame(width: self.screenwidth/1.5, height: self.screenheight/4.25)
                                }
                            }
                        }
                    }
                }
                else {
                    //MARK: Settings
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
                                        
                                    }) {
                                        HStack {
                                            Text(String(self.observer.keys/3))
                                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("personality"))
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
                                if self.observer.userrates.count == 0 {
                                    ZStack {
                                        Color(.white)
                                            .frame(width: screenwidth/1.25, height: screenheight*0.234)
                                            .cornerRadius(15)
                                            .shadow(radius: 30)
                                        /*Text("No Ratings Yet")
                                            .font(Font.custom("Gilroy-Light", size: 24))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("purp"))*/
                                        Loader()
                                        
                                        VStack(alignment: .trailing) {
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    self.observer.refreshRates()
                                                }) {
                                                    Image(systemName: "arrow.clockwise")
                                                    .resizable()
                                                    .frame(width: 25, height: 30)
                                                    .foregroundColor(Color("purp"))
                                                }.padding(.trailing, 10).padding(.top, 10)
                                            }
                                            Spacer()
                                        }.frame(width: screenwidth/1.25, height: screenheight*0.234)
                                    }
                                }
                                else {
                                    ZStack {
                                        RecentRatings(unlockindex: self.$unlockindex, unlock: self.$unlock, homecomment: self.$homecomment).frame(width: screenwidth/1.25, height: screenheight*0.234)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    self.rating.toggle()
                                    print(self.observer.users.count)
                                }) {
                                    Text("Rate")
                                        .font(Font.custom("Gilroy-Light", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.white))
                                        .frame(width: screenwidth/1.25, height: 50)
                                        .background(Color("personality"))
                                        .cornerRadius(15)
                                }.padding(.top, 20).padding(.bottom, 30)
                            }
                            if self.unlock {
                                ZStack {
                                    Button(action: {
                                        self.unlock = false
                                    }) {
                                        Color(.white)
                                            .opacity(0.4)
                                            .frame(width: self.screenwidth, height: self.screenheight)
                                    }
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("personality"))
                                        .frame(width: self.screenwidth/1.5, height: self.screenheight/2.5)
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("lightgray"))
                                        .frame(width: self.screenwidth/1.5 - 30, height: self.screenheight/2.5 - 30)
                                    VStack {
                                        Text("Unlock Profile")
                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("personality"))
                                            .animation(nil)
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.white)
                                                .frame(width: self.screenwidth/1.5 - 80, height: self.screenwidth/1.5 - 80)
                                            
                                            Image("locked")
                                                .resizable()
                                                .frame(width: self.screenwidth/1.5 - 100, height: self.screenwidth/1.5 - 100)
                                        }
                                        HStack {
                                            Button(action: {
                                                
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
                                                                .foregroundColor(Color(.white).opacity(0.4))
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
                                            }//.buttonStyle(PlainButtonStyle())
                                        }
                                    }.frame(width: self.screenwidth/1.5 - 30, height: self.screenheight/2.5 - 30)
                                }
                            }
                            if self.homecomment {
                                ZStack {
                                    Button(action: {
                                        self.homecomment = false
                                    }) {
                                        Color(.white)
                                            .opacity(0.4)
                                            .frame(width: self.screenwidth, height: self.screenheight)
                                    }
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("personality"))
                                        .frame(width: self.screenwidth/1.5, height: self.screenheight/3.5)
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("lightgray"))
                                        .frame(width: self.screenwidth/1.5 - 30, height: self.screenheight/3.5 - 30)
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
                                    }.frame(width: self.screenwidth/1.5 - 30, height: self.screenheight/3.5 - 30)
                                }
                            }
                        }
                    }
                }
            }.frame(width: screenwidth, height: screenheight).background(Color("lightgray").edgesIgnoringSafeArea(.all))
            .animation(.spring())
            .cornerRadius(self.show ? 30 : 0)
            .scaleEffect(self.show ? 0.95 : 1)
            .offset(x: self.show ? screenwidth/2.75 : 0, y: self.show ? 2 : 0)
        }.edgesIgnoringSafeArea(.all)
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
                .cornerRadius(15)
                .shadow(radius: 30)
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
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Color(.white)
                    .frame(width: screenwidth/1.25, height: screenheight*0.234)
                    .cornerRadius(15)
                    .shadow(radius: 30)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 13) {
                        ForEach((0...self.observer.numrates).reversed(), id:\.self) {index in
                            Bar(unlockindex: self.$unlockindex, unlock: self.$unlock, homecomment: self.$homecomment, index: index, rating: ratingtype(overall: CGFloat((self.observer.userrates[index].prefix(9).suffix(3) as NSString).doubleValue), appearance: CGFloat((self.observer.userrates[index].prefix(3) as NSString).doubleValue), personality: CGFloat((self.observer.userrates[index].prefix(6).suffix(3) as NSString).doubleValue)))
                        }
                    }.padding(.vertical, 10)
                }.frame(width: screenwidth/1.25, height: screenheight*0.234)
                    .cornerRadius(15)
            }
        }
    }
}


//MARK: Profile
struct Profile: View {
    @Binding var images: [Data]
    @Binding var bio: [String]
    @Binding var name: String
    @Binding var age: String
    @State var count: Int = 0
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            if self.images[count].count != 0 {
                VStack {
                    Image(uiImage: UIImage(data: self.images[count])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenwidth - 20, height: (screenwidth - 20)*1.3)
                        .animation(nil)
                        .cornerRadius(20)
                    Spacer()
                }.frame(width: screenwidth-20, height: screenheight/1.15)
                    .cornerRadius(20)
            }
            VStack {
                Spacer()
                ZStack {
                    ZStack {
                        Color("lightgray")
                            .opacity(0.95)
                            .frame(width: screenwidth - 20, height: screenheight/3.25)
                            .clipShape(BottomShape())
                            .cornerRadius(20)
                        
                        VStack(spacing: 10) {
                            Spacer()
                            
                            //MARK: Bio
                            ScrollView(.vertical, showsIndicators: false) {
                                HStack {
                                    Text(name.uppercased())
                                        .font(Font.custom("Gilroy-Light", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("purp"))
                                        .padding(.leading, 20)
                                    Text(age)
                                        .font(Font.custom("Gilroy-Light", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("purp").opacity(0.5))
                                    Spacer()
                                }
                                
                                Divider()
                                    .frame(width: self.screenwidth-80)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                
                                ForEach(bio, id: \.self) { str in
                                    VStack {
                                        if String(str.prefix(1)) == "1" {
                                            BioCardsFP(index: (String(str.prefix(3)).suffix(2) as NSString).integerValue, text: String(str)[3..<str.count])
                                            Divider()
                                                .frame(width: self.screenwidth-80)
                                                .foregroundColor(.white).padding(.bottom, 10)
                                        }
                                        else {
                                        }
                                    }.frame(width: self.screenwidth - 40)
                                }
                            }.frame(width: screenwidth - 40, height: screenheight/3.25 - 100)
                                //.background(Color(.white).opacity(0.75)).cornerRadius(10)
                            
                        }.frame(width: screenwidth - 40, height: screenheight/3.25 - 140)
                    }
                    
                    //MARK: Left Right and Rate
                    HStack(spacing: 0) {
                        Button(action: {
                            if self.count == 0 {
                                self.count = 3
                            }
                            else {
                                self.count -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color("purp"))
                                .background(Circle().foregroundColor(.white).opacity(0.7))
                        }
                        
                        Button(action: {
                            
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color(.white).opacity(0.7))
                                    .frame(width: 80, height: 80)
                                
                                Image("rating(temp)")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            }
                        }.padding(.horizontal, (screenwidth-20)/8).buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            if self.count == 3 {
                                self.count = 0
                            }
                            else {
                                self.count += 1
                            }
                        }) {
                            Image(systemName: "arrow.right.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color("purp"))
                                .background(Circle().foregroundColor(.white).opacity(0.7))
                        }
                    }.padding(.bottom, (screenheight/3.25))
                }
            }.frame(width: screenwidth-20, height: screenheight/1.15)
            .cornerRadius(20)
            VStack {
                ImageIndicator(count: self.$count)
                Spacer()
            }.frame(width: screenwidth - 20, height: screenheight/1.15)
        }
    }
}


//MARK: RatingProfile
struct RatingProfile: View {
    @EnvironmentObject var observer: observer
    @Binding var index: Int
    @Binding var show: Bool
    @Binding var appearance: Float
    @Binding var personality: Float
    @Binding var showrating: Bool
    @State var count: Int = 0
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            if self.observer.users[self.index].ProfilePics[count].count != 0 {
                VStack {
                    ZStack {
                        WebImage(url: URL(string: self.observer.users[self.index].ProfilePics[self.count]))
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
                }.frame(width: screenwidth-20, height: screenheight/1.15)
                    .cornerRadius(20)
            }
            VStack {
                Spacer()
                HStack {
                    HStack {
                        Text(self.observer.users[self.index].Name.uppercased())
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("personality"))
                            .padding(.leading, 10)
                            .animation(nil)
                        Text(self.observer.users[self.index].Age)
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
                            .clipShape(BottomShape())
                            .cornerRadius(20)
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            ForEach(self.observer.users[index].Bio, id: \.self) { str in
                                VStack {
                                    BioCardsFP(index: (String(str.prefix(2)) as NSString).integerValue, text: String(str)[2..<str.count]).animation(nil)
                                    Rectangle()
                                        .frame(width: self.screenwidth-80, height: 2)
                                        .foregroundColor(.gray)
                                        .opacity(0.75)
                                        .padding(.bottom, 10)
                                }.frame(width: self.screenwidth - 40)
                            }
                        }.frame(width: screenwidth - 40, height: screenheight/3.25 - 60)
                    }
                    HStack(spacing: 0) {
                        //MARK: Rating Button
                        Spacer()
                        ZStack {
                            Button(action: {
                                self.showrating.toggle()
                            }) {
                                if self.showrating {
                                    
                                }
                                else {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(Color(.white).opacity(0.7))
                                            .frame(width: 40, height: 40)
                                        
                                        Image("rating(temp)")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }.buttonStyle(PlainButtonStyle())
                            if self.showrating {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color("lightgray"))
                                        .frame(width: 40, height: 60)
                                        .cornerRadius(20)
                                        .offset(y: -10)
                                    VStack {
                                        Rectangle()
                                            .foregroundColor(Color("lightgray"))
                                            .frame(width: 120, height: 180)
                                            .cornerRadius(15)
                                        Spacer()
                                    }.frame(width: 80, height: 180).offset(y: -90)
                                    VStack {
                                        Spacer()
                                        Button(action: {
                                            self.showrating.toggle()
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .resizable()
                                                .frame(width: 20, height: 10)
                                                .foregroundColor(Color("personality"))
                                        }
                                    }.frame(width: 80, height: 180).offset(y: -80)
                                    VStack(spacing: 5) {
                                        HStack {
                                            ProfileRatingSlider(percentage: self.$appearance, title: "appearance").accentColor(Color("appearance")).padding(.leading, 15)
                                            Spacer()
                                            ProfileRatingSlider(percentage: self.$personality, title: "personality").accentColor(Color("personality")).padding(.trailing, 15)
                                        }
                                        Spacer()
                                    }.frame(width: 120, height: 160).offset(y: -85)
                                }
                            }
                        }.frame(width: 80, height: 80).padding(.trailing, (1.15*(screenwidth-20)/10)-10)
                    }.padding(.bottom, (screenheight/3.25))
                }.frame(height: screenheight/3.25)
            }.frame(width: screenwidth-20, height: screenheight/1.25)
            .cornerRadius(20)
            VStack {
                ImageIndicator(count: self.$count)
                Spacer()
            }.frame(width: screenwidth - 20, height: screenheight/1.15)
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
                                    Rectangle()
                                        .frame(width: self.screenwidth-80, height: 2)
                                        .foregroundColor(.gray)
                                        .opacity(0.75)
                                        .padding(.bottom, 10)
                                }.frame(width: self.screenwidth - 40)
                            }
                        }.frame(width: screenwidth - 40, height: screenheight/3.25 - 60)
                    }
                }.frame(height: screenheight/3.25)
            }.frame(width: screenwidth-20, height: screenheight/1.25)
            .cornerRadius(20)
            VStack {
                ImageIndicator(count: self.$count)
                Spacer()
            }.frame(width: screenwidth - 20, height: screenheight/1.15)
        }
    }
}


//MARK: BioCardsForProfile
struct BioCardsFP: View {
    @State var index: Int = 0
    @State var text = ""
    @State var categories = ["General", "Education", "Occupation", "Music", "Sports", "Movies", "TV-Shows", "Hobbies", "Motto", "Future"]
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Image(self.categories[self.index])
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(self.categories[self.index] + ":")
                    .font(Font.custom("ProximaNova-Regular", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("personality").opacity(0.75))
                Spacer()
            }.padding(.leading, 10)
            Text(self.text)
                .font(Font.custom("ProximaNova-Regular", size: 12))
                //.fontWeight(.semibold)
                .foregroundColor(Color("personality").opacity(0.6))
                .padding(.horizontal, 20)
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
                            Image(title)
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(title + ": ")
                                .font(Font.custom("Gilroy-Light", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("purp").opacity(0.8))
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
                            .font(Font.custom("Gilroy-Light", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("purp").opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
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
                            Image(title)
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(title + ": ")
                                .font(Font.custom("Gilroy-Light", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("purp").opacity(0.8))
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
                        
                        ResizingTextField(text: self.$text[index])
                            .frame(width: self.screenwidth - 105, height: 100)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                        
                        HStack(spacing: 0) {
                            Spacer()
                            Text("Characters: ")
                                .font(Font.custom("Gilroy-Light", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("purp").opacity(0.8))
                                .padding(.bottom, 10)
                                .animation(nil)
                            if self.text[index].count > 200 {
                                Text(String(self.text[index].count))
                                    .font(Font.custom("Gilroy-Light", size: 14))
                                    .fontWeight(.semibold)
                                    .frame(width: 25, alignment: .trailing)
                                    .foregroundColor(Color("personality").opacity(0.8))
                                    .padding(.bottom, 10)
                                    .animation(nil)
                            }
                            else {
                                Text(String(self.text[index].count))
                                    .font(Font.custom("Gilroy-Light", size: 14))
                                    .fontWeight(.semibold)
                                    .frame(width: 25, alignment: .trailing)
                                    .foregroundColor(Color("purp").opacity(0.8))
                                    .padding(.bottom, 10)
                                    .animation(nil)
                            }
                            Text("/200")
                                .font(Font.custom("Gilroy-Light", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("purp").opacity(0.8))
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                                .animation(nil)
                        }
                    }
                }.frame(width: self.screenwidth - 85)
                .cornerRadius(10)
            }
            //MARK: Default
            else {
                HStack {
                    Image(title)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 10)
                    Button(action: {
                        for num in 0...8 {
                            self.showinfo[num] = false
                        }
                        self.showinfo[self.index] = true
                    }) {
                        HStack {
                            Text(title + ":")
                                .font(Font.custom("Gilroy-Light", size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("purp").opacity(0.8))
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.edit.toggle()
                        self.selected[self.index] = true
                    }) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("purp").opacity(0.8))
                    }.padding(.trailing, 10)
                }.frame(width: screenwidth - 85, height: 65)
                    .background(Color(.white))
                    .cornerRadius(10)
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
                    .frame(height: geometry.size.height * CGFloat(self.percentage / 10))
                    .cornerRadius(0)
                VStack(spacing: 0) {
                    Image("appearance")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.top, 10)
                    Text("Appearance")
                        .font(Font.custom("Gilroy-Light", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    Text(String(Int(100 - Double(self.percentage).truncate(places: 1)*10)) + "%" )
                        .font(Font.custom("Gilroy-LIght", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                    Spacer()
                    Image("personality")
                        .resizable()
                        .frame(width: 35, height: 35)
                    Text("Personality")
                        .font(Font.custom("Gilroy-Light", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    Text(String(Int(Double(self.percentage).truncate(places: 1)*10)) + "%")
                        .font(Font.custom("Gilroy-LIght", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                        .padding(.bottom, 10)
                }
            }.cornerRadius(18)
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
                        .font(Font.custom("Gilroy-Light", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                    
                    Text(String(Double(self.percentage).truncate(places: 1)))
                        .font(Font.custom("Gilroy-LIght", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .animation(nil)
                    Spacer()
                }
            }.cornerRadius(18)
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
                        .font(Font.custom("Gilroy-LIght", size: 14))
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
    var id = Auth.auth().currentUser?.uid
    init() {
        self.users = [UserData]()
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if (UserDefaults.standard.value(forKey: "ID") as! String) == (document.get("ID") as! String) {
                        self.lock = document.get("Lock") as! [Bool]
                        self.userrates = document.get("Rates") as! [String]
                        self.keys = document.get("Keys") as! Int
                        self.comments = document.get("Comments") as! [String]
                        self.rating = ratingtype(overall: CGFloat(document.get("OverallRating") as! Double), appearance: CGFloat(document.get("AppearanceRating") as! Double), personality: CGFloat(document.get("PersonalityRating") as! Double))
                        self.numrates = self.userrates.count-1
                        for _ in 0...self.numrates {
                            self.showratings.append(false)
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
                            self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating))
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
                            self.ratesinfo.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating))
                        }
                    }
                }
            }
        }
    }
    func relogin() {
        self.users = [UserData]()
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            else {
                for document in querySnapshot!.documents {
                    if UserDefaults.standard.value(forKey: "ID") as! String == document.get("ID") as! String {
                        self.lock = document.get("Lock") as! [Bool]
                        self.userrates = document.get("Rates") as! [String]
                        self.rating = ratingtype(overall: CGFloat(document.get("OverallRating") as! Double), appearance: CGFloat(document.get("AppearanceRating") as! Double), personality: CGFloat(document.get("PersonalityRating") as! Double))
                        self.numrates = self.userrates.count-1
                        for _ in 0...self.numrates {
                            self.showratings.append(false)
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
                            self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating))
                        }
                    }
                }
                self.users.shuffle()
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
                            self.users.append(UserData(Age: age, Bio: bio, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating))
                        }
                    }
                }
            }
        }
    }
}


//MARK: CreateUser
func CreateUser(name: String, age: String, gender: String, percentage: Double, overallrating: Double, appearancerating: Double, personalityrating: Double, profilepics: [Data], photopostion: [Int], bio: [String], complete: @escaping (Bool)-> Void) {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    
    db.collection("users").document(uid!).setData(["Name": name, "Age": age, "Gender": gender, "Percentage": percentage, "SelfRating": overallrating, "ProfilePics": [String](), "Bio": [String](), "Rates": [String](), "OverallRating": overallrating, "AppearanceRating": appearancerating, "PersonalityRating": personalityrating, "ID": uid!, "Lock": [Bool](), "Keys": 0]) { (err) in
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
                        UserDefaults.standard.set(bio, forKey: "Bio")
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
func UpdateRating(user: UserData, appearance: Double, personality: Double, keys: Int) {
    let overall = Double(Double(personality)*Double(user.Percentage).truncate(places: 2) + Double(appearance)*Double(1-user.Percentage).truncate(places: 2)).truncate(places: 1)
    let newoverall = Double(user.OverallRating*Double(user.Rates.count+1) + overall)/Double(user.Rates.count+2).truncate(places: 1)
    let newappearance = Double(user.AppearanceRating*Double(user.Rates.count+1) + appearance)/Double(user.Rates.count+2).truncate(places: 1)
    let newpersonality = Double(user.PersonalityRating*Double(user.Rates.count+1) + personality)/Double(user.Rates.count+2).truncate(places: 1)
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    db.collection("users").document(user.id).updateData(["OverallRating": newoverall.truncate(places: 1), "AppearanceRating": newappearance.truncate(places: 1), "PersonalityRating": newpersonality.truncate(places: 1), "Rates": FieldValue.arrayUnion([String(appearance.truncate(places: 1)) + String(personality.truncate(places: 1)) + String(overall) + uid!])])
    db.collection("users").document(uid!).updateData(["Keys": keys])
    print(user.Percentage, newappearance, newpersonality, newoverall)
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
        view.font = UIFont(name: "Gilroy-ExtraBold", size: 15)
        if text.count == 0 {
            view.textColor = UIColor(named: "purp")!.withAlphaComponent(0.5)
            view.text = "Write Something"
        }
        else {
            view.textColor = UIColor(named: "purp")
            view.text = text
        }
        view.backgroundColor = UIColor(named: "lightgray")!.withAlphaComponent(0.3)
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
            textView.text = ""
            textView.textColor = UIColor(named: "purp")
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
            view.textColor = UIColor(named: "purp")
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
}
