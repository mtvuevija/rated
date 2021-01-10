//
//  Home.swift
//  Rated


import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import GoogleMobileAds
import SystemConfiguration

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
                                ZStack {
                                    Color(.white)
                                        .frame(width: 50, height: 40)
                                        .opacity(0)
                                    Image(systemName: "line.horizontal.3")
                                        //.font(Font.system(size: 36, weight: .heavy))
                                        .resizable()
                                        .frame(width: 30, height: 24)
                                        .foregroundColor(Color(.darkGray))
                                    /*Image("settings-1")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: screenheight*0.047, height: screenheight*0.047)
                                        .foregroundColor(Color(.darkGray))*/
                                }
                            }.buttonStyle(PlainButtonStyle()).padding(.leading, 10)
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
                                        .frame(width: screenheight*0.04, height: screenheight*0.04)
                                        .foregroundColor(Color(.blue).opacity(0.4))
                                }//.padding(2.5).background(Color(.blue).opacity(0.4).cornerRadius(10))
                            }/*.padding(5).background(Color(.white).cornerRadius(12.5).shadow(color: Color("lightgray"), radius: 5))*/.padding(.trailing, screenwidth*0.05)
                        }.padding(.top, self.screenheight > 800 ? self.screenheight*0.05 : screenheight*0.035)
                        //MARK: Recent Ratings
                        HStack {
                            Image("ratings")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color(.darkGray))
                                .padding(.leading, 30)
                            Text("Recent Ratings")
                                .font(Font.custom("ProximaNova-Regular", size: 24))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(Color(.darkGray))
                                .frame(height: screenheight*0.05)
                                .minimumScaleFactor(0.02)
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
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
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
                            .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10))
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
                                        Text("Rate")
                                            .font(Font.custom("ProximaNova-Regular", size: 18))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(.darkGray))
                                        /*HStack(spacing: 0) {
                                            GIFView(gifName: "rategif")
                                                .frame(width: 80, height: 45)
                                        }.frame(width: screenwidth/2).padding(2.5)*/
                                        
                                        //.background(Color(.blue).opacity(0.4).cornerRadius(screenheight*0.02))
                                    }.padding(10).padding(.horizontal, 20).background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(screenheight*0.02 + 2.5))
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
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .foregroundColor(self.stats ? Color(.darkGray) : Color(.gray).opacity(0.5))
                                                    .minimumScaleFactor(0.01)
                                                /*Circle()
                                                    .foregroundColor(Color("personality"))
                                                    .frame(width: 10, height: 10)
                                                    .opacity(self.stats ? 1 : 0.1)*/
                                                Image("stats")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: self.screenheight*0.025, height: self.screenheight*0.025)
                                                    .foregroundColor(self.stats ? Color(.darkGray) : Color(.gray).opacity(0.5))
                                                    
                                            }.frame(width: screenwidth/2.5, height: screenheight*0.05)
                                        }
                                        Button(action: {
                                            self.stats = false
                                        }) {
                                            VStack(spacing: 2.5) {
                                                Text("Preferences")
                                                    .font(Font.custom("ProximaNova-Regular", size: 16))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .foregroundColor(self.stats ? Color(.gray).opacity(0.5) : Color(.darkGray))
                                                    .minimumScaleFactor(0.01)
                                                /*Circle()
                                                    .foregroundColor(Color("personality"))
                                                    .frame(width: 10, height: 10)
                                                    .opacity(self.stats ? 0.1 : 1)*/
                                                Image("settings")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: self.screenheight*0.025, height: self.screenheight*0.025)
                                                    .foregroundColor(self.stats ? Color(.gray).opacity(0.5) : Color(.darkGray))
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
                                                HStack(spacing: 7.5) {
                                                    Text("Save")
                                                        .font(Font.custom("ProximaNova-Regular", size: 20))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(Color(.darkGray))
                                                        .fixedSize(horizontal: true, vertical: true)
                                                    Image("save")
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(Color(.darkGray))
                                                }
                                            }.padding(10)//.padding(.horizontal, 10).background(Color("lightgray").opacity(0.2).shadow(color: Color("lightgray"), radius: 15).cornerRadius(5))
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
                                    .foregroundColor(Color(.darkGray))
                                    .frame(width: self.screenwidth/1.75)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 10)
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
                                                    .foregroundColor(Color(.darkGray))
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
                                                    .foregroundColor(Color(.darkGray))
                                                    .frame(height: 50)
                                            }
                                            else {
                                                Text("Remove Rating")
                                                    .font(Font.custom("ProximaNova-Regular", size: 22))
                                                    .fontWeight(.semibold)
                                                    .animation(nil)
                                                    .foregroundColor(Color(.darkGray))
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
                                                    .foregroundColor(self.confirm || self.confirm1 ? .white : Color(.darkGray))
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
                .font(Font.custom("ProximaNova-Regular", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
                .padding(.top, screenheight*0.0123)
            ZStack {
                RoundedRectangle(cornerRadius: 17.5)
                    .foregroundColor(Color("lightgray")).opacity(0.5)
                    .frame(width: self.screenheight*0.3, height: screenheight*0.05)
                ZStack {
                    RoundedRectangle(cornerRadius: 17.5)
                        .foregroundColor(Color("purp"))
                        .frame(width: (self.screenheight*0.3)/3, height: screenheight*0.05 - 2)
                        .background(Color(.white))
                        .cornerRadius(17.5)
                    /*RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 80, height: screenheight*0.05 - 2)*/
                }.offset(x: self.gender*(self.screenheight*0.3)/3)
                HStack(spacing: 0) {
                    Button(action: {
                        self.gender = -1
                        //self.observer.myprofile.Preferences[0] = "Male"
                    }) {
                        Text("Male")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(self.gender == -1 ? .white : Color("purp"))
                            .lineLimit(1)
                            .frame(width: (self.screenheight*0.3)/3)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.gender = 0
                        //self.observer.myprofile.Preferences[0] = "Female"
                    }) {
                        Text("Female")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(self.gender == 0 ? .white : Color("purp"))
                            .lineLimit(1)
                            .frame(width: (self.screenheight*0.3)/3)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.gender = 1
                        //self.observer.myprofile.Preferences[0] = "Everyone"
                    }) {
                        Text("Everyone")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(self.gender == 1 ? .white : Color("purp"))
                            .lineLimit(1)
                            .frame(width: (self.screenheight*0.3)/3)
                            .minimumScaleFactor(0.01)
                    }
                }.frame(width: 240, height: screenheight*0.05)
            }
            Text("Get Rated By:")
                .font(Font.custom("ProximaNova-Regular", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
            
            ZStack {
                RoundedRectangle(cornerRadius: 17.5)
                    .foregroundColor(Color("lightgray")).opacity(0.5)
                    .frame(width: (self.screenheight*0.3), height: screenheight*0.05)
                ZStack {
                    RoundedRectangle(cornerRadius: 17.5)
                        .foregroundColor(Color("purp"))
                        .frame(width: (self.screenheight*0.3)/3, height: screenheight*0.05 - 2)
                        .background(Color(.white))
                        .cornerRadius(17.5)
                    /*RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.blue).opacity(0.5))
                        .frame(width: 80, height: screenheight*0.05 - 2)*/
                }.offset(x: self.ratinggender*(self.screenheight*0.3)/3)
                HStack(spacing: 0) {
                    Button(action: {
                        self.ratinggender = -1
                        //self.observer.myprofile.Preferences[1] = "Male"
                    }) {
                        Text("Male")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(self.ratinggender == -1 ? .white : Color("purp"))
                            .lineLimit(1)
                            .frame(width: (self.screenheight*0.3)/3)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.ratinggender = 0
                        //self.observer.myprofile.Preferences[1] = "Female"
                    }) {
                        Text("Female")
                            .font(Font.custom("ProximaNova-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(self.ratinggender == 0 ? .white : Color("purp"))
                            .lineLimit(1)
                            .frame(width: (self.screenheight*0.3)/3)
                            .minimumScaleFactor(0.01)
                    }
                    Button(action: {
                        self.ratinggender = 1
                        //self.observer.myprofile.Preferences[1] = "Everyone"
                    }) {
                        Text("Everyone")
                            .font(Font.custom("ProximaNova-Regular", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(self.ratinggender == 1 ? .white : Color("purp"))
                            .lineLimit(1)
                            .frame(width: (self.screenheight*0.3)/3)
                            .minimumScaleFactor(0.01)
                    }
                }.frame(width: 240, height: screenheight*0.05)
            }
            
            HStack(spacing: 0) {
                Text("Age Range:")
                    .font(Font.custom("ProximaNova-Regular", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.darkGray))
                    .padding(.trailing, 5)
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
                    .foregroundColor(Color("purp"))
                    .background(Color(.white))
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
                        self.first = false
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
                        self.second = false
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
