//
//  DateViewController.swift
//  ShareProject
//
//  Created by 유태선 on 2024/06/04.
//

import UIKit

class DateViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    var message : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let message = message {
            dateLabel.text = message
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
