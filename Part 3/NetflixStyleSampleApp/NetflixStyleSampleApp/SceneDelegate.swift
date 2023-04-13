//
//  SceneDelegate.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let windowScene = scene as? UIWindowScene else { return }
    self.window = UIWindow(windowScene: windowScene)
    
    let layout = UICollectionViewFlowLayout() // CollectionView는 FlowLayout이 있어야 함
    let homeViewController = HomeViewController(collectionViewLayout: layout) // 정의한 뷰 컨트롤러 (컬렉션 뷰 레이아웃이기 때문에 레이아웃 객체를 전달 해야 함)
    let rootNavigationController = UINavigationController(rootViewController: homeViewController) // 네이게이션 컨트롤러의 루트 뷰 컨트롤러 설정
    
    self.window?.rootViewController = rootNavigationController // Home을 루트로 가지는 루트 네이게이션 컨트롤러를 윈도우의 루트 뷰 컨트롤러로 설정
    self.window?.makeKeyAndVisible() // 설정한 값들이 실제로 보여짐
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

