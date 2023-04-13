//
//  ViewController.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var collectionView: UICollectionView!
  
  private var diaryList = [Diary]() { // Diary type Array
    didSet {
      self.saveDiaryList() // 값이 변경될 때 UserDefaults에 저장
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureCollectionView()
    self.loadDiaryList()
    
    // 수정, 즐겨찾기 토글, 삭제 Notification Observing
    NotificationCenter.default.addObserver(self, selector: #selector(editDiaryNotification(_:)), name: NSNotification.Name("editDiary"), object: nil) // DiaryDetailViewController에서 수정버튼 클릭을 감시
    NotificationCenter.default.addObserver(self, selector: #selector(starDiaryNotification(_:)), name: NSNotification.Name("starDiary"), object: nil) // DiaryDetailViewController에서 즐겨찾기 토글이 일어나는 것을 감시
    NotificationCenter.default.addObserver(self, selector: #selector(deleteDiaryNotification(_:)), name: Notification.Name("deleteDiary"), object: nil) // DiaryDetailViewController에서 삭제버튼 클릭을 감시
  }
  
  private func configureCollectionView() {
    self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // collectionView에 표시되는 content의 간격 설정
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }
  
  @objc func editDiaryNotification(_ notification: Notification) {
    // post에서 notification에 전달된 object, userInfo 가져오기
    guard let diary = notification.object as? Diary else { return }
    guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return } // 전달받은 Diary 객체의 uuidString에 해당되는 데이터가 diaryList에 있는지 검색
    // guard let row = notification.userInfo?["indexPath.row"] as? Int else { return } -> 기존 코드: indexPath 받기
    self.diaryList[index] = diary // 수정된 Diary 객체로 변경
    self.diaryList = self.diaryList.sorted(by: { // 날짜 최신순으로 정렬
      $0.date.compare($1.date) == .orderedDescending
    })
    self.collectionView.reloadData()
  }
  
  @objc func starDiaryNotification(_ notification: Notification) {
    guard let starDiary = notification.object as? [String: Any] else { return }
    guard let isStar = starDiary["isStar"] as? Bool else { return }
    guard let uuidString = starDiary["uuidString"] as? String else { return }
    // guard let indexPath = starDiary["indexPath"] as? IndexPath else { return } -> 기존 코드: indexPath 받기
    guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
    self.diaryList[index].isStar = isStar // 해당되는 인덱스의 diary의 isStar 값 갱신
  }
  
  @objc func deleteDiaryNotification(_ notification: Notification) {
    guard let uuidString = notification.object as? String else { return }
    // guard let indexPath = notification.object as? IndexPath else { return } -> 기존 코드: indexPath 받기
    guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
    self.diaryList.remove(at: index) // 전달 받은 indexPath에 해당되는 데이터를 리스트에서 삭제
    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)]) // 해당되는 데이터를 Collection View에서 삭제 (기존코드: indexPath -> IndexPath(row: index, section: 0)])
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // 일기작성 화면 이동은 Sugueway를 통한 이동이기 때문에 prepare 메서드를 오버라이딩
    if let writeDiaryViewController = segue.destination as? WriteDiaryViewController { // 이동하려는 화면이 일기작성 화면일 경우
      writeDiaryViewController.delegate = self // delegate 위임, self(ViewController)에 delegate 채택
    }
  }
  
  private func saveDiaryList() { // 일기를 UserDefaults에 Dictionary로 저장
    let date = self.diaryList.map { // Dictionary Array
      [
        "uuidString": $0.uuidString,
        "title": $0.title,
        "contents": $0.contents,
        "date": $0.date,
        "isStar": $0.isStar
      ]
    }
    let userDefaults = UserDefaults.standard // user defaults에 접근
    userDefaults.set(date, forKey: "diaryList") // Dictionary Array 전달
  }
  
  private func loadDiaryList() {
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return } // UserDefaults에 저장된 DiaryList Dictionary Array 가져옴, Any type으로 return하기 때문에 Dictionary Array 형태로 캐스팅
    self.diaryList = data.compactMap { // 불러온 데이터를 Diary type으로 캐스팅해서 리스트에 대입
      guard let uuidString = $0["uuidString"] as? String else { return nil }
      guard let title = $0["title"] as? String else { return nil } // Dictionary Array가 Any로 return하기 때문에 타입 캐스팅
      guard let contents = $0["contents"] as? String else { return nil }
      guard let date = $0["date"] as? Date else { return nil }
      guard let isStar = $0["isStar"] as? Bool else { return nil }
      return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
    }
    
    self.diaryList = self.diaryList.sorted(by: { // 날짜 최신순 정렬
      $0.date.compare($1.date) == .orderedDescending // 왼쪽 요소와 오른쪽 요소를 비교해 내림차순 정렬
    })
  }
  
  private func dateToString(date: Date) -> String {
    // 변환기 설정
    let formatter = DateFormatter()
    formatter.dateFormat = "yy년 MM월 dd일 (EEEEE)"
    formatter.locale = Locale(identifier: "ko_KR")
    
    return formatter.string(from: date) // Date type -> String type
  }
}

extension ViewController: UICollectionViewDataSource { // collection View로 보여지는 content를 관리
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.diaryList.count // 일기 수만큼 표시
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // collection View의 지정된 위치에 표시할 셀
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() } // 스토리보드에서 정의한 프로토타입 셀을 재사용 셀로 설정, DiaryCell로 다운캐스팅 실패시 빈 셀을 반환
    
    let diary = self.diaryList[indexPath.row] // 해당되는 인덱스의 Diary 객체 가져옴
    cell.titleLabel.text = diary.title
    cell.dateLabel.text = self.dateToString(date: diary.date) // Diary의 date 프로퍼티는 Date type이기 때문에 String으로 변환하여 Label에 대입
    
    return cell
  }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // cell의 사이즈를 설정 (cgSize로 설정)
    return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200) // 한 셀의 width: 아이폰 화면의 1/2 값에서 content inset에서 설정해준 셀 간격 20(10 * 2)을 뺀 값 -> 행 당 셀이 두 개씩 표시
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { // 특정 셀이 선택되었음을 알림
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
    let diary = self.diaryList[indexPath.row] // 선택된 셀을 추출
    
    // 다음 화면으로 데이터 넘기기
    viewController.diary = diary
    viewController.indexPath = indexPath
    // viewController.delegate = self -> NotificationCenter로 구현해서 필요 x
    self.navigationController?.pushViewController(viewController, animated: true) // DiaryDetailViewController로 Push
  }
}

extension ViewController: WriteDiaryViewDelegate {
  func didSelectRegister(diary: Diary) {
    self.diaryList.append(diary) // 리스트에 Diary 객체 추가
    self.diaryList = self.diaryList.sorted(by: { // 일기 등록하고 일기 리스트를 날짜 최신순으로 정렬
      $0.date.compare($1.date) == .orderedDescending
    })
    self.collectionView.reloadData() // 일기를 추가할 때마다 collectionView reload
  }
}

/*
extension ViewController: DiaryDetailViewDelegate {
  func didSelectDelete(indexPath: IndexPath) {
    self.diaryList.remove(at: indexPath.row) // 전달 받은 indexPath에 해당되는 데이터를 리스트에서 삭제
    self.collectionView.deleteItems(at: [indexPath]) // 해당되는 데이터를 Collection View에서 삭제
  }
  
  func didSelectStar(indexPath: IndexPath, isStar: Bool) {
    self.diaryList[indexPath.row].isStar = isStar // 해당되는 인덱스의 diary의 isStar 값 갱신
  }
}
 - NotificationCenter로 구현해서 필요 x
*/
