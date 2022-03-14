//
//  ErrorMessage.swift
//  Weather
//
//  Created by 조동진 on 2022/02/05.
//

import Foundation

struct ErrorMessage: Codable {
  let message: String
} // 잘못된 도시를 입력했을 때 전달 받는 에러 메시지(JSON 객체)를 매핑하는 구조체
