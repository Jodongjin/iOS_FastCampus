//
//  ContentCollectionViewHeader.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/15.
//

import UIKit

// 섹션 헤더 정의 (UICollectionReusableView Type 이어야 헤더 또는 푸터가 될 수 있음)
class ContentCollectionViewHeader: UICollectionReusableView {
  let sectionNameLabel = UILabel()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    sectionNameLabel.font = .systemFont(ofSize: 17, weight: .bold)
    sectionNameLabel.textColor = .white
    sectionNameLabel.sizeToFit()
    
    addSubview(sectionNameLabel) // Label 추가
    
    sectionNameLabel.snp.makeConstraints({
      $0.centerY.equalToSuperview()
      $0.top.bottom.leading.equalToSuperview().offset(10) // 10 만큼 띄우기
    })
  }
}
