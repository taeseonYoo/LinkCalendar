import UIKit
import FirebaseFirestore
import FirebaseAuth

class DateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    //    var dataArray = [String]()
    var currentUserName = "Unknown User"
    var userName = "na"
    
    
    
    weak var delegate: DateViewControllerDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.didDismissDateViewController()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//선택되었을 때
        print("\(dataArray[indexPath.row])가 선택되었습니다")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let changeScheduleVC = storyboard.instantiateViewController(withIdentifier: "ChangeViewController") as? ChangeViewController {
            
            changeScheduleVC.delegate=self
            changeScheduleVC.chooseSchedule=dataArray[indexPath.row]
            // 모달로 뷰 컨트롤러 표시하기
            self.present(changeScheduleVC, animated: true, completion: nil)
        }
    }
    // UITableViewDelegate 메서드
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .delete
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                print("\(dataArray[indexPath.row])가 선택되었습니다")
                
                
                
                let db = Firestore.firestore()
                
                db.collection("Calendars").document(dataArray[indexPath.row].calendarNum).collection("schedule").document(dataArray[indexPath.row].documentID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("\(self.dataArray[indexPath.row])가 삭제되었습니다")
                        self.dataArray.remove(at: indexPath.row) // 배열에서도 해당 데이터를 삭제합니다.
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        
                    }
                }

                tableView.reloadData()
            }
        }
    
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
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
                            if let name = document.data()["name"] as? String{
                                self.userName = name
                            }
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
                                                let event = CalendarEvent(title: title, description: description, author: author,documentID: scheduleDoc.documentID,calendarNum: calendarDocID)
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
    
    @IBAction func addSchedule(_ sender: UIButton) {
        // 스토리보드 인스턴스 가져오기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // AddScheduleViewController 인스턴스 생성하기
        if let addScheduleVC = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController {
            addScheduleVC.delegate = self
            var tmp = Schedule(scheduleNum: "", date: "", authors: "")
            tmp.scheduleNum=currentUserName
            tmp.date=message ?? "2024/01/01"
            tmp.authors=self.userName
            
            addScheduleVC.schedule=tmp
            // 모달로 뷰 컨트롤러 표시하기
            self.present(addScheduleVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func BackController(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        
    }
    
    
}

extension DateViewController: AddScheduleViewControllerDelegate {
    func didAddSchedule() {
        fetchCurrentUserName { [weak self] success in
            guard let self = self else { return }
            if success {
                self.fetchCalendarData()
            } else {
                print("Failed to fetch current user name")
            }
        }
        
        self.tableView.reloadData()
        
        
    }
}
extension DateViewController: ChangeViewControllerDelegate{
    func didAddschedule(){
        fetchCurrentUserName { [weak self] success in
            guard let self = self else { return }
            if success {
                self.fetchCalendarData()
            } else {
                print("Failed to fetch current user name")
            }
        }
        
        self.tableView.reloadData()
    }
}

protocol DateViewControllerDelegate:AnyObject{
    func didDismissDateViewController()
}
