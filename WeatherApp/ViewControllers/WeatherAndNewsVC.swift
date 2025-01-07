import UIKit

class WeatherAndNewsVC: UIViewController {
    
    // MARK: Variables and Constants
    private var weatherModel = WeatherViewModel()
    private let newsTableViewModel = NewsTableViewModel()
    
    let topPadding: CGFloat = 12
    let weatherImageSize: CGFloat = 100
    let tableViewSpacing: CGFloat = 20
    let newsTableHeightMultiplier: CGFloat = 0.15
    let weatherTableHeightMultiplier: CGFloat = 0.35
    
    // MARK: UI Elements
    
    let cityNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Here will be city name"
        label.textAlignment = .center
        label.font = UIFont(name: "Roboto-Bold", size: 28)
        label.textColor = .white
        return label
    }()
    
    let weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "questionmark")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "Here will be temperature"
        label.textAlignment = .center
        label.font = UIFont(name: "Roboto-Bold", size: 36)
        label.textColor = .white
        return label
    }()
    
    let weatherTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        return table
    }()
    
    let newsTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        return table
    }()
    
    let backgroundImage: UIImageView = {
        let background = UIImageView(frame: UIScreen.main.bounds)
        background.image = UIImage(named: "Mountains.Sunset")
        background.contentMode = .scaleAspectFill
        return background
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableViews()
        fetchDataForUITableViews()
        bindWeatherModel()
    }
    
    // MARK: Setup Views and Constraints
    
    private func setupView() {
        setBackgroundImage()
        [cityNameLabel, weatherImage, temperatureLabel, newsTableView, weatherTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false; view.addSubview($0)
        }
        setConstraints()
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // City Name Label
            cityNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topPadding),
            cityNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Weather Image
            weatherImage.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: topPadding),
            weatherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImage.widthAnchor.constraint(equalToConstant: weatherImageSize),
            weatherImage.heightAnchor.constraint(equalToConstant: weatherImageSize),

            // Temperature Label
            temperatureLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: topPadding),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // News TableView
            newsTableView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: tableViewSpacing),
            newsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: newsTableHeightMultiplier),

            // Weather TableView
            weatherTableView.topAnchor.constraint(equalTo: newsTableView.bottomAnchor, constant: tableViewSpacing),
            weatherTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            weatherTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: weatherTableHeightMultiplier),
        ])
    }
    
    // MARK: Fetch Data
    
    private func fetchDataForUITableViews() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        weatherModel.fetchWeatherData { [weak self] result in
            switch result {
            case .success:
                print("Weather data fetched successfully")
                DispatchQueue.main.async {
                    self?.weatherTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching weather data: \(error)")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        newsTableViewModel.loadArticles { [weak self] result in
            switch result {
            case .success:
                print("News data fetched successfully")
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.newsTableView.reloadData()
                    self.bindWeatherModel()
                }
            case .failure(let error):
                print("Error fetching news data: \(error)")
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            print("Both data fetches are complete")
        }
    }
    // MARK: Set icon and info about weather today
    
    private func bindWeatherModel() {
        weatherModel.updateWeatherViewState = {[weak self] weatherData in
            DispatchQueue.main.async {
                self?.cityNameLabel.text = weatherData.cityName
                self?.weatherImage.image = UIImage(systemName: weatherData.weatherIcon)
                self?.temperatureLabel.text = weatherData.temperatureLabel
            }
        }
    }
    
    // MARK: Set Background Image
    
    private func setBackgroundImage() {
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    // MARK: Deinit
    
    deinit {
        weatherModel.resetData()
        weatherModel.resetData()
        newsTableViewModel.resetData()
        print("WeatherAndNewsViewController was deinitialized")
    }
}

// MARK: UITableViewDelegate and UITableViewDataSource

extension WeatherAndNewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == weatherTableView {
            return weatherModel.weatherDays.count
        } else {
            return min(newsTableViewModel.articles.count, 10)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case weatherTableView:
            return configureWeatherCell(for: indexPath)
            
        case newsTableView:
            return configureNewsCell(for: indexPath)
            
        default:
            fatalError("Unexpected table view")
        }
    }
    
    private func configureWeatherCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = weatherTableView.dequeueReusableCell(
            withIdentifier: WeatherCell.identifier,
            for: indexPath) as? WeatherCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = false
        
        if let iconName = weatherModel.iconForDay(for: indexPath.row) {
            cell.weatherIcon.image = UIImage(systemName: iconName)
        }
        
        let dayWeather = weatherModel.weatherDays[indexPath.row]
        cell.configureCell(with: dayWeather)
        
        return cell
    }
    
    private func configureNewsCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = newsTableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let newsData = newsTableViewModel.articles[indexPath.row]
        cell.configureCell(with: newsData)
        return cell
    }
    
    // MARK: NewsTableView cell allows to move to the news URL
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == newsTableView else {return }
        let articles = newsTableViewModel.articles[indexPath.row]
        if let url = URL(string: articles.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: Height of row for all UITableViews
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    
    // MARK: - Registering rows and setting delegates for UITableViews
    private func setupTableViews() {
            registerAndSetupTableView(weatherTableView, cellClass: WeatherCell.self)
            registerAndSetupTableView(newsTableView, cellClass: NewsCell.self)
        }
        
    private func registerAndSetupTableView <T: UITableViewCell & IdentifiableCell> (_ tableView: UITableView, cellClass: T.Type) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass, forCellReuseIdentifier: T.identifier)
    }
}

protocol IdentifiableCell {
    static var identifier: String { get }
}

