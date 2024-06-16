//
//  ChangeViewController.swift
//  ShareProject
//
//  Created by 유태선 on 2024/06/09.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChangeViewController: UIViewController {
    var chooseSchedule : CalendarEvent?
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var destextView: UITextView!
    weak var delegate: ChangeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        titleTextField.text=chooseSchedule?.title
        destextView.text=chooseSchedule?.description
        // Do any additional setup after loading the view.
        
        destextView.layer.borderColor = UIColor(hex: "#4B89DC").cgColor
        titleTextField.layer.borderColor = UIColor(hex: "#4B89DC").cgColor // 원하는 색상으로 변경
        titleTextField.layer.borderWidth = 1.0 // 테두리 두께 설정
        titleTextField.layer.cornerRadius = 5.0 // 필요 시 모서리 둥글게 설정
        
        
    }
    
    @IBAction func changeData(_ sender: UIButton) {
        updateCalendarEvent()
        self.delegate?.didAddSchedule()
        self.dismiss(animated: true)
        
    }
    
    func updateCalendarEvent() {
        let db = Firestore.firestore()
        
        db.collection("Calendars").document(chooseSchedule!.calendarNum).collection("schedule").document(chooseSchedule!.documentID).updateData([
            "title": titleTextField.text,
            "description": destextView.text
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    
    
    @IBAction func BackContoller(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    
}
protocol ChangeViewControllerDelegate: AnyObject {
    func didAddSchedule()
}
