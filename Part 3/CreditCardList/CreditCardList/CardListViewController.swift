//
//  CardListViewController.swift
//  CreditCardList
//
//  Created by 조동진 on 2022/02/08.
//

import UIKit
import Kingfisher // image
//import FirebaseDatabase // Database
import FirebaseFirestore
import FirebaseFirestoreSwift
import simd

/*
 - 화면 전체의 UITableView에는 component가 없어서 UITableViewController로 설정
 - UIViewController에 UITableViewController를 추가해도 되지만 UITableView를 구성하는 데 필요한 Delegate와 DataSource를 기본 연결된 상태로 제공, RootView로 UITableView를 가지게 됨(UIViewController는 그냥 View) -> 별도 Delegate 선언 필요 x
 */

class CardListViewController: UITableViewController {
//  var ref: DatabaseReference! // Firebase Realtime Database를 가져오는 reference 값 (Firebase RT DB에서의 루트)
  
  // Firestore DB 선언
  var db = Firestore.firestore()
    
  var creditCardList: [CreditCard] = [] // 전달받은 데이터의 가공된 형태 (셀에 전달할 데이터)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // UITableView Cell Register
    let nibName = UINib(nibName: "CardListCell", bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: "CardListCell")

    // Realtime Database Read
//    ref = Database.database().reference() // Firebase가 데이터베이스를 잡아내고 Firebase에서 만든 데이터를 주고 받음
//
//    // value 값을 바라보고 snapshot을 제공해줌
//    ref.observe(.value, with: { snapshot in
//      guard let value = snapshot.value as? [String: [String: Any]] else { return } // 각자가 만든 데이터 형식
//
//      // Decoding
//      do {
//        let jsonData = try JSONSerialization.data(withJSONObject: value) // json data
//        let cardData = try JSONDecoder().decode([String: CreditCard].self, from: jsonData)
//        let cardList = Array(cardData.values) // Dictionary에서 value만 추출한 배열
//        self.creditCardList = cardList.sorted { $0.rank < $1.rank } // 프로퍼티에 대입
//
//        // Table Reload는 UI -> Main thread에서 동작
//        DispatchQueue.main.async {
//          self.tableView.reloadData()
//        }
//      } catch let error {
//        print("ERROR JSON parsing \(error.localizedDescription)")
//      }
//    })
    
    // Firebase Read -> Firestore DB에서 받은 데이터를 디코딩하여 creditCardList에 대입
    db.collection("creditCardList").addSnapshotListener({ snapshot, error in
      guard let documents = snapshot?.documents else {
        print("ERROR Firestore fetching document \(String(describing: error))")
        return
      }
      
      // document에서 nil을 반환했을 때 creditCardList에 넣지 않기 위해 compactMap 사용
      self.creditCardList = documents.compactMap({ doc -> CreditCard? in
        do {
          let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: []) // document의 데이터를 JSON으로 받음
          let creditCard = try JSONDecoder().decode(CreditCard.self, from: jsonData) // 받은 JSON을 CreditCard로 디코딩
          return creditCard
        } catch let error {
          print("ERROR JSON Parsing \(error)")
          return nil
        } // JSON Parsing은 throw 함수
      }).sorted { $0.rank < $1.rank }
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }) // Realtime DB의 observe와 같은 역할
  }

  // 단일 섹션 -> 카드 배열의 인덱스 수가 테이블 뷰의 row
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return creditCardList.count
  }

  // 커스텀 셀과 그 셀에 전달될 데이터 지정
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }

    // 셀에 표시될 데이터 설정
    cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
    cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
    cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"

    let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL) // String -> URL
    cell.cardImageView.kf.setImage(with: imageURL)

    return cell
  }

  // Cell Height
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

  // Cell Selected
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    // 상세화면 전달
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }

    // 해당되는 셀의 promotionDetail 프로퍼티를 전달
    detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail

    self.show(detailViewController, sender: nil)

    // Realtime Database Read
//    let cardID = creditCardList[indexPath.row].id
    // Option 1: 객체의 Key를 예상가능 한 경우 (경로를 알 때), Key로 객체를 바로 가져오기
//    ref.child("Item\(cardID)/isSelected").setValue(true) // 해당되는 DB 경로의 isSelected 속성에 값 setting

    // Option 2: 객체의 id 속성으로 객체를 찾아 snapshot으로 찍고 찍은 객체의 value를 추출, value에서 key를 추출해 isSelected 속성 수정 (경로를 모를 때)
