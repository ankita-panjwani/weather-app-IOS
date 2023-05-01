//
//  ViewController.swift
//  Project-2-Ankita-Weather-App
//
//  Created by Ankita Panjwani on 2023-04-01.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private var locationManager: CLLocationManager!
    var selectedListItem : LocationItem?
    var coordinateVal: CLLocation?
    var weatherDataForecast: WeatherResponse?
    private var latitudeNum: Double?
    private var longitudeNum: Double?
    private var items: [LocationItem] = []
    
    var imageNam: String?
    var weatherCode: Int = 0
    var tempFarenValue: Float = 0.0
    var tempCelsius: Float = 0.0
    var feelsLikeCelsiusTemp: Float = 0.0
    var weatherCondition: String = ""
    var maxTemp: Float = 0.0
    var minTemp: Float = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.delegate =  self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            latitudeNum = location.coordinate.latitude
            longitudeNum = location.coordinate.longitude
            let query  = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            setupMap()
            loadWeather(search: query, setWeather: setWeatherDetails(weatherData:))
        }
    }
    
    private func getLocation() -> CLLocation {
        return CLLocation(latitude: latitudeNum ?? 0.0, longitude: longitudeNum ?? 0.0)
    }
    
    func setWeatherDetails(weatherData: WeatherResponse) -> Void{
        weatherDataForecast = weatherData
        coordinateVal = getLocation()
        var newWeatherUpdatedData = WeatherResponse(location: weatherData.location, current: weatherData.current, forecast: weatherData.forecast)
        newWeatherUpdatedData.updateCoordinates(latitude: latitudeNum!, longitude: longitudeNum!)
        
        coordinateVal = getLocation()
        let locationItem = LocationItem(temperature: "\(weatherData.current.temp_c)° C (H: \(weatherData.forecast.forecastday[0].day?.maxtemp_c ?? 0.0) °C   L: \(weatherData.forecast.forecastday[0].day?.mintemp_c ?? 0.0) °C)", locationImage: "\(codesImagesData["\(weatherData.current.condition?.code ?? 0)"] ?? "")", weatherDataForecast: newWeatherUpdatedData)
        setAnnotation(locationItem: locationItem, coordinate: coordinateVal!)
    }
    
    func setAnnotation(locationItem: LocationItem, coordinate: CLLocation){
        selectedListItem = locationItem
        coordinateVal = coordinate
        latitudeNum = locationItem.weatherDataForecast?.location.lat
        longitudeNum = locationItem.weatherDataForecast?.location.lon
        tempCelsius = locationItem.weatherDataForecast?.current.temp_c ?? 0.0
        weatherCode = locationItem.weatherDataForecast?.current.condition?.code ?? 0
        setupMap()
        addAnnotation(location: coordinate, locationItem: locationItem)
        items.append(locationItem)
        tableView.reloadData()
    }
    
    func addAnnotation(location: CLLocation, locationItem: LocationItem){
        let annotation = MyAnnotation(coordinate: location.coordinate, title: "\(locationItem.weatherDataForecast?.current.condition?.text ?? "")", subtitle: "Temp: \(locationItem.weatherDataForecast?.current.temp_c ?? 0.0) °C, Feels like: \(locationItem.weatherDataForecast?.current.feelslike_c ?? 0.0) °C", glyphText: "\(locationItem.weatherDataForecast?.current.temp_c ?? 0.0)°")
        mapView.addAnnotation(annotation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            if let latitude = latitudeNum, let longitude = longitudeNum{
                print("Current Location in if:: Latitude: \(latitude), Longitude: \(longitude)")
            }
            
        case .denied: print("Location authorization denied")
            
        case .authorized: print("Location authorized")
            
        case .notDetermined: print("Location not determined")
            
        case .restricted: print("Location Restricted")
            
        @unknown default:
            fatalError()
        }
    }
    
    
    @IBAction func goToAddLocationScreen(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddLocationScreen", sender: self)
    }
    
    
    
    private func setupMap(){
        let location = getLocation()
        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate , latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
        
        //        camera boundaries
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundary, animated: true)
        
        // control boundaries
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
}





extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationsList", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.weatherDataForecast?.location.name
        content.secondaryText = item.temperature
        content.image = UIImage(systemName: item.locationImage)
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationItem = items[indexPath.row]
        selectedListItem = locationItem
        latitudeNum = locationItem.weatherDataForecast?.location.lat
        longitudeNum = locationItem.weatherDataForecast?.location.lon
        weatherCode = locationItem.weatherDataForecast?.current.condition?.code ?? 0
        tempCelsius = locationItem.weatherDataForecast?.current.temp_c ?? 0.0
        let newCoordinate = getLocation()
        addAnnotation(location: newCoordinate, locationItem: locationItem)
        setupMap()
        
    }
}



extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "whatisthis?"
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: 0, y: 10)
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button
        
        if let image = codesImagesData["\(self.weatherCode)"]{
            let image = UIImage(systemName: image)
            view.leftCalloutAccessoryView = UIImageView(image: image)
        }
        view.tintColor = UIColor.systemCyan
        if(tempCelsius >= 35.0){
            view.markerTintColor = UIColor(red: 139/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
        else if(tempCelsius >= 25.0 && tempCelsius < 35.0){
            view.markerTintColor = UIColor.orange
        }
        else if(tempCelsius >= 17.0 && tempCelsius < 25.0){
            view.markerTintColor = UIColor.yellow
        }
        else if(tempCelsius >= 12.0 && tempCelsius < 17.0){
            view.markerTintColor = UIColor.blue
        }
        else if(tempCelsius >= 0.0 && tempCelsius < 12.0){
            view.markerTintColor = UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 1.0)
        }
        else if(tempCelsius < 0.0){
            view.markerTintColor = UIColor.purple
        }
        
        //        setting the glyph text
        if let myAnnotation = annotation as? MyAnnotation{
            view.glyphText = myAnnotation.glyphText
        }
        return view
    }
    
    //    Detail Closure button tapped action function
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        performSegue(withIdentifier: "goToDetailsScreen", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddLocationScreen"{
            
            let destination = segue.destination as! AddNewLocation
            destination.callBackLocation = setAnnotation
        }
        
        if segue.identifier == "goToDetailsScreen"{
            let destination = segue.destination as! DetailsScreen
            destination.locationItem = selectedListItem
            destination.weatherData = weatherDataForecast
        }
    }
}


class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
        super.init()
    }
}





