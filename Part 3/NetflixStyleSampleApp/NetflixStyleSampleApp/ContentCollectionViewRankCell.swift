//
//  ContentCollectionViewRankCell.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/15.
//

import UIKit

class ContentCollectionViewRankCell: UICollectionViewCell {
  let imageView = UIImageView()
  let rankLabel = UILabel()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // contentView
    contentView.layer.cornerRadius = 5
    contentView.clipsToBounds = true
    
    // imageView
    imageView.contentMode = .scaleToFill
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints({
      $0.top.trailing.bottom.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.8) // super view보다 조금 작게
    })
    
    // rankLabel
    rankLabel.font = .systemFont(ofSize: 100, weight: .black)
    rankLabel.textColor = .white
    contentView.addSubview(rankLabel)
    rankLabel.snp.makeConstraints({
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview().offset(25)
    })
  }
}
