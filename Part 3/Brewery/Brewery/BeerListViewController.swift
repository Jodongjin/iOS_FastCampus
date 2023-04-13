//
//  BeerListViewController.swift
//  Brewery
//
//  Created by 조동진 on 2022/02/16.
//

import UIKit

class BeerListViewController: UITableViewController {
  var beerList = [Beer]()
  var dataTasks = [URLSessionTask]()
  var currentPage = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // UINavigationBar
    title = "패캠브루어리"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    // UITableView 설정
    tableView.register(BeerListCell.self, forCellReuseIdentifier: "BeerListCell") // 정의한 셀 Register
    tableView.rowHeight = 150 // tableView height 설정 (Delegate로도 설정 가능)
    tableView.prefetchDataSource = self // pageNation을 위한 prefetch
    
    fetchBeer(of: currentPage)
  }
}
 
// UITableView DataSource, Delegate
extension BeerListViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return beerList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as? BeerListCell else { return UITableViewCell() }
    // == let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as! BeerListCell (guard ~ esle 없이)
    
    let beer = beerList[indexPath.row]
    cell.configure(with: beer) // cell의 component configure
    
    return cell
  }
  
  // BeerDetailViewController로 Beer entity 전달
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let seletedBeer = beerList[indexPath.row]
    let detailViewController = BeerDetailViewController() // storyboard를 통해 구현할 때는 뷰 컨트롤러를 storyboard에서 찾음
    
    detailViewController.beer = seletedBeer
    self.show(detailViewController, sender: nil)
  }
}

// Data Fetching (private -> 다른 곳에서 패칭 불가)
private extension BeerListViewController {
  func fetchBeer(of page: Int) {
    guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
          dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil
          else { return }
    // dataTasks 배열에 있는 task 중에서 originalRequest.url(요청된 url이)이 새롭게 요청된 url(page와 조합되어 생성된 url)과 일치하는 task가 없어야 함 -> 새로운 url만 받겠다
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
      guard error == nil,
            let self = self,
            let response = response as? HTTPURLResponse,
            let data = data,
            let beer = try? JSONDecoder().decode([Beer].self, from: data) else {
        print("ERROR: URLSession data Task \(error?.localizedDescription ?? "")")
        return
      }
      
      switch response.statusCode {
      case (200...299): // Success
        self.beerList += beer // data insert
        self.currentPage += 1 // API에서 25개씩 제공해주므로 한 페이지 당 25개 표현
        
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      case(400...499): // Client Error
        print("""
          ERROR: Client ERROR \(response.statusCode)
          Response: \(response)
        """)
      case(500...599): // Server Error
        print("""
          ERROR: Server ERROR \(response.statusCode)
          Response: \(response)
        """)
      default:
        print("""
          ERROR: \(response.statusCode)
          Response: \(response)
        """)
      }
    })
    
    dataTask.resume() // Task 실행
    dataTasks.append(dataTask) // dataTask가 실행될 때마다 dataTasks에 추가해 줘야 실행된 url인지 구별 가능 -> dataTasks에 존재하는 url이면 함수 첫 라인 guard문에서 걸러져 request를 진행하지 않게 됨
  }
}

// Prefetch DataSource
extension BeerListViewController: UITableViewDataSourcePrefetching {
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    guard currentPage != 1 else { return } // currentPage가 1일 때는 viewDidLoad에서 패칭
    
    indexPaths.forEach {
      if ($0.row + 1)/25 + 1 == currentPage {
        self.fetchBeer(of: currentPage)
      }
    }
  }
}

/*
 - dataTask(with, completionHandler): completionHandler -> data, response, error를 뱉어줌, 해당 핸들러 안에서 데이터 가공 및 사용
 
 - PrefetchRow: 화면에 나타난 셀 말고 추가될 예정인 셀(미리 불러오는 역할)
 - indexPaths.forEach {
    if ($0.row + 1)/25 + 1 == currentPage {
      self.fetchBeer(of: currentPage)
    }
 viewDidLoad에서 fetchBeer를 호출해 currentPage가 2가 되므로 25번째 인덱스에 해당하는 셀이 화면 밖(나타날 예정인 셀)에 포함되면 if 조건이 참이 되므로 다시 fetchBeer를 호출하여 뒤의 데이터를 불러옴
 $0.row 인덱스는 0부터이므로 + 1을 해준 값을 25로 나눠야 함
 화면을 아래로 스크롤 할 때, 25의 배수에 해당되는 인덱스가 예정인 셀에 포함되면 매번 패칭을 하게 됨 -> 불러오는 데이터가 중복될 수 있으므로 한 번 불러온 페이지를 안 부르게 조정
 */
