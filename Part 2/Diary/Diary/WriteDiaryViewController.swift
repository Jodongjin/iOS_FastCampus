//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 조동진 on 2022/02/02.
//

import UIKit

enum DiaryEditorMode {
  case new
  case edit(IndexPath, Diary) // 연관 값으로 indexPath, Diary 전달 받음
}

// delegate를 통해 이전 scene으로 data(Diary type) 전달
protocol WriteDiaryViewDelegate: AnyObject {
  func didSelectRegister(diary: Diary) // 작성된 Diary 객체 전달
}

class WriteDiaryViewController: UIViewController {
  
  @IBOutlet var titleTextField: UITextField!
  @IBOutlet var contentsTextView: UITextView!
  @IBOutlet var dateTextField: UITextField!
  @IBOutlet var confirmButton: UIBarButtonItem!
  
  private let datePicker = UIDatePicker()
  private var diaryDate: Date? // datePicker의 값을 저장
  weak var delegate: WriteDiaryViewDelegate? // delegate 변수 정의
  var diaryEditorMode: DiaryEditorMode = .new // 초기값 = .new
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureContentsTextView() // TextView border setting
    self.configureDatePicker() // Date TextField -> DatePicker setting
    self.configureInputField() // inputFields configure setting
    self.configureEditMode() // Fill inputFields setting (When click the "수정" Button at DiaryDetailViewController
    self.confirmButton.isEnabled = false
  }
  
  private func configureEditMode() {
    switch self.diaryEditorMode { // DiaryDetailViewController에서 받은 값이 .edit일 경우
    case let .edit(_, diary): // diary 객체를 diary 상수에 대입해서 inputField 채우기
      self.titleTextField.text = diary.title
      self.contentsTextView.text = diary.contents
      self.dateTextField.text = dateToString(date: diary.date)
      self.diaryDate = diary.date
      self.confirmButton.title = "수정"
      
    default:
      break
    }
  }
  
  private func dateToString(date: Date) -> String {
    // 변환기 설정
    let formatter = DateFormatter()
    formatter.dateFormat = "yy년 MM월 dd일 (EEEEE)"
    formatter.locale = Locale(identifier: "ko_KR")
    
    return formatter.string(from: date) // Date type -> String type
  }
  
  private func configureContentsTextView() { // TextView의 border 설정
    let borderColor = UIColor(red: 220/225, green: 220/225, blue: 220/225, alpha: 1.0) // alpha 값은 0.0 ~ 1.0 (0.0에 가까울수록 투명해짐) / red, green, blue 매개변수에는 alpha와 마찬가지로 0.0 ~ 1.0 사이의 값을 넣어줘야 하기 때문에 나누기 225
    self.contentsTextView.layer.borderColor = borderColor.cgColor // layer 관련 색상을 설정할 때는 UIColor가 아닌 cgColor로 설정
    self.contentsTextView.layer.borderWidth = 0.5 // 보더 두께
    self.contentsTextView.layer.cornerRadius = 5.0
  }
  
  private func configureDatePicker() {
    // datePicker 설정
    self.datePicker.datePickerMode = .date // 날짜만 설정
    self.datePicker.preferredDatePickerStyle = .wheels // 스타일
    self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged) // UIController 객체가 이벤트에 응답하는 방식 설정 / action: 이벤트 발생시 호출될 메서드 (Selector형), for: 어떤 이벤트 발생시 selector 호출
    self.datePicker.locale = Locale(identifier: "ko-KR")
    
    // 설정된 datePicker를 날짜 TextField로 설정 -> TextField 선택시 키보드 아닌  DatePicker
    self.dateTextField.inputView = self.datePicker
  }
  
  private func configureInputField() {
    self.contentsTextView.delegate = self // delegate 설정, 내용란이 입력될 때마다
    self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged) // 제목란이 입력될 때마다
    self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged) // 날짜란이 입력될 때마다 (dateTextField는 키보드로 입력받는 형태가 아니기 때문에 DatePicker로 날짜를 변경해도 dateTextFieldChange 메서드가 호출되지 않음 -> datePickerValueDidChange 메서드에서 값이 변경될 때마다 editingChanged 액션을 발생시켜줘야함
  }
  
  // 등록버튼을 눌렀을 때, Diary 객체를 생성하고 delegate에 정의한 didSelectRegister 메서드 호출해 인자로 생성된 Diary 객체 전달
  @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
    // 제목, 내용, 날짜(DatePicker에서 가져온 값을 저장한 self 프로퍼티) 가져오기
    guard let title = self.titleTextField.text else { return }
    guard let contents = self.contentsTextView.text else { return }
    guard let date = self.diaryDate else { return }
    
    switch self.diaryEditorMode {
    case .new: // 새로운 내용 작성일 경우
      let diary = Diary(
        uuidString: UUID().uuidString, // 일기의 고유 값 생성
        title: title,
        contents: contents,
        date: date,
        isStar: false) // Diary 객체 생성, 일기를 새로 만들 때는 isStar가 false
      self.delegate?.didSelectRegister(diary: diary)
      
    case let .edit(_, diary): // DiaryDetailViewController로부터 .edit 값을 받은 경우 (수정일 경우)
      let diary = Diary(
        uuidString: diary.uuidString,
        title: title,
        contents: contents,
        date: date,
        isStar: diary.isStar) // 일기를 수정할 경우 isStar가 현재값
      NotificationCenter.default.post(
        name: NSNotification.Name("editDiary"),
        object: diary,
        userInfo: nil)
      
        /*
         - 기존 코드 -> userInfo: [ "indexPath.row": indexPath.row])
         - 수정된 Diary 객체를 NotificationCenter로 전달 / name: 설정한 이름으로 옵저버에서 설정한 이름에 Notification event가 발생하였는지 관찰, object: 전달할 객체, userInfo: Notification과 관련된 값 전달 -> collectionView의 리스트도 수정이 필요하기 때문에 indexPath.row 값 전달 / 수정버튼을 눌렀을 때, Notification Center가 editDiary라는 key를 옵저빙하는 곳에 수정된 diary 객체를 전달함 (옵저빙 하는 곳은 ViewController, DiaryDetailViewController)
         - runtime error 때문에 indexPath 값이 아닌 uuid 값을 전달
         */
    }
    
    
    self.navigationController?.popViewController(animated: true) // 이전 화면으로
  }
  
  @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
    // 변환기 설정
    let formatter = DateFormatter() // Date type과 Text type 상호 변환
    formatter.dateFormat = "yyyy년 MM월 dd일 (EEEEE)" // Date type을 어떤 형태의 Text로 변환할 건지 / (EEEEE): 요일을 한 글자로 표시
    formatter.locale = Locale(identifier: "ko_KR") // 한국어 설정
    
    self.diaryDate = datePicker.date
    self.dateTextField.text = formatter.string(from: datePicker.date) // 현재 DatePicker의 값을 변환기에 넣어 dateTextField 값 갱신
    self.dateTextField.sendActions(for: .editingChanged) // datePicker의 값이 변경될 때마다 datePickerValueDidChange 메서드가 호출되고 dateTextField는 dateTextField에 추가한 addTarget으로 editingChaned 액션을 보내 selector 메서드를 호출할 수 있게 됨
  }
  
  @objc private func titleTextFieldDidChange(_ textField: UITextField) {
    self.validateInputField() // 제목 입력마다 confirmButton 활성화 여부 확인
  }
  
  @objc private func dateTextFieldDidChange(_ textField: UITextField) {
    self.validateInputField() // 날짜 입력마다 confirmButton 활성화 여부 확인
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // 화면을 터치하면 호출되는 메서드
    self.view.endEditing(true) // Editing 창(키보드, DatePicker 등) 사라짐
  }
  
  private func validateInputField() {
    self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !(self.contentsTextView.text.isEmpty) // 모든 inputField가 비어있지 않으면 confirmButton 활성화
  }
}

extension WriteDiaryViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) { // TextView에 Text가 입력될 때마다 호출
    self.validateInputField() // textField에 내용이 입력될 때마다 모든 inputField가 채워졌는지 확인하고 confirmButton을 활성화
  }
}


/*
 - tapConfirmButton 메서드에서 수정된 내용을 전달하는 Notification Center를 구현 -> Notification Center에 수정된 Diary 객체를 전달하고 Notification Center를 구독하고 있는 화면에서 객체를 전달 받고 View에도 수정된 내용이 갱신되게 구현
 - Notification Center: 등록된 이벤트가 발생하면 해당 이벤트에 대한 액션을 취하는 것, 앱 내에서 아무 곳에서나 메시지를 던지면 아무 곳에서나 메시지를 받을 수 있게 함
 - Post 메서드를 통해 이벤트를 전송하고 Observer를 등록해서 이벤트를 받음
*/
