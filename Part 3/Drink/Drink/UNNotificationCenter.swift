//
//  UNNotificationCenter.swift
//  Drink
//
//  Created by 조동진 on 2022/02/10.
//

import Foundation
import UserNotifications

// Content, Trigger, Request setting
extension UNUserNotificationCenter {
  func addNotificationRequest(by alert: Alert) {
    // Content setting
    let content = UNMutableNotificationContent()
    content.title = "물 마실 시간이에요💧"
    content.body = "세계보건기구(WHO)가 권장하는 하루 물 섭취량은 1.5~2L입니다."
    content.sound = .default
    content.badge = 1
    
    // Trigger setting
    let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date) // Trigger에 설정할 날짜 정보를 alert으로부터 가져옴 (시, 분)
    let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alert.isOn) // alert의 isOn이 켜져있으면 반복, 꺼져있으면 반복 종료
    
    // Request setting
    let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
    
    self.add(request, withCompletionHandler: nil) // UNUserNotificationCenter에 request add
  }
}


/*
 - UNUserNotificationCenter class에 Alert 객체를 받아 Request를 만들고 Center에 추가하는 함수 extention
 - 사용자가 앱을 실행할 시 뱃지를 사라지게 할 코드를 따로 구현 해야 함 -> SceneDelegate
 
 - 알림 발송은 Trigger로 발송
 */
