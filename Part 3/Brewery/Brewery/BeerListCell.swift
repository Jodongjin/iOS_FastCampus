//
//  BeerListCell.swift
//  Brewery
//
//  Created by 조동진 on 2022/02/16.
//

import UIKit
import SnapKit
import Kingfisher

class BeerListCell: UITableViewCell {
  let beerImageView = UIImageView()
  let nameLabel = UILabel()
  let taglineLabel = UILabel()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    [beerImageView, nameLabel, taglineLabel].forEach {
      contentView.addSubview($0)
    }
    
    beerImageView.contentMode = .scaleAspectFit
    
    nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
    nameLabel.numberOfLines = 2
    
    taglineLabel.font = .systemFont(ofSize: 14, weight: .light)
    taglineLabel.textColor = .systemBlue
    taglineLabel.numberOfLines = 0
    
    beerImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.top.bottom.equalToSuperview().inset(20)
      $0.width.equalTo(80)
      $0.height.equalTo(120)
    }
    
    nameLabel.snp.makeConstraints {
      $0.leading.equalTo(beerImageView.snp.trailing).offset(10)
      $0.bottom.equalTo(beerImageView.snp.centerY) // Label bottom이 imageView의 가운데로
      $0.trailing.equalToSuperview().inset(20)
    }
    
    taglineLabel.snp.makeConstraints {
      $0.leading.trailing.equalTo(nameLabel)
      $0.top.equalTo(nameLabel.snp.bottom).offset(5)
    }
  }
  
  // 외부를 통해 components에 넣을 데이터 전달 받기
  func configure(with beer: Beer) {
    let imageURL = URL(string: beer.imageURL ?? "") // Stirng To URL convert
    beerImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "beer_icon"))
    nameLabel.text = beer.name ?? "이름 없는 맥주"
    taglineLabel.text = beer.tagLine
    
    accessoryType = .disclosureIndicator // 셀 우측에 ">" 추가
    selectionStyle = .none // 셀을 탭해도 회색음영 발생 x
  }
}

/*
 - kf.setImage -> with: Source, placeholder: 이미지를 불러올 수 없을 때 대체할 이미지
 */
