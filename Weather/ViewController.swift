//
//  ViewController.swift
//  Weather
//
//  Created by 조동진 on 2022/02/05.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var cityNameTextField: UITextField!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var weatherDescriptionLabel: UILabel!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var maxTempLabel: UILabel!
  @IBOutlet weak var minTempLabel: UILabel!
  @IBOutlet weak var weatherStackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
    if let cityName = self.cityNameTextField.text { // 텍스트 필드에 작성된 도시 이름
      self.getCurrentWeather(cityName: cityName) // 해당되는 도시의 날씨 정보 (Current Weather API 호출)
      self.view.endEditing(true) // 버튼이 눌리면 키보드 사라짐
    }
  }
  
  func configureView(weatherInformation: WeatherInformation) {
    self.cityNameLabel.text = weatherInformation.name
    if let weather = weatherInformation.weather.first { // weather 프로퍼티(배열)의 첫 요소 Weather 객체
      self.weatherDescriptionLabel.text = weather.description
    }
    self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃" // 절대온도 값에서 섭씨온도로 변환
    self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃"
    self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃"
  }
  
  func showAlert(message: String) {
    let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  func getCurrentWeather(cityName: String) {
    guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=380b924af19adee70ea092b369051b84") else { return } // 호출할 API 주소 / q: cityNAme, appid: API Key (매개변수 구분은 &)
    let session = URLSession(configuration: .default) // configuration 결정 & session 생성 (.default: 기본 세션)
    session.dataTask(with: url) { [weak self] data, response, error in // 캡처 리스트, 순환참조 해결
      let successRange = (200..<300) // 200 ~ 299 (정상처리 된 Status Code)
      guard let data = data, error == nil else { return } // 데이터를 받았고, error가 없을 때 (요청 성공)
      let decoder = JSONDecoder() // JSONDecoder: JSON 객체에서 데이터 유형의 인스턴스로 디코딩 하는 객체 (Decodable, Codable Protocol을 준수하는 사용자 정의 타입(WeatherInformation)으로 변환시켜줌)
      
      if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
        guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }// type: JSON을 매핑시켜줄 Codable Protocol을 준수하는 사용자 정의 타입 전달, from: 서버에서 받은 JSON 데이터 전달 / 디코딩을 실패하면 에러를 던지기 때문에 try? 문
        DispatchQueue.main.async {
          self?.weatherStackView.isHidden = false // UI 작업
          self?.configureView(weatherInformation: weatherInformation) // 현재 날씨 정보 View에 표시
        } // 응답받은 Status Code가 200 ~ 299에 해당된다면 WeatherInformation으로 디코딩
      } else {
        guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
        DispatchQueue.main.async {
          self?.showAlert(message: errorMessage.message) // UI 작업
        }
      } // Status Code가 200번 대가 아니라면 ErrorMessage로 디코딩
    }.resume() // 작업(dataTask) 실행
  }
}
/*
 - session.dataTask(with: url) { closure } -> 서버로 데이터 요청, 응답 받음 / with: API 호출 할 URL, completion handler closure 정의
 - dataTask가 API를 호출하고 서버에서 응답이 오면 completion handler closure가 호출됨
 - dataTask: API 호출, 데이터 요청, 응답 받기, 디코딩
 - 클로저 안에 data 파라미터에는 서버에서 응답받은 데이터가 저장, response 파라미터에는 HTTP 헤더 및 상태코드와 같은 응답 데이터가 전달, error 파라미터에는 요청이 실패하게 되면 error 객체가 전달 (성공하면 nil 반환)
 
 - DispatchQueue.main.async: 네트워크 작업은 별도의 스레드에서 진행되고 응답이 온다고 해도 자동으로 main 스레드로 돌아오지 않기 때문에 completion closure handler에서 UI 작업을 한다면 main 스레드에서 작업을 하도록 직접 만들어줘야 함 -> 해당 코드 안에 있는 구문들은 main 스레드 안에서 작업 됨
 
 - 잘못된 도시 이름으로 Current Weather API를 호출하면 "404" HTTP Status Code와 함께 에러 메시지 응답이 옴 -> 에러 메시지: JSON 객체로 "cod": 404, "message": "city not found"
 - option + cmd + I: 크롬 브라우저 개발자 모드 -> Network 탭 -> cmd + R (새로고침) -> 호출한 API 정보 확인 가능 (Status Code 등)
 - completion handler에서 응답받은 Status Code가 200이라면 WeatherInformation 객체로 디코딩, 404라면 ErrorMessage 객체로 디코딩
 */
