import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    private enum Layout {
        static let trackersTitle = "Трекеры"
        static let statisticsTitle = "Статистика"
    }
    
    private enum Constants {
        static let trackersTitle = "Трекеры"
    }
    
    // MARK: - Public Static Properties
    static let identifier = "TrackerCollectionViewCell"
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var quantityManagementView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium12
        label.textColor = UIColor(resource: .ypWhite)
        
        // TODO: - delete
        label.text = "Test"
        
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium16
        
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium12
        label.textColor = UIColor(resource: .black)
        
        // TODO: - delete
        label.text = "Test"
        
        return label
    }()
    
    private lazy var quantityManagementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.setImage(UIImage(resource: .done), for: .selected)
        
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupSubViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        contentView.backgroundColor = UIColor.clear
    }
    
    private func setupSubViews() {
        [cardView, quantityManagementView, trackerLabel, emojiLabel, counterLabel, quantityManagementButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [cardView, quantityManagementView].forEach {
            contentView.addSubview($0)
        }
        [trackerLabel, emojiLabel].forEach {
            cardView.addSubview($0)
        }
        [counterLabel, quantityManagementButton].forEach {
            quantityManagementView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalTo: emojiLabel.widthAnchor),
            
            trackerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            quantityManagementView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityManagementView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            quantityManagementView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            quantityManagementView.heightAnchor.constraint(equalToConstant: 58),
            
            counterLabel.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: quantityManagementView.leadingAnchor, constant: 12),
            
            
            quantityManagementButton.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 8),
            quantityManagementButton.trailingAnchor.constraint(equalTo: quantityManagementView.trailingAnchor, constant: -12),
            quantityManagementButton.widthAnchor.constraint(equalToConstant: 34),
            quantityManagementButton.heightAnchor.constraint(equalTo: quantityManagementButton.widthAnchor)
        ])
    }
    
    // MARK: - Public Properties
    
    // MARK: - Public Methods
    
    // MARK: - IB Actions

}

// MARK: - Preview
extension TrackerCollectionViewCell {
    func configure(title: String, emoji: String, counter: Int) {
        trackerLabel.text = title
        emojiLabel.text = emoji
        counterLabel.text = "\(counter)"
    }
    func configure(title: String, emoji: String, counter: Int, ifGenerateColor: Bool) {
        trackerLabel.text = title
        emojiLabel.text = emoji
        counterLabel.text = "\(counter)"
        let randomColor: UIColor = .random()
        cardView.backgroundColor = randomColor
        quantityManagementButton.tintColor = randomColor
    }
}

//#Preview("Card") {
//    let screenWidth = UIScreen.main.bounds.width
//    let containerHeight: CGFloat = 500
//    
//    let container = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: containerHeight))
//    container.backgroundColor = .systemGray2
//    
//    let cellHeight: CGFloat = 160
//    let cell = TrackerCollectionViewCell(frame: CGRect(x: 0, y: 0, width: screenWidth/2, height: cellHeight))
//    
//    cell.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
//    
//    cell.configure(title: "Tracker 1", emoji: "📈", counter: 123)
//    
//    container.addSubview(cell)
//    return container
//}
