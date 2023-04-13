//
//  AppDelegate.swift
//  Drink
//
//  Created by 조동진 on 2022/02/10.
//

import UIKit
import NotificationCenter
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  let userNotificationCenter = UNUserNotificationCenter.current()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    
    // 사용자에게 알림 허용 구하기
    let authrizationOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound]) // 인증 요청 할 옵션
    userNotificationCenter.requestAuthorization(options: authrizationOptions, completionHandler: { _, error in
      if let error = error {
        print("ERROR: notification authrization request \(error.localizedDescription)")
      }
    }) // 사용자 인증 요청
    
    return true
  }

}

extension AppDelegate:UNUserNotificationCenterDelegate {
  // Center에 보내기 전 handling
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .list, .badge, .sound]) // 각 알림에 대해 표시할 방법
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
  }
}

/*
 - 앱에서 Local 알림 등의 알림을 주려면 사용자의 승인을 받아야 함
 */
