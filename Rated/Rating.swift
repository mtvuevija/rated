//
//  Rating.swift
//  Rated

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import GoogleMobileAds
import SystemConfiguration

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
    
    @State var openness = [false, false, false, false, false, false, false]
    @State var conscientiousness = [false, false, false, false, false, false, false]
    @State var extraversion = [false, false, false, false, false, false, false]
    @State var agreeableness = [false, false, false, false, false, false, false]
    @State var neuroticism = [false, false, false, false, false, false, false]
    
    @State var traits = true
    @State var edu = true
    @State var occu = true
    @State var sport = true
    @State var hobby = true
    @State var mnt = true
    @State var mus  = true
    
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
                                                        .padding(.leading, self.screenheight*0.02)
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
                                                        //MARK: Personality Traits
                                                        VStack {
                                                            HStack {
                                                                Image("heart")
                                                                    .renderingMode(.template)
                                                                    .resizable()
                                                                    .frame(width: 18, height: 18)
                                                                    .foregroundColor(Color("personality"))
                                                                    .padding(.leading, 10)
                                                                Text("Personality Traits")
                                                                    .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(Color(.darkGray))
                                                                Spacer()
                                                                Image(systemName: "chevron.down")
                                                                    .font(Font.system(size: 15, weight: .heavy))
                                                                    .foregroundColor(Color(.darkGray))
                                                                    .rotationEffect(.degrees(self.traits ? 180 : 0))
                                                                    .padding(.trailing, 10)
                                                            }.padding(.horizontal, 10).background(Color(.white))
                                                                .onTapGesture {
                                                                    self.traits.toggle()
                                                            }
                                                            if self.traits {
                                                                PersonalityTraitsView(openness: self.$openness, conscientiousness: self.$conscientiousness, extraversion: self.$extraversion, agreeableness: self.$agreeableness, neuroticism: self.$neuroticism)
                                                            }
                                                        }.frame(width: self.screenwidth*0.8 + 20).padding(.vertical, 20).background(Color(.white).cornerRadius(15)).padding(.top, 10)
                                                        
                                                        VStack(spacing: 5) {
                                                            Group {
                                                                if self.observer.users[self.observer.rated].Education.count > 0 {
                                                                    //MARK: Education
                                                                    VStack(spacing: 5) {
                                                                        HStack {
                                                                            Image("education-2")
                                                                                .renderingMode(.template)
                                                                                .resizable()
                                                                                .frame(width: 25, height: 25)
                                                                                .foregroundColor(Color(.darkGray))
                                                                            Text("Education")
                                                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                                .fontWeight(.semibold)
                                                                                .foregroundColor(Color(.darkGray))
                                                                            Spacer()
                                                                            Image(systemName: "chevron.down")
                                                                                .font(Font.system(size: 15, weight: .heavy))
                                                                                .foregroundColor(Color(.darkGray))
                                                                                .rotationEffect(.degrees(self.edu ? 180 : 0))
                                                                        }.padding(.horizontal, 10).padding(.vertical, 5).background(Color(.white)).onTapGesture {
                                                                            self.edu.toggle()
                                                                        }.padding(.bottom, self.edu ? 5 : 0)
                                                                        if edu {
                                                                            ForEach(self.observer.users[self.observer.rated].Education, id: \.self) { education in
                                                                                HStack {
                                                                                    Image("education-1")
                                                                                        .renderingMode(.template)
                                                                                        .resizable()
                                                                                        .frame(width: 20, height: 20)
                                                                                        .foregroundColor(Color(.darkGray))
                                                                                        .padding(.leading, 10)
                                                                                    VStack(alignment: .leading, spacing: 0) {
                                                                                        Text(String(education.prefix(education.count-4)))
                                                                                            .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                                            .fontWeight(.semibold)
                                                                                            .foregroundColor(Color(.darkGray))
                                                                                        Text(String(education.suffix(4)))
                                                                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                                                                            .fontWeight(.semibold)
                                                                                            .foregroundColor(Color(.darkGray))
                                                                                            .opacity(0.5)
                                                                                    }
                                                                                    Spacer()
                                                                                }.frame(width: self.screenwidth*0.7, height: 45)
                                                                                    .background(Color(.white).cornerRadius(10).shadow(color: Color("lightgray"), radius: 15))
                                                                                    .padding(.vertical, 2.5)
                                                                            }
                                                                        }
                                                                    }.frame(width: self.screenwidth*0.8).padding(10).padding(.bottom, self.edu ? 5 : 0)
                                                                        .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(15)).padding(.vertical, 2.5)
                                                                    RoundedRectangle(cornerRadius: 0.5).frame(width: self.screenwidth*0.8 - 20, height: 1).foregroundColor(Color(.darkGray))
                                                                }
                                                                if self.observer.users[self.observer.rated].Occupation1.count > 0 {
                                                                    //MARK: Occupation
                                                                    VStack(spacing: 5) {
                                                                        HStack {
                                                                            Image("occupation-1")
                                                                                .renderingMode(.template)
                                                                                .resizable()
                                                                                .frame(width: 25, height: 25)
                                                                                .foregroundColor(Color(.darkGray))
                                                                            Text("Occupation")
                                                                                .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                                .fontWeight(.semibold)
                                                                                .foregroundColor(Color(.darkGray))
                                                                            Spacer()
                                                                            Image(systemName: "chevron.down")
                                                                                .font(Font.system(size: 15, weight: .heavy))
                                                                                .foregroundColor(Color(.darkGray))
                                                                                .rotationEffect(.degrees(self.occu ? 180 : 0))
                                                                        }.padding(.horizontal, 10).background(Color(.white)).onTapGesture {
                                                                            self.occu.toggle()
                                                                        }.padding(.bottom, self.occu ? 5 : 0)
                                                                        if occu {
                                                                            ForEach(0...(self.observer.users[self.observer.rated].Occupation1.count-1), id: \.self) { num in
                                                                                HStack {
                                                                                    Image("occupation-1")
                                                                                        .renderingMode(.template)
                                                                                        .resizable()
                                                                                        .frame(width: 20, height: 20)
                                                                                        .foregroundColor(Color(.darkGray))
                                                                                        .padding(.leading, 10)
                                                                                    VStack(alignment: .leading, spacing: 0) {
                                                                                        Text(self.observer.users[self.observer.rated].Occupation1[num])
                                                                                            .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                                            .fontWeight(.semibold)
                                                                                            .foregroundColor(Color(.darkGray))
                                                                                        Text(self.observer.users[self.observer.rated].Occupation2[num])
                                                                                            .font(Font.custom("ProximaNova-Regular", size: 14))
                                                                                            .fontWeight(.semibold)
                                                                                            .foregroundColor(Color(.darkGray))
                                                                                            .opacity(0.5)
                                                                                    }
                                                                                    Spacer()
                                                                                }.frame(width: self.screenwidth*0.7, height: 45)
                                                                                    .background(Color(.white).cornerRadius(10).shadow(color: Color("lightgray"), radius: 15))
                                                                                    .padding(.vertical, 2.5)
                                                                            }
                                                                        }
                                                                    }.frame(width: self.screenwidth*0.8).padding(10).padding(.bottom, self.occu ? 5 : 0)
                                                                    .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(15))
                                                                    RoundedRectangle(cornerRadius: 0.5).frame(width: self.screenwidth*0.8 - 20, height: 1).foregroundColor(Color(.darkGray))
                                                                }
                                                            }
                                                            if self.observer.users[self.observer.rated].Sports.count > 0 {
                                                                //MARK: Sports
                                                                VStack(spacing: 5) {
                                                                    HStack {
                                                                        Image("basketball")
                                                                            .renderingMode(.template)
                                                                            .resizable()
                                                                            .frame(width: 25, height: 25)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Text("Sports")
                                                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                            .fontWeight(.semibold)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Spacer()
                                                                        Image(systemName: "chevron.down")
                                                                            .font(Font.system(size: 15, weight: .heavy))
                                                                            .foregroundColor(Color(.darkGray))
                                                                            .rotationEffect(.degrees(self.sport ? 180 : 0))
                                                                    }.padding(.horizontal, 10).background(Color(.white)).onTapGesture {
                                                                        self.sport.toggle()
                                                                    }.padding(.bottom, self.sport ? 5 : 0)
                                                                    if sport {
                                                                        ForEach(self.observer.users[self.observer.rated].Sports, id: \.self) { sp in
                                                                            HStack {
                                                                                Image(sp.lowercased())
                                                                                    .renderingMode(.template)
                                                                                    .resizable()
                                                                                    .frame(width: 20, height: 20)
                                                                                    .foregroundColor(Color(.darkGray))
                                                                                    .padding(.leading, 10)
                                                                                VStack(alignment: .leading, spacing: 0) {
                                                                                    Text(sp)
                                                                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(Color(.darkGray))
                                                                                }
                                                                                Spacer()
                                                                            }.frame(width: self.screenwidth*0.7, height: 40)
                                                                                .background(Color(.white).cornerRadius(10).shadow(color: Color("lightgray"), radius: 15))
                                                                                .padding(.vertical, 2.5)
                                                                        }
                                                                    }
                                                                }.frame(width: self.screenwidth*0.8).padding(10).padding(.bottom, self.sport ? 5 : 0)
                                                                .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(15))
                                                                RoundedRectangle(cornerRadius: 0.5).frame(width: self.screenwidth*0.8 - 20, height: 1).foregroundColor(Color(.darkGray))
                                                            }
                                                            if self.observer.users[self.observer.rated].Hobbies.count > 0 {
                                                                //MARK: Hobbies
                                                                VStack(spacing: 5) {
                                                                    HStack {
                                                                        Image("hobbies-1")
                                                                            .renderingMode(.template)
                                                                            .resizable()
                                                                            .frame(width: 25, height: 25)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Text("Hobbies")
                                                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                            .fontWeight(.semibold)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Spacer()
                                                                        Image(systemName: "chevron.down")
                                                                            .font(Font.system(size: 15, weight: .heavy))
                                                                            .foregroundColor(Color(.darkGray))
                                                                            .rotationEffect(.degrees(self.hobby ? 180 : 0))
                                                                    }.padding(.horizontal, 10).background(Color(.white)).onTapGesture {
                                                                        self.hobby.toggle()
                                                                    }.padding(.bottom, self.hobby ? 5 : 0)
                                                                    if hobby {
                                                                        ForEach(self.observer.users[self.observer.rated].Hobbies, id: \.self) { hb in
                                                                            HStack {
                                                                                Image("hobbies-1")
                                                                                    .renderingMode(.template)
                                                                                    .resizable()
                                                                                    .frame(width: 20, height: 20)
                                                                                    .foregroundColor(Color(.darkGray))
                                                                                    .padding(.leading, 10)
                                                                                VStack(alignment: .leading, spacing: 2.5) {
                                                                                    Text(hb)
                                                                                        .font(Font.custom("ProximaNova-Regular", size: 18))
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(Color(.darkGray))
                                                                                }
                                                                                Spacer()
                                                                            }.frame(width: self.screenwidth*0.7, height: 40)
                                                                                .background(Color(.white).cornerRadius(10).shadow(color: Color("lightgray"), radius: 15))
                                                                                .padding(.vertical, 2.5)
                                                                        }
                                                                    }
                                                                }.frame(width: self.screenwidth*0.8).padding(10).padding(.bottom, self.hobby ? 5 : 0)
                                                                .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(15))
                                                                RoundedRectangle(cornerRadius: 0.5).frame(width: self.screenwidth*0.8 - 20, height: 1).foregroundColor(Color(.darkGray))
                                                            }
                                                            
                                                            if self.observer.users[self.observer.rated].MovieTV1.count > 0 {
                                                                //MARK: Movies/TV
                                                                VStack(spacing: 5) {
                                                                    HStack {
                                                                        Image("Movies")
                                                                            .renderingMode(.template)
                                                                            .resizable()
                                                                            .frame(width: 25, height: 25)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Text("Movies/TV")
                                                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                            .fontWeight(.semibold)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Spacer()
                                                                        Image(systemName: "chevron.down")
                                                                            .font(Font.system(size: 15, weight: .heavy))
                                                                            .foregroundColor(Color("personality"))
                                                                            .rotationEffect(.degrees(self.mnt ? 180 : 0))
                                                                    }.padding(.horizontal, 10).background(Color(.white)).onTapGesture {
                                                                        self.mnt.toggle()
                                                                    }.padding(.bottom, self.mnt ? 5 : 0)
                                                                    if mnt {
                                                                        ForEach(0...(self.observer.users[self.observer.rated].MovieTV1.count-1), id: \.self) { num in
                                                                            HStack {
                                                                                Image(self.observer.users[self.observer.rated].MovieTV2[num])
                                                                                    .renderingMode(.template)
                                                                                    .resizable()
                                                                                    .frame(width: 20, height: 20)
                                                                                    .foregroundColor(Color(.white))
                                                                                    .padding(.leading, 10)
                                                                                VStack(alignment: .leading, spacing: 0) {
                                                                                    Text(self.observer.users[self.observer.rated].MovieTV1[num])
                                                                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(Color(.white))
                                                                                    Text(self.observer.users[self.observer.rated].MovieTV2[num])
                                                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(Color(.white))
                                                                                        .opacity(0.5)
                                                                                }
                                                                                Spacer()
                                                                            }.frame(width: self.screenwidth*0.7, height: 45)
                                                                                .background(Color(.darkGray).cornerRadius(10))
                                                                        }
                                                                    }
                                                                }.frame(width: self.screenwidth*0.8).padding(10).padding(.bottom, self.mnt ? 5 : 0)
                                                                .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(15))
                                                                RoundedRectangle(cornerRadius: 2).frame(width: self.screenwidth*0.8 - 20, height: 4).foregroundColor(Color("personality"))
                                                            }
                                                            if self.observer.users[self.observer.rated].Music1.count > 0 {
                                                                //MARK: Music
                                                                VStack(spacing: 5) {
                                                                    HStack {
                                                                        Image("song")
                                                                            .renderingMode(.template)
                                                                            .resizable()
                                                                            .frame(width: 25, height: 25)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Text("Music")
                                                                            .font(Font.custom("ProximaNova-Regular", size: 20))
                                                                            .fontWeight(.semibold)
                                                                            .foregroundColor(Color(.darkGray))
                                                                        Spacer()
                                                                        Image(systemName: "chevron.down")
                                                                            .font(Font.system(size: 15, weight: .heavy))
                                                                            .foregroundColor(Color("personality"))
                                                                            .rotationEffect(.degrees(self.mus ? 180 : 0))
                                                                    }.padding(.horizontal, 10).background(Color(.white)).onTapGesture {
                                                                        self.mus.toggle()
                                                                    }.padding(.bottom, self.mus ? 5 : 0)
                                                                    if mus {
                                                                        ForEach(0...(self.observer.users[self.observer.rated].Music1.count-1), id: \.self) { num in
                                                                            HStack {
                                                                                Image(self.observer.users[self.observer.rated].Music2[num])
                                                                                    .renderingMode(.template)
                                                                                    .resizable()
                                                                                    .frame(width: 20, height: 20)
                                                                                    .foregroundColor(Color(.white))
                                                                                    .padding(.leading, 10)
                                                                                VStack(alignment: .leading, spacing: 0) {
                                                                                    Text(self.observer.users[self.observer.rated].Music1[num])
                                                                                        .font(Font.custom("ProximaNova-Regular", size: 16))
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(Color(.white))
                                                                                    Text(self.observer.users[self.observer.rated].Music2[num])
                                                                                        .font(Font.custom("ProximaNova-Regular", size: 14))
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(Color(.white))
                                                                                        .opacity(0.5)
                                                                                }
                                                                                Spacer()
                                                                            }.frame(width: self.screenwidth*0.7, height: 45)
                                                                                .background(Color(.darkGray).cornerRadius(10))
                                                                        }
                                                                    }
                                                                }.frame(width: self.screenwidth*0.8).padding(10).padding(.bottom, self.mus ? 5 : 0)
                                                                .background(Color(.white).shadow(color: Color(.black).opacity(0.1), radius: 15, x: 10, y: 10).shadow(color: .white, radius: 15, x: -10, y: -10).cornerRadius(15))
                                                            }
                                                            Spacer().frame(height: 1)
                                                        }.background(Color(.white).cornerRadius(15))
                                                    }.frame(width: screenwidth - 20, height: screenheight*0.7 - 20).background(Color(.clear)).cornerRadius(30).animation(.spring())
                                                    
                                                }
                                                
                                            }.offset(y: self.bio ? -screenheight*0.35 : screenheight*0.35)
                                        }.frame(width: screenwidth - 20, height: screenheight*0.7).cornerRadius(25)
                                    }.frame(width: screenwidth - 20, height: screenheight*0.7).cornerRadius(25).scaleEffect(self.next ? 0 : 1)
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
                                                        .background(Circle().frame(width: 65, height: 65).foregroundColor(.blue))//.shadow(color: .blue, radius: 5))
                                                }
                                            }
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 37.5)
                                                .frame(width: self.rating ? 265 : 65, height: self.rating ? 75 : 65)
                                                .foregroundColor(self.rating ? .white : .yellow)
                                                .shadow(color: Color("lightgray"), radius: 5)
                                                //.shadow(color: self.rating ? Color("lightgray") : .yellow, radius: 5)
                                            
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
                                            self.openness[self.observer.users[self.observer.rated].Traits[0]-1] = true
                                            self.conscientiousness[self.observer.users[self.observer.rated].Traits[1]-1] = true
                                            self.extraversion[self.observer.users[self.observer.rated].Traits[2]-1] = true
                                            self.agreeableness[self.observer.users[self.observer.rated].Traits[3]-1] = true
                                            self.neuroticism[self.observer.users[self.observer.rated].Traits[4]-1] = true
                                        }) {
                                            Image(self.bio ? "eye" : "heart")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .padding(20)
                                                .foregroundColor(.white)
                                                .background(Circle().frame(width: 65, height: 65).foregroundColor(Color(self.bio ? "appearance" : "personality"))) //.shadow(color: Color(self.bio ? "appearance" : "personality"), radius: 5))
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
                                                    .font(Font.system(size: 32, weight: .heavy))
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
                            self.rating1 = false
                        }) {
                            ZStack {
                                Color(.white)
                                    .frame(width: 50, height: 50)
                                    .opacity(0)
                                Image(systemName: "chevron.left")
                                    .font(Font.system(size: 24, weight: .heavy))
                                    .foregroundColor(Color(.darkGray))
                            }
                        }//.padding(.leading, 10)
                        Spacer()
                        Button(action: {
                            self.showkeys.toggle()
                        }) {
                            HStack(spacing: 2.5) {
                                Text(String(self.observer.keys))
                                    .font(Font.custom("ProximaNova-Regular", size: 28))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.blue).opacity(0.5))
                                    .animation(nil)
                                Image("key")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(.blue).opacity(0.5))
                            }
                        }.padding(.trailing, 15)
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
                            }.padding(.all, 10).background(Color(.white).cornerRadius(15)).blur(radius: !self.observer.socialunlock ? 2: 0)
                            if !self.observer.socialunlock {
                                Image("lock")
                                    .resizable()
                                    .frame(width: 50, height: 50)
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

//MARK: Personality Traits
struct PersonalityTraitsView: View {
    @Binding var openness: [Bool]
    @Binding var conscientiousness: [Bool]
    @Binding var extraversion: [Bool]
    @Binding var agreeableness: [Bool]
    @Binding var neuroticism: [Bool]
    @State var o = false
    @State var c = false
    @State var e = false
    @State var a = false
    @State var n = false
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: self.o ? 0 : 10) {
                Image("openness")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.darkGray))
                    .padding(.leading, 5)
                    .offset(x: self.o ? 27.5 : 0)
                VStack(spacing: 5) {
                    HStack(spacing: 2.5) {
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[0] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[1] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[2] ? 0.6 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[3] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[4] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[5] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(openness[6] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                    }
                    if o {
                        HStack(alignment: .top) {
                            Text("practical calculative")
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
                        }.padding(.horizontal, 15)
                    }
                }
                Button(action: {
                    self.o.toggle()
                    self.c = false
                    self.e = false
                    self.a = false
                    self.n = false
                }) {
                    Image("info")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.darkGray))
                        .offset(x: self.o ? -27.5 : 0, y: 2.5)
                }
            }
            HStack(alignment: .top, spacing: self.c ? 0 : 10) {
                Image("conscientiousness")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.darkGray))
                    .padding(.leading, 5)
                    .offset(x: self.c ? 27.5 : 0)
                VStack(spacing: 2.5) {
                    HStack(spacing: 2.5) {
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[0] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[1] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[2] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[3] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[4] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[5] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(conscientiousness[6] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                    }
                    if c {
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
                        }.padding(.horizontal, 15)
                    }
                }
                Button(action: {
                    self.c.toggle()
                    self.o = false
                    self.e = false
                    self.a = false
                    self.n = false
                }) {
                    Image("info")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.darkGray))
                        .offset(x: self.c ? -27.5 : 0, y: 2.5)
                }
            }
            HStack(alignment: .top, spacing: self.e ? 0 : 10) {
                Image("extraversion")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.darkGray))
                    .padding(.leading, 5)
                    .offset(x: self.e ? 27.5 : 0)
                VStack(spacing: 2.5) {
                    HStack(spacing: 2.5) {
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[0] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[1] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[2] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[3] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[4] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[5] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(extraversion[6] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                    }
                    if e {
                        HStack(alignment: .top) {
                            Text("solitary reserved")
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
                        }.padding(.horizontal, 15)
                    }
                }
                Button(action: {
                    self.e.toggle()
                    self.c = false
                    self.o = false
                    self.a = false
                    self.n = false
                }) {
                    Image("info")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.darkGray))
                        .offset(x: self.e ? -27.5 : 0, y: 2.5)
                }
            }
            HStack(alignment: .top, spacing: self.a ? 0 : 10) {
                Image("agreeableness")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.darkGray))
                    .padding(.leading, 5)
                    .offset(x: self.a ? 27.5 : 0)
                
                VStack(spacing: 2.5) {
                    HStack(spacing: 2.5) {
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[0] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[1] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[2] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[3] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[4] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[5] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(agreeableness[6] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                    }
                    if a {
                        HStack(alignment: .top) {
                            Text("hostile \n critical")
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
                        }.padding(.horizontal, 15)
                    }
                }
                Button(action: {
                    self.a.toggle()
                    self.c = false
                    self.e = false
                    self.o = false
                    self.n = false
                }) {
                    Image("info")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.darkGray))
                        .offset(x: self.a ? -27.5 : 0, y: 2.5)
                }
            }
            HStack(alignment: .top, spacing: self.n ? 0 : 10) {
                Image("neuroticism")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.darkGray))
                    .padding(.leading, 5)
                    .offset(x: self.n ? 27.5 : 0)
            
                VStack(spacing: 2.5) {
                    HStack(spacing: 2.5) {
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[0] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[1] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[2] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[3] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[4] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[5] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                        Circle()
                            .strokeBorder(lineWidth: 5)
                            .foregroundColor(Color(.darkGray))
                            .frame(width: 25, height: 25)
                            .overlay(Circle().foregroundColor(Color("personality").opacity(neuroticism[6] ? 1 : 0)).frame(width: 15.5, height: 15.5))
                    }
                    if n {
                        HStack(alignment: .top) {
                            Text("secure confident")
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
                        }.padding(.horizontal, 15)
                    }
                }
                Button(action: {
                    self.n.toggle()
                    self.c = false
                    self.e = false
                    self.a = false
                    self.o = false
                }) {
                    Image("info")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.darkGray))
                        .offset(x: self.n ? -27.5 : 0, y: 2.5)
                }
            }
        }//.scaleEffect(0.9)
    }
}
