//
//  ViewController.swift
//  Notice
//
//  Created by 조동진 on 2022/02/09.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

class ViewController: UIViewController {
  var remoteConfig: RemoteConfig?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    remoteConfig = RemoteConfig.remoteConfig()
    
    let setting = RemoteConfigSettings()
    setting.minimumFetchInterval = 0
    
    remoteConfig?.configSettings = setting
    remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults") // P List를 RemoteConfig가 인식
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    getNotice()
  }
}

// Remote Config
extension ViewController {
  func getNotice() {
    guard let remoteConfig = remoteConfig else { return }
    
    remoteConfig.fetch(completionHandler: { [weak self] status, _ in
      if status == .success { // fetch success
        remoteConfig.activate(completion: nil)
      } else {
        print("ERROR: Config not fetched")
      }
      
      guard let self = self else { return }
      
      if !self.isNoticeHidden(remoteConfig) { // Notice 표기
        let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
        
        noticeVC.modalPresentationStyle = .custom
        noticeVC.modalTransitionStyle = .crossDissolve
        
        let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n") // remoteConfig에서 해당되는 Key의 값 추출
        let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
        let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
        
        // Notice View present
        noticeVC.noticeContents = (title: title, detail: detail, date: date)
        self.present(noticeVC, animated: true, completion: nil)
      } else {
        self.showEventAlert()
      }
    })
  }
  
  func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
    return remoteConfig["isHidden"].boolValue // isHidden Key를 가지는 원격구성의 값 추출 (.boolValue: 해당 값의 자료형 표시)
  }
}

// A/B Testing
extension ViewController {
  func showEventAlert() {
    guard let remoteConfig = remoteConfig else { return }
    
    remoteConfig.fetch(completionHandler: { [weak self] status, _ in
      if status == .success {
        remoteConfig.activate(completion: nil)
      } else {
        print("Config not fetched")
      }
      
      let message = remoteConfig["message"].stringValue ?? ""
      
      // Alert config
      let confirmAction = UIAlertAction(title: "확인하기", style: .default, handler: { _ in
        Analytics.logEvent("promotion_alert", parameters: nil) // Firebase에서 이벤트를 기록
      }) // 확인버튼 탭시 event logging
      
      let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
      let alertController = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert) // Remote Config에서 불러온 message 대입
      
      alertController.addAction(confirmAction)
      alertController.addAction(cancelAction)
      
      self?.present(alertController, animated: true, completion: nil)
    })
  }
}

/*
 - setting.minimumFetchInterval: 테스트를 위해 새로운 값을 fetch하는 interval을 최소화 -> 최대한 자주 원격 구성에 있는 데이터를 가져오게 구성
 - Config 객체의 각 키에 대한 기본값 설정 -> Property List 추가
     원격구성은 Key: Value 형태 -> Root Key type = Dictionary
     총 네 개의 Key로 제어 -> 4개 item 추가
     isHidden: Notice ViewController를 토글
     title, detail, date: 라벨에 추가될 문자열
 
 - Swift에서 개행은 \n이지만 Remote Config 콘솔에 \n을 넣으면 역슬래쉬가 두 번 찍혀서 추출됨 -> Swift에서 개행을 인식하지 못함
   replacingOccurrences: 추출 값 "\\n" -> "\n"으로 변경
 
 - Value 업데이트는 Firebase 웹 콘솔을 통해 진행
   코드에서 설정해둔 Value의 type은 맞춰줘야함 (boolValue, stringValue)
 
 - Analytics.logEvent() -> parameters를 입력하면 Firebase DebugView에서 발생한 이벤트에 추가적으로 Key: Value 값이 표시됨
 */
