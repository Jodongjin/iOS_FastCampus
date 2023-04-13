//
//  HomeViewController.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/15.
//

import UIKit
import SwiftUI

class HomeViewController: UICollectionViewController {
  var contents: [Content] = []
  var mainItem: Item?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // CollectionView 설정
    collectionView.backgroundColor = .black
    
    // 네이게이션 설정
    navigationController?.navigationBar.backgroundColor = .clear
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.hidesBarsOnSwipe = true // 스크롤을 통한 스와이프 액션 시 네비게이션 바 가림
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "netflix_icon"), style: .plain, target: nil, action: nil)
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: nil, action: nil)
    
    // Data 가져오기
    contents = getContents()
    mainItem = contents.first?.contentItem.randomElement() // Main section 중 무작위 item을 뽑아 mainItem으로 setting
    
    // CollectionView Item(Cell) 설정
    collectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: "ContentCollectionViewCell") // Basic, Large Cell register
    collectionView.register(ContentCollectionViewRankCell.self, forCellWithReuseIdentifier: "ContentCollectionViewRankCell") // Rank Cell register
    collectionView.register(ContentCollectionViewMainCell.self, forCellWithReuseIdentifier: "ContentCollectionViewMainCell") // Main Cell register
    collectionView.register(ContentCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentCollectionViewHeader") // Header 설정
    collectionView.collectionViewLayout = layout()
  }
  
  // plist에서 Content 객체로 데이터들을 불러오는 함수
  func getContents() -> [Content] {
    guard let path = Bundle.main.path(forResource: "Content", ofType: "plist"), // plist 경로
          let data = FileManager.default.contents(atPath: path), // 해당 경로의 데이터 추출
          let list = try? PropertyListDecoder().decode([Content].self, from: data) else { return [] } // 디코딩
    
    return list
  }
  
  // 각각의 섹션 타입에 대한 UICollectionViewLayout 설정
  private func layout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { [weak self] sectionNumber, environment -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      
      switch self.contents[sectionNumber].sectionType {
      case .basic:
        return self.createBasicTypeSection()
      case .large:
        return self.createLargeTypeSection()
      case .rank:
        return self.createRankTypeSection()
      case .main:
        return self.createMainTypeSection()
      }
    }
  }
  
  // Basic Type Section Layout
  private func createBasicTypeSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(0.75))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 10, leading: 5, bottom: 0, trailing: 5)
    
    // group setting
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
    
    // section setting
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    // 헤더 추가 (basic section type의 경우에만)
    let sectionHeader = self.createSectionHeader()
    section.boundarySupplementaryItems = [sectionHeader]
    
    return section
  }
  
  // Large Type Section Layout (Basic Tpye과 사이즈만 다름)
  private func createLargeTypeSection() -> NSCollectionLayoutSection {
    // item setting -> itemSize가 Basic과 같은 이유는 그룹 사이즈를 다르게 할 것이기 때문 (itemSize는 분수값이므로 그룹 사이즈가 늘어나면 그 안에 아이템 사이즈도 늘어남)
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.75))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 10, leading: 5, bottom: 0, trailing: 5)
    
    // group setting
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(400)) // height 두 배
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
    
    // section setting
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    let sectionHeader = self.createSectionHeader()
    section.boundarySupplementaryItems = [sectionHeader]
    
    return section
  }
  
  // Rank Type Section Layout
  private func createRankTypeSection() -> NSCollectionLayoutSection {
    // item setting
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.9))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 10, leading: 5, bottom: 0, trailing: 5)
    
    // group setting
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
    
    // section setting
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    let sectionHeader = self.createSectionHeader()
    section.boundarySupplementaryItems = [sectionHeader]
    
    return section
  }
  
  // Rank Type Section Layout (Header x)
  private func createMainTypeSection() -> NSCollectionLayoutSection {
    // item setting
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    // group setting
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(450))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
    // section setting
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
    
    return section
  }
  
  // SectionHeader layout 설정
  private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    // Section Header 사이즈
    let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30))
    
    // Section Header Layout
    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
    
    return sectionHeader
  }
}

// UICollectionView DataSource: CollectionView의 설정
extension HomeViewController {
  // 섹션 당 보여질 셀의 개수
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1 // 첫 번째 섹션에서 하나의 셀만 보여줌
    default:
      return contents[section].contentItem.count // 나머지 섹션은 contentItem의 개수만큼 셀 표기
    }
  }
  
  // CollectionView 셀 설정
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch contents[indexPath.section].sectionType {
    case .basic, .large: // 이미지만 보여주는 Cell (ContentCollectionViewCell)
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as? ContentCollectionViewCell else { return UICollectionViewCell() }

      cell.imageView.image = contents[indexPath.section].contentItem[indexPath.row].image // 셀에 이미지 설정
      
      return cell
      
    case .rank:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewRankCell", for: indexPath) as? ContentCollectionViewRankCell else { return UICollectionViewCell() }
      
      cell.imageView.image = contents[indexPath.section].contentItem[indexPath.row].image
      cell.rankLabel.text = String(describing: indexPath.row + 1) // "1"위부터 표시
      
      return cell
      
    case .main:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewMainCell", for: indexPath) as? ContentCollectionViewMainCell else { return UICollectionViewCell() }
      
      cell.imageView.image = mainItem?.image
      cell.descriptionLabel.text = mainItem?.description
      return cell
    }
  }
  
  // 섹션 개수 설정
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return contents.count // plist의 Item 개수 == 섹션 개수 (6)
  }
  
  // 헤더 뷰 설정
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
      guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ContentCollectionViewHeader", for: indexPath) as? ContentCollectionViewHeader else { fatalError("Could not dequeue Header") }
      
      headerView.sectionNameLabel.text = contents[indexPath.section].sectionName
      
      return headerView
    } else {
      return UICollectionReusableView()
    }
  }
}

// UICollectionView Delegate: 셀 선택 액션 설정
extension HomeViewController {
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let sectionName = contents[indexPath.section].sectionName
    print("TEST: \(sectionName)섹션의 \(indexPath.row + 1) 번째 컨텐츠")
  }
}

/*
// SwiftUI를 활용한 미리보기
struct HomeViewController_Previews: PreviewProvider {
  static var previews: some View {
    Container().edgesIgnoringSafeArea(.all)
  }
  
  struct Container: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
      let layout = UICollectionViewLayout()
      let homeViewController = HomeViewController(collectionViewLayout: layout)
      return UINavigationController(rootViewController: homeViewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    typealias UIViewControllerType = UIViewController
  }
}
*/

/*
 - SceneDelegate -> willConnectTo session에서 layout = UICollectionViewFlowLayout(): 빈 플로우 레이아웃으로 설정했지만 실제로 뷰가 켜지고 나면 viewDidLoad() -> collectionView.collectionViewLayout = layout()으로 레이아웃을 새로 설정
 - Composisional Layout에서 사이즈를 만들고 싶을 때: NSCollectionLayoutSize()
 */
