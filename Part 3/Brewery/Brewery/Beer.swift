//
//  Beer.swift
//  Brewery
//
//  Created by 조동진 on 2022/02/16.
//

import Foundation

struct Beer: Decodable {
  let id: Int?
  let name, taglineString, description, brewersTips, imageURL: String?
  let foodPairing: [String]?
  
  // hashtag String edit
  var tagLine: String {
    let tags = taglineString?.components(separatedBy: ". ") // String Array
    let hashtags = tags?.map {
      "#" + $0.replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: ".", with: "")
        .replacingOccurrences(of: ",", with: " #")
    }
    return hashtags?.joined(separator: " ") ?? "" // ex) #tag #good #work
  }
  
  // 실제 서버에서 보내주는 키 값으로 매칭
  enum CodingKeys: String, CodingKey {
    case id, name, description // 그대로 사용
    case taglineString = "tagline"
    case imageURL = "image_url"
    case brewersTips = "brewers_tips"
    case foodPairing = "food_pairing"
  }
}
