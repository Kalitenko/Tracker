import UIKit

enum EmptyStateViewType {
    case trackers
    case categories
    case filtering
    case statistics
    
    var image: UIImage {
        switch self {
        case .trackers, .categories: UIImage(resource: .trackersAndCategories)
        case .filtering: UIImage(resource: .filtering)
        case .statistics: UIImage(resource: .statistics)
        }
    }
    
    var labelText: String {
        switch self {
        case .trackers: L10n.whatToTrack
        case .categories: L10n.categoryHint
        case .filtering: "Ничего не найдено"
        case .statistics: "Анализировать пока нечего"
        }
    }
}

final class EmptyStateView: UIView {
    
    // MARK: - Constants
    private enum Layout {
        static let spacing: CGFloat = 8
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(resource: .black)
        label.font = UIFont.medium12
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Layout.spacing
        return stack
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func show(type: EmptyStateViewType) {
        imageView.image = type.image
        label.text = type.labelText
        imageView.isHidden = false
        label.isHidden = false
    }
    
    func hide() {
        imageView.isHidden = true
        label.isHidden = true
    }
    
}
