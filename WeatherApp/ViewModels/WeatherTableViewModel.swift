import Foundation

final class WeatherViewModel {
    
    struct WeatherViewData {
        let cityName: String
        let weatherIcon: String
        let temperatureLabel: String
    }
    // MARK: Variables
    private var weatherData: WeatherData? {
        didSet {
            guard let weatherData = weatherData else { return }
            updateWeatherViewState?(makeWeatherViewData(from: weatherData))
        }
    }
    var weatherDays: [DayWeather] {
        return weatherData?.days ?? []
    }
    
    var updateWeatherViewState: ((WeatherViewData) -> Void)?
    
    let weatherIconMap: [String: String] = [
           "clear-day": "sun.max",
           "clear-night": "moon",
           "rain": "cloud.rain",
           "snow": "cloud.snow",
           "sleet": "cloud.sleet",
           "wind": "wind",
           "fog": "cloud.fog",
           "cloudy": "cloud",
           "partly-cloudy-day": "cloud.sun",
           "partly-cloudy-night": "cloud.moon"
       ]
    
    // MARK: Obtaining weather data for the UIViewTable
    func fetchWeatherData(completion: @escaping(Result<Void,Error>)-> Void) {
        APIService.shared.fetchData(with:ServiceURLs.weatherURL(for: ServiceURLs.city), resultType: WeatherData.self) {[weak self] result in
            guard let self = self else {completion(.failure(NSError(domain: "Self released", code: 5, userInfo: [NSLocalizedDescriptionKey:"The view model was released before data was obtained"])))
                return
            }
            switch result{
            case.success(let data):
                DispatchQueue.main.async {
                    self.weatherData = data
                    completion(.success(()))
                }
            case .failure(let error):
                print("The following error occurred during decoding: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func makeWeatherViewData(from weatherData: WeatherData) -> WeatherViewData {
        let formattedCityName = formatCityName(weatherData.address)
        guard let firstDay = weatherData.days.first else {
            return WeatherViewData(cityName: "Неизвестно", weatherIcon: "questionmark", temperatureLabel: "N/A")
        }
       let weatherIcon = weatherIconMap[firstDay.icon] ?? "questionmark"
       let temperatureLabel = "\(Int(firstDay.temp))°C"
       
       return WeatherViewData(cityName: formattedCityName,
                              weatherIcon: weatherIcon,
                              temperatureLabel: temperatureLabel)
   }
    
    // MARK: Setup of weather icon for each day
    func iconForDay(for index: Int) -> String? { 
        let day = weatherDays[index]
        return weatherIconMap[day.icon]
    }
    
    
    private func formatCityName(_ cityName: String) -> String {
        guard !cityName.contains(" ") else { return cityName }
        
        return cityName.reduce(into: "") { result, character in
            if character.isUppercase && !result.isEmpty {
                result += " "
            }
            result.append(character)
        }
    }
    // MARK: Reseting data
    func resetData() {
        weatherData = nil
        updateWeatherViewState?(WeatherViewData(cityName: "", weatherIcon: "", temperatureLabel: ""))
    }
}
