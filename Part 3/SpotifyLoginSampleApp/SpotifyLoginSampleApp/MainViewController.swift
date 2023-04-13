//
//  MainViewController.swift
//  SpotifyLoginSampleApp
//
//  Created by 조동진 on 2022/02/08.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
  
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var resetPasswordButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // MainViewController 진입시 로그인 성공 상태이므로 뒤로가기가 불가능하게 설정
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // MainViewController 진입시 로그인 성공 상태이므로 back 버튼이 있는 네이게이션 바 숨기기
    navigationController?.navigationBar.isHidden = true
    
    // 로그인한 사용자의 이메일 가져오기
    let email = Auth.auth().currentUser?.email ?? "고객"
    
    welcomeLabel.text = """
    환영합니다.
    \(email)님
    """
    
    let isEmailSignIn = Auth.auth().currentUser?.providerData[0].providerID == "password"
    resetPasswordButton.isHidden = !isEmailSignIn // Email Sign In이 아니라면 버튼 숨기기
  }
  
  @IBAction func logoutButtonTapped(_ sender: UIButton) {
    let firebaseAuth = Auth.auth()
    
    do {
      try firebaseAuth.signOut()
      
      // 에러가 발생하지 않았을 때 실행
      self.navigationController?.popToRootViewController(animated: true) // 버튼을 눌렀을 때 첫 번째 화면으로 이동
    } catch let signOutError as NSError {
      print("ERROR: signout \(signOutError.localizedDescription)")
    }
  }
  
  @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
    let email = Auth.auth().currentUser?.email ?? ""
    Auth.auth().sendPasswordReset(withEmail: email, completion: nil)
  }
  
  @IBAction func profileUpdateButtonTapped(_ sender: UIButton) {
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    changeRequest?.displayName = "호랑이" // 닉네임 설정 -> 실제로는 입력 받은 값으로 업데이트
    changeRequest?.commitChanges(completion: { _ in // commit 해야 적용됨
      let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "고객" // displayName이 없다면 email, email도 없다면 "고객"
      
      self.welcomeLabel.text = """
        환영합니다.
        \(displayName)님
        """
    })
  }
}

/*
 - signOut: 로그아웃 -> 에러 처리를 위한 throw 함수이기 때문에 do try - catch 문으로 처리
 - 구글 로그인에 대한 로그아웃도 Firebase 인증값에 대한 로그아웃을 진행하기 때문에 logoutButtonTapped의 signOut 로직 그대로 두면 됨
 
 - 비밀번호 변경 기능은 소셜 로그인으로 로그인 한 사용자에게는 보이지 않게 구현 -> 업체의 사용자 정보 열람 권한을 부여받았을 뿐이기 때문에 소셜 계정의 비밀번호를 직접 변경할 수는 없음
 - 현재 User의 providerData의 providerID가 "password"라면 emailSignIn
 - Firebase를 통해 사용자의 이메일로 비밀번호 변경 url을 전송
 - sendPasswordReset: Firebase 인증에서 제공하는 사용자 관리 메서드 중 하나
 
 - logoutButtonTapped에는 각 인증 업체별 로그아웃이 아닌 Firebase 인증값에 대한 로그아웃을 진행하기 때문에 signOut 코드를 로그아웃이 일어나는 액션에 놓기만 하면 로그인 방식과는 상관없이 작동
 - 애플 로그인은 사용자 개인 정보 보호를 위해 사용자가 애플 아이디로 로그인 하고자 할 때, 이메일을 공유할지 가릴지 선택하게 함 -> 사용자가 이메일을 가린다면 애플은 사용자의 개인 이메일 주소를 숨기고 고유의 임의 이메일 주소를 공유함
 - 따라서 let email = Auth.auth().currentUser?.email ?? "고객" -> 해당 코드에서 임의의 이메일이 표시됨
 - Firebase 인증에서 제공하는 사용자 프로필 업데이트 메서드를 통해 사용자 이름 표시 구현
 - 사용자 프로필에는 displayName 외에도 email, photoUrl, phoneNumber 등의 다양한 옵션 제공 -> 프로필 화면 구현 (응용 과제)
 */
