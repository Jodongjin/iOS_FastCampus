//
//  ViewController.swift
//  Calculator
//
//  Created by 조동진 on 2022/01/27.
//

import UIKit

enum Operation {
  case Add
  case Subtract
  case Divide
  case Multiply
  case unknown
}

class ViewController: UIViewController {

  @IBOutlet weak var numberOutputLabel: UILabel!
  
  var displayNumber = "" // 버튼을 누를 때마다 Label에 표시될 수
  var firstOperand = "" // 첫 번째 피연산자 (이전 연산 값)
  var secondOperand = "" // 두 번째 피연산자 (새로 입력된 값)
  var result = "" // 계산의 결과 값
  var currentOperation: Operation = .unknown // 연산자
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func tapNumberButton(_ sender: UIButton) {
    guard let numberValue = sender.title(for: .normal) else { return } // 선택한 숫자 버튼의 title 값을 가져옴
    if self.displayNumber.count < 9 { // 최대 입력 가능한 자릿수 = 9
      self.displayNumber += numberValue // 문자열 더하기
      self.numberOutputLabel.text = self.displayNumber // Label에 노출
    }
  }
  
  @IBAction func tapClearButton(_ sender: UIButton) {
    self.displayNumber = ""
    self.firstOperand = ""
    self.secondOperand = ""
    self.result = ""
    self.currentOperation = .unknown
    self.numberOutputLabel.text = "0"
  }
  
  @IBAction func tapDotButton(_ sender: UIButton) {
    if self.displayNumber.count < 8, !self.displayNumber.contains(".") { // 7자리 이하이고(소수점을 표현하기 위해 최소 2자리가 있어야하기 때문) "."이 포함되어 있지 않으면 실행
      self.displayNumber += self.displayNumber.isEmpty ? "0." : "."
      self.numberOutputLabel.text = self.displayNumber
    }
  }
  
  @IBAction func tapDivideButton(_ sender: UIButton) {
    self.operation(.Divide)
  }
  
  @IBAction func tapMultiplyButton(_ sender: UIButton) {
    self.operation(.Multiply)
  }
  
  @IBAction func tapSubtractButton(_ sender: UIButton) {
    self.operation(.Subtract)
  }
  
  @IBAction func tapAddButton(_ sender: UIButton) {
    self.operation(.Add)
  }
  
  @IBAction func tapEqualButton(_ sender: UIButton) {
    self.operation(self.currentOperation)
  }
  
  func operation(_ operation: Operation) {
    if self.currentOperation != .unknown {
      if !self.displayNumber.isEmpty { // 화면이 비어있지 않으면 (숫자를 누른 후 연산자를 누른 경우)
        self.secondOperand = self.displayNumber // 화면의 수를 두 번째 피연산자에 대입
        self.displayNumber = "" // 결과를 표시한 후, 새로운 숫자를 누를 시 새롭게 누른 숫자만 표시되어야 하기 때문에 Label 초기화
        
        guard let firstOperand = Double(self.firstOperand) else { return } // firstOperand를 문자열에서 Double형으로 캐스팅한 새 상수 정의
        guard let secondOperand = Double(self.secondOperand) else { return }
        
        switch self.currentOperation {
        case .Add:
          self.result = "\(firstOperand + secondOperand)"
          
        case .Subtract:
          self.result = "\(firstOperand - secondOperand)"
          
        case .Divide:
          self.result = "\(firstOperand / secondOperand)"
          
        case .Multiply:
          self.result = "\(firstOperand * secondOperand)"
          
        default:
          break
        }
        
        if let result = Double(self.result), result.truncatingRemainder(dividingBy: 1) == 0 { // result를 Double형으로 캐스팅하고 1로 나눴을 때 나머지가 0이면
          self.result = "\(Int(result))" // Int형으로 캐스팅해서 문자열로 저장
        }
        
        self.firstOperand = self.result
        self.numberOutputLabel.text = self.result
      }
      
      self.currentOperation = operation
    } else { // currentOperation이 .unknown -> 처음 숫자를 누르고 연산자를 눌렀을 때
      self.firstOperand = self.displayNumber // 화면에 표시된 수가 첫 번째 피연산자
      self.currentOperation = operation // 선택한 operation으로 currentOperation 초기화
      self.displayNumber = "" // 화면에 표시될 문자열을 초기화하는 이유는 연산자 선택 후, 새로운 숫자만 Label에 표시되어야 하기 때문
    }
  }
  
}

