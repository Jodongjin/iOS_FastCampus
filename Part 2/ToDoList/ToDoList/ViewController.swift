//
//  ViewController.swift
//  ToDoList
//
//  Created by 조동진 on 2022/01/27.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet var editButton: UIBarButtonItem! // weak로 연결하면 Done으로 바꿨을 때 Edit 버튼이 메모리에서 해제되어 다시 사용할 수 없음
  var doneButton: UIBarButtonItem?
  var tasks = [Task]() { // Task 배열
    didSet {
      self.saveTasks() // tasks에 할 일이 추가될 때마다 호출되어 UserDefaults에 task가 저장됨
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap)) // #selector(method): 버튼을 눌렀을 때 호출되는 메서드
    self.tableView.dataSource = self // UITableViewDataSource Protocol 채택 필요
    self.tableView.delegate = self // UITableViewDelegate Protocol 채택 필요
    self.loadTasks() // 할 일 불러오기
  }
  
  @objc func doneButtonTap() {
    self.navigationItem.leftBarButtonItem = self.editButton
    self.tableView.setEditing(false, animated: true)
  }
  
  /*
   - selector는 object-c에서 클래스의 메서드 이름을 가리키는데 사용되는 참조타입으로 동적호출 등의 목적으로 사용 -> swift로 넘어오면서 구조체 형식으로 정의되고 #selector() 구문으로 해당 타입의 값을 생성할 수 있게 됨
   - selector 타입으로 전달할 메서드 정의에는 앞에 @objc 어트리뷰트 붙여야함 (object-c와의 호환성, swift에서 정의한 메서드를 object-c에서 사용)
   */

  @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
    guard !self.tasks.isEmpty else { return } // 비어있으면 실행 x
    self.navigationItem.leftBarButtonItem = self.doneButton // 버튼 수정
    self.tableView.setEditing(true, animated: true) // TableView의 편집모드 전환
  }
  
  @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert) // alert 생성 (preferredStyle: .actionSheet -> 아래에서 나타남)
    let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
      guard let title = alert.textFields?[0].text else { return }// 등록 버튼을 누르면 TextField에 작성된 text를 가져옴 (TextField가 하나이기 때문에 0 번째 인덱스)
      let task = Task(title: title, done: false)
      self?.tasks.append(task)
      self?.tableView.reloadData() // 테이블 뷰를 갱신하여 추가된 Cell 표시
      // debugPrint("\(alert.TextFields?[0].text)") -> 디버그 프린트 함수 (콘솔에 결과 출력)
    }) // alert의 버튼 생성 (handler: 사용자가 alert 버튼을 눌렀을 때 호출 -> 할 일을 테이블 뷰에 등록해야함)
    let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alert.addAction(cancelButton) // alert에 버튼 추가
    alert.addAction(registerButton)
    alert.addTextField(configurationHandler: { textField in
      textField.placeholder = "할 일을 입력해주세요."
    }) // alert에 TextField 추가 (configurationHandler: TextField를 설정하는 클로저, TextField 단일 매개변수 사용)
    self.present(alert, animated: true, completion: nil) // 버튼 나타내기
  }
  
  func saveTasks() { // UserDefaults에 데이터 삽입
    let data = self.tasks.map { // 배열 요소들을 Dictionary 형태로 매핑
      [
        "title": $0.title,
        "done": $0.done
      ]
    }
    let userDefaults = UserDefaults.standard // UserDefaults 인스턴스 생성 (하나의 앱에 하나만 가능)
    userDefaults.set(data, forKey: "tasks") // 데이터 삽입
  }
  
  func loadTasks() { // UserDefaults에서 데이터 추출
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "tasks") as? [[String : Any]] else { return }// 데이터 추출, Any 타입으로 반환하기 때문에 Dictionary로 타입 캐스팅
    self.tasks = data.compactMap {
      guard let title = $0["title"] as? String else { return nil } // 값이 Any 타입이니 String으로 형변환
      guard let done = $0["done"] as? Bool else { return nil }
      return Task(title: title, done: done)
    }
  }
}

/*
 - 클래스처럼 클로저는 참조타입이기 때문에 클로저의 본문에서 self로 클래스의 인스턴스를 캡쳐할 때 강한 순환 참조 발생
 - 두 개의 객체가 상호 참조할 때 강한 순환 참조(ARC의 단점)가 발생 -> 연관된 객체들은 reference count가 0이 되지 않아 메모리 누수가 발생
 - 클로저와 클래스 인스턴스 사이에 강한 순환 참조를 해결하기 위해 클로저의 선언부에 캡처 목록을 정의 [weak self]
 - 클로저의 선언부에 weak나 unknowned 키워드로 캡처목록을 정의하지 않고 클로저의 본문에서 self 키워드로 클래스의 프로퍼티에 접근하면 강한 순환 참조가 발생해 메모리 누수가 발생할 수 있음
*/

