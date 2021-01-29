//
//  WeatherManager3.swift
//  Clima
//
//  Created by Matty Shenkman on 8/17/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
   }


struct WeatherManager{
    
    var delegate: WeatherManagerDelegate?
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=6c9b7d37c65c01873af2809ea46d15bf&units=imperial"
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    func fetchWeather(_ lat: Double,_ lon: Double){
        let urlString = "\(weatherUrl)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String){
        //1. create url
        if let url = URL(string: urlString){
            
            //2. create url session
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, respose, error) in
                if (error != nil){
                    self.delegate?.didFailWithError(error: error!)
                           return
                       }
                       
                       if let safeData = data {
                        if let weather = self.parseJson(safeData){
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                       }
                   }
            //4. Start Task
            task.resume()
            }
    
        }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
