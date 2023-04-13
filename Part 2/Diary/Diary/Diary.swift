//
//  Diary.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import Foundation

struct Diary {
  var uuidString: String // Diary 객체의 고유 값
  var title: String
  var contents: String
  var date: Date
  var isStar: Bool // 즐겨찾기 여부
}
