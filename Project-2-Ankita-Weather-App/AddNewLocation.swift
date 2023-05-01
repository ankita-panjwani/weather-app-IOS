//
//  AddNewLocation.swift
//  Project-2-Ankita-Weather-App
//
//  Created by Ankita Panjwani on 2023-04-03.
//

import UIKit
import CoreLocation

class AddNewLocation: UIViewController {
    
    @IBOutlet weak var userEnteredLocation: UITextField!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var callBackLocation: ((_ locationItem: LocationItem, _ coordinate: CLLocation) -> Void)?
    var selectedLocationItem: LocationItem?
    var weatherData: WeatherResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySimpleImage()
        saveBtn.isEnabled = false
    }
    
    private func displaySimpleImage(){
        let config = UIImage.SymbolConfiguration(paletteColors:   [
            .systemYellow ,.systemBlue,  .systemRed
        ])
        weatherImage.preferredSymbolConfiguration =  config
        weatherImage.image = UIImage(systemName: "sun.max.fill")
    }
    
    func setWeatherData(data: WeatherResponse){
        weatherCondition.text = data.current.condition?.text
        temperature.text = "\(data.current.temp_c) °C"
        locationName.text = userEnteredLocation.text
        
        if let image = codesImagesData["\(data.current.condition?.code ?? 0)"] {
            weatherImage.image = UIImage(systemName: image)
        }
        selectedLocationItem = LocationItem(temperature: "\(data.current.temp_c ) °C (H: \(data.forecast.forecastday[0].day?.maxtemp_c ?? 0.0) °C   L: \(data.forecast.forecastday[0].day?.mintemp_c ?? 0.0) °C)", locationImage: "\(codesImagesData["\(data.current.condition?.code ?? 0)"] ?? "")", weatherDataForecast: data)
            weatherData = data
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func onSaveLocationItem(_ sender: UIBarButtonItem) {
        let coordinate = CLLocation(latitude: CLLocationDegrees(weatherData!.location.lat), longitude: CLLocationDegrees(weatherData!.location.lon))
        callBackLocation!(selectedLocationItem!, coordinate)
        dismiss(animated: true)
    }
    
    
    @IBAction func searchLocationBtn(_ sender: UIButton) {
        saveBtn.isEnabled = true
        loadWeather(search: userEnteredLocation.text, setWeather: setWeatherData(data: ))
    }
    
}
