//
//  DiaryCell.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  
  required init?(coder: NSCoder) { // 생성자 (UIView가 Xib나 스토리보드에서 생성될 때 이 생성자를 통해 객체가 생성됨)
    super.init(coder: coder)
    self.contentView.layer.cornerRadius = 3.0 // cell의 Root View에 접근
    self.contentView.layer.borderWidth = 1.0
    self.contentView.layer.borderColor = UIColor.black.cgColor
  }
}
