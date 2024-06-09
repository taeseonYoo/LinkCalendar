

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AddScheduleViewController: UIViewController {
    var titleText: String?
    var descriptionText: String?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    weak var delegate: AddScheduleViewControllerDelegate?

    var schedule : Schedule?
    
    var num : String = ""
    var date : String = ""
    var authors : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let schedule = schedule {
            print("Schedule Num: \(schedule.scheduleNum)")
            print("Date: \(schedule.date)")
            print("Authors: \(schedule.authors)")
            num = schedule.scheduleNum
            date = schedule.date
            authors = schedule.authors
            
        }
        
        
        textView.layer.borderColor = UIColor(hex: "#4B89DC").cgColor
        textField.layer.borderColor = UIColor(hex: "#4B89DC").cgColor // 원하는 색상으로 변경
        textField.layer.borderWidth = 1.0 // 테두리 두께 설정
        textField.layer.cornerRadius = 5.0 // 필요 시 모서리 둥글게 설정
        
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd" // 문자열의 날짜 형식과 일치해야 합니다.
        return dateFormatter.date(from: dateString)
    }
    
    func convertDateToTimestamp(_ date: Date) -> Timestamp {
        return Timestamp(date: date)
    }
    
    @IBAction func addSchedule(_ sender: UIButton) {
        titleText = textField.text
        descriptionText = textView.text
        
        
        let db = Firestore.firestore()
        db.collection("Calendars").whereField("calendar", isEqualTo: num).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let scheduleRef = db.collection("Calendars").document(document.documentID).collection("schedule")
                    
                    // date가 빈 문자열이 아닌지 확인합니다.
                    if !self.date.isEmpty {
                        if let dateObject = self.convertStringToDate(self.date) {
                            let timestamp = self.convertDateToTimestamp(dateObject)
                            
                            scheduleRef.addDocument(data: [
                                "title": self.titleText!,
                                "description": self.descriptionText!,
                                "authors": self.authors,
                                "date": timestamp
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(scheduleRef.collectionID)")
                                    self.delegate?.didAddSchedule()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

protocol AddScheduleViewControllerDelegate: AnyObject {
    func didAddSchedule()
}

