//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import UIKit

/*
protocol DiaryDetailViewDelegate: AnyObject {
  func didSelectDelete(indexPath: IndexPath) -> 삭제된 일기의 indexPath 전달
  func didSelectStar(indexPath: IndexPath, isStar: Bool) -> 즐겨찾기된 일기의 indexPath와 isStar 값 전달
}
 - delegate로 구현하면 1:1로만 데이터 전달이 가능 -> DiaryDetailViewController에서 ViewController와 StarViewController 중 한 쪽으로만 데이터 전달이 가능함(indexPath, isStar 정보) -> delegate가 아닌 앱 어디서든 데이터를 받을 수 있는 Notification Center를 이용해서 DiaryDetailViewController에서 삭제(didSelectDelete) 또는 즐겨찾기 토글(didSelectStar) 이벤트가 발생하면 ViewController와 StarViewController 모두에 이벤트가 전달되게 구현
 - 즐겨찾기 토글 이벤트 발생은 NotificationCenter로 처리해서 didSelectStar 함수 필요 x
*/

class DiaryDetailViewController: UIViewController {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var contentsTextView: UITextView!
  @IBOutlet var dateLabel: UILabel!
  var starButton: UIBarButtonItem?
  
  var diary: Diary? // 일기장 목록에서 받아올 Diary 프로퍼티
  var indexPath: IndexPath?
  // weak var delegate: DiaryDetailViewDelegate? -> NotificationCenter로 구현해서 필요 x
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureView()
    NotificationCenter.default.addObserver( // 즐겨찾기 토글이 발생할 때 starDiaryNotification 함수 호출
      self,
      selector: #selector(starDiaryNotification(_:)),
      name: NSNotification.Name("starDiary"),
      object: nil)
  }
  
  private func configureView() {
    guard let diary = self.diary else { return }
    self.titleLabel.text = diary.title
    self.contentsTextView.text = diary.contents
    self.dateLabel.text = self.dateToString(date: diary.date)
    self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton)) // 버튼을 눌렀을 때 selector 호출
    self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    self.starButton?.tintColor = .orange
    self.navigationItem.rightBarButtonItem = self.starButton
  }
  
  private func dateToString(date: Date) -> String {
    // 변환기 설정
    let formatter = DateFormatter()
    formatter.dateFormat = "yy년 MM월 dd일 (EEEEE)"
    formatter.locale = Locale(identifier: "ko_KR")
    
    return formatter.string(from: date) // Date type -> String type
  }
  
  @objc func editDiaryNotification(_ notification: Notification) {
    guard let diary = notification.object as? Diary else { return } // post에서 보낸 객체 추출
    // guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }// post에서 보낸 userInfo 값 추출 -> 여기서 row 값을 추출할 필요는 없음
    self.diary = diary // 수정된 diary 객체를 프로퍼티에 대입하고
    self.configureView() // View update
  }
  
  @objc func starDiaryNotification(_ notification: Notification) {
    guard let starDiary = notification.object as? [String: Any] else { return }
    guard let isStar = starDiary["isStar"] as? Bool else { return }
    guard let uuidString = starDiary["uuidString"] as? String else { return }
    guard let diary = self.diary else { return }
    if diary.uuidString == uuidString { // 현재 클래스 diary 프로퍼티의 uuidString이 전달받은 uuidString과 같다면
      self.diary?.isStar = isStar // isStar 값 갱신
      self.configureView() // View 업데이트
    }
  }
  
  @IBAction func tapEditButton(_ sender: UIButton) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
    guard let diary = self.diary else { return }
    guard let indexPath = self.indexPath else { return }
    viewController.diaryEditorMode = .edit(indexPath, diary) // WriteDiaryViewController의 diaryEditorMode 열거형 프로퍼티에 indexPath와 diary 객체 전달
    
    // Notification Observer 추가
    NotificationCenter.default.addObserver(self, selector: #selector(editDiaryNotification(_:)), name: NSNotification.Name("editDiary"), object: nil) // Notification을 옵저빙, editDiary라는 Notification event가 발생하는지 계속 관찰 -> 발생하면 selector 실행 / observer: 어떤 인스턴스에서 옵저빙 할 건지, selector: 실행될 함수, name: 관찰할 Notification 이름 / WriteDiaryViewController에서 editDiary Notification이 Post될 때, selector 함수가 실행됨
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  @IBAction func tapDeleteButton(_ sender: UIButton) {
    guard let uuidString = self.diary?.uuidString else { return }
    // guard let indexPath = self.indexPath else { return } -> 기존 코드: indexPath 전달
    // self.delegate?.didSelectDelete(indexPath: indexPath) -> NotificationCenter로 구현해서 필요 x
    NotificationCenter.default.post(
      name: NSNotification.Name("deleteDiary"),
      object: uuidString,
      userInfo: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func tapStarButton() { // 즐겨찾기 버튼 toggle
    guard let isStar = self.diary?.isStar else { return }
    // guard let indexPath = self.indexPath else { return } -> 기존 코드: indexPath 전달
    if isStar {
      self.starButton?.image = UIImage(systemName: "star")
    } else {
      self.starButton?.image = UIImage(systemName: "star.fill")
    }
    self.diary?.isStar = !isStar // 기존과 반대 값을 대입
    NotificationCenter.default.post( // 해당 일기의 Diary 객체와 indexPath와 즐겨찾기 여부를 NotificationCenter에 post
      name: Notification.Name("starDiary"),
      object: [
        "diary": self.diary as Any,
        "isStar": self.diary?.isStar ?? false,
        "uuidString": diary?.uuidString as Any
    ],
      userInfo: nil)
    // self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false) // diary 리스트에 사용될 indexPath와 해당 일기의 isStar 정보를 전달 -> NotificationCenter로 구현해서 필요 x
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self) // 해당 인스턴스에 추가된 옵저버 모두 제거
  }
}
