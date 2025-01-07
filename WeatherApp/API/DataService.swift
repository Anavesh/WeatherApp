import Foundation

class DataService {
    func fetchWeatherData(completion: @escaping (Result<WeatherData,Error>)-> Void) {
        let weatherURL = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/SaintPetersburg?unitGroup=uk&key=RSCXCH2KW49822H3WMA2Y26RF&contentType=json"
        
        guard let urlForRequest = URL(string: weatherURL) else {
            completion(.failure(NSError(domain: "URLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        URLSession.shared.dataTask(with: urlForRequest) {data, response, error in
            
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                let errorMessage: String
                switch response.statusCode {
                case 404:
                    errorMessage = "Resource not found(404)"
                case 500:
                    errorMessage = "Server error(500)"
                default:
                    errorMessage = "HTTPS status code \(response.statusCode)"
                }
                completion(.failure(NSError(domain: "HTTP error", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:errorMessage])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data error", code: 1, userInfo: [NSLocalizedDescriptionKey:"Failed to obtain data"])))
                return
            }
                
                do {
                    let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(NSError(domain: "Decoding error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data"])))
                }

        }.resume()
    }
}
