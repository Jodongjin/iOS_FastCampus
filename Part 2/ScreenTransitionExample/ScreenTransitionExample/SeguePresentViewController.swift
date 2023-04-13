//
//  SeguePresentViewController.swift
//  ScreenTransitionExample
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit

class SeguePresentViewController: UIViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  var name: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let name = name {
      self.nameLabel.text = name
      self.nameLabel.sizeToFit()
    }
  }
  
  @IBAction func tapBackButton(_ sender: UIButton) {
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
