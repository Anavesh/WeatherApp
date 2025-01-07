import Foundation

final class APIService {
    
    static let shared = APIService()
    
    func fetchData <T:Decodable> (with url: String, resultType: T.Type, completion: @escaping(Result <T,Error>) -> Void) {
        guard let urlForRequest = URL(string:url) else {completion(.failure(NSError(domain: "URL error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        URLSession.shared.dataTask(with: urlForRequest) {data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse, !(response.statusCode == 200) {
                let errorMessage: String
                switch response.statusCode {
                case 404:
                    errorMessage = "Resource not found(404). The request cannot be matched to any valid API request endpoint structure"
                case 401:
                    errorMessage = "Unauthorized(401). There is a problem with the API key, account or subscription."
                case 400:
                    errorMessage = "Bad request(400). The format of the API is incorrect or an invalid parameter or combination of parameters was supplied"
                case 429:
                    errorMessage = "Too many requests(429). The account has exceeded their assigned daily request limits."
                case 500:
                    errorMessage = "Internal server error(500). An error has occurred processing the request"
                default:
                    errorMessage = "HTTP status code: \(response.statusCode)"
                }
                completion(.failure(NSError(domain: "HTTP error", code: 1, userInfo: [NSLocalizedDescriptionKey : errorMessage])))
                return
        }
            guard let data = data else {completion(.failure(NSError(domain: "Data failure", code: 2, userInfo: [NSLocalizedDescriptionKey:"Failed to obtain data"])))
                return
            }
            
            guard !data.isEmpty else { completion(.failure(NSError(domain: "Empty data", code: 3, userInfo: [NSLocalizedDescriptionKey:"Obtained data is empty"])))
                return
            }
            
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(NSError(domain: "Decoding failure", code: 4, userInfo: [NSLocalizedDescriptionKey:"Failed to decode data"])))
                }
            
        }.resume()
    }
}
