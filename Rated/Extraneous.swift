//
//  Extraneous.swift
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
    @Published var myprofile = UserData(Age: "", Traits: [Int](), Education: [String](), Occupation1: [String](), Occupation2: [String](), Sports: [String](), Hobbies: [String](), MovieTV1: [String](), MovieTV2: [String](), Music1: [String](), Music2: [String](), StarSign: "", Politics: "", Gender: "", id: "", Name: "", Percentage: 0, ProfilePics: [String](), Rates: [String](), OverallRating: 0, AppearanceRating: 0, PersonalityRating: 0, SelfRating: 0, Socials: [String](), Report: 0, Reports: [String](), Preferences: [String]())
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
                        //let bio = document.get("Bio") as! [String]
                        let traits = document.get("Traits") as! [Int]
                        let education = document.get("Education") as! [String]
                        let occupation1 = document.get("Occupation (title)") as! [String]
                        let occupation2 = document.get("Occupation (co)") as! [String]
                        let sports = document.get("Sports") as! [String]
                        let hobbies = document.get("Hobbies") as! [String]
                        let mnt1 = document.get("MovieTV (title)") as! [String]
                        let mnt2 = document.get("MovieTV (genre)") as! [String]
                        let music1 = document.get("Music (title)") as! [String]
                        let music2 = document.get("Music (genre)") as! [String]
                        let starsign = document.get("Star Sign") as! String
                        let politics = document.get("Politics") as! String
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
                        self.myprofile = UserData(Age: age, Traits: traits, Education: education, Occupation1: occupation1, Occupation2: occupation2, Sports: sports, Hobbies: hobbies, MovieTV1: mnt1, MovieTV2: mnt2, Music1: music1, Music2: music2, StarSign: starsign, Politics: politics, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences)
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
                                    let traits = document.get("Traits") as! [Int]
                                    let education = document.get("Education") as! [String]
                                    let occupation1 = document.get("Occupation (title)") as! [String]
                                    let occupation2 = document.get("Occupation (co)") as! [String]
                                    let sports = document.get("Sports") as! [String]
                                    let hobbies = document.get("Hobbies") as! [String]
                                    let mnt1 = document.get("MovieTV (title)") as! [String]
                                    let mnt2 = document.get("MovieTV (genre)") as! [String]
                                    let music1 = document.get("Music (title)") as! [String]
                                    let music2 = document.get("Music (genre)") as! [String]
                                    let starsign = document.get("Star Sign") as! String
                                    let politics = document.get("Politics") as! String
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
                                    self.users.append(UserData(Age: age, Traits: traits, Education: education, Occupation1: occupation1, Occupation2: occupation2, Sports: sports, Hobbies: hobbies, MovieTV1: mnt1, MovieTV2: mnt2, Music1: music1, Music2: music2, StarSign: starsign, Politics: politics, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
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
                            let traits = document.get("Traits") as! [Int]
                            let education = document.get("Education") as! [String]
                            let occupation1 = document.get("Occupation (title)") as! [String]
                            let occupation2 = document.get("Occupation (co)") as! [String]
                            let sports = document.get("Sports") as! [String]
                            let hobbies = document.get("Hobbies") as! [String]
                            let mnt1 = document.get("MovieTV (title)") as! [String]
                            let mnt2 = document.get("MovieTV (genre)") as! [String]
                            let music1 = document.get("Music (title)") as! [String]
                            let music2 = document.get("Music (genre)") as! [String]
                            let starsign = document.get("Star Sign") as! String
                            let politics = document.get("Politics") as! String
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
                            self.ratesinfo.append(UserData(Age: age, Traits: traits, Education: education, Occupation1: occupation1, Occupation2: occupation2, Sports: sports, Hobbies: hobbies, MovieTV1: mnt1, MovieTV2: mnt2, Music1: music1, Music2: music2, StarSign: starsign, Politics: politics, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
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
                                let traits = document.get("Traits") as! [Int]
                                let education = document.get("Education") as! [String]
                                let occupation1 = document.get("Occupation (title)") as! [String]
                                let occupation2 = document.get("Occupation (co)") as! [String]
                                let sports = document.get("Sports") as! [String]
                                let hobbies = document.get("Hobbies") as! [String]
                                let mnt1 = document.get("MovieTV (title)") as! [String]
                                let mnt2 = document.get("MovieTV (genre)") as! [String]
                                let music1 = document.get("Music (title)") as! [String]
                                let music2 = document.get("Music (genre)") as! [String]
                                let starsign = document.get("Star Sign") as! String
                                let politics = document.get("Politics") as! String
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
                                newusers.append(UserData(Age: age, Traits: traits, Education: education, Occupation1: occupation1, Occupation2: occupation2, Sports: sports, Hobbies: hobbies, MovieTV1: mnt1, MovieTV2: mnt2, Music1: music1, Music2: music2, StarSign: starsign, Politics: politics, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
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
                        let traits = document.get("Traits") as! [Int]
                        let education = document.get("Education") as! [String]
                        let occupation1 = document.get("Occupation (title)") as! [String]
                        let occupation2 = document.get("Occupation (co)") as! [String]
                        let sports = document.get("Sports") as! [String]
                        let hobbies = document.get("Hobbies") as! [String]
                        let mnt1 = document.get("MovieTV (title)") as! [String]
                        let mnt2 = document.get("MovieTV (genre)") as! [String]
                        let music1 = document.get("Music (title)") as! [String]
                        let music2 = document.get("Music (genre)") as! [String]
                        let starsign = document.get("Star Sign") as! String
                        let politics = document.get("Politics") as! String
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
                        self.myprofile = UserData(Age: age, Traits: traits, Education: education, Occupation1: occupation1, Occupation2: occupation2, Sports: sports, Hobbies: hobbies, MovieTV1: mnt1, MovieTV2: mnt2, Music1: music1, Music2: music2, StarSign: starsign, Politics: politics, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences)
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
                            let traits = document.get("Traits") as! [Int]
                            let education = document.get("Education") as! [String]
                            let occupation1 = document.get("Occupation (title)") as! [String]
                            let occupation2 = document.get("Occupation (co)") as! [String]
                            let sports = document.get("Sports") as! [String]
                            let hobbies = document.get("Hobbies") as! [String]
                            let mnt1 = document.get("MovieTV (title)") as! [String]
                            let mnt2 = document.get("MovieTV (genre)") as! [String]
                            let music1 = document.get("Music (title)") as! [String]
                            let music2 = document.get("Music (genre)") as! [String]
                            let starsign = document.get("Star Sign") as! String
                            let politics = document.get("Politics") as! String
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
                            self.ratesinfo.append(UserData(Age: age, Traits: traits, Education: education, Occupation1: occupation1, Occupation2: occupation2, Sports: sports, Hobbies: hobbies, MovieTV1: mnt1, MovieTV2: mnt2, Music1: music1, Music2: music2, StarSign: starsign, Politics: politics, Gender: gender, id: id, Name: name, Percentage: percentage, ProfilePics: profilepics, Rates: rates, OverallRating: overallrating, AppearanceRating: appearancerating, PersonalityRating: personalityrating, SelfRating: selfrating, Socials: socials, Report: report, Reports: reports, Preferences: preferences))
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

//MARK: CreateUser2
func CreateUser2(name: String, bdate: String, gender: String, percentage: Double, overallrating: Double, appearancerating: Double, personalityrating: Double, profilepics: [Data], traits: [Int], education: [String], occupation1: [String], occupation2: [String], sports: [String], hobby: [String], mnt1: [String], mnt2: [String], music1: [String], music2: [String], starsign: String, politics: String, socials: [String], complete: @escaping (Bool)-> Void) {
    print("bruh")
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid = Auth.auth().currentUser?.uid
    var images = [String]()
    
    db.collection("users").document(uid!).setData(["Name": name, "Birthdate": bdate, "Gender": gender, "Percentage": percentage, "SelfRating": overallrating, "SelfARating": appearancerating, "SelfPRating": personalityrating, "ProfilePics": [String](), "Rates": [String](), "OverallRating": overallrating, "AppearanceRating": appearancerating, "PersonalityRating": personalityrating, "ID": uid!, "Lock": [Bool](), "Keys": 0, "Comments": [String](), "Socials": socials, "Report": 0, "Preferences": ["Everyone", "Everyone", "18-99"], "Reports": [String](), "Reported": [Bool](), "Traits": traits, "Education": education, "Occupation (title)": occupation1, "Occupation (co)": occupation2, "Sports": sports, "Hobbies": hobby, "MovieTV (title)": mnt1,  "MovieTV (genre)": mnt2, "Music (title)": music1, "Music (genre)": music2, "Star Sign": starsign, "Politics": politics]) { (err) in
        if err != nil{
            print((err?.localizedDescription)!)
            complete(false)
            return
        }
    }
    for num in 0...3 {
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
                    complete(true)
                }
            }
        }
    }
    print("bruh2")
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
                if UserDefaults.standard.value(forKey: "notsignedup") as? Bool ?? true{
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
                                .fixedSize(horizontal: true, vertical: true)
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
                    .foregroundColor(Color(.darkGray))
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
    //var Bio: [String]
    var Traits: [Int]
    var Education: [String]
    var Occupation1: [String]
    var Occupation2: [String]
    var Sports: [String]
    var Hobbies: [String]
    var MovieTV1: [String]
    var MovieTV2: [String]
    var Music1: [String]
    var Music2: [String]
    var StarSign: String
    var Politics: String
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
