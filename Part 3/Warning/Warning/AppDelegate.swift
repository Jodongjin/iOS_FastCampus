//
//  AppDelegate.swift
//  Warning
//
//  Created by 조동진 on 2022/02/14.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // didFinish에서 구현해도 됨 (구분을 위해 여기)
    UNUserNotificationCenter.current().delegate = self
    return true
  }


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 공유 인스턴스 구성 (Firebase 초기화)
    FirebaseApp.configure()
    
    Messaging.messaging().delegate = self
    
    // FCM 현재 등록 토큰 확인
    Messaging.messaging().token(completion: { token, error in
      if let error = error {
        print("ERROR FCM 등록토큰 가져오기: \(error.localizedDescription)")
      } else if let token = token {
        print("FCM 등록토큰: \(token)")
      }
    })
    
    // 사용자 승인
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, error in
      print("ERROR, Request Notification Authorization: \(error.debugDescription)")
    })
    
    application.registerForRemoteNotifications()
    
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
  // 원격으로 받은 Notification에 디스플레이 형태 설정 (ios10 이후부터 알림의 형태를 알림센터, 배너, 뱃지, 소리로 구분하여 어떻게 표시할지 설정 가능
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.list, .banner, .badge, .sound]) // 모두 뜨게 설정
  }
}

extension AppDelegate: MessagingDelegate {
  // 토큰이 갱신되는 시점을 알려주는 Delegate Method
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else { return } // 토큰을 받았다면
    print("FCM 등록토큰 갱신: \(token)")
  }
}
