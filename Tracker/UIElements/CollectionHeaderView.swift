import UIKit

final class CollectionHeaderView: UICollectionReusableView {
    
    // MARK: - Constants
    private enum Layout {
        static let leadingTrailingInset: CGFloat = 28
    }
    
    // MARK: - Public Static Properties
    static let identifier = "CollectionHeaderView"
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    lazy var headerLabel: UILabel = {
        let label = Label(style: .collectionHeader)
        
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
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.leadingTrailingInset),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.leadingTrailingInset)
        ])
    }
}
