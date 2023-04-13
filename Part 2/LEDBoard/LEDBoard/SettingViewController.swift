//
//  SettingViewController.swift
//  LEDBoard
//
//  Created by 조동진 on 2022/01/26.
//

import UIKit

protocol LEDBoardSettingDelegate: AnyObject { // delegate pattern을 위한 protocol 정의
  func changedSetting(text: String?, textColor: UIColor, backgroundColor: UIColor)
}

class SettingViewController: UIViewController {
  
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var yellowButton: UIButton!
  @IBOutlet weak var purpleButton: UIButton!
  @IBOutlet weak var greenButton: UIButton!
  
  @IBOutlet weak var blackButton: UIButton!
  @IBOutlet weak var blueButton: UIButton!
  @IBOutlet weak var orangeButton: UIButton!
  
  weak var delegate: LEDBoardSettingDelegate? // delegate 프로퍼티 추가
  var textColor: UIColor = .yellow // 이전 ViewController에 데이터를 전달하고 전달받을 변수
  var backgroundColor: UIColor = .black
  
  var ledText: String? // 이전 ViewController에서 데이터를 전달받을 변수
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureView()
  }
  
  private func configureView() {
    if let ledText = self.ledText {
      self.textField.text = ledText
    }
    self.changeTextColorButton(color: self.textColor)
    self.changeBackgroundColorButton(color: self.backgroundColor)
  }
  
  @IBAction func tapTextColorButton(_ sender: UIButton) { // 어떤 버튼이 클릭되었는지는 sender parameter로 알 수 있음(선택된 버튼의 인스턴스가 담김)
    if sender == self.yellowButton {
      self.changeTextColorButton(color: .yellow)
      self.textColor = .yellow
    } else if sender == self.purpleButton {
      self.changeTextColorButton(color: .purple)
      self.textColor = .purple
    } else {
      self.changeTextColorButton(color: .green)
      self.textColor = .green
    }
  }
  
  @IBAction func tapBackgroundColorButton(_ sender: UIButton) {
    if sender == self.blackButton {
      self.changeBackgroundColorButton(color: .black)
      self.backgroundColor = .black
    } else if sender == blueButton {
      self.changeBackgroundColorButton(color: .blue)
      self.backgroundColor = .blue
    } else {
      self.changeBackgroundColorButton(color: .orange)
      self.backgroundColor = .orange
    }
  }
  
  @IBAction func tapSaveButton(_ sender: UIButton) {
    self.delegate?.changedSetting(text: self.textField.text, textColor: self.textColor, backgroundColor: self.backgroundColor) // 이전 View로 넘어가기 전에 설정된 값들을 전달
    self.navigationController?.popViewController(animated: true)
  }
  
  private func changeTextColorButton(color: UIColor) { // color로 전달된 색상에 해당되는 버튼만 alpha 값 = 1, 나머지 버튼의 alpha 값 = 2
    self.yellowButton.alpha = color == UIColor.yellow ? 1 : 0.2
    self.purpleButton.alpha = color == UIColor.purple ? 1 : 0.2
    self.greenButton.alpha = color == UIColor.green ? 1 : 0.2
  }
  
  private func changeBackgroundColorButton(color: UIColor) {
    self.blackButton.alpha = color == UIColor.black ? 1 : 0.2
    self.blueButton.alpha = color == UIColor.blue ? 1 : 0.2
    self.orangeButton.alpha = color == UIColor.orange ? 1 : 0.2
  }
}
