//
//  AlertListCell.swift
//  Drink
//
//  Created by 조동진 on 2022/02/10.
//

import UIKit
import UserNotifications

class AlertListCell: UITableViewCell {
  let userNotificationCenter = UNUserNotificationCenter.current()
  
  @IBOutlet weak var meridiemLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var alertSwitch: UISwitch!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  @IBAction func alertSwitchValueChanged(_ sender: UISwitch) {
    guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
          var alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return }
    
    alerts[sender.tag].isOn = sender.isOn // 선택된 스위치 상태와 스위치가 해당되는 셀의 태그에 해당되는 UserDefaults alerts 배열의 스위치 상태를 일치시켜줌
    UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
    
    if sender.isOn {
      userNotificationCenter.addNotificationRequest(by: alerts[sender.tag]) // new alert add to center (스위치가 해당되는 셀의 정보로 Request 생성, 추가)
    } else {
      userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[sender.tag].id])
    }
  }
}
