//
//  WeatherInformation.swift
//  Weather
//
//  Created by 조동진 on 2022/02/05.
//

// openWeatherMap에서 제공하는 JSON 데이터를 받기 위한 구조체

import Foundation

struct WeatherInformation: Codable {
  let weather: [Weather]
  let temp: Temp
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case weather
    case temp = "main" // JSON의 "main" 키와 매핑
    case name
  } // weather, name은 JSON의 키 값과 이름이 일치함
}

struct Weather: Codable {
  let id: Int
  let main: String
  let description: String
  let icon: String
}

struct Temp: Codable {
  let temp: Double
  let feelsLike: Double
  let minTemp: Double
  let maxTemp: Double
  
  enum CodingKeys: String, CodingKey {
    case temp
    case feelsLike = "feels_like"
    case minTemp = "temp_min"
    case maxTemp = "temp_max"
  } // 구조체에서 정의한 프로퍼티와 서버에서 제공하는 JSON 데이터의 키 값이 달라도 정상적으로 매핑 가능
}


/*
 - Codable Protocol: 자신을 변환하거나 외부 표현(ex: JSON)으로 변환할 수 있는 타입
 - Codable: Decodable과 Encodable을 준수함
 - Decodable: 자신을 외부 표현에서 디코딩 할 수 있는 타입
 - Encodable: 자신을 외부 표현에서 인코딩 할 수 있는 타입
 - 즉, Codable Protocol을 채택 -> JSON 디코딩 & 인코딩 모두 가능 (WeatherInformation 객체를 JSON 형태로 만들 수 있고, JSON 형태를 WeatherInformation 객체로 만들 수 있음)
 - 해당 프로젝트에서는 서버에서 전달 받은 JSON 데이터를 WeatherInformation으로 변환 (디코딩)
 - JSON 형태의 데이터를 변환하고자 할 때, 기본적으로 JSON 타입의 키와 사용자가 정의한 프로퍼티 이름과 타입이 일치해야 함 (Weather Struct) / 만약, 다르게 사용하고 싶다면 타입 내부에서 CodingKeys라는 String 타입의 열거형을 선언하고 CodingKey Protocol을 준수하게 만들어야 함 -> Weather 구조체는 같게, Temp 구조체는 다르게 매핑
 - openWeatherMap에서 제공하는 JSON에 "weather" 배열 안에 id, main, description, icon을 프로퍼티로 하는 객체가 있기 때문에 배열 안 객체를 Weather 구조체로 매핑하고 "weather" 배열 이름을 WeatherInfomation의 프로퍼티 이름으로 매핑
 - 마찬가지로 JSON의 "main"키에 있는 객체를 Temp 구조체에 매핑
 */
