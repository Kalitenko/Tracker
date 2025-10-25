import UIKit

final class EmptyStateView: UIView {
    
    // MARK: - Constants
    private enum Layout {
        static let spacing: CGFloat = 8
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .emptyState))
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
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
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
    func show() {
        imageView.isHidden = false
        label.isHidden = false
    }
    
    func hide() {
        imageView.isHidden = true
        label.isHidden = true
    }
    
}
