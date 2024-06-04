import UIKit
import FirebaseFirestore
import FirebaseAuth

class DateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [String]()
    var currentUserName = "Unknown User"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
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
                        self.dataArray = document.data()["members"] as? [String] ?? ["No Members"]
                        break
                    } else {
                        print("\(num ?? "No Calendar") and \(self.currentUserName)")
                    }
                }
                self.tableView.reloadData() // 데이터를 가져온 후 tableView를 리로드합니다.
            }
        }
    }
}

