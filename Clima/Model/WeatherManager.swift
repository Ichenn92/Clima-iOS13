//
//  WeatherManager.swift
//  Clima
//
//  Created by Tristan Hörler on 05.12.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
	func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
	func didFailWithError(error: Error)
}

struct WeatherManager {
        //Temporary API key - change api key to make it work
	let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=d67f59a3e4d73d9747bdd67988476778"
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
		if let url = URL(string: urlString) {
			let session = URLSession(configuration: .default)
			let task = session.dataTask(with: url) { (data, response, error) in
				if error != nil {
					delegate?.didFailWithError(error: error!)
					return
				}
				if let safeData = data {
					if let weather = parseJSON(safeData) {
						delegate?.didUpdateWeather(self, weather: weather)
					}
				}
			}
			task.resume()
		}
	}
	
	func parseJSON(_ weatherData: Data) -> WeatherModel? {
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
