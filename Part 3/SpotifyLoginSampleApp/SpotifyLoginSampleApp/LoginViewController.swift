//
//  LoginViewController.swift
//  SpotifyLoginSampleApp
//
//  Created by 조동진 on 2022/02/07.
//

import UIKit
import Firebase
import GoogleSignIn

// import FirebaseAuth
// import AuthenticationServices -> 이 객체를 통해 애플 아이디 인증값을 받고 전달 가능
// import CryptoKit -> 해쉬값 추가 코드를 위한 import

class LoginViewController: UIViewController {
  
  @IBOutlet weak var emailLoginButton: UIButton!
  @IBOutlet weak var googleLoginButton: GIDSignInButton! // Firebase 인증에서 제공하는 type으로 변경
  @IBOutlet weak var appleLoginButton: UIButton!
  
  // private var currentNonce: String
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    [emailLoginButton, googleLoginButton, appleLoginButton].forEach {
      $0?.layer.borderWidth = 1
      $0?.layer.borderColor = UIColor.white.cgColor
      $0?.layer.cornerRadius = 30
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Navigation Bar 숨기기
    navigationController?.navigationBar.isHidden = true
  }
  
  @IBAction func googleLoginButtonTapped(_ sender: UIButton) {
    // Firebase 인증
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    let config = GIDConfiguration(clientID: clientID)
    
    // Google Sign In / presenting: 웹 뷰를 띄울 View Controller
    GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
      if let error = error { // 에러를 받았다면
          print("ERROR", error.localizedDescription)
        return
      }

      guard let authentication = user?.authentication, // 인증 값과
            let idToken = authentication.idToken else { return } // 토큰을 받았다면

      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken) // 구글 아이디 토큰, 엑세스 토큰을 부여 받음

        Auth.auth().signIn(with: credential) { _, _ in // _, _: result value, error value
            self.showMainViewController()
        }
    }
  }
  
  private func showMainViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
    mainViewController.modalPresentationStyle = .fullScreen
    UIApplication.shared.windows.first?.rootViewController?.show(mainViewController, sender: nil) // 루트 뷰 컨트롤러에서 MainViewController로 이동
  }
  
  @IBAction func appleLoginButtonTapped(_ sender: UIButton) {
    // startSignInWithAppleFlow() // 애플 로그인 화면 출력
  }
}

/*
 extension LoginViewController: ASAuthorizationControllerDelegate {
     func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
         if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
             guard let nonce = currentNonce else {
                 fatalError("Invalid state: A login callback was received, but no login request was sent.")
             }
             guard let appleIDToken = appleIDCredential.identityToken else {
                 print("Unable to fetch identity token")
                 return
             }
             guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                 print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                 return
             }
             
             let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
             
             Auth.auth().signIn(with: credential) { authResult, error in
                 if let error = error {
                     print ("Error Apple sign in: %@", error)
                     return
                 }
                 // User is signed in to Firebase with Apple.
                 // ...
                 ///Main 화면으로 보내기
                 let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                 let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController")
                 mainViewController.modalPresentationStyle = .fullScreen
                 self.navigationController?.show(mainViewController, sender: nil)
             }
         }
     }
 }
 */

/*
 - 암호화된 nonce를 생성하는 과정
 - sha256, randomNonceString 등은 Firebase에서 nonce를 생성하기 위해 제공하는 코드
 - startSignInWithAppleFlow: 애플에 인증값을 요청할 때, request를 생성하여 전달 -> request에 nonce가 포함되어 릴레이 공격을 방지하고 추후 Firebase에서도 무결성 확인
 //Apple Sign in
 extension LoginViewController {
     func startSignInWithAppleFlow() {
         let nonce = randomNonceString()
         currentNonce = nonce
         let appleIDProvider = ASAuthorizationAppleIDProvider()
         let request = appleIDProvider.createRequest()
         request.requestedScopes = [.fullName, .email]
         request.nonce = sha256(nonce)
         
         let authorizationController = ASAuthorizationController(authorizationRequests: [request])
         authorizationController.delegate = self
         authorizationController.presentationContextProvider = self
         authorizationController.performRequests()
     }
     
     private func sha256(_ input: String) -> String {
         let inputData = Data(input.utf8)
         let hashedData = SHA256.hash(data: inputData)
         let hashString = hashedData.compactMap {
             return String(format: "%02x", $0)
         }.joined()
         
         return hashString
     }
     
     // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
     private func randomNonceString(length: Int = 32) -> String {
         precondition(length > 0)
         let charset: Array<Character> =
             Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
         var result = ""
         var remainingLength = length
         
         while remainingLength > 0 {
             let randoms: [UInt8] = (0 ..< 16).map { _ in
                 var random: UInt8 = 0
                 let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                 if errorCode != errSecSuccess {
                     fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                 }
                 return random
             }
             
             randoms.forEach { random in
                 if remainingLength == 0 {
                     return
                 }
                 
                 if random < charset.count {
                     result.append(charset[Int(random)])
                     remainingLength -= 1
                 }
             }
         }
         
         return result
     }
 }

 extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
     func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
         return self.view.window!
     }
 }

 */

/*
 - GIDSignInButton: UIButton을 상속하며 구글 로그인을 실행시켜주는 GoogleSignIn SDK의 객체
 - Google Sign In을 진행하기 위해 로그인을 진행 할 웹 뷰가 필요하고 해당 뷰를 띄울 뷰 컨트롤러 선언이 필요
 - GIDSignIn.sharedInstance.signIn 호출을 통해 구글 아이디 토큰과 구글 엑세스 토큰을 받았지만 이를 Firebase 사용자 인증 정보로 등록하는 과정 필요
 - 구글 아이디로 Auth.auth().signIn()을 호출할 경우 with에 credential을 전달
 
 - 애플 아이디 로그인 구현은 모두 주석처리로 구현
 - 애플 아이디 로그인 시 아래에 뜨는 창을 AS Authrization Controller라고 함 (AS: AuthenticationServices)
 - Nonce: 암호화된 임의의 난수 / 단 한 번만 사용할 수 있는 값 / 주로 암호화 통신을 할 때 사용 ex) 패스워드 정보 등 / 동일한 요청을 짧은 시간에 여러 번 보내는 릴레이 공격 방지 / 정보 탈취 없이 안전하게 인증 정보 전달을 위한 안전 장치 -> credential을 생성할 때 인자로 전달
 - 애플 계정 로그인에서 nonce 값은 앱에서 애플 계정으로, 애플 계정에서 Firebase로 전달되는 과정에서 릴레이 공격이나 로그인 정보 탈취 없이 안전하게 인증 정보가 전달되게 하기 위해 사용됨
 - 애플에 권한 요청을 할 때 전달될 해쉬 nonce 프로퍼티 정의
 - authorizationController: ASAuthorizationController를 통해 로그인 요청 -> 애플에서 appleIDCredential(appleIDToken, idToken)을 제공 -> Token들로 credential을 만들어 Firebase Auth에서 제공하는 signIn()으로 전달
 
 * Apple Sign In은 시뮬레이터에서 제대로 동작하지 않음 -> 실제 기기로 연결하여 작동 확인
 */
