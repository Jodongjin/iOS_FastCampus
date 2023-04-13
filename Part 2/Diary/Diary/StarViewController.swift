//
//  StarViewController.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import UIKit

class StarViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var diaryList = [Diary]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureCollectionView()
    self.loadStarDiaryList()
    
    // 수정, 즐겨찾기 토글, 삭제 Notification Observing
    NotificationCenter.default.addObserver(self, selector: #selector(editDiaryNotification(_:)), name: NSNotification.Name("editDiary"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(starDiaryNotification(_:)), name: NSNotification.Name("starDiary"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(deleteDiaryNotification(_:)), name: NSNotification.Name("deleteDiary"), object: nil)
  }
  
  private func configureCollectionView() {
    self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }
  
  private func dateToString(date: Date) -> String {
    // 변환기 설정
    let formatter = DateFormatter()
    formatter.dateFormat = "yy년 MM월 dd일 (EEEEE)"
    formatter.locale = Locale(identifier: "ko_KR")
    
    return formatter.string(from: date) // Date type -> String type
  }
  
  // UserDefaults에 저장된 Diary List중 즐겨찾기 되어 있는 것만 추출
  private func loadStarDiaryList() {
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
    self.diaryList = data.compactMap{
      guard let uuidString = $0["uuidString"] as? String else { return nil }
      guard let title = $0["title"] as? String else { return nil } // Dictionary의 value가 Any 타입(guard let data 문)이므로 타입 캐스팅
      guard let contents = $0["contents"] as? String else { return nil }
      guard let date = $0["date"] as? Date else { return nil }
      guard let isStar = $0["isStar"] as? Bool else { return nil }
      return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
    }.filter({
      $0.isStar == true // isStar 프로퍼티가 true인 데이터만 추출
    }).sorted(by: {
      $0.date.compare($1.date) == .orderedDescending
    })
    // self.collectionView.reloadData() -> loadStarDiaryList()를 호출하는 곳이 viewWillAppear에서 viewDidLoad로 변경되어 필요 x
  }
  
  @objc func editDiaryNotification(_ notification: Notification) { // DiaryDetail에서 수정되면 실행
    guard let diary = notification.object as? Diary else { return }
    guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
    // guard let row = notification.userInfo?["indexPath.row"] as? Int else { return } -> 기존 코드: indexPath 받음
    self.diaryList[index] = diary
    self.diaryList = self.diaryList.sorted(by: {
      $0.date.compare($1.date) == .orderedDescending
    })
    self.collectionView.reloadData()
  }
  
  @objc func starDiaryNotification(_ notification: Notification) { // DiaryDetail에서 즐겨찾기 토글되면 실행
    guard let starDiary = notification.object as? [String: Any] else { return }
    guard let diary = starDiary["diary"] as? Diary else { return }
    guard let isStar = starDiary["isStar"] as? Bool else { return }
    guard let uuidString = starDiary["uuidString"] as? String else { return }
    // guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return } -> 이 코드를 여기에 두면 즐겨찾기 했을 때 즐겨찾기에 추가가 안 됨(if isStar{} 구문이 실행 x, 해당하는 일기가 없으면 return으로 함수가 조기 종료되기 때문 -> 즐겨찾기가 삭제될 때만(else 구문) 실행
    // guard let indexPath = starDiary["indexPath"] as? IndexPath else { return } -> 기존 코드: indexPath 받음
    if isStar { // 넘어온 isStar 값이 true라면 (즐겨찾기 등록 누름)
      self.diaryList.append(diary) // 리스트에 넘겨받은 Diary 객체 추가
      self.diaryList = self.diaryList.sorted(by: {
        $0.date.compare($1.date) == .orderedDescending
      })
      self.collectionView.reloadData()
    } else { // 넘어온 isStar 값이 false라면 (즐겨찾기 삭제 누름)
      guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
      self.diaryList.remove(at: index) // 즐겨찾기 목록에서 삭제
      self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)]) // Collection View에서 삭제
    }
  }
  
  @objc func deleteDiaryNotification(_ notification: Notification) { // DiaryDetail에서 삭제되면 실행
    guard let uuidString = notification.object as? String else { return }
    // guard let indexPath = notification.object as? IndexPath else { return } -> 기존 코드: indexPath 받음
    guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
    self.diaryList.remove(at: index) // Index out of range runtime error
    /*
     - 수정, 삭제, 즐겨찾기 상태변경 등의 Notification에 indexPath를 보내서 일기장 목록 화면과 즐겨찾기 화면에 전달하는데, 일기장 화면과 즐겨찾기 화면의 일기 개수가 다를 경우 index out of range error 발생 -> ex) 즐겨찾기에 일기 1개 있고 일기장 목록에 2개가 있을 때, 2번째 일기를 삭제하면 즐겨찾기 화면에서도 Notification에 전달된 indexPath값으로 리스트 데이터를 삭제함. 이 때, 즐겨찾기 목록에는 인덱스가 0까지 밖에 없기 때문에 StarDiaryList의 길이를 초과한 index 접근이 발생
     - 해결법: 일기를 추가할 때마다 Diary 객체에 일기의 고유한 값을 저장하고 Notification에 indexPath 값이 아닌 Diary 객체의 고유한 값을 넘겨야 함, 전달 받은 쪽에서 해당 ViewController의 배열에 전달 받은 고유한 값에 해당되는 Diary 객체가 있는지 확인하고 해당되는 인덱스의 데이터를 수정, 삭제, 즐겨찾기 상태 업데이트 해야 함
     */
    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
  }
}

extension StarViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.diaryList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCell else { return UICollectionViewCell() }
    let diary = self.diaryList[indexPath.row]
    cell.titleLabel.text = diary.title
    cell.dateLabel.text = self.dateToString(date: diary.date)
    return cell
  }
}

extension StarViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
  }
}

// 즐겨찾기된 일기를 누르면 DiaryDetailViewController로 이동하여 해당 일기 정보 전달(Diary 객체, indexPath)
extension StarViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
    let diary = self.diaryList[indexPath.row]
    viewController.diary = diary
    viewController.indexPath = indexPath
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}
