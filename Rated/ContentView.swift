//
//  ContentView.swift
//  Rated
//
//  Created by Michael Vu on 7/17/20.
//  Copyright © 2020 Evija Digital. All rights reserved.
//

import SwiftUI
import Combine
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
                /*VStack(spacing: 5) {
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
                }.offset(y: self.shift ? CGFloat(-32*self.index) : 0).animation(.spring())*/
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
                /*for str in self.observer.myprofile.Bio {
                    self.newbio[(String(str.prefix(2)) as NSString).integerValue] = String(str)[2..<str.count]
                }*/
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
                                /*ScrollView(.vertical, showsIndicators: false) {
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
                                }.frame(width: 0.84*screenwidth, height: screenheight*0.62 - 20)*/
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
            RoundedRectangle(cornerRadius: 3.5)
                .frame(width: 7, height: screenheight*0.074)
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
    @Binding var index: Int
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            Text("Overall")
                .font(Font.custom("ProximaNova-Regular", size: 18))
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
                    }.cornerRadius(10)
                    Spacer()
                }
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 3.5)
                        .frame(width: 7, height: screenheight*0.074)
                        .rotationEffect(Angle(degrees: self.index == 0 ? Double(observer.rating.overall*18)-90 : -90), anchor: UnitPoint(x: 0.5, y: 1))
                        .foregroundColor(Color(.darkGray))
                        .animation(.spring())
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color(.darkGray))
                        .offset(y: 7.5)
                }.frame(width: screenheight*0.17, height: screenheight*0.074)
                //RatingMeter()
            }.frame(width: screenheight*0.17, height: screenheight*0.085)
                .padding(.bottom, 5)
            Text(self.observer.userrates.count == 1 ? String(self.observer.userrates.count) + " Rating" : String(self.observer.userrates.count) + " Ratings")
                .font(Font.custom("ProximaNova-Regular", size: 12))
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
                .padding(.bottom, 15)
        }.frame(height: screenheight*0.234)
    }
}


//MARK: DetailsMeter
struct DetailsMeter: View {
    @Binding var index: Int
    let screenwidth = UIScreen.main.bounds.width
    let screenheight = UIScreen.main.bounds.height
    @EnvironmentObject var observer: observer
    var body: some View {
        VStack {
            HStack(spacing: 30) {
                VStack(spacing: 0) {
                    Text("Appearance")
                        .font(Font.custom("ProximaNova-Regular", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("appearance"))
                        .padding(.top, 10)
                    Image("eye")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color("appearance"))
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
                            }.cornerRadius(10)
                            Spacer()
                        }
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 2.5)
                                .frame(width: 5, height: 40)
                                .rotationEffect(Angle(degrees: self.index == 1 ? Double(observer.rating.appearance*18)-90 : -90), anchor: UnitPoint(x: 0.5, y: 1))
                                .foregroundColor(Color(.darkGray))
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(.darkGray))
                                .offset(y: 5)
                        }.frame(width: 100, height: 40)
                    }.frame(width: 100, height: 60)
                }
                VStack(spacing: 0) {
                    Text("Personality")
                        .font(Font.custom("ProximaNova-Regular", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("personality"))
                        .padding(.top, 10)
                    Image("heart")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color("personality"))
                        .padding(2.5)
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
                            }.cornerRadius(10)
                            Spacer()
                        }
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 2.5)
                                .frame(width: 5, height: 40)
                                .rotationEffect(Angle(degrees: self.index == 1 ? Double(observer.rating.personality*18)-90 : -90), anchor: UnitPoint(x: 0.5, y: 1))
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
                    OverallMeter(index: self.$index)
                        .frame(width: screenwidth/1.25)
                    DetailsMeter(index: self.$index)
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
                .foregroundColor(Color(.darkGray))
                .padding(.top, screenheight*0.0123)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("lightgray")).opacity(0.2)
                    .frame(width: 240, height: screenheight*0.05)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.darkGray)).opacity(0.8)
                        .frame(width: 80, height: screenheight*0.05 - 2)
                    /*RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 80, height: screenheight*0.05 - 2)*/
                }.offset(x: self.gender*80)
                HStack(spacing: 0) {
                    Button(action: {
                        self.gender = -1
                        //self.observer.myprofile.Preferences[0] = "Male"
                    }) {
                        Text("Male")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(self.gender == -1 ? .white : Color(.darkGray))
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
                            .foregroundColor(self.gender == 0 ? .white : Color(.darkGray))
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
                            .foregroundColor(self.gender == 1 ? .white : Color(.darkGray))
                            .lineLimit(1)
                            .frame(width: 80)
                            .minimumScaleFactor(0.01)
                    }
                }.frame(width: 240, height: screenheight*0.05)
            }
            Text("Get Rated By:")
                .font(Font.custom("ProximaNova-Regular", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("lightgray")).opacity(0.2)
                    .frame(width: 240, height: screenheight*0.05)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.darkGray)).opacity(0.8)
                        .frame(width: 80, height: screenheight*0.05 - 2)
                    /*RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 80, height: screenheight*0.05 - 2)*/
                }.offset(x: self.ratinggender*80)
                HStack(spacing: 0) {
                    Button(action: {
                        self.ratinggender = -1
                        //self.observer.myprofile.Preferences[1] = "Male"
                    }) {
                        Text("Male")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(self.ratinggender == -1 ? .white : Color(.darkGray))
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
                            .foregroundColor(self.ratinggender == 0 ? .white : Color(.darkGray))
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
                            .foregroundColor(self.ratinggender == 1 ? .white : Color(.darkGray))
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
                    .foregroundColor(Color(.darkGray))
                    .padding(.trailing, 10)
                HStack(spacing: 0) {
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
                }.padding(5)//.background(Color(.darkGray).cornerRadius(5))
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
                    .foregroundColor(Color(.darkGray)).opacity(0.8)
                    //.background(Color(.white))
                    .offset(x: self.width)
                    .animation(nil)
                Circle()
                    .foregroundColor(Color(.darkGray))
                    .frame(width: self.first ? 20 : 15, height: self.first ? 20 : 15)
                    //.background(Circle().foregroundColor(.white))
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
                    .foregroundColor(Color(.darkGray))//.opacity(0.5))
                    .frame(width: self.second ? 20 : 15, height: self.second ? 20 : 15)
                    //.background(Circle().foregroundColor(.white))
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
