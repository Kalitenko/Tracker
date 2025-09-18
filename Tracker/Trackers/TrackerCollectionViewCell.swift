import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapQuantityManagementButton(id: UInt, at: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    private enum Layout {
        // Texts
        static let trackersTitle = "Трекеры"
        static let statisticsTitle = "Статистика"
        
        // Sizes
        static let cardHeight: CGFloat = 90
        static let quantityViewHeight: CGFloat = 58
        static let emojiSize: CGFloat = 24
        static let quantityButtonSize: CGFloat = 34
        static let cornerRadius: CGFloat = 16
        
        // Insets
        static let cardSideInset: CGFloat = 12
        static let cardBottomInset: CGFloat = 12
        static let quantityTopInset: CGFloat = 16
        static let quantityButtonTopInset: CGFloat = 8
        static let quantitySideInset: CGFloat = 12
    }
    
    // MARK: - Public Static Properties
    static let identifier = "TrackerCollectionViewCell"
    
    // MARK: - UI Elements
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        view.layer.cornerRadius = Layout.cornerRadius
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
        
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium16
        label.textAlignment = .center
        label.backgroundColor = UIColor(resource: .ypWhite).withAlphaComponent(0.3)
        label.layer.cornerRadius = Layout.emojiSize / 2
        label.clipsToBounds = true
        
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium12
        label.textColor = UIColor(resource: .black)
        
        return label
    }()
    
    private lazy var quantityManagementButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.background.backgroundColor = .clear
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.setImage(UIImage(resource: .done), for: .selected)
        button.addTarget(self, action: #selector(quantityManagementButtonTapped), for: .touchUpInside)
        
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
        contentView.backgroundColor = .clear
    }
    
    private func setupSubViews() {
        [cardView, quantityManagementView, trackerLabel, emojiLabel, counterLabel, quantityManagementButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [cardView, quantityManagementView].forEach { contentView.addSubview($0) }
        [trackerLabel, emojiLabel].forEach { cardView.addSubview($0) }
        [counterLabel, quantityManagementButton].forEach { quantityManagementView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: Layout.cardHeight),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.cardSideInset),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.cardSideInset),
            emojiLabel.widthAnchor.constraint(equalToConstant: Layout.emojiSize),
            emojiLabel.heightAnchor.constraint(equalTo: emojiLabel.widthAnchor),
            
            trackerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.cardSideInset),
            trackerLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.cardSideInset),
            trackerLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Layout.cardBottomInset),
            
            quantityManagementView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityManagementView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            quantityManagementView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            quantityManagementView.heightAnchor.constraint(equalToConstant: Layout.quantityViewHeight),
            
            counterLabel.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: Layout.quantityTopInset),
            counterLabel.leadingAnchor.constraint(equalTo: quantityManagementView.leadingAnchor, constant: Layout.quantitySideInset),
            
            quantityManagementButton.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: Layout.quantityButtonTopInset),
            quantityManagementButton.trailingAnchor.constraint(equalTo: quantityManagementView.trailingAnchor, constant: -Layout.quantitySideInset),
            quantityManagementButton.widthAnchor.constraint(equalToConstant: Layout.quantityButtonSize),
            quantityManagementButton.heightAnchor.constraint(equalTo: quantityManagementButton.widthAnchor)
        ])
    }
    
    // MARK: - Public Properties
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Private Properties
    private var isCompletedToday: Bool = false
    private var trackerId: UInt?
    private var indexPath: IndexPath?
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, isCompletedToday: Bool, indexPath: IndexPath, completedDays counter: Int, datePickerDate date: Date) {
        trackerLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        quantityManagementButton.tintColor = tracker.color
        counterLabel.text = Utils.dayCountString(for: counter)
        
        self.isCompletedToday = isCompletedToday
        quantityManagementButton.isSelected = isCompletedToday
        self.trackerId = tracker.id
        self.indexPath = indexPath
        
        let today = Calendar.current.startOfDay(for: Date())
        let datePickerDay = Calendar.current.startOfDay(for: date)
        quantityManagementButton.isEnabled = datePickerDay <= today
    }
    
    // MARK: - IB Actions
    @objc private func quantityManagementButtonTapped() {
        guard let trackerId, let indexPath else {
            assertionFailure("Missing trackerId or indexPath")
            Logger.error("Нет trackerId или indexPath")
            return
        }
        Logger.info("Кнопка трекера нажата")
        delegate?.didTapQuantityManagementButton(id: trackerId, at: indexPath)
    }
}

// MARK: - Preview
#if DEBUG
extension TrackerCollectionViewCell {
    func configure(title: String, emoji: String, counter: Int) {
        trackerLabel.text = title
        emojiLabel.text = emoji
        counterLabel.text = Utils.dayCountString(for: counter)
    }
}
#endif
#Preview("Card") {
    let screenWidth = UIScreen.main.bounds.width
    let containerHeight: CGFloat = 500
    
    let container = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: containerHeight))
    container.backgroundColor = .systemGray2
    
    let cellHeight: CGFloat = 160
    let cell = TrackerCollectionViewCell(frame: CGRect(x: 0, y: 0, width: screenWidth/2, height: cellHeight))
    
    cell.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
    
    cell.configure(title: "Tracker 1", emoji: "📈", counter: 123)
    
    container.addSubview(cell)
    return container
}
