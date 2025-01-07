import Foundation

struct WeatherData: Decodable {
    let address: String
    let timezone: String
    let description: String
    let days: [DayWeather]
}

struct DayWeather: Decodable {
    let datetime: String
    let tempmax: Double
    let tempmin: Double
    let temp: Double
    let humidity: Double
    let windspeed: Double
    let pressure: Double
    let cloudcover: Double
    let conditions: String
    let icon: String
}
