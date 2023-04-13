//
//  StarCell.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import UIKit

class StarCell: UICollectionViewCell {
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  required init?(coder: NSCoder) { // StarViewController의 Collcetion View에 표시되는 Cell의 설정
    super.init(coder: coder)
    self.contentView.layer.cornerRadius = 3.0
    self.contentView.layer.borderWidth = 1.0
    self.contentView.layer.borderColor = UIColor.black.cgColor
  }
}
