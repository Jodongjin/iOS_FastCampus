//
//  AppDelegate.swift
//  CreditCardList
//
//  Created by 조동진 on 2022/02/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    
    // DB 선언
    let db = Firestore.firestore()

    // Firestore DB에 데이터가 없을 때만 초기에 한 번에 데이터를 넣어주기 때문에 데이터 유무 확인
    db.collection("creditCardList").getDocuments { snapshot, _ in
      guard snapshot?.isEmpty == true else { return }
      
      // CreditCard 객체를 넣을 batch 생성
      let batch = db.batch()

      // 객체 더미를 넣을 경로 설정 (creditCardList 컬렉션에 각 문서에 삽입)
      let card0Ref = db.collection("creditCardList").document("card0")
      let card1Ref = db.collection("creditCardList").document("card1")
      let card2Ref = db.collection("creditCardList").document("card2")
      let card3Ref = db.collection("creditCardList").document("card3")
      let card4Ref = db.collection("creditCardList").document("card4")
      let card5Ref = db.collection("creditCardList").document("card5")
      let card6Ref = db.collection("creditCardList").document("card6")
      let card7Ref = db.collection("creditCardList").document("card7")
      let card8Ref = db.collection("creditCardList").document("card8")
      let card9Ref = db.collection("creditCardList").document("card9")
      
      // batch에 데이터 삽입
      do {
        // from: Encoding(to JSON)이 가능한 객체를 넣으면 알아서 인코딩하여 삽입, forDocument: 데이터를 넣을 경로
        try batch.setData(from: CreditCardDummy.card0, forDocument: card0Ref)
        try batch.setData(from: CreditCardDummy.card1, forDocument: card1Ref)
        try batch.setData(from: CreditCardDummy.card2, forDocument: card2Ref)
        try batch.setData(from: CreditCardDummy.card3, forDocument: card3Ref)
        try batch.setData(from: CreditCardDummy.card4, forDocument: card4Ref)
        try batch.setData(from: CreditCardDummy.card5, forDocument: card5Ref)
        try batch.setData(from: CreditCardDummy.card6, forDocument: card6Ref)
        try batch.setData(from: CreditCardDummy.card7, forDocument: card7Ref)
        try batch.setData(from: CreditCardDummy.card8, forDocument: card8Ref)
        try batch.setData(from: CreditCardDummy.card9, forDocument: card9Ref)
      } catch let error {
        print("ERROR writing card to Firestore \(error.localizedDescription)")
      }
      
      batch.commit() // 반드시 batch를 commit 해주어야 데이터가 추가됨
    }
    
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

