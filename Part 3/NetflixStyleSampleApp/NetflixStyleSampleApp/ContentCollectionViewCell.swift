//
//  ContentCollectionViewCell.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/15.
//

import UIKit
import SnapKit

// 커스텀 셀
class ContentCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  // sub view 올리기
  override func layoutSubviews() {
    super.layoutSubviews()
    
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 5
    contentView.clipsToBounds = true
    
    imageView.contentMode = .scaleToFill // image 표현 방식
    
    contentView.addSubview(imageView) // contentView에 imageView 추가 (storyboard에서 component를 추가하는 것)
    
    // image View의 오토 레이아웃 설정 (SnapKit 사용)
    imageView.snp.makeConstraints({
      $0.edges.equalToSuperview() // imageView의 superView인 contentView에 딱 맞게 레이아웃 설정
    })
  }
}

/*
 - UICollectionViewCell의 경우 self.backgroundColor를 설정한다고 실제 레이아웃에 표현되지 않음
   셀의 레이아웃은 기본 셀이 있고 contentView라는 기본 객체가 있는 형태 -> contentView를 super view로 보고 이 위에 sub view들을 올림
 */
