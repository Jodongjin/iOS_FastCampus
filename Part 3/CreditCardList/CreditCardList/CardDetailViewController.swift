//
//  CardDetailViewController.swift
//  CreditCardList
//
//  Created by 조동진 on 2022/02/08.
//

import UIKit
import Lottie

class CardDetailViewController: UIViewController {
  var promotionDetail: PromotionDetail? // 부모 뷰(CardList)에서 받을 데이터
  
  @IBOutlet weak var lottieView: AnimationView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var periodLabel: UILabel!
  @IBOutlet weak var conditionLabel: UILabel!
  @IBOutlet weak var benefitConditionLabel: UILabel!
  @IBOutlet weak var benefitDetailLabel: UILabel!
  @IBOutlet weak var benefitDateLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 이미지 뷰에 로티 이미지 추가
    let animationView = AnimationView(name: "money") // lottie가 가져올 json file 이름
    lottieView.contentMode = .scaleAspectFit
    lottieView.addSubview(animationView)
    animationView.frame = lottieView.bounds
    animationView.loopMode = .loop // 이미지 반복 설정
    animationView.play()
  }
  
  // promotionDetail의 데이터를 라벨에 setting
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard let detail = promotionDetail else { return }
    
    titleLabel.text = """
      \(detail.companyName)카드 쓰면
      \(detail.amount)만원 드려요
      """
    
    periodLabel.text = detail.period
    conditionLabel.text = detail.condition
    benefitConditionLabel.text = detail.benefitCondition
    benefitDetailLabel.text = detail.benefitDetail
    benefitDateLabel.text = detail.benefitDate
  }
}
