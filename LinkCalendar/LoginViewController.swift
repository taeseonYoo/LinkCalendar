//
//  LoginViewController.swift
//  ShareProject
//
//  Created by 유태선 on 2024/05/26.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func LoginButton(_ sender: UIButton) {
        let email: String = emailTextField.text!.description
                let pw: String = pwTextField.text!.description
        
        Auth.auth().signIn(withEmail: email, password: pw) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            // ...
            if authResult != nil {
                print("로그인 성공")
                guard let TabViewController = self?.storyboard?.instantiateViewController(withIdentifier: "TabController") as? UITabBarController else { return }
                // 화면 전환 애니메이션 설정
                TabViewController.modalTransitionStyle = .coverVertical
                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
                TabViewController.modalPresentationStyle = .fullScreen
                self?.present(TabViewController, animated: true, completion: nil)
                self!.emailTextField.text=""
                self!.pwTextField.text=""
            } else {
                print("로그인 실패")
                print(error.debugDescription)
                
            }
            
        }
    }
    
}
