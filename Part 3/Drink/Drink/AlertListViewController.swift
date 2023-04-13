//
//  AlertListViewController.swift
//  Drink
//
//  Created by 조동진 on 2022/02/10.
//

import UIKit
import UserNotifications

class AlertListViewController: UITableViewController {
  var alerts: [Alert] = []
  let userNotificationCenter = UNUserNotificationCenter.current()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // tableView Cell setting
    let nibName = UINib(nibName: "AlertListCell", bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: "AlertListCell")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    alerts = alertList()
  }
  
  @IBAction func addAlertButtonAction(_ sender: UIBarButtonItem) {
    guard let addAlertVC = storyboard?.instantiateViewController(withIdentifier: "AddAlertViewController") as? AddAlertViewController else { return }
    
    // AddAlertViewController의 pickedDate closure를 부모 Controller에서 정의
    addAlertVC.pickedDate = { [weak self] date in
      guard let self = self else { return }
      
      var alertList = self.alertList()
      let newAlert = Alert(date: date, isOn: true)
      
      alertList.append(newAlert)
      alertList.sort { $0.date < $1.date }
      
      self.alerts = alertList // alerts update
      
      UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts") // UserDefaults에 넣을 데이터 encoding
      self.userNotificationCenter.addNotificationRequest(by: newAlert) // new alert add to center
      
      self.tableView.reloadData()
    }
    
    self.present(addAlertVC, animated: true, completion: nil)
  }
  
  // alerts Data loading from UserDefaults
  func alertList() -> [Alert] {
    guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
          let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return [] } // UserDefaults에서 받은 데이터 decoding
    return alerts
  }
}

// UITableView Datasource, Delegate (UITableViewController를 상속 받았기 때문에 프로토콜 채택 필요 x
extension AlertListViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alerts.count
  }
  
  // section 나눠서 헤더 표현
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: // 첫 번째 section
      return "💧 물마실 시간"
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Cell 선언
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertListCell", for: indexPath) as? AlertListCell else { return UITableViewCell() }
    
    cell.alertSwitch.isOn = alerts[indexPath.row].isOn
    cell.timeLabel.text = alerts[indexPath.row].time
    cell.meridiemLabel.text = alerts[indexPath.row].meridiem
    
    cell.alertSwitch.tag = indexPath.row // tag 값 설정
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  // TableView Cell editable(can delete) setting
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      // Remove alert
      self.alerts.remove(at: indexPath.row) // alerts Array update
      UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts") // UserDefaults update
      
      // Remove request
      userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[indexPath.row].id]) // 남아있는 Request 중 identifiers에 해당되는 requests 삭제
      
      tableView.reloadData()
      return
    default:
      break
    }
  }
}

/*
 - UserDefaults는 개발자가 임의로 정의한 구조체(Alert)를 이해하지 못 하기 때문에 인코딩, 디코딩 필요 -> Alert struct가 Codable을 채택한 이유
 - Alert의 isOn 수정 -> Cell이 자기 자신의 index를 알아야 함: cellForRowAt 메서드에서 태그 값을 부여함으로써 구현
 - switch는 cell이 아니기 때문에 선택된 스위치가 어떤 셀의 index에 해당되는지 알 수 없기 때문에 indexPath.row 값을 switch의 tag 값으로 설정 -> AlertListCell에서 스위치가 선택되었을 때 해당 스위치가 올려져 있는 셀을 tag 값으로 구분하여 inOn 속성 변경
 - Local 알림은 Notification Center에 request가 add 되는 형태이고 해당 Center가 trigger 조건을 만족할 때마다 사용자에게 noti를 보내게 됨
 
 - 알림이 생성되는 곳은 AlertListViewController: 새 alert이 생성되는 경우, AlertListCell(when the switch is on): 셀의 스위치를 킬 경우
 - 알림이 삭제되는 곳은 AlertListViewController: 셀을 삭제하는 경우, AlertListCell: 셀의 스위치를 끌 경우
 */
