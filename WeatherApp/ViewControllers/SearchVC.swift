import UIKit

class SearchVC: UIViewController, UISearchBarDelegate {
    
    // MARK: Variables and constants
    let horizontalPadding: CGFloat = 20
    let verticalSpacing: CGFloat = 20
    let searchBarHeight: CGFloat = 60
    
    // MARK: UI elements
    private let citySearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter city name"
        searchBar.returnKeyType = .done
        searchBar.searchBarStyle = .minimal 
        searchBar.isTranslucent = false
        return searchBar
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter city name (in English) for weather forecast"
        label.textColor = .white
        label.font = UIFont(name: "Roboto-Bold", size: 16)
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Roboto-Bold", size: 16)
        label.textColor = .orange
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        citySearchBar.delegate = self
        resetTextInputAndErrorLabel()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setConstraints()
        setUpCitySearchBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        citySearchBar.resignFirstResponder()
        citySearchBar.delegate = nil
    }
    
    // MARK: Set view and constraints
    private func setView() {
        [citySearchBar, instructionLabel, errorLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; view.addSubview($0) }
        view.backgroundColor = .systemIndigo
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Constraints for instructionLabel
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: citySearchBar.topAnchor, constant: -verticalSpacing),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            
            // Constraints for citySearchBar
            citySearchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            citySearchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            citySearchBar.heightAnchor.constraint(equalToConstant: searchBarHeight),
            citySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding * 2),
            citySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding * 2),
            
            // Constraints for errorDescriptionLabel
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: citySearchBar.bottomAnchor, constant: verticalSpacing),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    // MARK: Search bar visual configurations
    
    func setUpCitySearchBar() {
        citySearchBar.delegate = self
        
        // Setup textfield
        if let textField = citySearchBar.value(forKey:"searchField") as? UITextField {
            textField.layer.cornerRadius = 10
            textField.backgroundColor = .white
            textField.layer.masksToBounds = true

            // Remove background white square around search bar
            let backgroundView = UIView(frame: textField.bounds)
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 10
            backgroundView.layer.masksToBounds = true
            textField.addSubview(backgroundView)
            textField.sendSubviewToBack(backgroundView)
            textField.borderStyle = .none
        }
    }
    // MARK: Search bar action configurations
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cityName = searchBar.text, !cityName.isEmpty else {
            print("Error. City name is empty")
            return
        }
        checkCityExistence(city: cityName) { [weak self] result in
            switch result {
            case .success(let exists):
                if exists {
                    print("The city is found.")
                    ServiceURLs.city = cityName
                    DispatchQueue.main.async {
                        let viewController = WeatherAndNewsVC()
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorLabel.text = "City is not found. Please try again."
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorLabel.text = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: Function to check city existence
    func checkCityExistence(city: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = ServiceURLs.weatherURL(for: city)
        
        APIService.shared.fetchData(with: urlString, resultType: WeatherData.self) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                if let nsError = error as NSError?, nsError.domain == "HTTP error" && nsError.code == 1 {
                    completion(.success(false))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: Delete all text in UI elements
    
    private func resetTextInputAndErrorLabel() {
        citySearchBar.text = ""
        errorLabel.text = ""
    }
}
