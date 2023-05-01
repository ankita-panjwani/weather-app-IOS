//
//  WeatherStructs.swift
//  Project-2-Ankita-Weather-App
//
//  Created by Ankita Panjwani on 2023-04-02.


import CoreLocation
import Foundation

struct LocationItem {
    let temperature: String
    let locationImage: String
    let weatherDataForecast: WeatherResponse?
}

struct WeatherResponse: Decodable {
    var location: Location
    let current: Weather
    let forecast: Forecast
    
    mutating func updateCoordinates(latitude: Double, longitude: Double) {
        location.lat = latitude
        location.lon = longitude
    }
}

struct Location: Decodable {
    let name: String
    var lat: Double
    var lon: Double
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let feelslike_c: Float
    let condition: WeatherCondition?
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
    let icon: String
}

struct Forecast: Decodable {
    let forecastday: [ForecastLists]
}

struct ForecastLists: Decodable {
    let day: Temperatures?
    let date: String
}

struct Temperatures: Decodable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: WeatherCondition?
}