// DataSource Protocol을 통해 TableView를 생성하는데 필요한 정보를 TableView 객체에 제공하는 코드를 작성
extension ViewController: UITableViewDataSource { // 필수 구현 메서드 2개
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tasks.count // 하나의 섹션에 할 일들을 표시하므로 배열의 길이를 행의 길이로 설정
  } // 각 섹션에 표시할 행의 개수
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) // 스토리보드에서 정의한 cell을 가져오는 함수
    let task = self.tasks[indexPath.row] // indexPath는 데이블 뷰에서 셀의 위치를 나타내는 인덱스
    cell.textLabel?.text = task.title
    if task.done { // done 프로퍼티의 값에 따라 체크마크 표시
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    self.tasks.remove(at: indexPath.row) // tasks 배열에 할 일 삭제
    tableView.deleteRows(at: [indexPath], with: .automatic) // TableView에도 삭제
    
    if self.tasks.isEmpty { // 모든 cell이 삭제되면
      self.doneButtonTap() // 편집모드 빠져나옴
    }
  } // 편집모드에서 삭제 버튼을 눌렀을 때, 어떤 Cell인지 알려주는 메서드 -> 편집모드를 통해 삭제 가능하고, 스와이프로도 삭제 가능
  
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  } // 행이 이동가능하게 하는 함수
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    var tasks = self.tasks // tasks 배열 복사
    let task = tasks[sourceIndexPath.row] // 기존 위치의 cell에 해당되는 배열의 데이터
    
    tasks.remove(at: sourceIndexPath.row) // 기존 위치의 cell에 해당되는 배열 인덱스의 데이터 삭제
    tasks.insert(task, at: destinationIndexPath.row) // 이동한 위치의 cell에 해당되는 배열의 자리에 데이터 삽입
    // 삭제되는 순간 뒤에서 앞으로 데이터 땡겨오고, 삽입되는 순간 뒤로 데이터 밀려짐 -> 삭제, 삽입 위치만 정해주면 알아서 정렬됨
    
    self.tasks = tasks // 원래 배열에 다시 복사
  } // 행이 다른 위치로 이동하면 sourceIndexPath 파라미터를 통해 원래 있었던 위치를 알려주고 destinationIndexPath를 통해 어디로 이동했는지 알려줌
  // 위 두 개 메서드로 편집모드에서 cell의 재정렬 가능
}

/*
 - dequeueReusableCell: 지정된 식별자에 대한 재사용 가능한 테이블 뷰의 셀 객체(재사용 할 셀 객체)를 반환하고 이를 테이블 뷰에 추가하는 역할을 하는 메서드, indexPath 위치에서 셀을 재사용 -> 특정 섹션의 N 번째 Row를 그리는데 필요한 cell을 반환하는 함수. 즉, 행에 표시할 cell을 반환
 - 한 마디로 큐를 사용해 셀을 재사용 -> 수백 개의 Cell을 메모리에 할당하기보다 Cell을 재사용
 - ex) 화면에 보이는 최대 Cell의 개수가 10개일 때, 처음 보이는 10개의 Cell만 메모리에 로드하고 스크롤로 내리면 새로운 Cell은 이전의 Cell을 재사용하여 로드해 메모리 낭비를 방지
 - 스크롤을 내리며 새로운 Cell이 보이면 기존의 Cell 데이터들은 Reuse Pool이라는 곳에 큐가 되어 들어가고 나중에 해당 데이터를 다시 볼 때 디큐됨
 - indexPath 매개변수는 section과 row 프로퍼티를 지님  ex) section = 0, row = 0 -> 가장 위의 Cell
 - numberOfRowsInSection 메서드에서 tasks의 총 개수만큼 row가 있다고 했으므로 indexPath.row은 0 ~ tasks.count 값을 지님
*/

/*
 - UserDefaults: 런타임 환경에 동작하면서 앱이 실행되는 동안 기본 저장소에 접근해 데이터를 기록하고 가져오는 역할을 하는 인터페이스
 - Key:Vaule 쌍으로 저장되고 Singleton Pattern으로 설계되어 앱 전체에 단 하나의 인스턴스만 존재
 - 기본 타입과 NS 타입 등을 저장 가능
 */

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var task = self.tasks[indexPath.row] // indexPath: 선택한 Cell의 index  ex) 첫 번째 Cell 선택: indexPath = 0
    task.done = !task.done // 반대가 되게
    self.tasks[indexPath.row] = task // 반대된 값을 tasks 배열의 원래 위치의 데이터에 덮어 씌움
    self.tableView.reloadRows(at: [indexPath], with: .automatic) // 선택된 Cell만 reload, at 매개변수가 배열이므로 여러 개의 Cell을 동시에 reload 가능 (여기서는 하나만)
  } // Cell을 선택했을 때, 어떤 Cell이 선택되었는지 알려주는 메서드
}

