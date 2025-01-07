import Foundation

struct ServiceURLs {
    static var city = "Default city"
    static func weatherURL (for city: String) -> String {
        return "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(city)?unitGroup=uk&key=\(APIKeys.weatherAPIKey)&contentType=json"
    }
    
    static var newsURL: String { 
        return "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=\(APIKeys.newsAPIKey)"
    }
}
