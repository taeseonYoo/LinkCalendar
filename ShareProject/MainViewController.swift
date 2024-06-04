//
//  ViewController.swift
//  ShareProject
//
//  Created by 유태선 on 2024/05/26.
//

import UIKit

class MainViewController: UIViewController ,UICalendarSelectionSingleDateDelegate{
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("Date is",dateComponents)
        
        
        guard let detailVC = self.storyboard?.instantiateViewController(identifier: "DateViewController") as? DateViewController else { return }
                
                detailVC.modalTransitionStyle = .coverVertical
        detailVC.modalPresentationStyle = .automatic
                
                
        
        // 연, 월, 일을 추출하여 문자열로 변환
        let year = dateComponents?.year ?? 0
        let month = dateComponents?.month ?? 0
        let day = dateComponents?.day ?? 0
        let dateString = "\(year)-\(month)-\(day)"
        
        detailVC.message = dateString
        
        self.present(detailVC, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendarVC = UICalendarView(frame: UIScreen.main.bounds)
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarVC.selectionBehavior=selection
        calendarVC.calendar = .current //뷰 컨트롤러의 캘린더를 사용자의 지역의 현재 캘린더로 설정
        calendarVC.locale = .current //캘린더 뷰 컨트롤러의 지역을 사용자의 지역의 현재 지역
        calendarVC.fontDesign = . rounded //캘린더 뷰 컨트롤러의 글꼴 디자인을 둥근 것으로 설정
        self.view.addSubview(calendarVC)
    }


}

