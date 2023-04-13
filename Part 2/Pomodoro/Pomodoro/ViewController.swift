//
//  ViewController.swift
//  Pomodoro
//
//  Created by 조동진 on 2022/02/03.
//

import UIKit
import AudioToolbox

enum TimerStatus {
  case start
  case pause
  case end
}

class ViewController: UIViewController {

  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var toggleButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  
  var duration = 60 // 타이머에 설정된 시간을 초로 저장 (default = 60초)
  var timerStatus: TimerStatus = .end // 타이머의 상태 프로퍼티
  var timer: DispatchSourceTimer? // 타이머
  var currentSeconds = 0 // 남은 시간
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureToggleButton()
  }
  
  /*
  func setTimerInfoViewVisble(isHidden: Bool) {
    self.timerLabel.isHidden = isHidden
    self.progressView.isHidden = isHidden
  }
  */
  
  // 버튼 상태에 따른 타이틀 설정
  func configureToggleButton() {
    self.toggleButton.setTitle("시작", for: .normal)
    self.toggleButton.setTitle("일시정지", for: .selected) // 버튼이 눌려진 상태면 일시정지로 타이틀 설정
  }
  
  func startTimer() {
    if self.timer == nil { // 타이머 생성
      self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main) // quere: 어떤 쓰레드 큐에서 반복 동작할 건지 설정 (타이머가 돌 때마다 남은 시간을 업데이트 하거나 프로그레스 뷰 업데이트 등 UI관련 작업 -> main thread)
      self.timer?.schedule(deadline: .now(), repeating: 1) // 어떤 주기로 타이머를 실행할 건지 설정 / deadline: 타이머가 시작된 후 몇 초 뒤에 작업 실행할 건지, repeating: 반복 주기(초)
      self.timer?.setEventHandler(handler: { [weak self] in // 캡처 목록
        guard let self = self else { return } // self가 string reference가 되게 -> 옵셔널 바인딩
        self.currentSeconds -= 1
        let hour = self.currentSeconds / 3600
        let minutes = (self.currentSeconds % 3600) / 60
        let seconds = (self.currentSeconds % 3600) % 60
        self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds) // %02d: 두 자리 숫자 형식 지정자
        
        // 토마토 돌리기
        self.progressView.progress = Float(self.currentSeconds) / Float(self.duration) // 남은 시간 / 전체 시간으로 1초마다 progress 감소, progress는 Float type
        
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
          self.imageView.transform = CGAffineTransform(rotationAngle: .pi) // CGAffineTransfrom (구조체): 뷰의 프레임을 계산하지 않고 2D 그래픽을 그림(뷰 이동, 회전 등) / .pi: 180도 회전
        }) // delay: 애니메이션을 몇 초 뒤에 동작할 건지
        UIView.animate(withDuration: 0.5, delay:0.5, animations: {
          self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
        })
        
        if self.currentSeconds <= 0 {
          self.stopTimer()
          AudioServicesPlaySystemSound(1005) // 아이본 기본 시스템 효과음 재생, SystemSoundID 값은 iphonedev.wiki 사이트에서 확인 가능
        }
      }) // 타이머 동작할 때마다 실행 (1초)
      self.timer?.resume() // 타이머 시작
    }
  }
  
  func stopTimer() {
    if self.timerStatus == .pause {
      self.timer?.resume()
    }
    self.timerStatus = .end
    self.cancelButton.isEnabled = false
    // self.setTimerInfoViewVisble(isHidden: true)
    // self.datePicker.isHidden = false
    UIView.animate(withDuration: 0.5, animations: {
      self.timerLabel.alpha = 0
      self.progressView.alpha = 0
      self.datePicker.alpha = 1
      self.imageView.transform = .identity // 이미지 뷰 원상태
    })
    self.toggleButton.isSelected = false
    self.timer?.cancel() // 타이머 종료
    self.timer = nil // 메모리 해제 -> 타이머 종료시 꼭 nil을 할당해 메모리 해제 해줘야 함 (해제 안 하면 화면을 벗어나도 타이머가 계속 동작될 수 있음)
  }

  @IBAction func tapCancelButton(_ sender: UIButton) {
    switch self.timerStatus {
    case .start, .pause: // 타이머 시작 or 일시정지 상태
      self.timerStatus = .end
      self.cancelButton.isEnabled = false
      // self.setTimerInfoViewVisble(isHidden: true)
      // self.datePicker.isHidden = false
      UIView.animate(withDuration: 0.5, animations: {
        self.timerLabel.alpha = 0
        self.progressView.alpha = 0
        self.datePicker.alpha = 1
        self.imageView.transform = .identity // 이미지 뷰 원상태
      })
      self.toggleButton.isSelected = false
      self.stopTimer()
      
    default:
      break
    }
  }
  
  @IBAction func tapToggleButton(_ sender: UIButton) {
    self.duration = Int(self.datePicker.countDownDuration) // countDownDuration: DatePicker에서 선택한 시간(초)
    switch self.timerStatus {
    case .end: // 타이머 시작
      self.currentSeconds = self.duration
      self.timerStatus = .start
      // self.setTimerInfoViewVisble(isHidden: false) // timerLabel, progressView 표시
      // self.datePicker.isHidden = true // datePicker 숨김
      UIView.animate(withDuration: 0.5, animations: {
        self.timerLabel.alpha = 1
        self.progressView.alpha = 1
        self.datePicker.alpha = 0
      }) // withDuration: 애니메이션을 몇 초동안 지속할 건지, animations(클로저): 원하는 값의 최종 값을 설정 -> 현재 값에서 최종 값으로 변하는 애니메이션이 실행
      self.toggleButton.isSelected = true // configureToggleButton()을 통해 버튼 타이틀 변경
      self.cancelButton.isEnabled = true // 취소 버튼 활성화
      self.startTimer()
      
    case .start: // 타이머 일시정지
      self.timerStatus = .pause
      self.toggleButton.isSelected = false
      self.timer?.suspend() // 일시정지
      
    case .pause: // 타이머 재시작
      self.timerStatus = .start
      self.toggleButton.isSelected = true
      self.timer?.resume() // 타이머 시작
    }
  }
}


/*
 - main thread는 ios에서 한 개만 존재하는 thread (일반적으로 작성하는 대부분의 코드는 main thread에서 실행됨
 - 작성한 코드가 코코아에서 실행되는데 코코아가 코드를 main thread에서 호출하기 때문
 - mian thread는 interface thread라고도 불리는데, 유저가 인터페이스에 접근하면 이벤트가 메인 스레드에 전달되고 작성한 코드는 이에 반응 -> 즉, 인터페이스와 관련된 코드는 반드시 메인 스레드에서 작성되어야 함 (UI과 관련된 작업)
 */

/*
 - 일시정지 누른 상태에서 취소 버튼 누르면 런타임 에러
 - suspend() 메서드로 타이머를 일시정지 하면, 아직 수행해야 할 작업은 남아있음을 의미하기 때문에 suspend된 타이머에 nil을 대입하면 에러
 - 일시정지 상태에서 타이머를 중지하고 nil을 대입하려면 그 전에 resume() 메서드 호출
 */
