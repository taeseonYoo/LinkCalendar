import UIKit
import Firebase
import FirebaseAuth

class MainViewController: UIViewController, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate , DateViewControllerDelegate{
    
    
    
    func didDismissDateViewController() {
        
        
        self.eventsDatesComponents.removeAll()
        calendarVC.reloadDecorations(forDateComponents: eventsDatesComponents, animated: false)

        calendarVC.removeFromSuperview()
        setup()
        
    }
    func setup(){
        calendarVC = UICalendarView(frame: UIScreen.main.bounds)
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarVC.selectionBehavior = selection
        calendarVC.calendar = .current
        calendarVC.locale = .current
        calendarVC.fontDesign = .rounded
        calendarVC.delegate = self
        self.view.addSubview(calendarVC)
        
        fetchCurrentUserName { [weak self] success in
            guard let self = self else { return }
            if success {
                self.fetchCalendarData()
            } else {
                print("Failed to fetch current user name")
            }
        }
    }
    
    var eventsDatesComponents: [DateComponents] = []
    var calendarVC: UICalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
        
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("Date is", dateComponents)
        guard let detailVC = self.storyboard?.instantiateViewController(identifier: "DateViewController") as? DateViewController else { return }
        
        detailVC.delegate=self
        detailVC.modalTransitionStyle = .coverVertical
        detailVC.modalPresentationStyle = .automatic
        
        let year = dateComponents?.year ?? 0
        let month = dateComponents?.month ?? 0
        let day = dateComponents?.day ?? 0
        let dateString = "\(year)/\(month)/\(day)"
        
        detailVC.message = dateString
        
        self.present(detailVC, animated: true, completion: nil)
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let customBlue = UIColor(red: 75/255.0, green: 137/255.0, blue: 220/255.0, alpha: 1.0)
        
        for eventDate in eventsDatesComponents {
            if eventDate.year == dateComponents.year && eventDate.month == dateComponents.month && eventDate.day == dateComponents.day {
                return UICalendarView.Decoration.default(color: customBlue, size: .large)
            }
        }
        return nil
    }
    
    var currentUserName = "Unknown User"
    
    func fetchCurrentUserName(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        if let currentUser = Auth.auth().currentUser {
            let userUid = currentUser.uid
            
            db.collection("User").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(false)
                } else {
                    for document in querySnapshot!.documents {
                        let uid = document.data()["uuid"] as? String
                        if uid == userUid {
                            if let sharedCalendar = document.data()["sharedCalendar"] as? String {
                                self.currentUserName = sharedCalendar
                                completion(true)
                                return
                            }
                        }
                    }
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func fetchCalendarData() {
        let db = Firestore.firestore()
        
        db.collection("Calendars").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var uniqueDates = Set<DateComponents>()
                self.eventsDatesComponents.removeAll()
                
                
                for document in querySnapshot!.documents {
                    let num = document.data()["calendar"] as? String
                    if num == self.currentUserName {
                        print("Matched Calendar")
                        
                        let calendarDocID = document.documentID
                        db.collection("Calendars").document(calendarDocID).collection("schedule").getDocuments() { (scheduleSnapshot, scheduleErr) in
                            if let scheduleErr = scheduleErr {
                                print("Error getting schedules: \(scheduleErr)")
                            } else {
                                for scheduleDoc in scheduleSnapshot!.documents {
                                    if let dateTimestamp = scheduleDoc.data()["date"] as? Timestamp {
                                        let scheduleDate = dateTimestamp.dateValue()
                                        
                                        let calendar = Calendar.current
                                        let dateComponents = calendar.dateComponents([.year, .month, .day], from: scheduleDate)
                                        
                                        // 중복 확인
                                        if !uniqueDates.contains(dateComponents) {
                                            uniqueDates.insert(dateComponents)
                                            self.eventsDatesComponents.append(dateComponents)
                                        }
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.calendarVC.reloadDecorations(forDateComponents: self.eventsDatesComponents, animated: true)
                                }
                            }
                        }
                        break
                    } else {
                        print("\(num ?? "No Calendar") and \(self.currentUserName)")
                    }
                }
            }
        }
    }
    
}

