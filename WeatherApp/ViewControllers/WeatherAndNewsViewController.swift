import UIKit

class WeatherAndNewsViewController: UIViewController {
    
    //MARK: Variables
    
    private var weatherModel: WeatherViewModel?
    private let weatherTableViewModel = WeatherTableViewModel()
    private let newsTableViewModel = NewsTableViewModel()

    
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
        let background = UIImageView(frame:UIScreen.main.bounds)
        background.image = UIImage(named: "Mountains.Sunset")
        background.contentMode = .scaleAspectFill
        return background
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setConstraints()
        initializeWeatherModel()
        setWeatherTableView()
        setNewsTableView()
        bindWeatherModel()
        fetchNewsData()
        fetchWeatherData()
    }
    
    private func setView() {
        [cityNameLabel, weatherImage, temperatureLabel, newsTableView, weatherTableView].forEach {$0.translatesAutoresizingMaskIntoConstraints = false; view.addSubview($0)}
        setBackgroundImage()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            cityNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cityNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherImage.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 20),
            weatherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImage.widthAnchor.constraint(equalToConstant: 100),
            weatherImage.heightAnchor.constraint(equalToConstant: 100),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 20),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            newsTableView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20),
            newsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weatherTableView.topAnchor.constraint(equalTo: newsTableView.bottomAnchor, constant: 60),
            weatherTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func bindWeatherModel() {
        weatherModel?.updateView = {[weak self] in
            self?.cityNameLabel.text = self?.weatherModel?.cityName
            self?.temperatureLabel.text = self?.weatherModel?.temperatureLabel
            guard let iconImage = self?.weatherModel?.weatherIcon else {return}
            self?.weatherImage.image = UIImage(systemName: iconImage)
        }
    }
    
    private func initializeWeatherModel() {
        weatherModel = WeatherViewModel()
        weatherModel?.fetchWeather()
    }
    
    private func fetchWeatherData() {
        weatherTableViewModel.fetchWeatherData { [weak self] result in
             switch result {
             case .success:
                 DispatchQueue.main.async {
                     self?.weatherTableView.reloadData()
                 }
             case .failure(let error):
                 print("Error fetching weather data: \(error)")
             }
         }
     }
    
    private func fetchNewsData() {
        newsTableViewModel.fetchNewsData {[weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching news data: \(error)")
            }
        }
    }
   
    // MARK: Formatting string with date to days of the week

    func dayOfWeek(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_EN") // Устанавливаем локаль
        inputFormatter.dateFormat = "yyyy-MM-dd" // Формат входящей даты (замените на нужный)

        // Преобразуем строку в объект Date
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        let today = Date()
        
        // Проверяем является ли эта дата сегодняшней, если да то обозначаем вместо дня недели Today
           let calendar = Calendar.current
           if calendar.isDate(date, inSameDayAs: today) {
               return "Today"
           }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_EN")
        outputFormatter.dateFormat = "EEEE" // Формат для дня недели

        let dayOfWeek = outputFormatter.string(from: date)
        return dayOfWeek.capitalized // Возвращаем день недели с заглавной буквы
    }
    
    func setBackgroundImage() {
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
    }
}

extension WeatherAndNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == weatherTableView {
            return weatherTableViewModel.weatherDays.count
        } else {
            return newsTableViewModel.articles.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == weatherTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.identifier, for: indexPath) as? WeatherCell else { fatalError("Unable to dequeue WeatherCell in MainViewController")}
            cell.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            if let iconName = weatherTableViewModel.iconForDay(for: indexPath.row) {
                let iconImage = UIImage(systemName: iconName)
                cell.weatherIcon.image = iconImage
            }
            
            let dayWeather = weatherTableViewModel.weatherDays[indexPath.row]
            cell.dayLabel.text = dayOfWeek(dayWeather.datetime)
            cell.minTempLabel.text = "\(Int(dayWeather.tempmin))°C"
            cell.maxTempLabel.text = "\(Int(dayWeather.tempmax))°C"
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else {
                fatalError("Unable to dequeue NewsCell in MainViewController")
            }
            cell.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            let newsData = newsTableViewModel.articles[indexPath.row]
            cell.configureCell(with: newsData)
            return cell
        }
    }
    
    private func setWeatherTableView() {
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        weatherTableView.register(WeatherCell.self, forCellReuseIdentifier: WeatherCell.identifier)
    }
    
    private func setNewsTableView() {
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
    }
}
