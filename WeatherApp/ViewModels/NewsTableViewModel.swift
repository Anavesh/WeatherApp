import Foundation

final class NewsTableViewModel {
    
    // MARK: Variables
    private var articleResponse: NewsData?
    var articles: [Article] {
        articleResponse?.articles ?? []
    }
    
    // MARK: Obtaining data for the UITableView
    func loadArticles(completion: @escaping (Result<Void, Error>) -> Void) {
        APIService.shared.fetchData(with: ServiceURLs.newsURL, resultType: NewsData.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let newsData):
                self.articleResponse = newsData
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    // MARK: Reset data for the UITableView
    func resetData() {
        articleResponse = nil
    }
}
