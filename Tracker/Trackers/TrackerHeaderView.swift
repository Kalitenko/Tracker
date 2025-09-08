import UIKit

final class TrackerCollectionHeaderView: UICollectionReusableView {
    
    // MARK: - Constants
    private enum Layout {
        static let trackersTitle = "Трекеры"
        static let statisticsTitle = "Статистика"
    }
    
    // MARK: - Public Static Properties
    static let identifier = "TrackerCollectionViewCell"
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold19
        label.textColor = UIColor(resource: .black)
        
        return label
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
        backgroundColor = UIColor.clear
    }
    
    private func setupSubViews() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.leadingAnchor.constraint(equalTo: trailingAnchor, constant: -28)
        ])
    }
    
}
