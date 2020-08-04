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
import SwiftUICharts

//MARK: MainView
struct MainView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @State var signup = UserDefaults.standard.value(forKey: "signup") as? Bool ?? false
    @State var login = UserDefaults.standard.value(forKey: "login") as? Bool ?? false
    @State var profile = UserDefaults.standard.value(forKey: "profile") as? Bool ?? false
    @State var images = UserDefaults.standard.value(forKey: "ProfilePics")
    var body: some View {
        VStack {
            if status {
                if profile {
                    VStack {
                        HStack {
                            Button(action: {
                                UserDefaults.standard.set(false, forKey: "profile")
                                NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)

                            }) {
                                Image(systemName: "chevron.left.circle")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(Color("purp"))
                            }.padding(.leading, 15)
                            Spacer()
                        }
                        HomeProfile(images: UserDefaults.standard.value(forKey: "ProfilePics") as! [String], bio: UserDefaults.standard.value(forKey: "Bio") as! [String], name: UserDefaults.standard.value(forKey: "Name") as! String, age: UserDefaults.standard.value(forKey: "Age") as! String)
                            .animation(nil)
                    }
                }
                else {
                    HomeView().transition(.slide)
                }
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
                    self.profile = UserDefaults.standard.value(forKey: "profile") as? Bool ?? false
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
                                .keyboardType(.numberPad)
                        }
                        
                        ZStack {
                            Color(.gray)
                                .opacity(0.1)
                                .frame(width: screenwidth - 100, height: 50)
                                .cornerRadius(7.5)
                            
                            TextField("( _ _ _ ) - _ _ _ - _ _ _ _", text: $phonenumber)
                                .font(Font.custom("Gilroy-Light", size: 16))
                                .frame(width: screenwidth - 140, height: 50)
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
                        
                        TextField("_ _ _ _ _ _", text: $enteredcode)
                            .font(Font.custom("Gilroy-Light", size: 16))
                            .frame(width: screenwidth - 80, height: 50)
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
                                /*else {
                                    Image(uiImage: UIImage(data: self.profilepics[0])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .cornerRadius(15)
                                }*/
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
                                /*else {
                                    Image(uiImage: UIImage(data: self.profilepics[1])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .cornerRadius(15)
                                }*/
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
                                /*else {
                                    Image(uiImage: UIImage(data: self.profilepics[2])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .cornerRadius(15)
                                }*/
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
                                /*else {
                                    Image(uiImage: UIImage(data: self.profilepics[3])!)
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 100, height: 133)
                                        .cornerRadius(15)
                                }*/
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
                    self.loading.toggle()
                    /*if self.count == 1 {
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
                        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationcode, verificationCode: self.enteredcode)
                        
                        Auth.auth().signIn(with: credential) { (authResult, error) in
                            if error != nil {
                                self.msg = (error?.localizedDescription)!
                                self.loading.toggle()
                                self.alert.toggle()
                                return
                            }
                            self.loading.toggle()
                            self.next -= self.screenwidth
                            self.count += 1
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
                    }
                    else if self.count == 9 {
                        for num in self.biocards {
                            let index = (num.prefix(2) as NSString).integerValue
                            if self.selectedprompts[index] {
                                self.text[index] = "1" + String(num.prefix(2)) + self.text[index]
                            }
                        }
                        let selfratingg = Double(Double(self.selfratingpersonality)*Double(self.percentage/10).truncate(places: 2) + Double(self.selfratingappearance)*Double(1-self.percentage/10).truncate(places: 2)).truncate(places: 1)
                        CreateUser(name: self.name.uppercased(), age: Int(self.age) ?? 0, gender: self.gender, percentage: Double(self.percentage/10).truncate(places: 2), selfrating: selfratingg, profilepics: self.profilepics, photopostion: self.position, bio: self.text) { (complete) in
                            
                            if complete {
                                self.loading.toggle()
                                self.next -= self.screenwidth
                                self.count += 1
                                AddImages()
                            }
                        }
                        print(UserDefaults.standard.value(forKey: "ProfilePics") as! [String])
                    }
                    else {*/
                        self.next -= self.screenwidth
                        self.count += 1
                    //}
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
    @State var show: Bool = false
    @State var index: Int = 0
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            //MARK: White Border
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 115, height: 40)
                        .foregroundColor(Color(.white).opacity(0.5))
                        .padding(.leading, 10)
                        .offset(y: CGFloat(index)*40)
                    Spacer()
                }.padding(.top, 172.5)
                Spacer()
            }.background(Color("appearance").edgesIgnoringSafeArea(.all))
            .edgesIgnoringSafeArea(.all)
                
            //MARK: Menu
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Menu")
                        .font(Font.custom("Gilroy-Light", size: 28))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("personality"))
                    Button(action: {
                        self.index = 0
                        self.show.toggle()
                    }) {
                        HStack {
                            Image("home")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("Home")
                                .font(Font.custom("Gilroy-Light", size: 20))
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
                                .frame(width: 25, height: 25)
                            Text("Profile")
                                .font(Font.custom("Gilroy-Light", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                            Spacer()
                        }.frame(width: 120).padding(.leading, 10)
                    }.buttonStyle(PlainButtonStyle())
                    Rectangle().frame(width: 120, height: 2).foregroundColor(Color("personality")).padding(.vertical, 15)
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "status")
                        NotificationCenter.default.post(name: NSNotification.Name("StatusChange"), object: nil)
                    }) {
                        HStack {
                            Image("signout")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("LogOut")
                                .font(Font.custom("Gilroy-Light", size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("personality"))
                            Spacer()
                        }.frame(width: 120).padding(.leading, 10)
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                }.padding(.top, 130).padding(.leading, 10)
                Spacer()
            }.edgesIgnoringSafeArea(.all)
            
            VStack {
                //MARK: Profile
                if self.index == 1 {
                    HStack {
                        Button(action: {
                            self.show.toggle()

                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 31, height: 25)
                                .foregroundColor(Color("personality"))
                        }.padding(.leading, 15)
                        Spacer()
                    }.padding(.top, 45)
                    HomeProfile(images: UserDefaults.standard.value(forKey: "ProfilePics") as! [String], bio: UserDefaults.standard.value(forKey: "Bio") as! [String], name: UserDefaults.standard.value(forKey: "Name") as! String, age: UserDefaults.standard.value(forKey: "Age") as! String)
                    Spacer()
                }
                //MARK: Home
                else if self.index == 0 {
                    HStack {
                        Button(action: {
                            self.show.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 31, height: 25)
                                .foregroundColor(Color("personality"))
                        }.padding(.leading, 15)
                        Spacer()
                    }.padding(.top, 45)
                    RecentRatings()
                    Spacer()
                }
            }.frame(width: screenwidth, height: screenheight).background(Color("gray").edgesIgnoringSafeArea(.all))
                .animation(.spring())
                .cornerRadius(self.show ? 30 : 0)
                .scaleEffect(self.show ? 0.9 : 1)
                .offset(x: self.show ? screenwidth / 3 : 0, y: self.show ? 2 : 0)
                .rotationEffect(.init(degrees: self.show ? -1.5 : 0))
        }.edgesIgnoringSafeArea(.all)
    }
}

