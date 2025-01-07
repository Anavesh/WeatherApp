import UIKit

final class WeatherCell: UITableViewCell, IdentifiableCell {
    
    // MARK: Variables
    
    static let identifier = "WeatherCell"
    
    // MARK: UI Elements
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Monday"
        label.textAlignment = .left
        label.font = UIFont(name: "Roboto-Regular", size: 20)
        label.textColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let weatherIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "questionmark")
        icon.tintColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
        return icon
    }()
    
    let maxTempLabel: UILabel = {
        let label = UILabel()
        label.text = "25°"
        label.font = UIFont(name: "Roboto-Bold", size: 20)
        label.textColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
        return label
    }()
    
    let minTempLabel: UILabel = {
        let label = UILabel()
        label.text = "16°"
        label.font = UIFont(name: "Roboto-Bold", size: 20)
        label.textColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup of view and constraints
    
    private func setView() {
        [dayLabel,weatherIcon, maxTempLabel, minTempLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false; 
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.heightAnchor.constraint(equalToConstant: 40),

            
            weatherIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weatherIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherIcon.heightAnchor.constraint(equalToConstant: 40),
            weatherIcon.widthAnchor.constraint(equalToConstant: 40),

            
            maxTempLabel.trailingAnchor.constraint(equalTo: minTempLabel.trailingAnchor, constant: -64),
            maxTempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            maxTempLabel.heightAnchor.constraint(equalToConstant: 40),
            
            minTempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            minTempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            minTempLabel.heightAnchor.constraint(equalToConstant: 40)
                 
       ])
    }
    
    func configureCell (with weather: DayWeather) {
        dayLabel.text = dayOfWeek(weather.datetime)
        minTempLabel.text = "\(Int(weather.tempmin))°C"
        maxTempLabel.text = "\(Int(weather.tempmax))°C"
    }
    
    // MARK: Date Formatter
    
    private func dayOfWeek(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_EN")
        inputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: dateString) else { return nil }
        let today = Date()
        
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_EN")
        outputFormatter.dateFormat = "EEEE"
        return outputFormatter.string(from: date).capitalized
    }
    
    // MARK: Cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        minTempLabel.text = nil
        maxTempLabel.text = nil
        weatherIcon.image = nil
    }
}
