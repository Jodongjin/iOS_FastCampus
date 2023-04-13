//
//  ViewController.swift
//  LEDBoard
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit

class ViewController: UIViewController, LEDBoardSettingDelegate {

  @IBOutlet weak var contentsLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.contentsLabel.textColor = .yellow
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // 다음 View로 넘어가기 전에 다음 ViewController의 delegate를 받고, 현재 View에 설정된 값들을 전달
    if let settingViewController = segue.destination as? SettingViewController {
      settingViewController.delegate = self
      settingViewController.ledText = self.contentsLabel.text
      settingViewController.textColor = self.contentsLabel.textColor
      settingViewController.backgroundColor = self.view.backgroundColor ?? .black // 옵셔널
    }
  }
  
  func changedSetting(text: String?, textColor: UIColor, backgroundColor: UIColor) {
    if let text = text {
      self.contentsLabel.text = text
    }
    self.contentsLabel.textColor = textColor
    self.view.backgroundColor = backgroundColor
  }

}

