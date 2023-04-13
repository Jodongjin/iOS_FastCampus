//
//  ViewController.swift
//  ScreenTransitionExample
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit

class ViewController: UIViewController, SendDataDelegate { // 위임자의 Protocol 채택

  @IBOutlet weak var nameLabel: UILabel!
  
  override func viewDidLoad() { // 루트 View이기 때문에 한 번만 호출됨 (더 이상 뒤로 갈 수 없음)
    super.viewDidLoad()
    print("ViewController 뷰가 로드 되었다.")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("ViewController 뷰가 나타날 것이다.")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("ViewController 뷰가 나타났다.")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("ViewController 뷰가 사라질 것이다.")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("ViewController 뷰가 사라졌다.")
  }
  
  @IBAction func tapCodePushButton(_ sender: UIButton) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CodePushViewController") as? CodePushViewController else { return } // 스토리보드에 있는 ViewController를 인스턴스화, 실제 클래스인 CodePushViewController로 다운캐스팅하여 해당 ViewController의 프로퍼티에 접근 -> 데이터를 전달할 수 있음
    viewController.name = "Dong jin" // 화면이 넘어가기 전에 넘어갈 ViewController의 프로퍼티에 데이터 전달
    viewController.delegate = self // CodePushViewController의 delegate 멤버를 self로 초기화하면 delegate를 위임받게 됨 (SendDataDelegate Protocol을 채택해야함)
    self.navigationController?.pushViewController(viewController, animated: true) // navigation stack에 새로운 화면이 Push
    
  }
  
  @IBAction func tapCodePresentButton(_ sender: UIButton) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CodePresentViewController") as? CodePresentViewController else { return }
    viewController.modalPresentationStyle = .fullScreen
    viewController.name = "Dong jin"
    viewController.delegate = self
    self.present(viewController, animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // Segue를 실행하기 직전에 시스템에 의해 호출됨
    if let viewController = segue.destination as? SeguePushViewController { // 선택한 Segue 객체가 SeguePushViewController 라면
      viewController.name = "Dong jin"
    } else if let viewController = segue.destination as? SeguePresentViewController { // 선택한 Segue 객체가 SeguePresentViewController라면
      viewController.name = "Dong jin"
    }
  }
  
  func sendData(name: String) { // Protocol SendDataDelegate, SendDataDelegate2를 준수하기 위한 메서드
    self.nameLabel.text = name
    self.nameLabel.sizeToFit()
  }
}

