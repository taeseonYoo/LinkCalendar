//
//  SetViewController.swift
//  ShareProject
//
//  Created by 유태선 on 2024/06/04.
//

import UIKit

class SetViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sectionHeader = ["내 정보", "캘린더"]
    
    var cellDataSource = [
            ["마이 페이지", "멤버 정보"], // 첫 번째 섹션의 데이터
            ["캘린더 정보", "캘린더 이미지","일정 관리"] // 두 번째 섹션의 데이터
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        
    }
    
}

extension SetViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Section

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeader.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeader[section]
    }

    // MARK: - Row Cell

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = cellDataSource[indexPath.section][indexPath.row]
        return cell
    }
}
