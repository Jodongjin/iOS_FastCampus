//
//  CovidDetailViewController.swift
//  COVID19
//
//  Created by 조동진 on 2022/02/07.
//

import UIKit

class CovidDetailViewController: UITableViewController {
  
  @IBOutlet weak var newCaseCell: UITableViewCell!
  @IBOutlet weak var totalCaseCell: UITableViewCell!
  @IBOutlet weak var recoverdCell: UITableViewCell!
  @IBOutlet weak var deathCell: UITableViewCell!
  @IBOutlet weak var percentageCell: UITableViewCell!
  @IBOutlet weak var overseasInflowCell: UITableViewCell!
  @IBOutlet weak var regionOutbreakCell: UITableViewCell!
  
  var covidOverview: CovidOverview? // 선택된 지역의 코로나 발생현황 데이터를 전달 받을 변수
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureView()
  }
  
  func configureView() {
    guard let covidOverview = self.covidOverview else { return }
    self.title = covidOverview.countryName
    self.newCaseCell.detailTextLabel?.text = "\(covidOverview.newCase) 명"
    self.totalCaseCell.detailTextLabel?.text = "\(covidOverview.totalCase) 명"
    self.recoverdCell.detailTextLabel?.text = "\(covidOverview.recovered) 명"
    self.deathCell.detailTextLabel?.text = "\(covidOverview.death) 명"
    self.percentageCell.detailTextLabel?.text = "\(covidOverview.percentage)%"
    self.overseasInflowCell.detailTextLabel?.text = "\(covidOverview.newFcase) 명"
    self.regionOutbreakCell.detailTextLabel?.text = "\(covidOverview.newCcase) 명"
  }
}

/*
 - 지역별 디테일 화면을 위해 Static Table View(정적인 Table View) 구현 사용
 - TableViewController를 상속 받는 클래스 생성 후, 스토리보드에서 이 클래스 채택 (TableView의 Content 속성: Static Cells
 - 정적 컨텐츠를 표시하는 테이블 뷰이기 때문에 DataSource를 이용애 셀을 구성하지 않고 스토리보드에서 구성한 셀들을 Outlet 변수로 만들어 Controller에서 값을 넣어줌
 */
