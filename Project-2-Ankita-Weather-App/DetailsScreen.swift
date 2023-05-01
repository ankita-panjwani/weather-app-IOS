//
//  DetailsScreen.swift
//  Project-2-Ankita-Weather-App
//
//  Created by Ankita Panjwani on 2023-04-01.
//

import UIKit

class DetailsScreen: UIViewController {
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeatherCondition: UILabel!
    @IBOutlet weak var highTemperature: UILabel!
    @IBOutlet weak var lowTemperature: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    
    var locationItem: LocationItem?
    var weatherData: WeatherResponse?
    var dateWeather: String = ""
    var dayOfTheWeek: String = ""
    var weatherCode: Int = 0
    
    private var forecastItems: [LocationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        forecastTableView.dataSource = self
        // Do any additional setup after loading the view.
        if let locationItem = locationItem {
            locationName.text = "\(locationItem.weatherDataForecast?.location.name ?? "")"
            currentTemperature.text = "\(locationItem.weatherDataForecast?.current.temp_c ?? 0.0) °C"
            currentWeatherCondition.text = "\(locationItem.weatherDataForecast?.current.condition?.text ?? "")"
            highTemperature.text = "H: \(locationItem.weatherDataForecast?.forecast.forecastday[0].day?.maxtemp_c ?? 0.0) °C"
            lowTemperature.text = "L: \(locationItem.weatherDataForecast?.forecast.forecastday[0].day?.mintemp_c ?? 0.0) °C"
        }
        
        print("forecast data list: \(String(describing: locationItem?.weatherDataForecast?.forecast.forecastday))")
    }
}

extension DetailsScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationItem?.weatherDataForecast?.forecast.forecastday.count ?? 0
    }
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastDaysList", for: indexPath)
        let item = locationItem?.weatherDataForecast?.forecast.forecastday[indexPath.row]
        var content = cell.defaultContentConfiguration()
        if let date = item?.date, let code = item?.day?.condition?.code {
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: date)!
            let mycalendar = Calendar.current
            let weekday = mycalendar.component(.weekday, from: date)
            let weekdayName = dateFormatter.weekdaySymbols[weekday - 1]
            dayOfTheWeek = weekdayName
            weatherCode = code
        }

        content.text = "\(dayOfTheWeek)"
        content.secondaryText = "\(item?.day?.avgtemp_c ?? 0.0) °C"
        content.image = UIImage(systemName: "\(codesImagesData["\(weatherCode)"] ?? "")")
        cell.contentConfiguration = content
        return cell
    }
}