//MARK: Recent Ratings
struct RecentRatings: View {
    @State var test: [CGFloat] = [9.2, 8.8, 9.0, 6.5]
    let screenwidth = UIScreen.main.bounds.width
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Recent Ratings")
                    .font(Font.custom("Gilroy-Light", size: 24))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("personality"))
                    .padding(.leading, 40)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(test, id: \.self) {rate in
                        Bar(percent: rate)
                    }
                }.padding(.horizontal, 10)
            }.frame(width: screenwidth/1.25, height: 190)
                .background(Color("personality"))
                .cornerRadius(15)
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
            if self.images[count].count != 0 {
                VStack {
                    WebImage(url: URL(string: self.images[self.count]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenwidth - 20, height: (screenwidth - 20)*1.3)
                        .animation(nil)
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
                    .frame(width: 25, height: 25)
                Text(self.categories[self.index] + ":")
                    .font(Font.custom("Gilroy-Light", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("purp").opacity(0.75))
                Spacer()
            }.padding(.leading, 10)
            Text(self.text)
                .font(Font.custom("Gilroy-Light", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color("purp").opacity(0.4))
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
                    .foregroundColor(Color("purp"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            if count == 1 {
                Circle()
                    .foregroundColor(Color("purp"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            if count == 2 {
                Circle()
                    .foregroundColor(Color("purp"))
                    .frame(width: 10, height: 10)
            }
            else {
                Circle()
                    .foregroundColor(Color(.gray).opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            if count == 3 {
                Circle()
                    .foregroundColor(Color("purp"))
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


//MARK: CreateUser
func CreateUser(name: String, age: Int, gender: String, percentage: Double, selfrating: Double, profilepics: [Data], photopostion: [Int], bio: [String], complete: @escaping (Bool)-> Void) {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    
    db.collection("users").document(uid!).setData(["Name": name, "Age": age, "Gender": gender, "Percentage": percentage, "SelfRating": selfrating, "ProfilePics": [String](), "Bio": [String](), "Rates": [String](), "Rating": 0]) { (err) in
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
            storage.child("ProfilePics").child(uid! + String(num)).putData(profilepics[num], metadata: nil) { (_, err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    complete(false)
                    return
                }
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
                        UserDefaults.standard.set(selfrating, forKey: "SelfRating")
                        UserDefaults.standard.set(bio, forKey: "Bio")
                        complete(true)
                    }
                }
            }
        }
    }
}


//MARK: AddImages
func AddImages() {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    var oldim = UserDefaults.standard.value(forKey: "ProfilePics") as! [String]
    while oldim.count < 4 {
        oldim = UserDefaults.standard.value(forKey: "ProfilePics") as! [String]
    }
    for num in 0...3 {
        for nu in 0...3 {
            if num == (oldim[nu].prefix(1) as NSString).integerValue {
                images.append(oldim[nu].substring(fromIndex: 1))
            }
        }
    }
    UserDefaults.standard.set(images, forKey: "ProfilePics")
    for num in 0...3 {
        db.collection("users").document(uid!).updateData(["ProfilePics": FieldValue.arrayUnion([images[num]])])
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


//MARK: Blur and Bottom
struct BottomShape : Shape {
    func path(in rect: CGRect) -> Path {
        return Path{path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addArc(center: CGPoint(x: rect.width / 8 + 24, y: 0), radius: 30, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: false)
            path.addArc(center: CGPoint(x: rect.width / 2, y: 0), radius: 45, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: false)
            path.addArc(center: CGPoint(x: 7*rect.width / 8 - 24, y: 0), radius: 30, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: false)
        }
    }
}


//MARK: Bar
struct Bar : View {
    var percent : CGFloat = 0
    var body : some View{
        VStack(spacing: 0) {
            if percent == 0 {
            }
            else {
                Spacer()
                Text(String(Double(percent)))
                    .font(Font.custom("Gilroy-Light", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                Button(action: {
                }) {
                    ZStack {
                        Rectangle().fill(Color("purp")).frame(width: 60.75, height: 15 * percent).cornerRadius(5)
                    }
                }
            }
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


//MARK: LabeledDivider
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
