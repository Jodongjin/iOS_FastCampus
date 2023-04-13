//
//  ContentCollectionViewMainCell.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/16.
//

import UIKit

class ContentCollectionViewMainCell: UICollectionViewCell {
  let baseStackView = UIStackView()
  let menuStackView = UIStackView()
  
  // menuStackView components
  let tvButton = UIButton()
  let movieButton = UIButton()
  let categoryButton = UIButton()
  
  // baseStackView components
  let imageView = UIImageView()
  let descriptionLabel = UILabel()
  let contentStackView = UIStackView()
  
  // baseStackView's contentStackView
  let plusButton = UIButton()
  let playButton = UIButton()
  let infoButton = UIButton()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    [baseStackView, menuStackView].forEach {
      contentView.addSubview($0)
    }
    
    // baseStackView
    baseStackView.axis = .vertical
    baseStackView.alignment = .center
    baseStackView.distribution = .fillProportionally
    baseStackView.spacing = 5
    
    [imageView, descriptionLabel, contentStackView].forEach {
      baseStackView.addArrangedSubview($0) // StackView에 추가할 때는 addArrangedSubview()
    }
    baseStackView.snp.makeConstraints({
      $0.edges.equalToSuperview()
    })
    
    // imageView
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints({
      $0.width.top.leading.trailing.equalToSuperview().inset(60)
      $0.height.equalTo(imageView.snp.width)
    })
    
    // Description Label
    descriptionLabel.font = .systemFont(ofSize: 13)
    descriptionLabel.textColor = .white
    descriptionLabel.sizeToFit()
    
    // ContentStackView
    contentStackView.axis = .horizontal
    contentStackView.alignment = .center
    contentStackView.distribution = .equalCentering
    contentStackView.spacing = 20
    [plusButton, playButton, infoButton].forEach {
      contentStackView.addArrangedSubview($0)
    }
    contentStackView.snp.makeConstraints({
      $0.leading.trailing.equalToSuperview().inset(30)
      // $0.height.equalTo(60)
    })
    
    // ContentStackView's Button
    [plusButton, infoButton].forEach {
      $0.titleLabel?.font = .systemFont(ofSize: 13)
      $0.setTitleColor(.white, for: .normal)
      $0.imageView?.tintColor = .white
      $0.adjustVerticalLayout(5) // UIButton file에서 extension하여 구현한 메서드
    }
    
    plusButton.setTitle("내가 찜한 콘텐츠", for: .normal)
    plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
    plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    
    infoButton.setTitle("정보", for: .normal)
    infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
    infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    
    playButton.setTitle("▶️ 재생", for: .normal)
    playButton.setTitleColor(.black, for: .normal)
    playButton.backgroundColor = .white
    playButton.layer.cornerRadius = 3
    playButton.snp.makeConstraints({
      $0.width.equalTo(90)
      $0.height.equalTo(30)
    })
    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    
    // menuStackView
    menuStackView.axis = .horizontal
    menuStackView.alignment = .center
    menuStackView.distribution = .equalSpacing
    menuStackView.spacing = 20
    [tvButton, movieButton, categoryButton].forEach {
      menuStackView.addArrangedSubview($0)
      $0.setTitleColor(.white, for: .normal)
      $0.layer.shadowColor = UIColor.black.cgColor // shadowColor는 cgColor를 받음
      $0.layer.shadowOpacity = 1
      $0.layer.shadowRadius = 3
    }
    
    tvButton.setTitle("TV 프로그램", for: .normal)
    tvButton.addTarget(self, action: #selector(tvButtonTapped), for: .touchUpInside) // Storyboard의 IBAction 추가
    
    movieButton.setTitle("영화", for: .normal)
    movieButton.addTarget(self, action: #selector(movieButtonTapped), for: .touchUpInside)
    
    categoryButton.setTitle("카테고리 🔻", for: .normal)
    categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
    
    menuStackView.snp.makeConstraints({
      $0.top.equalTo(baseStackView) // baseStackView edges == superView, menuStackView.top == superView / (baseStackView.snp.top)도 가능
      $0.leading.trailing.equalToSuperview().inset(30)
    })
  }
  
  @objc func tvButtonTapped(sender: UIButton!) {
    print("TEST: TV Button Tapped")
  }
  
  @objc func movieButtonTapped(sender: UIButton!) {
    print("TEST: Movie Button Tapped")
  }
  
  @objc func categoryButtonTapped(sender: UIButton!) {
    print("TEST: Category Button Tapped")
  }
  
  @objc func plusButtonTapped(sender: UIButton!) {
    print("TEST: Plus Button Tapped")
  }
  
  @objc func infoButtonTapped(sender: UIButton!) {
    print("TEST: Info Button Tapped")
  }
  
  @objc func playButtonTapped(sender: UIButton!) {
    print("TEST: Play Button Tapped")
  }
  
}

// baseStackView의 contentStackView의 plusButton, infoButton 설정 (imageView와 Label이 수직 정렬)
extension UIButton {
  func adjustVerticalLayout(_ spacing: CGFloat = 0) {
    let imageSize = self.imageView?.frame.size ?? .zero
    let titleLabelSize = self.titleLabel?.frame.size ?? .zero
    
    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
    self.imageEdgeInsets = UIEdgeInsets(top: -(titleLabelSize.height), left: 0, bottom: 0, right: -titleLabelSize.width)
  }
}
