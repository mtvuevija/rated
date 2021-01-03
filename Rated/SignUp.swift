//
//  SignUp.swift
//  Rated

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import GoogleMobileAds
import SystemConfiguration

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
    @State var next: CGFloat = 0//-8*UIScreen.main.bounds.width
    @State var enteredcode = ""
    @State var count: Int = 1
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
    
    @State var political = ""
    @State var politicals = ["Apolitical", "Liberal", "Moderate", "Conservative"]
    @State var politicalselect = [Bool](repeating: false, count: 4)
    
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
    @State var quit = false
    
    var body: some View {
        ZStack {
            ZStack {
                HStack(spacing: 0) {
                    //MARK: Phone Number 1
                    VStack(spacing: 20) {
                        Image("phone")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
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
                                        .foregroundColor(Color(.darkGray))
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .fontWeight(.semibold)
                                    ZStack {
                                        
                                        TextField("", text: $ccode)
                                            .foregroundColor(Color(.darkGray))
                                            .font(Font.custom("ProximaNova-Regular", size: 18).weight(.semibold))
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
                                        .foregroundColor(Color(.darkGray).opacity(0.5))
                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                        .fontWeight(.semibold)
                                }
                                TextField("", text: $phonenumber)
                                    .foregroundColor(Color(.darkGray).opacity(0.75))
                                    .font(Font.custom("ProximaNova-Regular", size: 18).weight(.semibold))
                                    .frame(width: screenwidth - 240, height: 50)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                            }
                            Button(action: {
                                if self.phonenumber.count == 10 {
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
                                }
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
                            .frame(width: 30, height: 30)
                        
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
                                            .foregroundColor(Color(.darkGray).opacity(0.5))
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                            .fontWeight(.semibold)
                                    }.frame(width: screenwidth/2 - 80, height: 50)
                                }
                                TextField("", text: $enteredcode)
                                    .font(Font.custom("ProximaNova-Regular", size: 18).weight(.semibold))
                                    .frame(width: screenwidth/2 - 80, height: 50)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(TextAlignment.center)
                                    .onReceive(Just(self.enteredcode)) { _ in self.limit() }
                                
                            }
                            Button(action: {
                                if self.enteredcode.count == 6 {
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
                                                self.loading.toggle()
                                                self.next -= self.screenwidth
                                                self.count += 1
                                            }
                                        }
                                    }
                                }
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
                    
                    Group {
                        //MARK: Name 3
                        VStack {
                            Image("name")
                                .resizable()
                                .frame(width: 30, height: 30)
                            
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
                                            .foregroundColor(Color(.darkGray).opacity(0.5))
                                            .fontWeight(.semibold)
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                    }
                                    TextField("", text: $name)
                                        .font(Font.custom("ProximaNova-Regular", size: 18).weight(.semibold))
                                        .frame(width: screenwidth - 140, height: 50)
                                        .foregroundColor(Color(.darkGray))
                                        .multilineTextAlignment(TextAlignment.center)
                                        .onReceive(Just(self.name)) { _ in self.limit() }
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
                                .frame(width: 30, height: 30)
                            
                            Text("Enter Your Birthdate")
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
                                .frame(width: 30, height: 30)
                            
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
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                            .foregroundColor(Color(.darkGray).opacity(0.5))
                                            .fontWeight(.semibold)
                                            
                                    }
                                    TextField("", text: $gender)
                                        .font(Font.custom("ProximaNova-Regular", size: 18).weight(.semibold))
                                        .frame(width: screenwidth - 140, height: 50)
                                        .foregroundColor(Color(.darkGray))
                                        .multilineTextAlignment(TextAlignment.center)
                                        .onReceive(Just(self.gender)) { _ in self.limit() }
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
                        
                        //MARK: Profile Pictures 8
                        VStack(spacing: 20) {
                            
                            Image("profilepic")
                                .resizable()
                                .frame(width: 30, height: 30)
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
                                for val in self.showimage {
                                    if !val {
                                        return
                                    }
                                }
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
                        
                        //MARK: Set Up Bio
                        VStack {
                            Image("Bio")
                                .resizable()
                                .frame(width: 50, height: 50)
                            
                            Text("Now you will set up your bio. Remember, adding more information will allow people to get a better sense of who you really are.")
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.darkGray))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: false)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 10)
                            
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
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Personality Traits
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
                                                .foregroundColor(Color(.darkGray).opacity(1))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[0] ? 1 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.openness = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray).opacity(1))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.openness = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray).opacity(1))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.openness = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray).opacity(1))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray).opacity(1))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray).opacity(1))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(openness[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.openness = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
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
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.conscientiousness = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(conscientiousness[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.conscientiousness = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
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
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.extraversion = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.extraversion = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(extraversion[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.extraversion = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
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
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.agreeableness = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.agreeableness = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(agreeableness[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.agreeableness = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
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
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 40, height: 40)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[0] ? 0.6 : 0)).frame(width: 28, height: 28))
                                                .onTapGesture {
                                                    self.neuroticism = [true, false, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[1] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.neuroticism = [false, true, false, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[2] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, true, false, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 27.5, height: 27.5)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[3] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, true, false, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 30, height: 30)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[4] ? 0.6 : 0)).frame(width: 18, height: 18))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, false, true, false, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(width: 35, height: 35)
                                                .overlay(Circle().foregroundColor(Color("purp").opacity(neuroticism[5] ? 0.6 : 0)).frame(width: 23, height: 23))
                                                .onTapGesture {
                                                    self.neuroticism = [false, false, false, false, false, true, false]
                                                }
                                            Circle()
                                                .strokeBorder(lineWidth: 5)
                                                .foregroundColor(Color(.darkGray))
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
                            }.scaleEffect(0.9)
                            
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
                                    .padding(.bottom, 30)
                                    .opacity(0.7)
                            }
                        }.frame(width: screenwidth, height: screenheight)
                        
                        //MARK: Education
                        VStack(spacing: 0) {
                            Spacer()
                            Image("Education")
                                .resizable()
                                .frame(width: 30, height: 30)
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
                                .frame(width: 30, height: 30)
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
                                .frame(width: 30, height: 30)
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
                                                .onReceive(Just(self.newitem)) { _ in self.limit() }
                                        }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                    }
                                    Button(action: {
                                        for s in self.newsports {
                                            if s == self.newitem {
                                                self.msg = "No Duplicates Allowed"
                                                self.alert.toggle()
                                                return
                                            }
                                        }
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
                                .frame(width: 30, height: 30)
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
                                                .onReceive(Just(self.newitem)) { _ in self.limit() }
                                        }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                                        Button(action: {
                                            for h in self.hobbiesdata {
                                                if h == self.newitem {
                                                    self.msg = "No Duplicates Allowed"
                                                    self.alert.toggle()
                                                    self.newitem = ""
                                                    return
                                                }
                                            }
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
                                    }.padding(.bottom, 10)
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
                                        Image(systemName: "xmark")
                                            .font(Font.system(size: 20, weight: .heavy))
                                            .foregroundColor(Color("personality"))
                                            .padding(.leading, 10)
                                            .onTapGesture {
                                                self.hobbiesdata.remove(at: self.hobbiesdata.firstIndex(of: hobbie)!)
                                            }
                                    }.padding(.vertical, 5).padding(.horizontal, 20).frame(width: self.screenwidth - 80, height: 70).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
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
                                            .fixedSize(horizontal: true, vertical: true)
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
                                .frame(width: 30, height: 30)
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
                                .frame(width: 30, height: 30)
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
                                .frame(width: 30, height: 30)
                            VStack(spacing: 15) {
                                Text("Star Sign")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                ScrollView {
                                    VStack {
                                        ForEach(0...self.starsigns.count-1, id: \.self) { ind in
                                            VStack(spacing: 5) {
                                                Button(action: {
                                                    if self.starsignsselect[ind] {
                                                        self.starsign = ""
                                                        self.starsignsselect = [Bool](repeating: false, count: 12)
                                                    }
                                                    else {
                                                        self.starsignsselect = [Bool](repeating: false, count: 12)
                                                        self.starsignsselect[ind] = true
                                                        self.starsign = self.starsigns[ind]
                                                    }
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
                        
                        //MARK: Political Leaning
                        VStack {
                            Spacer()
                            Image("Politics")
                                .resizable()
                                .frame(width: 30, height: 30)
                            VStack {
                                Text("Political Leaning")
                                    .font(Font.custom("ProximaNova-Regular", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.bottom, 10)
                                VStack {
                                    ForEach(0...self.politicals.count-1, id: \.self) { ind in
                                        VStack(spacing: 5) {
                                            Button(action: {
                                                if self.politicalselect[ind] {
                                                    self.political = ""
                                                    self.politicalselect = [Bool](repeating: false, count: 4)
                                                }
                                                else {
                                                    self.politicalselect = [Bool](repeating: false, count: 4)
                                                    self.political = self.politicals[ind]
                                                    self.politicalselect[ind] = true
                                                }
                                            }) {
                                                HStack {
                                                    /*Image(self.politicals[ind])
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(self.politicalselect[ind] ? Color(.white) : Color(.darkGray).opacity(0.8))*/
                                                    Text(self.politicals[ind])
                                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(self.politicalselect[ind] ? Color(.white) : Color(.darkGray).opacity(0.8))
                                                        .fixedSize(horizontal: true, vertical: false)
                                                }.padding(20).frame(width: 280)
                                            }.background(Color(self.politicalselect[ind] ? .darkGray : .white).cornerRadius(10).shadow(color: Color(.black).opacity(self.starsignsselect[ind] ? 0 : 0.1), radius: 15, x: 10, y: 10))
                                        }.padding(.vertical, 7.5)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    self.next -= self.screenwidth
                                    self.count += 1
                                }) {
                                    if self.political.count > 0 {
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
                    
                    
                    //MARK: Socials 10
                    VStack {
                        Text("Socials")
                            .font(Font.custom("ProximaNova-Regular", size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("(These social media handles will be public)")
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
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .opacity(0.5)
                                        }
                                        TextField("", text: self.$instagramhandle)
                                            .font(Font.custom("ProximaNova-Regular", size: 18).weight(.semibold))
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10)
                                            .frame(width: 140, height: 40)
                                            .multilineTextAlignment(.center)
                                            .onReceive(Just(self.instagramhandle)) { _ in self.limit() }
                                    }.padding(5).background(Color("lightgray").opacity(0.5).cornerRadius(10))
                                }
                                Button(action: {
                                    self.instagram.toggle()
                                }) {
                                    Image(systemName: "plus")
                                        .font(Font.system(size: 24, weight: .bold))
                                        .foregroundColor(self.instagram ? Color("personality") : .gray)
                                        .rotationEffect(Angle(degrees: self.instagram ? 45 : 0))
                                }.padding(10).buttonStyle(PlainButtonStyle())
                            }.background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            HStack {
                                Image("twitter")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .padding(10)
                                if self.twitter {
                                    ZStack {
                                        if self.twitterhandle.count < 1 {
                                            Text("Twitter Handle")
                                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .opacity(0.5)
                                        }
                                        TextField("", text: self.$twitterhandle)
                                            .font(Font.custom("ProximaNova-Regular", size: 16).weight(.semibold))
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10)
                                            .frame(width: 140, height: 40)
                                            .multilineTextAlignment(.center)
                                            .onReceive(Just(self.twitterhandle)) { _ in self.limit() }
                                    }.padding(5).background(Color("lightgray").opacity(0.5).cornerRadius(10))
                                }
                                Button(action: {
                                    self.twitter.toggle()
                                }) {
                                    Image(systemName: "plus")
                                        .font(Font.system(size: 24, weight: .bold))
                                        .foregroundColor(self.twitter ? Color("personality") : .gray)
                                        .rotationEffect(Angle(degrees: self.twitter ? 45 : 0))
                                }.padding(10).buttonStyle(PlainButtonStyle())
                            }.background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
                            HStack {
                                Image("snapchat")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .padding(10)
                                if self.snapchat {
                                    ZStack {
                                        if self.snapchathandle.count < 1 {
                                            Text("Snapchat Handle")
                                                .font(Font.custom("ProximaNova-Regular", size: 16))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .opacity(0.5)
                                        }
                                        TextField("", text: self.$snapchathandle)
                                            .font(Font.custom("ProximaNova-Regular", size: 16).weight(.semibold))
                                            .foregroundColor(Color(.darkGray))
                                            .padding(10)
                                            .frame(width: 140, height: 40)
                                            .multilineTextAlignment(.center)
                                            .onReceive(Just(self.snapchathandle)) { _ in self.limit() }
                                    }.padding(5).background(Color("lightgray").opacity(0.5).cornerRadius(10))
                                }
                                Button(action: {
                                    self.snapchat.toggle()
                                }) {
                                    Image(systemName: "plus")
                                        .font(Font.system(size: 24, weight: .bold))
                                        .foregroundColor(self.snapchat ? Color("personality") : .gray)
                                        .rotationEffect(Angle(degrees: self.snapchat ? 45 : 0))
                                }.padding(10).buttonStyle(PlainButtonStyle())
                            }.background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
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
                                    /*let socials = [self.instagramhandle, self.snapchathandle, self.twitterhandle]
                                    
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
                                    }*/
                                    self.next -= self.screenwidth
                                    self.count += 1
                                }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .foregroundColor(!(self.instagram && self.instagramhandle.isEmpty || self.twitter && self.twitterhandle.isEmpty || self.snapchat && self.snapchathandle.isEmpty) ? Color(.blue).opacity(0.5) : Color("lightgray"))
                            }.padding(.top, 20)
                        }
                    }.frame(width: screenwidth, height: screenheight).offset(y: -80)
                    
                    Group {
                        //MARK: What Matters?
                        VStack {
                            HStack(spacing: 40) {
                                Image("eye")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 30, height: 35)
                                    .foregroundColor(Color("appearance"))
                                
                                Image("heart")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 30, height: 30)
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
                        
                        //MARK: Rate Yourself
                        VStack {
                            /*Image("rating(temp)")
                                .resizable()
                                .frame(width: 75, height: 75)*/
                            GIFView(gifName: "rategif")
                                .frame(width: 60, height: 30)
                                
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
                                print("hello")
                                let socials = [self.instagramhandle, self.snapchathandle, self.twitterhandle]
                                
                                let per = Double(self.percentage/10).truncate(places: 1)
                                
                                let overall = Double(Double(self.selfratingpersonality)*per + Double(self.selfratingappearance)*Double(1-per)).truncate(places: 1)
                                var traits = [Int]()
                                var counter: Int = 0
                                for val in self.openness {
                                    if val {
                                        traits.append(counter+1)
                                    }
                                    counter += 1
                                }
                                counter = 0
                                for val in self.conscientiousness {
                                    if val {
                                        traits.append(counter+1)
                                    }
                                    counter += 1
                                }
                                counter = 0
                                for val in self.extraversion {
                                    if val {
                                        traits.append(counter+1)
                                    }
                                    counter += 1
                                }
                                counter = 0
                                for val in self.agreeableness {
                                    if val {
                                        traits.append(counter+1)
                                    }
                                    counter += 1
                                }
                                counter = 0
                                for val in self.neuroticism {
                                    if val {
                                        traits.append(counter+1)
                                    }
                                    counter += 1
                                }
                                print(traits)
                                var sportsfin = [String]()
                                if self.newsports.count != 0 {
                                    for num in 0...(self.newsports.count-1) {
                                        if self.newsportsselect[num] {
                                            sportsfin.append(self.newsports[num])
                                        }
                                    }
                                }
                                for num in 0...(self.sports.count-1) {
                                    if self.sportsselect[num] {
                                        sportsfin.append(self.sports[num])
                                    }
                                }
                                CreateUser2(name: self.name, bdate: self.bdate, gender: self.gender, percentage: per, overallrating: overall, appearancerating: Double(self.selfratingappearance).truncate(places: 1), personalityrating: Double(self.selfratingpersonality).truncate(places: 1), profilepics: self.profilepics, traits: traits, education: self.educationdata, occupation1: self.occupationdata, occupation2: self.occupationdata1, sports: sportsfin, hobby: self.hobbiesdata, mnt1: self.mntdata, mnt2: self.mntgenres, music1: self.musicdata, music2: self.musicgenres, starsign: self.starsign, politics: self.political, socials: socials) { (val) in
                                    if val {
                                        self.showprofile.toggle()
                                        self.next -= self.screenwidth
                                        self.count += 1
                                        self.observer.signedup()
                                        self.loading.toggle()
                                    }
                                    else {
                                        self.msg = "There was an error with signing up. Try again later."
                                        self.alert.toggle()
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(.blue).opacity(0.5))
                            }
                        }.frame(width: screenwidth, height: screenheight)
                    }
                    
                    //MARK: Finished
                    VStack {
                        Image("Bio")
                            .resizable()
                            .frame(width: 50, height: 50)
                        
                        Text("Your account is now all set up.")
                            .font(Font.custom("ProximaNova-Regular", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkGray))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: false)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 10)
                        
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
                                .font(Font.custom("ProximaNova-Regular", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.white))
                                .padding(10).padding(.horizontal, 20)
                                .background(Color(.darkGray).cornerRadius(20))
                                .padding(.bottom, 50)
                                .opacity(0.7)
                        }
                    }.frame(width: screenwidth, height: screenheight)
                    
                    /*//MARK: Your Profile 11
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
                    }.frame(width: screenwidth, height: screenheight)*/
                    
                }.animation(.spring()).offset(x: screenwidth*9.5 + next).sheet(isPresented: self.$picker) {
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
                        if self.count != 3 && self.count != 7 && self.count != 8 {
                            Button(action: {
                                if self.count == 1 {
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
                        }
                        
                        Text("Sign Up")
                            .font(Font.custom("ProximaNova-Regular", size: 36))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkGray))
                            .padding(.horizontal, self.count != 3 && self.count != 7 && self.count != 8 ? 0 : 50)
                        Spacer()
                        
                        Button(action: {
                            //self.activeAlert = .second
                            self.quit = true
                            self.alert.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 24, weight: .heavy))
                                .foregroundColor(Color("personality"))
                        }.padding(.horizontal, 25)
                        
                    }.frame(width: screenwidth).padding(.top, self.screenheight > 800 ? screenheight*0.055 : screenheight*0.02)
                    if self.count > 2 && self.count < 7 {
                        VStack {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2.5)
                                    .frame(width: screenwidth - 60, height: 10)
                                    .foregroundColor(Color("lightgray").opacity(0.5))
                                Rectangle()
                                    .frame(width: (screenwidth - 60)*(CGFloat(self.count-3)/4), height: 10)
                                    .foregroundColor(Color("appearance"))
                            }.cornerRadius(3.5)
                            Spacer()
                        }
                    }
                    if self.count > 7 {
                        VStack {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2.5)
                                    .frame(width: screenwidth - 60, height: 10)
                                    .foregroundColor(Color("lightgray").opacity(0.5))
                                Rectangle()
                                    .frame(width: (screenwidth - 60)*(CGFloat(self.count-8)/10), height: 10)
                                    .foregroundColor(Color("personality"))
                            }.cornerRadius(3.5)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    
                }.animation(.easeInOut)/*
                .alert(isPresented: self.$quit) {
                    Alert(title: Text("Quit Sign Up?"), message: Text("Are you sure you want to leave the sign up page?"), primaryButton: .destructive(Text("Yes")) {
                            print("BURHHHHH")
                    }, secondaryButton: .cancel())
                }*/
                
            }.navigationBarBackButtonHidden(true)
            .navigationBarTitle("")
            .navigationBarHidden(true)
                .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
                .alert(isPresented: $alert) {
                    if self.quit {
                        return Alert(title: Text("Quit Sign Up?"), message: Text("Are you sure you want to leave the sign up page?"), primaryButton: .destructive(Text("Yes")) {
                            self.signup.toggle()
                            self.quit = false
                            }, secondaryButton: .cancel() {
                                self.quit = false
                            })
                    }
                    else {
                        return Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
                    }
                    
                }.offset(y: self.logged ? -screenheight*1.25 : 0).animation(.spring())
        }.background(Color("personality").edgesIgnoringSafeArea(.all))
    }
    
    func limit() {
        if self.enteredcode.count > 6 {
            self.enteredcode = String(self.enteredcode.prefix(6))
        }
        if self.name.count > 20 {
            self.name = String(self.name.prefix(20))
        }
        if self.gender.count > 20 {
            self.gender = String(self.gender.prefix(20))
        }
        if self.instagramhandle.count > 20 {
            self.instagramhandle = String(self.instagramhandle.prefix(20))
        }
        if self.twitterhandle.count > 20 {
            self.twitterhandle = String(self.twitterhandle.prefix(20))
        }
        if self.snapchathandle.count > 20 {
            self.snapchathandle = String(self.snapchathandle.prefix(20))
        }
        if self.newitem.count > 20 {
            self.newitem = String(self.newitem.prefix(20))
        }
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
    @State var alert = false
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
                        .onReceive(Just(self.school)) { _ in self.limit() }
                }.padding(5).background(Color(.white).cornerRadius(15).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))//RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(Color(.darkGray)))
                Spacer()
            }
            VStack {
                Text("Select Graduation Year")
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
                        for e in self.educationdata {
                            if e == (self.school + self.yearfin) {
                                self.alert.toggle()
                                return
                            }
                        }
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
            .background(LinearGradient(gradient: Gradient(colors: [Color(.white), Color("lightgray")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
            .alert(isPresented: $alert) {
                  Alert(title: Text("No Duplicates"), message: Text("You cannot add two of the same schools"), dismissButton: .default(Text("OK")))
            }.animation(.spring())
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
    func limit() {
        if self.school.count > 25 {
            self.school = String(self.school.prefix(25))
        }
    }
}


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
                            .onReceive(Just(self.title)) { _ in self.limit() }
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
                            .onReceive(Just(self.company)) { _ in self.limit() }
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
    func limit() {
        if self.title.count > 25 {
            self.title = String(self.title.prefix(25))
        }
        if self.company.count > 25 {
            self.company = String(self.company.prefix(25))
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
                            .onReceive(Just(self.title)) { _ in self.limit() }
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
    func limit() {
        if self.title.count > 25 {
            self.title = String(self.title.prefix(25))
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
                            .onReceive(Just(self.title)) { _ in self.limit() }
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
    func limit() {
        if self.title.count > 25 {
            self.title = String(self.title.prefix(25))
        }
    }
}
