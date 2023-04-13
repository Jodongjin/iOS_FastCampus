//
//  SeguePushViewController.swift
//  ScreenTransitionExample
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit

class SeguePushViewController: UIViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  var name: String?
  
  override func viewDidLoad() { // 이 View에서 나가면 메모리에서 ViewController가 삭제되기 때문에 다시 들어오면 다시 로드됨
    super.viewDidLoad()
    print("SeguePushController 뷰가 로드 되었다.")
    if let name = name {
      self.nameLabel.text = name
      self.nameLabel.sizeToFit()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("SeguePushController 뷰가 나타날 것이다.")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("SeguePushController 뷰가 나타났다.")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("SeguePushController 뷰가 사라질 것이다.")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("SeguePushController 뷰가 사라졌다.")
  }
  
  @IBAction func tapBackButton(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
}
