//
//  ViewController.swift
//  COVID19
//
//  Created by 조동진 on 2022/02/07.
//

import UIKit

import Alamofire // Alamofire 라이브러리 import (API 호출)
import Charts // Chart 라이브러리 import (PieChartView 사용)

class ViewController: UIViewController {

  @IBOutlet weak var totalCaseLabel: UILabel!
  @IBOutlet weak var newCaseLabel: UILabel!
  @IBOutlet weak var pieChartView: PieChartView!
  @IBOutlet weak var labelStackView: UIStackView!
  @IBOutlet weak var indicatorView: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.indicatorView.startAnimating()
    self.fetchCovidOverview(completionHandler: { [weak self] result in // 순환참조 방지 캡처 리스트
      guard let self = self else { return } // 일시적으로 self가 strong reference
      self.indicatorView.stopAnimating()
      self.indicatorView.isHidden = true
      self.labelStackView.isHidden = false
      self.pieChartView.isHidden = false
      
      switch result {
      case let .success(result):
        self.configureStarkView(koreaCovidOverview: result.korea)
        let covidOverViewList = self.makeCovidOverviewList(cityCovidOverview: result)
        self.configureCharView(covidOverviewList: covidOverViewList)
        
      case let .failure(error):
        debugPrint("\(error)")
      }
    })
  }
  
  func makeCovidOverviewList(cityCovidOverview: CityCovidOverview) -> [CovidOverview] {
    return [
      cityCovidOverview.seoul,
      cityCovidOverview.busan,
      cityCovidOverview.daegu,
      cityCovidOverview.incheon,
      cityCovidOverview.gwangju,
      cityCovidOverview.daejeon,
      cityCovidOverview.ulsan,
      cityCovidOverview.sejong,
      cityCovidOverview.gyeonggi,
      cityCovidOverview.chungbuk,
      cityCovidOverview.chungnam,
      cityCovidOverview.jeonnam,
      cityCovidOverview.gyeongbuk,
      cityCovidOverview.gyeongnam,
      cityCovidOverview.jeju
    ]
  }
  
  func configureCharView(covidOverviewList: [CovidOverview]) {
    self.pieChartView.delegate = self
    let entries = covidOverviewList.compactMap { [weak self] overview -> PieChartDataEntry? in
      guard let self = self else { return nil }
      return PieChartDataEntry(
        value: self.removeFormatString(string: overview.newCase),
        label: overview.countryName,
        data: overview
      )
    }
    let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황") // 항목 묶어주기
    dataSet.sliceSpace = 1 // 항목 간 간격
    dataSet.entryLabelColor = .black // 항목 이름 색
    dataSet.valueTextColor = .black
    dataSet.xValuePosition = .outsideSlice // 항목 이름이 차트 안에 표시되지 않고 바깥 선에 표시
    dataSet.valueLinePart1OffsetPercentage = 0.8
    dataSet.valueLinePart1Length = 0.2
    dataSet.valueLinePart2Length = 0.3
    dataSet.colors = ChartColorTemplates.vordiplom()
      + ChartColorTemplates.joyful()
      + ChartColorTemplates.liberty()
      + ChartColorTemplates.pastel()
      + ChartColorTemplates.material()
    
    self.pieChartView.data = PieChartData(dataSet: dataSet)
    self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80)
  }
  
  func removeFormatString(string: String) -> Double {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal // 세 자리마다 콤마를 찍는 문자열을 변경하기 때문에
    return formatter.number(from: string)?.doubleValue ?? 0
  }
  
  func configureStarkView(koreaCovidOverview: CovidOverview) {
    self.totalCaseLabel.text = "\(koreaCovidOverview.totalCase) 명"
    self.newCaseLabel.text = "\(koreaCovidOverview.newCase) 명"
  }

  func fetchCovidOverview(
    completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
  ) {
    let url = "https://api.corona-19.kr/korea/country/new/"
    let param = [
      "serviceKey": "rBqfY9LtPZpdR4FGJWumO3bKU2VD5AywI" // API Key
    ]
    
    AF.request(url, method: .get, parameters: param)
      .responseData(completionHandler: { response in
        switch response.result {
        case let .success(data): // 요청 성공
          print(data)
          do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(CityCovidOverview.self, from: data)
            completionHandler(.success(result))
          } catch { // 요청 성공, 디코딩 실패
            completionHandler(.failure(error))
          }
        case let .failure(error): // 요청 실패
          completionHandler(.failure(error))
        }
      })
  }
}

