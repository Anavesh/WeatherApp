import Foundation

struct APIKeys {
    static let weatherAPIKey = "RSCXCH2KW49822H3WMA2Y26RF"
    static let newsAPIKey = "1d1fcf828b574509bb475a706dbd5246"
}
   

struct ServiceURLs {
   static let weatherURL = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/Cordoba?unitGroup=uk&key=\(APIKeys.weatherAPIKey)&contentType=json"
    
    static let newsURL = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=\(APIKeys.newsAPIKey)"
}

