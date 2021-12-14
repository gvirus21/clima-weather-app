//
//  WeatherManager.swift
//  Clima
//
//  Created by Gourav Kumar on 10/12/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

import Foundation
import CoreLocation

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b61d92adff357c3d89b6989c080465a1&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url, completionHandler: handle(data: response: error: ))
        
        task.resume()
        
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            delegate?.didFailWithError(error: error!)
            return
        }
        
        guard let safeData = data else { return }
        
        guard let weather = self.parseJSON(safeData) else { return }
        
        self.delegate?.didUpdateWeather(self, weather: weather)
       
    }
    
    func parseJSON(_ weatherData: Data)  -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    

}