//    ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value, with: { [weak self] snapshot in
//      guard let self = self,
//            let value = snapshot.value as? [String: [String: Any]],
//            let key = value.keys.first else { return } // snapshot.value는 Array이지만 id는 고유 값이므로 하나의 인덱스만 있을 것 -> first
//
//      self.ref.child("\(key)/isSelected").setValue(true)
//    })
    
    // Firestore Read
    // Option 1: 경로를 알 때 (각 컬렉션과 문서의 ID를 알 때 -> Firestore의 경로는 각 컬렉션과 문서의 ID로 구성)
    // 문서 이름(경로): card + [index] -> 선택된 creditCardList index에 해당되는 데이터의 값을 수정
    let cardID = creditCardList[indexPath.row].id
//    db.collection("creditCardList").document("card\(cardID)").updateData(["isSelected": true])
    
    // Option 2: 경로를 모를 때 (고유 값으로 문서를 검색하고 해당 문서를 업데이트)
    // 컬렉션의 문서 중 id 값이 cardID와 같은 문서를 get
    db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments(completion: { snapshot, _ in
      guard let document = snapshot?.documents.first else {
        print("ERROR Firestore fetching document")
        return
      } // 배열로 알려줌
      
      document.reference.updateData(["isSelected": true]) // 해당 문서의 필드 업데이트
    })
  }

  // row edit setting (스와이프 시 삭제 버튼)
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Realtime Database Delete
//      // Option 1
//      let cardID = creditCardList[indexPath.row].id
//      ref.child("Item\(cardID)").removeValue() // 해당 경로의 데이터 객체 삭제

//      // Option 2
//      ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value, with: { [weak self] snapshot in
//        guard let self = self,
//              let value = snapshot.value as? [String: [String: Any]],
//              let key = value.keys.first else { return }
//
//        self.ref.child(key).removeValue()
//      })
      
      // Firestore Delete
      // Option 1: 경로를 알 때
      let cardID = creditCardList[indexPath.row].id
//      db.collection("creditCardList").document("card\(cardID)").delete() // 문서 삭제
      
      // Option 2: 경로를 모를 때
      db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments(completion: { snapshot, _ in
        guard let document = snapshot?.documents.first else {
          print("ERROR")
          return
        }
        document.reference.delete()
      })
    }
  }
}

/*
 - 카드 이미지: 오픈소스를 사용하여 셀에 전달
 - 보통 이미지를 표현할 때 이미지 자체를 서버에서 다운로드 하거나 기기에 모든 이미지를 저장한 상태에서 표현하지 않음 -> 이미지 Url만 전달받은 상태에서 그것을 이미지 뷰에 표현
 - Url 이미지를 편리하게 표현하게 도와주는 오픈소스: Kingfisher
 
 - Realtime Database는 snapshot을 통해 데이터를 불러옴 -> reference에서 값을 지켜보고 있다가 값을 snapshot 객체로 전달, 해당 객체를 클로저 내에서 가공하여 이용
 - snapshot.value: 우리가 이해하고 있는 데이터베이스의 자료구조 형태를 지정해주는 것 -> as? 캐스팅으로 정확한 데이터 타입을 지정해주지 않으면 데이터베이스는 snapshot에서 전달받은 값을 이해하지 못해서 nil 방출
 
 - 데이터 구조에 따라 Key를 임의의 문자열 조합으로 설정하기 때문에(id 중복 방지) 어떤 id일지 모르기 때문에 객체가 생성된 후에 확인 가능 -> 코드 작성 시점에는 해당 객체가 어떤 id를 가지게 될지 모름 -> 객체의 특정 component 값을 검색(query)하여 찾기 가능 (특정 값을 검색하여 객체의 snapshot 가져오기) 즉, 객체의 Key는 몰라도 component ex) id(객체가 가지는 고유한 값) 와 같은 값을 검색하여 찾는 것
 
 - 데이터 삭제는 nil 값을 대입하는 것이므로 쓰기와 같음
 - 또한 Firebase에서 삭제를 좀 더 명시적으로 표현하는 removeValue 제공 -> 마찬가지로 경로를 알 때와 모를 때 2가지 옵션
 
 - Realtime Database의 setValue() == Firestore의 updateData()
 */
 
