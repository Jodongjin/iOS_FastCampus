//
//  CodePresentViewController.swift
//  ScreenTransitionExample
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit



class CodePresentViewController: UIViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  var name: String?
  weak var delegate: SendDataDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let name = name {
      self.nameLabel.text = name
      self.nameLabel.sizeToFit()
    }
  }
  
  @IBAction func tapBackButton(_ sender: UIButton) {
    self.delegate?.sendData(name: "Dong jin")
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