extension ViewController: ChartViewDelegate {
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    guard let covidDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CovidDetailViewController") as? CovidDetailViewController else { return }
    guard let covidOverview = entry.data as? CovidOverview else { return } // 선택된 항목의 데이터 추출
    covidDetailViewController.covidOverview = covidOverview
    self.navigationController?.pushViewController(covidDetailViewController, animated: true)
  } // 차트에서 항목을 선택하였을 때 호출되는 메서드, entry 매개변수로 선택된 항목에 저장된 데이터를 가져올 수 있음
}

/*
 - completionHandler: API를 요청하고 서버에서 JSON 데이터를 응답 받거나 요청에 실패 하였을 때, completionHandler closure를 호출해 해당 클로저를 정의한 곳에 응답 받은 데이터를 전달
 - Result -> 첫 번째 제네릭: 요청에 성공(CityCovidOverview 객체가 열거형 연관값으로 전달됨) / 두 번째 제네릭: 요청에 실패(Error 객체가 열거형 연관값으로 전달됨)
 - AF.request: API 호출
 - 파라미터 1: url / 2: Request Method / 3: query parameter (Dictionary 형태로 전달하면 알아서 url 뒤에 추가해줌)
 - request 메서드 호출 뒤에 응답 데이터를 받을 수 있는 메서드(responseData)를 체이닝 -> 응답 데이터가 completionHandler 클로저의 파라미터로 전달됨 -> 전달된 파라미터의 result 프로퍼티로 요청 결과를 알 수 있음 (열거형 type)
 - case .success -> 연관값으로 서버에서 응답 받은 데이터가 전달됨 -> 전달 받은 데이터를 CityCovidOverview type으로 디코딩
 - 디코딩 된 CityCovidOverview 객체를 파라미터로 전달된 completionHandler 메서드의 인자로 전달 (Result type인 .success와 연관값으로 result 전달)
 
 - escaping closure: 클로저가 함수로 탈출 -> 함수의 인자로 클로저가 전달되지만 함수가 반환된 후에도 실행됨 (함수의 인자가 함수의 영역을 탈출하여 함수 밖에서도 사용되는 개념은 기존의 scope 개념을 완전히 무시) / 비동기 작업을 하는 경우 completion Handler로 escaping closure를 많이 사용 (네트워킹 작업 등)
 - responseData 파라미터에 정의한 completionHandler closure는 fetchCovidOverview 메서드가 반환된 후에 호출됨 -> 서버에서 데이터를 언제 응답시켜줄지 모르기 때문
 - escaping closure로 completionHandler를 정의하지 않는다면 서버에서 비동기로 데이터를 응답 받기 전(completionHandler가 호출되기 전)에 함수가 종료되어 서버의 응답을 받아도 completionHandler closure가 실행되지 않음 -> 함수 내에서 비동기 작업을 하고 비동기 작업의 결과를 completionHandler로 callback을 시켜줘야 한다면 escaping closure를 사용해 함수가 반환된 후에도 실행되게 만들어야 함
 
 - Alamofire에서 responseData 메서드의 completion handler는 기본적으로 main thread에서 동작하기 때문에 따로 mainDispathQueue를 안 만들어도 됨
 
 - PieChart에 데이터를 추가하려면 PieChartDataEntry 객체에 데이터 추가
 - PieChartDataEntry -> value: 차트 항목에 들어갈 값 (Double 타입으로 전달 해야 함) / label: PieChart에 표시할 항목의 이름 / data: data
 - entries 상수에는 CovidOverview 객체에서 PieChartDataEntry 객체로 매핑된 배열이 저장
 
 - pieChartView.spin: 차트 회전 / duration: 애니메이션이 지속되는 시간, fromAngle: 회전 시작점, toAngle: 회전 종료점
 */
