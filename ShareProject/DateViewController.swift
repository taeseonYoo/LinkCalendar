import UIKit
import FirebaseFirestore
import FirebaseAuth

class DateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    //    var dataArray = [String]()
    var currentUserName = "Unknown User"
    
    struct CalendarEvent {
        var title: String
        var description: String
        var author: String
    }
    
    // dataArray의 타입을 변경합니다.
    var dataArray = [CalendarEvent]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        let event = dataArray[indexPath.row]
        
        cell.titleLabel.text = event.title
        cell.descriptionLabel.text = event.description
        cell.authorLabel.text = event.author
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(dataArray[indexPath.row])가 선택되었습니다")
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        
        if let message = message {
            dateLabel.text = message
        }
        
        fetchCurrentUserName { [weak self] success in
            guard let self = self else { return }
            if success {
                self.fetchCalendarData()
            } else {
                print("Failed to fetch current user name")
            }
        }
    }
    
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
                self.dataArray.removeAll()
                
                for document in querySnapshot!.documents {
                    let num = document.data()["calendar"] as? String
                    if num == self.currentUserName {
                        print("Matched Calendar")
                        
                        // message를 Date로 변환
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd" // message의 날짜 형식에 맞게 설정
                        guard let messageDate = dateFormatter.date(from: self.message ?? "") else {
                            print("Error parsing message date")
                            return
                        }
                        
                        // 여기서 schedule 서브 컬렉션을 조회합니다.
                        let calendarDocID = document.documentID
                        db.collection("Calendars").document(calendarDocID).collection("schedule").getDocuments() { (scheduleSnapshot, scheduleErr) in
                            if let scheduleErr = scheduleErr {
                                print("Error getting schedules: \(scheduleErr)")
                            } else {
                                for scheduleDoc in scheduleSnapshot!.documents {
                                    if let dateTimestamp = scheduleDoc.data()["date"] as? Timestamp {
                                        let scheduleDate = dateTimestamp.dateValue()
                                        
                                        // messageDate와 scheduleDate를 비교하여 같은 경우에만 데이터를 추가
                                        if Calendar.current.isDate(scheduleDate, inSameDayAs: messageDate) {
                                            if let title = scheduleDoc.data()["title"] as? String, let description = scheduleDoc.data()["description"] as? String, let author = scheduleDoc.data()["authors"] as? String {
                                                let event = CalendarEvent(title: title, description: description, author: author)
                                                self.dataArray.append(event)
                                            }
                                        }
                                    }
                                }
                                self.tableView.reloadData() // 데이터를 가져온 후 tableView를 리로드합니다.
                            }
                        }
                        break
                    } else {
                        print("\(num ?? "No Calendar") and \(self.currentUserName)")
                    }
                }
                //                self.tableView.reloadData() // 데이터를 가져온 후 tableView를 리로드합니다.
            }
        }
    }
}

