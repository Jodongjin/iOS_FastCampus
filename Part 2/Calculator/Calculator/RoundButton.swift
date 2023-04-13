//
//  RoundButton.swift
//  Calculator
//
//  Created by 조동진 on 2022/01/27.
//

import UIKit

// UIButton을 상속하는 RoundButton (커스텀 버튼) 정의
// RoundButton은 스토리보드에서 isRound 속성을 변경시킬 수 있음
// @IBDesignable은 빌드 후에 스토리보드에 결과가 반영됨 -> @IBDesignable을 남용하면 스토리보드를 열 때마다 빌드가 돼서 렉 걸릴 수 있음

//@IBDesignable // 변경된 설정값을 스토리보드에서 실시간으로 확인할 수 있게 @IBDesignable 어노테이션
class RoundButton: UIButton { // 기존 UIButton의 속성들을 그대로 사용할 수 있고, 사용자가 원하는 속성들을 클래스에 정의 가능
  @IBInspectable var isRound: Bool = false { // 연산 프로퍼티, @IBInspectable 키워드를 어노테이션을 통해 스토리보드에서도 isRound 프로퍼티의 설정값을 변경할 수 있게 함
    didSet { // 프로퍼티 감시자
      if isRound {
        self.layer.cornerRadius = self.frame.height / 2 // 버튼의 cornerRadius 값을 버튼의 높이를 2로 나눈 값으로 설정 -> 정사각형은 원, 직사각형은 모서리가 둥글게 변함
      }
    }
  }

}
