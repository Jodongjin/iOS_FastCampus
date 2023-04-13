//
//  Content.swift
//  NetflixStyleSampleApp
//
//  Created by 조동진 on 2022/02/15.
//

import Foundation
import UIKit

// 데이터 구조체: 프로퍼티 리스트에 대한 디코딩이 필요 (인코딩 액션은 x)
struct Content: Decodable {
  let sectionType: SectionType
  let sectionName: String
  let contentItem: [Item]

  enum SectionType: String, Decodable {
    case basic
    case main
    case large
    case rank
    
    var identifier: String {
      switch self {
      case .basic:
        return "ContentCollectionViewCell"
      case .main:
        return "ContentCollectionViewMainCell"
      case .large:
        return "ContentCollectionViewLargeCell"
      case .rank:
        return "ContentCollectionViewRankCell"
      }
    }
  }
}

struct Item: Decodable {
  let description: String
  let imageName: String
  
  // imageName 프로퍼티의 이름을 가지는 이미지를 return
  var image: UIImage {
    return UIImage(named: imageName) ?? UIImage()
  }
}
