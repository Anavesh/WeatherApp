import Foundation

class WeatherCellModel {
    // MARK: Properties
    private var weatherData: WeatherData?
    private let weatherService = WeatherService()
    
    var daysWeather: [DayWeather] {
        return weatherData?.days ?? []
    }

    // MARK: Fetch Weather Data
    func fetchWeather(completion: @escaping (Result<Void, Error>) -> Void) {
        weatherService.fetchWeatherData { [weak self] result in
            switch result {
            case .success(let data):
                self?.weatherData = data
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Get Weather Info for a Day
    func weatherInfo(for index: Int) -> DayWeather? {
        guard index < daysWeather.count else { return nil }
        return daysWeather[index]
    }
}
