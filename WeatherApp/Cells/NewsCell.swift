import UIKit

final class NewsCell: UITableViewCell, IdentifiableCell {

    static let identifier = "NewsCell"
    
    // MARK: UI elements
    let newsLabel: UILabel = {
          let label = UILabel()
          label.numberOfLines = 0
          label.backgroundColor = .clear
          label.font = UIFont(name: "Roboto-Bold", size: 16)
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
        contentView.addSubview(newsLabel)
        newsLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            newsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newsLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            newsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    public func configureCell(with newsData: Article) {
        self.newsLabel.text = newsData.title
    }

    // MARK: Cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        newsLabel.text = nil
    }
}
