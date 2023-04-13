//
//  EnterEmailViewController.swift
//  SpotifyLoginSampleApp
//
//  Created by 조동진 on 2022/02/07.
//

import UIKit
import FirebaseAuth

class EnterEmailViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nextButton.layer.cornerRadius = 30
    
    nextButton.isEnabled = false
    
    emailTextField.delegate = self
    passwordTextField.delegate = self
    
    // 화면 진입시 커서가 emailTextField로 위치
    emailTextField.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Navigation Bar 보이기
    navigationController?.navigationBar.isHidden = false
  }
  
  @IBAction func nextButtonTapped(_ sender: UIButton) {
    // Firebase 이메일/비밀번호 인증
    let email = emailTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    
    // 신규 사용자 생성
    Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
      guard let self = self else { return }
      
      if let error = error { // 전달받은 데이터가 error라면 (사용자 생성 과정에서의 에러)
        let code = (error as NSError).code
        switch code {
        case 17007: // 이미 가입한 계정
          self.loginUser(withEmail: email, password: password)
        default: // 그 외 에러
          self.errorMessageLabel.text = error.localizedDescription
        }
      } else { // 에러가 없는 경우
        self.showMainViewController() // 로그인 성공시
      }
    })
  }
  
  private func showMainViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
    mainViewController.modalPresentationStyle = .fullScreen
    navigationController?.show(mainViewController, sender: nil)
  }
  
  private func loginUser(withEmail: String, password: String) {
    Auth.auth().signIn(withEmail: withEmail, password: password, completion: { [weak self] _, error in
      guard let self = self else { return }
      
      if let error = error { // 로그인 과정에서의 에러
        self.errorMessageLabel.text = error.localizedDescription
      } else {
        self.showMainViewController()
      }
    })
  }
}

extension EnterEmailViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true) // 입력이 끝나면
    return false // 키보드 내리기
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let isEmailEmpty = emailTextField.text == ""
    let isPasswordEmpty = passwordTextField.text == ""
    nextButton.isEnabled = !isEmailEmpty && !isPasswordEmpty // 둘 다 비어있지 않으면 true
  }
}

/*
 - createUser: FirebaseAuth SDK에서 제공하는 사용자 생성: 새 계정을 만들어 Firebase 인증 플랫폼에 전달 / completion: 결과값을 받음
 - createUser의 completion의 self.showMainViewController() 위 라인에 브레이크 포인트를 두고 앱을 실행하면 디버그 콘솔 왼쪽에 completion이 받은 데이터가 나옴 -> error를 받은 경우, 오른쪽 창에 po error를 입력하면 error에 대한 정보가 나옴
 
 - signIn: Firebase 인증을 통한 로그인
 */
