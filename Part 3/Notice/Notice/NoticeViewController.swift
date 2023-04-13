//
//  NoticeViewController.swift
//  Notice
//
//  Created by 조동진 on 2022/02/09.
//

import UIKit

class NoticeViewController: UIViewController {
  var noticeContents: (title: String, detail: String, date: String)? // ViewController에서 받아올 문자열 튜플
  
  @IBOutlet weak var noticeView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

    }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    noticeView.layer.cornerRadius = 6
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 팝업처럼 보이게 super view 배경 어둡게 설정
    
    guard let noticeContents = noticeContents else { return }
    titleLabel.text = noticeContents.title
    detailLabel.text = noticeContents.detail
    dateLabel.text = noticeContents.date
  }
  
  @IBAction func doneButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

/*
 - NoticeViewController를 표시할지 안 할지도 Remote Config를 통해 제어하기 때문에 기본 ViewController에서 Remote Config를 받아와서 ViewController에서 라벨에 표시될 문자열을 받아옴
 */
