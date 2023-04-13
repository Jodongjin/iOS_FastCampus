//
//  CodePushViewController.swift
//  ScreenTransitionExample
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit

protocol SendDataDelegate: AnyObject {
  func sendData(name: String)
}

class CodePushViewController: UIViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  var name: String?
  weak var delegate: SendDataDelegate? // delegate pattern을 사용할 때, delegate 변수 앞에는 weak 키워드를 붙여야함, 안 붙이면 강한순환참조 발생으로 메모리 누수
  // delegate란? 일을 위임하는 위임자를 의미, 위임자를 갖고 있는 객체가 다른 객체에게 자신의 일을 위임 (이전화면에 데이터를 위임하는 데 사용)
  // 위임자 ViewController에서 Protocol을 정의하고 해당 Protocol의 인스턴스를 만들어 정의된 함수를 호출 -> 위임받는 ViewController에서 위임자의 Protocol 변수를 self로 초기화하여 위임을 받음 -> Protocol을 채택하고 준수하여 위임된 일을 실행
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let name = name { // name이 nil이 아니라면(ViewController에서 데이터를 넣었다면), name에 대입하고
      self.nameLabel.text = name // nameLabel에 setting
      self.nameLabel.sizeToFit() // 글자 안 잘리게 하는 메서드
    }
  }
  
  @IBAction func tapBackButton(_ sender: UIButton) {
    self.delegate?.sendData(name: "Dong jin") // pop되기 전에 데이터를 전달 -> 데이터를 전달받은 ViewController에서 SendDataDelegate Protocol을 채택하고, delegate를 위임받게 되면 이전화면 ViewController에서 정의된 sendData 메서드가 실행됨
    self.navigationController?.popViewController(animated: true)
  }
}
