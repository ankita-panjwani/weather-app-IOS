//
//  apiCall.swift
//  Project-2-Ankita-Weather-App
//
//  Created by Ankita Panjwani on 2023-04-02.
//

import Foundation



func loadWeather(search: String?, setWeather: ((WeatherResponse) -> Void)?){
    guard
        let search = search,
        let url =  getURL(cityName: search)
    else { return }
    let session = URLSession.shared
    let dataTask = session.dataTask(with: url) { data, response, error in
        print("Network call finished")
        
        guard error == nil else {
            print("Error received: \(String(describing: error))")
            return
        }
        
        guard let data = data else {
            print("No data found")
            return
        }
        
        if let weatherData = parseJson(data: data){
            DispatchQueue.main.async {
                if let setWeather = setWeather {
                    (setWeather(weatherData))
                }
            }
        }
    }
    dataTask.resume()
}

private func parseJson(data: Data) -> WeatherResponse? {
    let decoder = JSONDecoder()
    var weather: WeatherResponse?
    do{
        weather = try decoder.decode(WeatherResponse.self, from: data)
    }
    catch {
        print("Error decoding: \(error)")
    }
    return weather
}

private func getURL(cityName: String) -> URL? {
    let baseUrl = "https://api.weatherapi.com/v1/"
    let currentWeatherEndpoint = "forecast.json"
//    let apiKey = "049e70990558421a91d172041231403"
    let apiKey = "bf2c5b55906c46f9831142522230704"
    guard let url = "\(baseUrl)\(currentWeatherEndpoint)?key=\(apiKey)&q=\(cityName)&days=7&aqi=no&alerts=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        return nil
        
    }
    return URL(string: url)
}

